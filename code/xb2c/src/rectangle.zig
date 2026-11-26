//! One certified rectangle job. Counts are empirical; the C certificate says nothing
//! about turns of the determinant between samples.
const std = @import("std");
const xb = @import("xb");
const Complex = std.math.Complex(f64);

pub const Options = struct {
    /// Max intervals per side, starting at one and doubling. At least four are
    /// needed for three agreeing meshes.
    max_segments: usize = 64,
    /// Do not assign a root this close to a side to the interior (GeV).
    edge_clearance: f64 = 1e-10,
    residual_bound: f64 = 1e-6,
};

pub const Job = struct {
    bounds: xb.xb_rect,
    sheet: xb.xb_sheet,
    path: xb.enum_xb_path = xb.XB_PATH_S40,
    options: Options = .{},
    /// Roots located on an enclosing rectangle. A count of one is refined from each one inside
    /// this rectangle before its centre.
    seeds: []const xb.xb_cplx = &.{},
};

pub const Sample = struct {
    energy: xb.xb_cplx,
    log_det: xb.xb_cplx,
};

pub const Boundary = struct {
    /// Sample on the suspect part of the contour.
    near: xb.xb_cplx,
    /// A located root too close to this boundary; null if the solve failed.
    candidate: ?xb.xb_root,
};

pub const Report = struct {
    certificate: xb.xb_cert,
    /// Empirical count of the final mesh; null for excluded or unresolved boxes.
    zero_count: ?usize = null,
    /// The refined zero when the count is one; null if that refinement did not converge.
    pole: ?xb.xb_root = null,
    /// The warning that left the count unresolved, if any.
    boundary: ?Boundary = null,
    /// The first root a boundary solve located inside the box, kept whatever the count.
    interior: ?xb.xb_root = null,
};

/// Reuses the caller's plan and sample buffer. On return, samples holds the last complete
/// counterclockwise mesh, without a repeated corner; it is empty if the box is excluded or
/// a determinant is unavailable. No point outside `bounds` is evaluated, and the job never
/// moves its own boundary.
pub fn run(model: *const xb.xb_model, ws: *xb.xb_ws, plan: *xb.xb_plan, job: Job, allocator: std.mem.Allocator, samples: *std.ArrayList(Sample)) !Report {
    samples.clearRetainingCapacity();
    const r = job.bounds;
    const opts = job.options;
    if (opts.max_segments == 0 or opts.max_segments > std.math.maxInt(isize) / 4 or
        !std.math.isFinite(opts.residual_bound) or opts.residual_bound <= 0 or
        !std.math.isFinite(opts.edge_clearance) or opts.edge_clearance < 0 or
        !std.math.isFinite(r.re_hi - r.re_lo) or !std.math.isFinite(r.im_hi - r.im_lo)) return error.InvalidArgument;
    var report: Report = .{ .certificate = undefined };
    try check(xb.xb_certify(model, r, job.sheet, job.path, plan, &report.certificate));
    if (report.certificate.failed != 0) return report;

    const solve: Solver = .{ .model = model, .ws = ws, .plan = plan };
    scan(solve, r, opts, job.seeds, allocator, samples, &report) catch |err| switch (err) {
        error.EvaluationUnavailable => samples.clearRetainingCapacity(),
        else => return err,
    };
    return report;
}

pub fn check(status: xb.xb_status) !void {
    switch (status) {
        xb.XB_OK => {},
        xb.XB_ENOMEM => return error.OutOfMemory,
        xb.XB_EARG => return error.InvalidArgument,
        xb.XB_ENOCERT => return error.NoCertificate,
        xb.XB_EGSL => return error.GslFailure,
        xb.XB_EDOM, xb.XB_EPREC => return error.EvaluationUnavailable,
        else => return error.UnknownStatus,
    }
}

const Solver = struct {
    model: *const xb.xb_model,
    ws: *xb.xb_ws,
    plan: *const xb.xb_plan,

    fn sample(self: Solver, energy: xb.xb_cplx) !Sample {
        var ld: xb.xb_cplx = undefined;
        try check(xb.xb_det(self.model, self.ws, self.plan, energy, &ld, 0, null));
        if ((!std.math.isFinite(ld.re) and ld.re != -std.math.inf(f64)) or !std.math.isFinite(ld.im)) return error.EvaluationUnavailable;
        return .{ .energy = energy, .log_det = ld };
    }

    fn refine(self: Solver, seed: xb.xb_cplx, bound: f64) !?xb.xb_root {
        var root: xb.xb_root = undefined;
        check(xb.xb_refine(self.model, self.ws, self.plan, seed, bound, &root)) catch |err| switch (err) {
            error.EvaluationUnavailable => return null,
            else => return err,
        };
        return if (root.converged != 0) root else null;
    }
};

