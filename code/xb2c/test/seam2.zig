//! Seam 2: the Zig rectangle job and the subdivision driver. Every case uses the real C plan,
//! determinant, and solver.
const std = @import("std");
const xb = @import("xb");
const rectangle = @import("rectangle");
const driver = @import("driver");
const fixtures = @import("fixtures.zig");
const expect = std.testing.expect;
const allocator = std.testing.allocator;

const Search = struct {
    model: fixtures.Model,
    ws: fixtures.Workspace,
    plan: fixtures.Plan,
    samples: std.ArrayList(rectangle.Sample) = .empty,

    fn init(params: xb.xb_params) !Search {
        const model = try fixtures.Model.init(params);
        errdefer model.deinit();
        const ws = try fixtures.Workspace.init(model);
        errdefer ws.deinit();
        return .{ .model = model, .ws = ws, .plan = try fixtures.Plan.init(model) };
    }

    fn deinit(self: *Search) void {
        self.samples.deinit(allocator);
        self.plan.deinit();
        self.ws.deinit();
        self.model.deinit();
    }

    fn run(self: *Search, bounds: xb.xb_rect, options: rectangle.Options) !rectangle.Report {
        return self.runOn(bounds, fixtures.physical, xb.XB_PATH_S40, options);
    }

    fn runOn(self: *Search, bounds: xb.xb_rect, sheet: xb.xb_sheet, path: xb.enum_xb_path, options: rectangle.Options) !rectangle.Report {
        return rectangle.run(self.model.ptr, self.ws.ptr, self.plan.ptr(), .{
            .bounds = bounds,
            .sheet = sheet,
            .path = path,
            .options = options,
        }, allocator, &self.samples);
    }

    fn bare(self: Search) ![2]f64 {
        var info: xb.xb_info = undefined;
        try fixtures.ok(xb.xb_model_info(self.model.ptr, &info));
        return .{ info.bare[0].energy, info.bare[1].energy };
    }
};

fn freeLevels(n: i32) xb.xb_params {
    var params = fixtures.baseline(xb.XB_1PP);
    params.n_bare = n;
    params.g = 0;
    params.g_b = 0;
    params.contact = 0;
    params.panel_nodes = 1;
    params.panel_length = params.cutoff;
    return params;
}

test "rectangle job refines the recorded 1++ X_b on the reference rule" {
    var params = fixtures.baseline(xb.XB_1PP);
    params.panel_nodes = 24;
    params.panel_length = params.cutoff;
    var search = try Search.init(params);
    defer search.deinit();
    const expected = fixtures.recorded_1pp[2];
    const report = try search.run(.{
        .re_lo = expected - 0.0015,
        .re_hi = expected + 0.0025,
        .im_lo = -0.002,
        .im_hi = 0.002,
    }, .{});
    // SPEC seam 2 item 1 (user, 2026-11-26): the seam-1 bar, since the seed carries the
    // 24-node rule's discretization error.
    try std.testing.expectEqual(@as(?usize, 1), report.zero_count);
    const root = report.pole orelse return error.MissingPole;
    try std.testing.expectApproxEqAbs(expected, root.energy.re, 1e-8);
    try std.testing.expectApproxEqAbs(0.0, root.energy.im, 1e-10);
}

test "rectangle job separates an empty box from a box with two decoupled levels" {
    var search = try Search.init(freeLevels(2));
    defer search.deinit();
    // For g = g_b = C = 0, the bordered matrix has determinant (E - eps_1)(E - eps_2).
    const lo, const hi = try search.bare();
    const empty = try search.run(.{ .re_lo = hi + 0.01, .re_hi = hi + 0.04, .im_lo = -0.015, .im_hi = 0.015 }, .{});
    try std.testing.expectEqual(@as(?usize, 0), empty.zero_count);
    const pair = try search.run(.{ .re_lo = lo - 0.2, .re_hi = hi + 0.2, .im_lo = -0.4, .im_hi = 0.4 }, .{});
    try std.testing.expectEqual(@as(?usize, 2), pair.zero_count);
    try expect(pair.pole == null);
}

