//! The subdivision driver of the pole search (code/xb2c/SPEC.md, "Zig driver"). N persistent
//! workers, each with a workspace and a plan buffer created and destroyed on its own thread,
//! take rectangles and real-axis energies from a shared queue. A rectangle that is excluded,
//! counts two or more zeros, or stays unresolved is split off-centre, down to the minimum size,
//! and its children go back on the queue. Every rectangle becomes one JSON line keyed by an id
//! that encodes its subdivision path, so a record's content does not depend on scheduling or
//! worker count. The output is JSON lines of four kinds: "run" (inputs, first), "rectangle",
//! "scan", and "summary" (last).
const std = @import("std");
const xb = @import("xb");
const rectangle = @import("rectangle");
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub const Path = enum { s40, margin };

/// A root rectangle: a sheet label ordered (BB, BB*, B*B*), a path family, and bounds in GeV
/// from M_th.
pub const Region = struct {
    sheet: [3]i8,
    path: Path = .s40,
    re: [2]f64,
    im: [2]f64,
};

pub const Options = struct {
    /// A rectangle whose longer side is at most this (GeV) is not split.
    min_size: f64 = 1e-4,
    /// Write each counted rectangle's final boundary mesh with its record.
    samples: bool = false,
    job: rectangle.Options = .{},
};

/// Per-energy jobs on a line of constant Im E, without rectangle state.
pub const Scan = struct {
    re: [2]f64,
    points: u32,
    im: f64 = 0,
    /// Signs ordered (BB, BB*, B*B*); null flips every threshold below Re E, the physical
    /// sheet's upper half plane continued to the real axis: T(E + i0).
    sheet: ?[3]i8 = null,
    /// Half-width (GeV) of the box certified at each energy, which lies on its top edge.
    box: f64 = 1e-6,
};

pub const Spec = struct {
    domain: []const Region = &.{},
    scan: ?Scan = null,
    options: Options = .{},
    /// Persistent workers, at least one.
    workers: usize = 1,
};

pub const Status = enum {
    /// Excluded, counted at two or more, or unresolved, and split into two children.
    split,
    /// Counted, then discarded: the split line between it and its sibling moved away from a
    /// zero found on or next to it, and both children were recounted.
    superseded,
    /// Excluded by the certificate at the minimum size, and never counted.
    excluded,
    /// Empirical count zero.
    empty,
    /// Count one, refined to a zero inside the rectangle.
    pole,
    /// Count one; the refinement did not converge inside the rectangle.
    unconverged,
    /// Count two or more at the minimum size.
    multiple,
    /// No accepted count at the minimum size.
    unresolved,
};

/// A zero located by xb_refine: E in GeV from M_th, the residual |D~|, the iterations.
pub const Root = struct { E: [2]f64, residual: f64, iterations: i32 };

/// A refined pole: E = M - i Gamma/2 from M_th, with the mass M and the width Gamma (GeV).
pub const Pole = struct { E: [2]f64, M: f64, Gamma: f64, residual: f64, iterations: i32 };

/// Which side of the rectangle a located boundary root lies next to: the split line shared
/// with its sibling, another internal line, or the outer edge of its domain region.
pub const Edge = enum { split, internal, outer };

/// The boundary sample that left the count unresolved, the root located near it, if any, and
/// the side next to that root.
pub const Boundary = struct { near: [2]f64, candidate: ?Root, edge: ?Edge };

/// xb_cert in JSON: null where the C record holds a non-finite number (a vacuous condition,
/// +inf, or one not evaluated after the first failure, NaN).
pub const Certificate = struct {
    failed: i32,
    margin: [5]?f64,
    slope: ?f64,
    depth: ?f64,
    node: [3]i8,
    dropped: [3]i8,
    n_path: i32,
};

/// One JSON line per rectangle. Bounds are (re_lo, re_hi, im_lo, im_hi) in GeV from M_th.
pub const Record = struct {
    kind: []const u8 = "rectangle",
    id: []const u8,
    sheet: []const u8,
    path: Path,
    bounds: [4]f64,
    certificate: Certificate,
    status: Status,
    /// The accepted empirical count; null when excluded or unresolved.
    count: ?u32,
    /// The refined zero; only with status pole.
    pole: ?Pole,
    boundary: ?Boundary,
    /// The final boundary mesh, counterclockwise without a repeated corner, as
    /// (Re E, Im E, log|D~|, arg D~), when sampling is on.
    samples: []const [4]?f64 = &.{},
};