fn midpoint(a: xb.xb_cplx, b: xb.xb_cplx) xb.xb_cplx {
    return .{ .re = a.re + 0.5 * (b.re - a.re), .im = a.im + 0.5 * (b.im - a.im) };
}

fn distance(a: xb.xb_cplx, b: xb.xb_cplx) f64 {
    return @max(@abs(a.re - b.re), @abs(a.im - b.im));
}

fn edgeDistance(r: xb.xb_rect, e: xb.xb_cplx) f64 {
    return @min(e.re - r.re_lo, r.re_hi - e.re, e.im - r.im_lo, r.im_hi - e.im);
}

fn refineMesh(solve: Solver, allocator: std.mem.Allocator, samples: *std.ArrayList(Sample)) !bool {
    const n = samples.items.len;
    try samples.resize(allocator, 2 * n);
    // Even entries are the old mesh; only odd entries require a new determinant.
    var i = n;
    while (i > 0) {
        i -= 1;
        samples.items[2 * i] = samples.items[i];
    }
    for (0..n) |k| {
        const a = samples.items[2 * k].energy;
        const b = samples.items[2 * ((k + 1) % n)].energy;
        const mid = midpoint(a, b);
        if (distance(a, mid) == 0 or distance(b, mid) == 0) {
            // Roundoff prevents a distinct finer mesh. Keep the last complete mesh.
            for (0..n) |j| samples.items[j] = samples.items[2 * j];
            samples.items.len = n;
            return false;
        }
        samples.items[2 * k + 1] = try solve.sample(mid);
    }
    return true;
}

// Delves–Lyness (1967), Eq. (5.17), with principal phases in (-pi, pi].
fn crossing(d: f64) isize {
    if (d <= -std.math.pi) return 1;
    if (d > std.math.pi) return -1;
    return 0;
}

fn smaller(a: Sample, b: Sample) Sample {
    return if (a.log_det.re <= b.log_det.re) a else b;
}

fn scaledValue(s: Sample, scale: f64) Complex {
    const amp = @exp(s.log_det.re - scale);
    return .{ .re = amp * @cos(s.log_det.im), .im = amp * @sin(s.log_det.im) };
}

fn inset(x: f64, lo: f64, hi: f64, clearance: f64) f64 {
    // Keep a forward finite difference at the seed inside the C plan as well.
    const pad = @min(0.25 * (hi - lo), @max(clearance, 2 * @sqrt(std.math.floatEps(f64)) * @abs(x)));
    return @min(hi - pad, @max(lo + pad, x));
}

fn investigate(solve: Solver, r: xb.xb_rect, opts: Options, a: Sample, b: Sample) !Boundary {
    const anchor = smaller(a, b);
    const span = distance(a.energy, b.energy);
    const scale = @max(a.log_det.re, b.log_det.re);
    const fa = scaledValue(a, scale);
    const fb = scaledValue(b, scale);
    const d = fb.sub(fa);
    var z = anchor.energy;
    if (d.re != 0 or d.im != 0) {
        // First complex secant step using samples we already have; then use the C hybrid
        // solver. Limit the seed and the returned root to the vicinity of this segment.
        const step = Complex.init(b.energy.re - a.energy.re, b.energy.im - a.energy.im).mul(fa.div(d));
        const guess = xb.xb_cplx{ .re = a.energy.re - step.re, .im = a.energy.im - step.im };
        if (std.math.isFinite(guess.re) and std.math.isFinite(guess.im) and distance(guess, z) <= span) z = guess;
    }
    const seed: xb.xb_cplx = .{
        .re = inset(z.re, r.re_lo, r.re_hi, opts.edge_clearance),
        .im = inset(z.im, r.im_lo, r.im_hi, opts.edge_clearance),
    };
    const root = try solve.refine(seed, opts.residual_bound);
    return .{
        .near = anchor.energy,
        .candidate = if (root) |p| if (distance(p.energy, anchor.energy) <= span) p else null else null,
    };
}