test "rectangle job locates a near-edge zero without assigning it to the interior" {
    var search = try Search.init(freeLevels(1));
    defer search.deinit();
    var info: xb.xb_info = undefined;
    try fixtures.ok(xb.xb_model_info(search.model.ptr, &info));
    const level = info.bare[0].energy;
    const edge = 5e-11;
    const report = try search.run(.{ .re_lo = level - 0.04, .re_hi = level + 0.04, .im_lo = -0.04, .im_hi = edge }, .{});
    try expect(report.zero_count == null and report.pole == null);
    const candidate = (report.boundary orelse return error.MissingBoundaryWarning).candidate orelse return error.MissingBoundaryRoot;
    // The root is not a sampled boundary point: the top edge is above it by edge.
    try std.testing.expectApproxEqAbs(level, candidate.energy.re, 1e-12);
    try std.testing.expectApproxEqAbs(0.0, candidate.energy.im, 1e-12);
}

test "rectangle job leaves an edge unresolved if the nearby zero is outside the certified box" {
    var search = try Search.init(freeLevels(2));
    defer search.deinit();
    const level = (try search.bare())[0];
    const report = try search.run(.{ .re_lo = level - 0.04, .re_hi = level + 0.04, .im_lo = -0.04, .im_hi = -5e-5 }, .{});
    try expect(report.zero_count == null and report.pole == null);
    const warning = report.boundary orelse return error.MissingBoundaryWarning;
    try expect(warning.candidate == null);
}

/// Independent polygon winding of the *closed form* for the aliasing fixture. Sum the
/// principal angle between consecutive values using the dot and cross products, not the
/// job's signed principal-phase crossings.
fn bareWinding(r: xb.xb_rect, levels: [2]f64, segments: usize) i32 {
    const C = std.math.Complex(f64);
    const corners = [_]C{
        C.init(r.re_lo, r.im_lo), C.init(r.re_hi, r.im_lo),
        C.init(r.re_hi, r.im_hi), C.init(r.re_lo, r.im_hi),
    };
    var angle: f64 = 0;
    var prev = corners[0].sub(C.init(levels[0], 0)).mul(corners[0].sub(C.init(levels[1], 0)));
    const n: f64 = @floatFromInt(segments);
    for (corners, 0..) |a, side| {
        const d = corners[(side + 1) % 4].sub(a);
        for (1..segments + 1) |j| {
            const t: f64 = @floatFromInt(j);
            const e = a.add(d.mul(C.init(t / n, 0)));
            const value = e.sub(C.init(levels[0], 0)).mul(e.sub(C.init(levels[1], 0)));
            angle += std.math.atan2(prev.re * value.im - prev.im * value.re, prev.re * value.re + prev.im * value.im);
            prev = value;
        }
    }
    return @intFromFloat(@round(angle / (2 * std.math.pi)));
}

test "rectangle job does not report an aliased zero count when a corner dip exposes two hidden levels" {
    var search = try Search.init(freeLevels(2));
    defer search.deinit();
    const levels = try search.bare();
    const r: xb.xb_rect = .{ .re_lo = levels[1] - 8, .re_hi = levels[1] + 0.07, .im_lo = -8, .im_hi = 0.21 };
    // Like Ying–Katz Example 4.2, the first three meshes agree on zero when there are two
    // zeros near one corner. Here the actual C determinant supplies two simple bare zeros.
    for ([_]usize{ 1, 2, 4 }) |n| try std.testing.expectEqual(@as(i32, 0), bareWinding(r, levels, n));
    const report = try search.run(r, .{ .max_segments = 4 });
    try expect(report.zero_count == null and report.pole == null);
}

/// The 1++ baseline on the reference's single 24-node rule, where the recorded seeds hold to
/// 1e-8 GeV (SPEC seam 1, test 2).
fn referenceRule() xb.xb_params {
    var params = fixtures.baseline(xb.XB_1PP);
    params.panel_nodes = 24;
    params.panel_length = params.cutoff;
    return params;
}

test "rectangle job counts zero on a 1++ box without a bound state" {
    var search = try Search.init(referenceRule());
    defer search.deinit();
    // Between chi_b1(2P) at -349 MeV and X_b at -91 MeV.
    const report = try search.run(.{ .re_lo = -0.3, .re_hi = -0.15, .im_lo = -0.01, .im_hi = 0.01 }, .{});
    try std.testing.expectEqual(@as(?usize, 0), report.zero_count);
}