/// One JSON line per scan energy.
pub const ScanRecord = struct {
    kind: []const u8 = "scan",
    index: u32,
    E: [2]f64,
    sheet: []const u8,
    certificate: Certificate,
    /// (log|D~|, arg D~); null where the box is excluded or D~ is unavailable there.
    log_det: ?[2]?f64,
    /// The on-shell T between node channels, row-major with the outgoing channel first, as
    /// (Re, Im); null outside the node channels or without log_det.
    t: []const ?[2]f64,
};

/// A pole, or a root located on an outer domain edge, in the summary.
pub const Found = struct { id: []const u8, sheet: []const u8, E: [2]f64, M: f64, Gamma: f64, residual: f64, iterations: i32 };

/// Where the run's time went (SPEC.md, user story 21), in seconds.
pub const Timing = struct {
    wall: f64 = 0,
    /// Summed over workers.
    jobs: f64 = 0,
    /// Summed over workspaces, from xb_timing; the rest of jobs is certification, refinement
    /// steps and the driver. kernel_double holds the double-precision moments and their
    /// contraction with the spin tables.
    kernel_double: f64 = 0,
    moments_extended: f64 = 0,
    assembly: f64 = 0,
    lu: f64 = 0,
    moment_sets_double: i64 = 0,
    moment_sets_extended: i64 = 0,
    matrices: i64 = 0,
};

/// The last line. Lists are sorted by id.
pub const Summary = struct {
    kind: []const u8 = "summary",
    workers: u32,
    rectangles: u32,
    status: std.enums.EnumFieldStruct(Status, u32, 0),
    poles: []const Found,
    /// Roots within the clearance of an outer domain edge, from final unresolved records; they
    /// are not counted as interior poles.
    outer: []const Found,
    /// Final records whose zeros are not settled: unconverged, multiple, unresolved.
    open: []const []const u8,
    scans: u32,
    timing: Timing,
};

/// The first line: every input of the run, and the model's derived thresholds and bare energies.
const Header = struct {
    kind: []const u8 = "run",
    params: xb.xb_params,
    thresholds: [3]?f64,
    reduced_masses: [3]?f64,
    bare: []const f64,
    reference_masses: []const f64,
    domain: []const Region,
    scan: ?Scan,
    options: Options,
    workers: u32,
};

/// Off-centre split lines, as fractions of the longer side from its lower end: the first is the
/// default, the rest are tried in turn when a line moves.
const split_fractions = [_]f64{ 0.4472135954999579, 0.5527864045000421, 0.3819660112501051, 0.6180339887498949, 0.3, 0.7, 0.25, 0.75, 0.2, 0.8 };
/// A moved line keeps this fraction of the parent's side from every suspect zero and from the
/// lines it replaces: a zero that close to a corner dips |D~| eightfold on the coarsest mesh.
const split_guard = 0.2;
/// Moves of one split line; child digits 2 m and 2 m + 1 stay single characters.
const max_moves = 4;
/// A splittable rectangle longer than this many times its width is certified and split without
/// a count: meshes started at its corners give its long sides segments that span several zeros
/// near the real axis, and three of them can agree on an aliased count. Ordinary splits stay
/// below 1/0.447 = 2.24.
const max_aspect = 2.5;
const max_id = 64;

const Id = struct {
    len: u8 = 0,
    bytes: [max_id]u8 = undefined,

    fn root(region: usize) Id {
        var id: Id = .{};
        id.len = @intCast((std.fmt.bufPrint(&id.bytes, "{d}", .{region}) catch unreachable).len);
        return id;
    }

    /// The parent's id, then '/' before the first subdivision digit.
    fn child(parent: Id, digit: u8) error{IdTooLong}!Id {
        var id = parent;
        const first = std.mem.indexOfScalar(u8, parent.slice(), '/') == null;
        if (@as(usize, id.len) + @intFromBool(first) + 1 > max_id) return error.IdTooLong;
        if (first) {
            id.bytes[id.len] = '/';
            id.len += 1;
        }
        id.bytes[id.len] = '0' + digit;
        id.len += 1;
        return id;
    }

    fn slice(self: *const Id) []const u8 {
        return self.bytes[0..self.len];
    }
};

const Axis = enum { re, im };

fn coordinate(axis: Axis, e: xb.xb_cplx) f64 {
    return switch (axis) {
        .re => e.re,
        .im => e.im,
    };
}