/// A count of one: refine from each seed inside the box, kept off its sides like a boundary
/// seed, then from its centre.
fn refineOne(solve: Solver, r: xb.xb_rect, opts: Options, seeds: []const xb.xb_cplx) !?xb.xb_root {
    for (seeds) |s| {
        if (!(s.re >= r.re_lo and s.re <= r.re_hi and s.im >= r.im_lo and s.im <= r.im_hi)) continue;
        const seed: xb.xb_cplx = .{
            .re = inset(s.re, r.re_lo, r.re_hi, opts.edge_clearance),
            .im = inset(s.im, r.im_lo, r.im_hi, opts.edge_clearance),
        };
        if (try solve.refine(seed, opts.residual_bound)) |root| return root;
    }
    return solve.refine(midpoint(.{ .re = r.re_lo, .im = r.im_lo }, .{ .re = r.re_hi, .im = r.im_hi }), opts.residual_bound);
}

fn scan(solve: Solver, r: xb.xb_rect, opts: Options, seeds: []const xb.xb_cplx, allocator: std.mem.Allocator, samples: *std.ArrayList(Sample), report: *Report) !void {
    const corners: [4]xb.xb_cplx = .{
        .{ .re = r.re_lo, .im = r.im_lo },
        .{ .re = r.re_hi, .im = r.im_lo },
        .{ .re = r.re_hi, .im = r.im_hi },
        .{ .re = r.re_lo, .im = r.im_hi },
    };
    try samples.resize(allocator, corners.len);
    for (corners, samples.items) |e, *s| s.* = try solve.sample(e);

    var prior: ?isize = null;
    var agreeing: usize = 0;
    var interior: ?xb.xb_root = null;
    defer report.interior = interior;
    var count_floor: isize = 0;
    while (true) {
        const s = samples.items;
        for (s) |p| if (p.log_det.re == -std.math.inf(f64)) {
            report.boundary = .{
                .near = p.energy,
                .candidate = .{ .energy = p.energy, .residual = 0, .iterations = 0, .converged = 1 },
            };
            return;
        };

        var winding: isize = 0;
        for (s, 0..) |mid, i| {
            const a = s[if (i == 0) s.len - 1 else i - 1];
            const b = s[(i + 1) % s.len];
            const delta = b.log_det.im - mid.log_det.im;
            winding += crossing(delta);
            // A new midpoint that changes its old segment's winding locates the source
            // of a change. Check local changes even if they cancel in the total count.
            const changed = prior != null and i % 2 == 1 and
                crossing(mid.log_det.im - a.log_det.im) + crossing(delta) != crossing(b.log_det.im - a.log_det.im);
            // An eightfold dip against both neighbours is a warning, not a theorem.
            const dip = @min(a.log_det.re, b.log_det.re) - mid.log_det.re >= @log(8.0);
            const antipodal = @abs(@abs(delta) - std.math.pi) <= 8 * std.math.floatEps(f64);
            const warning = if (changed or dip) blk: {
                const peer = smaller(a, b);
                // A root already located within this segment explains the warning; each
                // solve costs many determinants.
                if (interior) |p| {
                    if (distance(p.energy, mid.energy) <= distance(mid.energy, peer.energy)) continue;
                }
                break :blk try investigate(solve, r, opts, mid, peer);
            } else if (antipodal) try investigate(solve, r, opts, mid, b) else continue;
            const root = warning.candidate orelse {
                report.boundary = warning;
                return;
            };
            if (edgeDistance(r, root.energy) <= opts.edge_clearance) {
                report.boundary = warning;
                return;
            }
            if (interior) |p| {
                if (distance(p.energy, root.energy) > opts.edge_clearance) count_floor = 2;
            } else {
                interior = root;
                count_floor = 1;
            }
        }

        agreeing = if (prior != null and prior.? == winding) agreeing + 1 else 1;
        if (agreeing >= 3 and winding >= count_floor) {
            report.zero_count = @intCast(winding);
            if (winding != 1) return;
            const root = interior orelse (try refineOne(solve, r, opts, seeds) orelse return);
            if (edgeDistance(r, root.energy) <= opts.edge_clearance) {
                report.zero_count = null;
                report.boundary = .{ .near = root.energy, .candidate = root };
                return;
            }
            report.pole = root;
            return;
        }

        if (s.len / 4 > opts.max_segments / 2 or !try refineMesh(solve, allocator, samples)) return;
        prior = winding;
    }
}