/// The rectangle records of a domain run, sorted by id, with their JSON lines.
const Records = struct {
    arena: std.heap.ArenaAllocator,
    items: []driver.Record,
    lines: []const []const u8,

    fn deinit(self: *Records) void {
        self.arena.deinit();
    }

    fn get(self: Records, id: []const u8) !driver.Record {
        for (self.items) |r| if (std.mem.eql(u8, r.id, id)) return r;
        return error.MissingRecord;
    }
};

/// Runs the driver and parses its output back from JSON, as a reader of the file would.
fn domainRun(params: xb.xb_params, domain: []const driver.Region, options: driver.Options, workers: usize) !Records {
    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    try driver.run(std.testing.io, allocator, params, .{ .domain = domain, .options = options, .workers = workers }, &out.writer);
    var arena: std.heap.ArenaAllocator = .init(allocator);
    errdefer arena.deinit();
    const a = arena.allocator();
    const Entry = struct { record: driver.Record, line: []const u8 };
    var entries: std.ArrayList(Entry) = .empty;
    var it = std.mem.splitScalar(u8, out.written(), '\n');
    while (it.next()) |line| {
        if (!std.mem.startsWith(u8, line, "{\"kind\":\"rectangle\"")) continue;
        const copy = try a.dupe(u8, line);
        try entries.append(a, .{ .record = try std.json.parseFromSliceLeaky(driver.Record, a, copy, .{}), .line = copy });
    }
    std.mem.sort(Entry, entries.items, {}, struct {
        fn less(_: void, x: Entry, y: Entry) bool {
            return std.mem.lessThan(u8, x.record.id, y.record.id);
        }
    }.less);
    const items = try a.alloc(driver.Record, entries.items.len);
    const lines = try a.alloc([]const u8, entries.items.len);
    for (entries.items, items, lines) |e, *r, *l| {
        r.* = e.record;
        l.* = e.line;
    }
    return .{ .arena = arena, .items = items, .lines = lines };
}

const physical_sheet = [3]i8{ 1, 1, 1 };

/// No record is left open, and the refined poles are exactly the expected bound states, each
/// within the seam-1 bar of its recorded seed (24-node rule).
fn expectPoles(records: Records, expected: []const f64) !void {
    var found: usize = 0;
    for (records.items) |r| {
        try expect(r.status != .unresolved and r.status != .multiple and r.status != .unconverged);
        const pole = r.pole orelse continue;
        try expect(r.status == .pole);
        found += 1;
        var matched = false;
        for (expected) |e| matched = matched or (@abs(pole.E[0] - e) <= 1e-8 and @abs(pole.E[1]) <= 1e-10);
        try expect(matched);
    }
    try std.testing.expectEqual(expected.len, found);
}

test "driver splits a box holding X_b and chi_b1(3P) and refines both" {
    var records = try domainRun(referenceRule(), &.{.{ .sheet = physical_sheet, .re = .{ -0.1, -0.05 }, .im = .{ -0.01, 0.01 } }}, .{ .min_size = 0.005 }, 2);
    defer records.deinit();
    const root = try records.get("0");
    try expect(root.status == .split and root.count == 2);
    try expectPoles(records, &.{ fixtures.recorded_1pp[2], fixtures.recorded_1pp[3] });
}

test "driver reproduces the four 1++ bound states from one elongated box on the reference rule" {
    // chi_b1(1P) to X_b and chi_b1(3P) on the real axis, 749 x 20 MeV.
    var records = try domainRun(referenceRule(), &.{.{ .sheet = physical_sheet, .re = .{ -0.75, -0.001 }, .im = .{ -0.01, 0.01 } }}, .{ .min_size = 0.001 }, 4);
    defer records.deinit();
    try expectPoles(records, &fixtures.recorded_1pp);
}

/// X_b on the reference rule, refined by the rectangle job.
fn referenceXb() !f64 {
    var search = try Search.init(referenceRule());
    defer search.deinit();
    const expected = fixtures.recorded_1pp[2];
    const report = try search.run(.{ .re_lo = expected - 0.0015, .re_hi = expected + 0.0025, .im_lo = -0.002, .im_hi = 0.002 }, .{});
    return (report.pole orelse return error.MissingPole).energy.re;
}