/// Roots located so far inside a rectangle, handed down to its children as refinement seeds.
/// Beyond four, roots are dropped: a count of one then refines from its centre, as without
/// seeds.
const Seeds = struct {
    items: [4]xb.xb_cplx = undefined,
    len: u8 = 0,

    fn add(self: *Seeds, e: xb.xb_cplx) void {
        for (self.slice()) |s| {
            if (s.re == e.re and s.im == e.im) return;
        }
        if (self.len == self.items.len) return;
        self.items[self.len] = e;
        self.len += 1;
    }

    fn slice(self: *const Seeds) []const xb.xb_cplx {
        return self.items[0..self.len];
    }

    fn inside(self: *const Seeds, b: xb.xb_rect) Seeds {
        var out: Seeds = .{};
        for (self.slice()) |e| {
            if (e.re >= b.re_lo and e.re <= b.re_hi and e.im >= b.im_lo and e.im <= b.im_hi) out.add(e);
        }
        return out;
    }
};

const Cell = struct {
    bounds: xb.xb_rect,
    region: u32,
    id: Id,
    /// The split that made this cell, null for a root.
    family: ?*Family = null,
    slot: u1 = 0,
    seeds: Seeds = .{},
};

/// A counted rectangle: its job report and, when sampling, its final mesh, owned until its
/// record is written.
const Outcome = struct {
    report: rectangle.Report,
    samples: []const [4]?f64 = &.{},
};

/// Two children of one split, settled together once both are counted, so that a zero on or
/// next to their shared line moves the line before either is resolved.
const Family = struct {
    parent: Cell,
    axis: Axis,
    at: f64,
    moves: u8 = 0,
    /// Coordinates along the axis the line must keep away from: at most nine per settle (two
    /// candidates, three located roots of each sibling, the line), over at most five settles.
    suspects: [48]f64 = undefined,
    n_suspects: usize = 0,
    remaining: std.atomic.Value(u8) = .init(2),
    children: [2]Cell = undefined,
    outcomes: [2]Outcome = undefined,

    fn range(self: *const Family) [2]f64 {
        const b = self.parent.bounds;
        return switch (self.axis) {
            .re => .{ b.re_lo, b.re_hi },
            .im => .{ b.im_lo, b.im_hi },
        };
    }

    fn suspect(self: *Family, x: f64) void {
        if (self.n_suspects == self.suspects.len) return;
        self.suspects[self.n_suspects] = x;
        self.n_suspects += 1;
    }

    /// The first listed line at least `guard` from every suspect.
    fn nextLine(self: *const Family, guard: f64) ?f64 {
        const lo, const hi = self.range();
        for (split_fractions) |f| {
            const x = lo + f * (hi - lo);
            for (self.suspects[0..self.n_suspects]) |s| {
                if (@abs(x - s) < guard) break;
            } else return x;
        }
        return null;
    }
};

/// The roots a report located: its refined zero, its boundary candidate and its interior root.
fn located(report: rectangle.Report, buffer: *[3]xb.xb_cplx) []const xb.xb_cplx {
    var n: usize = 0;
    for ([_]?xb.xb_root{ report.pole, if (report.boundary) |b| b.candidate else null, report.interior }) |found| {
        const r = found orelse continue;
        buffer[n] = r.energy;
        n += 1;
    }
    return buffer[0..n];
}

fn xbSheet(sheet: [3]i8) xb.xb_sheet {
    return .{ .pp = sheet[0], .pv = sheet[1], .vv = sheet[2] };
}

fn longSide(b: xb.xb_rect) f64 {
    return @max(b.re_hi - b.re_lo, b.im_hi - b.im_lo);
}

/// A queued job: a rectangle, or the index of a scan energy.
const Task = union(enum) { cell: Cell, scan: u32 };

const Worker = struct {
    ws: *xb.xb_ws,
    plan: *xb.xb_plan,
    samples: std.ArrayList(rectangle.Sample) = .empty,
    /// Children that did not fit in the queue; this worker takes them first.
    local: std.ArrayList(Task) = .empty,
};