test "driver moves a split line that runs through X_b and still refines both poles" {
    const params = referenceRule();
    const x_b = try referenceXb();
    // Where the driver splits a box holding X_b and chi_b1(3P).
    const box = [2]f64{ -0.12, -0.03 };
    var first = try domainRun(params, &.{.{ .sheet = physical_sheet, .re = box, .im = .{ -0.01, 0.01 } }}, .{ .min_size = 0.005 }, 2);
    defer first.deinit();
    const shift = x_b - (try first.get("0/0")).bounds[1];
    // The same box translated so that this line runs through X_b.
    var moved = try domainRun(params, &.{.{ .sheet = physical_sheet, .re = .{ box[0] + shift, box[1] + shift }, .im = .{ -0.01, 0.01 } }}, .{ .min_size = 0.005 }, 2);
    defer moved.deinit();
    for ([_][]const u8{ "0/0", "0/1" }) |id| try expect((try moved.get(id)).status == .superseded);
    try expect(@abs((try moved.get("0/2")).bounds[1] - x_b) > 1e-6);
    try expectPoles(moved, &.{ fixtures.recorded_1pp[2], fixtures.recorded_1pp[3] });
}

/// A 4 x 4 MeV box whose upper Re edge lies 5e-11 GeV beyond X_b, straddling the real axis.
fn outerEdgeBox(x_b: f64) driver.Region {
    return .{ .sheet = physical_sheet, .re = .{ x_b - 0.004, x_b + 5e-11 }, .im = .{ -0.002, 0.002 } };
}

test "driver keeps an outer edge next to X_b in place and reports it unresolved" {
    const x_b = try referenceXb();
    const box = outerEdgeBox(x_b);
    const re = box.re;
    const im = box.im;
    var records = try domainRun(referenceRule(), &.{box}, .{ .min_size = 0.002 }, 2);
    defer records.deinit();
    var unresolved: usize = 0;
    for (records.items) |r| {
        try expect(r.bounds[0] >= re[0] and r.bounds[1] <= re[1] and r.bounds[2] >= im[0] and r.bounds[3] <= im[1]);
        try expect(r.pole == null);
        if (r.status != .unresolved) continue;
        unresolved += 1;
        // A leaf at the minimum size on the outer edge, with X_b as its outer-boundary candidate.
        try expect(@max(r.bounds[1] - r.bounds[0], r.bounds[3] - r.bounds[2]) <= 0.002 and r.bounds[1] == re[1]);
        const warning = r.boundary orelse return error.MissingBoundaryWarning;
        const candidate = warning.candidate orelse return error.MissingBoundaryRoot;
        try expect(warning.edge == .outer);
        try std.testing.expectApproxEqAbs(x_b, candidate.E[0], 1e-12);
        try std.testing.expectApproxEqAbs(0.0, candidate.E[1], 1e-12);
    }
    try std.testing.expectEqual(@as(usize, 1), unresolved);
}

/// The 2++ baseline on the coarse rule of seam 1's Cauchy test: D~ is analytic on a certified
/// rectangle for every rule, and the certificate does not depend on the rule.
fn coarse2pp() xb.xb_params {
    var params = fixtures.baseline(xb.XB_2PP);
    params.panel_nodes = 8;
    params.panel_length = 0.5;
    return params;
}

test "2++: across a flipped pole crossing the S40 path, the count equals its children's and the margin path's" {
    var search = try Search.init(coarse2pp());
    defer search.deinit();
    const sheet = fixtures.bb_sheet;
    // The kernel-window fixture of seam 1: its BB pole crosses the selected bend.
    const a = fixtures.bb_kernel_box;
    const whole = try search.runOn(a, sheet, xb.XB_PATH_S40, .{});
    try expect(whole.certificate.failed == 0 and whole.certificate.depth > 0);
    const count = whole.zero_count orelse return error.Unresolved;
    const line = a.im_lo + 0.4472135954999579 * (a.im_hi - a.im_lo);
    var children = [2]xb.xb_rect{ a, a };
    children[0].im_hi = line;
    children[1].im_lo = line;
    var sum: usize = 0;
    for (children) |child| {
        const report = try search.runOn(child, sheet, xb.XB_PATH_S40, .{});
        try expect(report.certificate.failed == 0);
        sum += report.zero_count orelse return error.Unresolved;
    }
    try std.testing.expectEqual(count, sum);
    const margin = try search.runOn(a, sheet, xb.XB_PATH_MARGIN, .{});
    try expect(margin.certificate.failed == 0);
    try std.testing.expectEqual(@as(?usize, count), margin.zero_count);
}

test "driver reports F5 excluded by (C5), splits it to the minimum size, and never counts it" {
    // F5 of the certificate test on (-,-,+), in GeV.
    const re = [2]f64{ -0.0466, -0.0464 };
    const im = [2]f64{ -0.0002, -0.0001 };
    const min_size = 1e-4;
    var records = try domainRun(coarse2pp(), &.{.{ .sheet = .{ -1, -1, 1 }, .re = re, .im = im }}, .{ .min_size = min_size }, 4);
    defer records.deinit();
    const f5 = try records.get("0");
    try expect(f5.certificate.failed == 5 and f5.status == .split and f5.count == null);
    var area: f64 = 0;
    for (records.items) |r| {
        if (r.certificate.failed != 0) try expect(r.count == null and r.pole == null and (r.status == .split or r.status == .excluded));
        if (r.status == .excluded) try expect(@max(r.bounds[1] - r.bounds[0], r.bounds[3] - r.bounds[2]) <= min_size);
        if (r.status != .split and r.status != .superseded) area += (r.bounds[1] - r.bounds[0]) * (r.bounds[3] - r.bounds[2]);
    }
    // The final records tile F5.
    try std.testing.expectApproxEqRel((re[1] - re[0]) * (im[1] - im[0]), area, 1e-9);
}

/// A small 1++ domain: a box holding X_b and chi_b1(3P), which splits; an elongated empty one,
/// split before counting; and the outer-edge box, whose subdivision moves a split line.
fn smallDomain() ![3]driver.Region {
    return .{
        .{ .sheet = physical_sheet, .re = .{ -0.1, -0.05 }, .im = .{ -0.01, 0.01 } },
        .{ .sheet = physical_sheet, .re = .{ -0.3, -0.15 }, .im = .{ -0.01, 0.01 } },
        outerEdgeBox(try referenceXb()),
    };
}

test "driver writes identical records with one worker and with four" {
    const domain = try smallDomain();
    var one = try domainRun(referenceRule(), &domain, .{ .min_size = 0.002, .samples = true }, 1);
    defer one.deinit();
    var four = try domainRun(referenceRule(), &domain, .{ .min_size = 0.002, .samples = true }, 4);
    defer four.deinit();
    var moved = false;
    for (one.items) |r| moved = moved or r.status == .superseded;
    try expect(moved);
    try std.testing.expectEqual(one.lines.len, four.lines.len);
    for (one.lines, four.lines) |a, b| try std.testing.expectEqualStrings(a, b);
}

/// The winding number of D~ along the closed polygon of written samples (E, log|D~|, arg D~):
/// the sum of the principal angles between consecutive values, over 2 pi.
fn sampleWinding(samples: []const [4]?f64) !i64 {
    var angle: f64 = 0;
    for (samples, 0..) |s, i| {
        const next = samples[(i + 1) % samples.len];
        const turn = (next[3] orelse return error.NonFinite) - (s[3] orelse return error.NonFinite);
        angle += std.math.atan2(@sin(turn), @cos(turn));
    }
    return @intFromFloat(@round(angle / (2 * std.math.pi)));
}

test "with sampling on, every record's count equals the winding of its own samples" {
    const domain = try smallDomain();
    var records = try domainRun(referenceRule(), &domain, .{ .min_size = 0.002, .samples = true }, 2);
    defer records.deinit();
    var counted: usize = 0;
    for (records.items) |r| {
        const count = r.count orelse continue;
        try expect(r.samples.len >= 4);
        try std.testing.expectEqual(@as(i64, count), try sampleWinding(r.samples));
        counted += 1;
    }
    // The parent of two zeros, its two children, and the empty box.
    try expect(counted >= 4);
}