const Search = struct {
    io: Io,
    gpa: Allocator,
    model: *const xb.xb_model,
    info: xb.xb_info,
    spec: Spec,
    /// M_th: E is measured from it.
    origin: f64,
    plan_size: usize,
    queue: Io.Queue(Task),
    /// Jobs queued or in progress; the last one to finish closes the queue.
    pending: std.atomic.Value(usize) = .init(0),
    failed: std.atomic.Value(bool) = .init(false),
    /// Guards out, err and the summary below.
    mutex: Io.Mutex = .init,
    out: *Io.Writer,
    err: ?anyerror = null,
    rectangles: u32 = 0,
    scans: u32 = 0,
    status: std.enums.EnumFieldStruct(Status, u32, 0) = .{},
    /// Ids owned by the search.
    poles: std.ArrayList(Found) = .empty,
    outer: std.ArrayList(Found) = .empty,
    open: std.ArrayList([]const u8) = .empty,
    timing: Timing = .{},

    fn deinit(self: *Search) void {
        for (self.poles.items) |f| self.gpa.free(f.id);
        for (self.outer.items) |f| self.gpa.free(f.id);
        for (self.open.items) |id| self.gpa.free(id);
        self.poles.deinit(self.gpa);
        self.outer.deinit(self.gpa);
        self.open.deinit(self.gpa);
    }

    fn work(self: *Search) void {
        self.workLoop() catch |err| self.fail(err);
    }

    fn workLoop(self: *Search) !void {
        var ws: ?*xb.xb_ws = null;
        try rectangle.check(xb.xb_ws_create(self.model, &ws));
        defer xb.xb_ws_destroy(ws);
        const plan = try self.gpa.alignedAlloc(u8, .@"16", self.plan_size);
        defer self.gpa.free(plan);
        var w: Worker = .{ .ws = ws.?, .plan = @ptrCast(plan.ptr) };
        defer w.samples.deinit(self.gpa);
        defer w.local.deinit(self.gpa);
        var busy: i96 = 0;
        while (true) {
            const task = w.local.pop() orelse (self.queue.getOne(self.io) catch break);
            if (!self.failed.load(.acquire)) {
                const start = Io.Clock.awake.now(self.io);
                (switch (task) {
                    .cell => |cell| self.execute(&w, cell),
                    .scan => |index| self.scanPoint(&w, index),
                }) catch |err| self.fail(err);
                busy += start.durationTo(Io.Clock.awake.now(self.io)).toNanoseconds();
            }
            if (self.pending.fetchSub(1, .acq_rel) == 1) self.queue.close(self.io);
        }
        var t: xb.xb_timing = undefined;
        try rectangle.check(xb.xb_ws_timing(ws, &t));
        self.mutex.lockUncancelable(self.io);
        defer self.mutex.unlock(self.io);
        self.timing.jobs += seconds(busy);
        self.timing.kernel_double += seconds(t.kernel_double_ns);
        self.timing.moments_extended += seconds(t.moments_extended_ns);
        self.timing.assembly += seconds(t.assembly_ns);
        self.timing.lu += seconds(t.lu_ns);
        self.timing.moment_sets_double += t.moments_double;
        self.timing.moment_sets_extended += t.moments_extended;
        self.timing.matrices += t.matrices;
    }

    fn fail(self: *Search, err: anyerror) void {
        self.mutex.lockUncancelable(self.io);
        defer self.mutex.unlock(self.io);
        if (self.err == null) self.err = err;
        self.failed.store(true, .release);
        self.queue.close(self.io);
    }

    fn execute(self: *Search, w: *Worker, cell: Cell) !void {
        const region = self.spec.domain[cell.region];
        const job: rectangle.Job = .{
            .bounds = cell.bounds,
            .sheet = xbSheet(region.sheet),
            .path = switch (region.path) {
                .s40 => xb.XB_PATH_S40,
                .margin => xb.XB_PATH_MARGIN,
            },
            .options = self.spec.options.job,
            .seeds = cell.seeds.slice(),
        };
        const b = cell.bounds;
        const long = longSide(b);
        const report = if (long > self.spec.options.min_size and long > max_aspect * @min(b.re_hi - b.re_lo, b.im_hi - b.im_lo)) blk: {
            var certified: rectangle.Report = .{ .certificate = undefined };
            try rectangle.check(xb.xb_certify(self.model, b, job.sheet, job.path, w.plan, &certified.certificate));
            w.samples.clearRetainingCapacity();
            break :blk certified;
        } else try rectangle.run(self.model, w.ws, w.plan, job, self.gpa, &w.samples);
        const outcome: Outcome = .{ .report = report, .samples = if (self.spec.options.samples) try self.capture(w.samples.items) else &.{} };
        const fam = cell.family orelse {
            defer self.gpa.free(outcome.samples);
            return self.resolve(w, cell, outcome, null);
        };
        fam.outcomes[cell.slot] = outcome;
        if (fam.remaining.fetchSub(1, .acq_rel) == 1) try self.settle(w, fam);
    }

    fn capture(self: *Search, samples: []const rectangle.Sample) ![]const [4]?f64 {
        const out = try self.gpa.alloc([4]?f64, samples.len);
        for (out, samples) |*o, s| o.* = .{ s.energy.re, s.energy.im, finite(s.log_det.re), finite(s.log_det.im) };
        return out;
    }

    /// Writes the record of a counted rectangle and splits it if needed. The caller owns the
    /// outcome's samples.
    fn resolve(self: *Search, w: *Worker, cell: Cell, outcome: Outcome, fam: ?*const Family) !void {
        const report = outcome.report;
        const b = cell.bounds;
        const splittable = longSide(b) > self.spec.options.min_size;
        const status: Status = if (report.certificate.failed != 0)
            if (splittable) .split else .excluded
        else if (report.zero_count) |n| switch (n) {
            0 => .empty,
            1 => if (report.pole != null) .pole else .unconverged,
            else => if (splittable) .split else .multiple,
        } else if (splittable) .split else .unresolved;
        try self.emit(cell, outcome, status, fam);
        if (status != .split) return;
        // Splits across the longer side.
        const fam_new = try self.gpa.create(Family);
        errdefer self.gpa.destroy(fam_new);
        fam_new.* = .{
            .parent = cell,
            .axis = if (b.re_hi - b.re_lo >= b.im_hi - b.im_lo) .re else .im,
            .at = undefined,
        };
        fam_new.parent.family = null;
        var buffer: [3]xb.xb_cplx = undefined;
        for (located(report, &buffer)) |e| fam_new.parent.seeds.add(e);
        const lo, const hi = fam_new.range();
        fam_new.at = lo + split_fractions[0] * (hi - lo);
        try self.spawn(w, fam_new);
    }

    /// Queues the two children of the family's current line. It fails only before the first
    /// child is queued; from then on other workers own the family.
    fn spawn(self: *Search, w: *Worker, fam: *Family) !void {
        var children: [2]Cell = undefined;
        for (&children, 0..) |*c, slot| {
            c.* = fam.parent;
            c.family = fam;
            c.slot = @intCast(slot);
            c.id = try fam.parent.id.child(@intCast(2 * fam.moves + slot));
        }
        switch (fam.axis) {
            .re => {
                children[0].bounds.re_hi = fam.at;
                children[1].bounds.re_lo = fam.at;
            },
            .im => {
                children[0].bounds.im_hi = fam.at;
                children[1].bounds.im_lo = fam.at;
            },
        }
        for (&children) |*c| c.seeds = fam.parent.seeds.inside(c.bounds);
        try w.local.ensureUnusedCapacity(self.gpa, children.len);
        fam.children = children;
        fam.remaining.store(2, .release);
        const tasks = [2]Task{ .{ .cell = children[0] }, .{ .cell = children[1] } };
        _ = self.pending.fetchAdd(tasks.len, .acq_rel);
        const queued = self.queue.put(self.io, &tasks, 0) catch |err| switch (err) {
            // Only a failed run closes the queue while a rectangle is in progress.
            error.Closed => return,
            // Nothing was queued.
            error.Canceled => return err,
        };
        w.local.appendSliceAssumeCapacity(tasks[queued..]);
    }

    /// Both children are counted. A zero located on their shared line, or a failed boundary
    /// solve on that line or next to a zero the sibling located, moves the line and both are
    /// recounted; otherwise each child is resolved on its own.
    fn settle(self: *Search, w: *Worker, fam: *Family) !void {
        const lo, const hi = fam.range();
        const guard = split_guard * (hi - lo);
        var conflict = false;
        var buffer: [3]xb.xb_cplx = undefined;
        for (fam.outcomes, 0..) |o, slot| {
            const r = o.report;
            if (r.certificate.failed != 0 or r.zero_count != null) continue;
            const warning = r.boundary orelse continue;
            if (warning.candidate) |c| {
                if (self.edgeOf(fam.children[slot], fam, c.energy) != .split) continue;
                fam.suspect(coordinate(fam.axis, c.energy));
                conflict = true;
                continue;
            }
            var explained = coordinate(fam.axis, warning.near) == fam.at;
            var located_buffer: [3]xb.xb_cplx = undefined;
            for (located(fam.outcomes[1 - slot].report, &located_buffer)) |e| {
                if (std.math.hypot(e.re - warning.near.re, e.im - warning.near.im) > guard) continue;
                fam.suspect(coordinate(fam.axis, e));
                explained = true;
            }
            conflict = conflict or explained;
        }
        if (conflict and fam.moves < max_moves) {
            fam.suspect(fam.at);
            if (fam.nextLine(guard)) |line| {
                for (fam.children, fam.outcomes) |c, o| {
                    try self.emit(c, o, .superseded, fam);
                    for (located(o.report, &buffer)) |e| fam.parent.seeds.add(e);
                    self.gpa.free(o.samples);
                }
                fam.at = line;
                fam.moves += 1;
                return self.spawn(w, fam);
            }
        }
        defer self.gpa.destroy(fam);
        defer for (fam.outcomes) |o| self.gpa.free(o.samples);
        for (fam.children, fam.outcomes) |c, o| try self.resolve(w, c, o, fam);
    }

    /// The side of the cell nearest to e.
    fn edgeOf(self: *const Search, cell: Cell, fam: ?*const Family, e: xb.xb_cplx) Edge {
        const b = cell.bounds;
        const r = self.spec.domain[cell.region];
        const gaps = [4]f64{ e.re - b.re_lo, b.re_hi - e.re, e.im - b.im_lo, b.im_hi - e.im };
        const sides = [4]f64{ b.re_lo, b.re_hi, b.im_lo, b.im_hi };
        const outer = [4]f64{ r.re[0], r.re[1], r.im[0], r.im[1] };
        const k = std.mem.indexOfMin(f64, &gaps);
        if (sides[k] == outer[k]) return .outer;
        if (fam) |f| if ((k < 2) == (f.axis == .re) and sides[k] == f.at) return .split;
        return .internal;
    }

    fn emit(self: *Search, cell: Cell, outcome: Outcome, status: Status, fam: ?*const Family) !void {
        const report = outcome.report;
        const region = self.spec.domain[cell.region];
        const b = cell.bounds;
        const record: Record = .{
            .id = cell.id.slice(),
            .sheet = sheetLabel(region.sheet),
            .path = region.path,
            .bounds = .{ b.re_lo, b.re_hi, b.im_lo, b.im_hi },
            .certificate = certificate(report.certificate),
            .status = status,
            .count = if (report.zero_count) |n| @intCast(n) else null,
            .pole = if (status == .pole) self.pole(report.pole.?) else null,
            .boundary = if (report.boundary) |warning| .{
                .near = .{ warning.near.re, warning.near.im },
                .candidate = if (warning.candidate) |r| root(r) else null,
                .edge = if (warning.candidate) |r| self.edgeOf(cell, fam, r.energy) else null,
            } else null,
            .samples = outcome.samples,
        };
        self.mutex.lockUncancelable(self.io);
        defer self.mutex.unlock(self.io);
        try self.writeLine(record);
        self.rectangles += 1;
        switch (status) {
            inline else => |s| @field(self.status, @tagName(s)) += 1,
        }
        switch (status) {
            .pole => try self.keep(&self.poles, record, report.pole.?),
            .unconverged, .multiple, .unresolved => {
                const id = try self.gpa.dupe(u8, record.id);
                self.open.append(self.gpa, id) catch |err| {
                    self.gpa.free(id);
                    return err;
                };
                if (status == .unresolved and record.boundary != null and record.boundary.?.edge == .outer)
                    try self.keep(&self.outer, record, report.boundary.?.candidate.?);
            },
            else => {},
        }
    }

    /// Adds a summary entry; the caller holds the mutex.
    fn keep(self: *Search, list: *std.ArrayList(Found), record: Record, r: xb.xb_root) !void {
        const p = self.pole(r);
        const id = try self.gpa.dupe(u8, record.id);
        list.append(self.gpa, .{ .id = id, .sheet = record.sheet, .E = p.E, .M = p.M, .Gamma = p.Gamma, .residual = p.residual, .iterations = p.iterations }) catch |err| {
            self.gpa.free(id);
            return err;
        };
    }

    /// One JSON line; the caller holds the mutex.
    fn writeLine(self: *Search, value: anytype) !void {
        var jw: std.json.Stringify = .{ .writer = self.out };
        try emitJson(&jw, value);
        try self.out.writeByte('\n');
        try self.out.flush();
    }

    /// D~ and the on-shell T at one energy of the scan, on the top edge of a box certified there.
    fn scanPoint(self: *Search, w: *Worker, index: u32) !void {
        const sc = self.spec.scan.?;
        const step = if (sc.points > 1) (sc.re[1] - sc.re[0]) / @as(f64, @floatFromInt(sc.points - 1)) else 0;
        const x = if (sc.points > 1 and index + 1 == sc.points) sc.re[1] else sc.re[0] + @as(f64, @floatFromInt(index)) * step;
        var sheet: [3]i8 = .{ 1, 1, 1 };
        for (self.info.threshold, &sheet) |d, *s| {
            if (d < x) s.* = -1;
        }
        if (sc.sheet) |given| sheet = given;
        const box: xb.xb_rect = .{ .re_lo = x - sc.box, .re_hi = x + sc.box, .im_lo = sc.im - sc.box, .im_hi = sc.im };
        var cert: xb.xb_cert = undefined;
        try rectangle.check(xb.xb_certify(self.model, box, xbSheet(sheet), xb.XB_PATH_S40, w.plan, &cert));
        // T has n_channels^2 entries, at most six channels (2++).
        const n: usize = @intCast(self.info.n_channels * self.info.n_channels);
        var t: [36]xb.xb_cplx = undefined;
        var ld: xb.xb_cplx = undefined;
        const have = cert.failed == 0 and blk: {
            rectangle.check(xb.xb_det(self.model, w.ws, w.plan, .{ .re = x, .im = sc.im }, &ld, n, &t)) catch |err| switch (err) {
                error.EvaluationUnavailable => break :blk false,
                else => return err,
            };
            break :blk true;
        };
        var entries: [t.len]?[2]f64 = @splat(null);
        if (have) {
            for (t[0..n], entries[0..n]) |v, *o| o.* = if (std.math.isNan(v.re) or std.math.isNan(v.im)) null else .{ v.re, v.im };
        }
        const record: ScanRecord = .{
            .index = index,
            .E = .{ x, sc.im },
            .sheet = sheetLabel(sheet),
            .certificate = certificate(cert),
            .log_det = if (have) .{ finite(ld.re), finite(ld.im) } else null,
            .t = entries[0..n],
        };
        self.mutex.lockUncancelable(self.io);
        defer self.mutex.unlock(self.io);
        try self.writeLine(record);
        self.scans += 1;
    }

    fn pole(self: *const Search, r: xb.xb_root) Pole {
        return .{
            .E = .{ r.energy.re, r.energy.im },
            .M = self.origin + r.energy.re,
            .Gamma = -2 * r.energy.im,
            .residual = r.residual,
            .iterations = r.iterations,
        };
    }
};

fn root(r: xb.xb_root) Root {
    return .{ .E = .{ r.energy.re, r.energy.im }, .residual = r.residual, .iterations = r.iterations };
}

fn finite(x: f64) ?f64 {
    return if (std.math.isFinite(x)) x else null;
}

fn certificate(c: xb.xb_cert) Certificate {
    return .{
        .failed = c.failed,
        .margin = .{ finite(c.margin[0]), finite(c.margin[1]), finite(c.margin[2]), finite(c.margin[3]), finite(c.margin[4]) },
        .slope = finite(c.slope),
        .depth = finite(c.depth),
        .node = c.node,
        .dropped = c.dropped,
        .n_path = c.n_path,
    };
}

fn seconds(ns: anytype) f64 {
    return @as(f64, @floatFromInt(ns)) * 1e-9;
}

const sheet_labels = [8][]const u8{ "(+,+,+)", "(+,+,-)", "(+,-,+)", "(+,-,-)", "(-,+,+)", "(-,+,-)", "(-,-,+)", "(-,-,-)" };

fn sheetLabel(sheet: [3]i8) []const u8 {
    var k: usize = 0;
    for (sheet) |s| k = 2 * k + @intFromBool(s < 0);
    return sheet_labels[k];
}

/// JSON through std.json.Stringify, with floats in shortest round-trip exponent form and every
/// non-finite float written as null.
fn emitJson(jw: *std.json.Stringify, v: anytype) Io.Writer.Error!void {
    const T = @TypeOf(v);
    switch (@typeInfo(T)) {
        .float => if (std.math.isFinite(v)) try jw.print("{e}", .{v}) else try jw.write(null),
        .optional => if (v) |x| try emitJson(jw, x) else try jw.write(null),
        .array => {
            try jw.beginArray();
            for (v) |x| try emitJson(jw, x);
            try jw.endArray();
        },
        .pointer => |p| {
            if (p.size != .slice or p.child == u8) return jw.write(v);
            try jw.beginArray();
            for (v) |x| try emitJson(jw, x);
            try jw.endArray();
        },
        .@"struct" => |s| {
            try jw.beginObject();
            inline for (s.field_names) |name| {
                try jw.objectField(name);
                try emitJson(jw, @field(v, name));
            }
            try jw.endObject();
        },
        else => try jw.write(v),
    }
}

/// Creates the model from params, then searches the domain and runs the scan of spec with
/// spec.workers threads. Writes the run line, one line per rectangle and scan energy, and the
/// summary to out.
pub fn run(io: Io, gpa: Allocator, params: xb.xb_params, spec: Spec, out: *Io.Writer) !void {
    const start = Io.Clock.awake.now(io);
    if (spec.workers == 0 or spec.workers > std.math.maxInt(u32) or spec.domain.len > std.math.maxInt(u32) or
        !(spec.options.min_size > 0)) return error.InvalidArgument;
    for (spec.domain) |r| {
        if (!(r.re[0] < r.re[1] and r.im[0] < r.im[1]) or !std.math.isFinite(r.re[1] - r.re[0]) or
            !std.math.isFinite(r.im[1] - r.im[0])) return error.InvalidArgument;
    }
    const points: u32 = if (spec.scan) |sc| blk: {
        if (!(sc.re[0] <= sc.re[1]) or !std.math.isFinite(sc.re[1] - sc.re[0]) or !std.math.isFinite(sc.im) or
            !(sc.box > 0)) return error.InvalidArgument;
        break :blk sc.points;
    } else 0;
    var model: ?*xb.xb_model = null;
    try rectangle.check(xb.xb_model_create(&params, &model));
    defer xb.xb_model_destroy(model);
    var plan_size: usize = 0;
    try rectangle.check(xb.xb_plan_size(model, &plan_size));
    var info: xb.xb_info = undefined;
    try rectangle.check(xb.xb_model_info(model, &info));

    var bare: [xb.XB_MAX_BARE]f64 = undefined;
    var reference: [xb.XB_MAX_BARE]f64 = undefined;
    const n_bare: usize = @intCast(info.n_bare);
    for (info.bare[0..n_bare], bare[0..n_bare], reference[0..n_bare]) |b, *e, *m| {
        e.* = b.energy;
        m.* = b.reference_mass;
    }
    var jw: std.json.Stringify = .{ .writer = out };
    try emitJson(&jw, Header{
        .params = params,
        .thresholds = .{ finite(info.threshold[0]), finite(info.threshold[1]), finite(info.threshold[2]) },
        .reduced_masses = .{ finite(info.reduced_mass[0]), finite(info.reduced_mass[1]), finite(info.reduced_mass[2]) },
        .bare = bare[0..n_bare],
        .reference_masses = reference[0..n_bare],
        .domain = spec.domain,
        .scan = spec.scan,
        .options = spec.options,
        .workers = @intCast(spec.workers),
    });
    try out.writeByte('\n');
    try out.flush();

    const buffer = try gpa.alloc(Task, 1024);
    defer gpa.free(buffer);
    var search: Search = .{
        .io = io,
        .gpa = gpa,
        .model = model.?,
        .info = info,
        .spec = spec,
        .origin = if (params.sector == xb.XB_1PP) params.m_B + params.m_Bstar else 2 * params.m_Bstar,
        .plan_size = plan_size,
        .queue = .init(buffer),
        .out = out,
    };
    defer search.deinit();
    search.pending.store(spec.domain.len + points, .release);
    if (spec.domain.len + points == 0) search.queue.close(io);

    var group: Io.Group = .init;
    for (0..spec.workers) |_| group.concurrent(io, Search.work, .{&search}) catch |err| {
        search.fail(err);
        break;
    };
    seed: {
        for (spec.domain, 0..) |r, i| {
            const cell: Cell = .{
                .bounds = .{ .re_lo = r.re[0], .re_hi = r.re[1], .im_lo = r.im[0], .im_hi = r.im[1] },
                .region = @intCast(i),
                .id = .root(i),
            };
            search.queue.putOne(io, .{ .cell = cell }) catch |err| {
                if (err == error.Canceled) search.fail(err);
                break :seed;
            };
        }
        for (0..points) |i| search.queue.putOne(io, .{ .scan = @intCast(i) }) catch |err| {
            if (err == error.Canceled) search.fail(err);
            break :seed;
        };
    }
    try group.await(io);
    if (search.err) |err| return err;

    const byId = struct {
        fn found(_: void, a: Found, b: Found) bool {
            return std.mem.lessThan(u8, a.id, b.id);
        }
        fn id(_: void, a: []const u8, b: []const u8) bool {
            return std.mem.lessThan(u8, a, b);
        }
    };
    std.mem.sort(Found, search.poles.items, {}, byId.found);
    std.mem.sort(Found, search.outer.items, {}, byId.found);
    std.mem.sort([]const u8, search.open.items, {}, byId.id);
    search.timing.wall = seconds(start.durationTo(Io.Clock.awake.now(io)).toNanoseconds());
    try search.writeLine(Summary{
        .workers = @intCast(spec.workers),
        .rectangles = search.rectangles,
        .status = search.status,
        .poles = search.poles.items,
        .outer = search.outer.items,
        .open = search.open.items,
        .scans = search.scans,
        .timing = search.timing,
    });
}
