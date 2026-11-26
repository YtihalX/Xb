//! xb2c: one run of the pole search from one configuration file (code/xb2c/SPEC.md, "Zig
//! driver").
//!
//!     zig build run -Doptimize=ReleaseFast -- config/search-2pp.zon
//!
//! The configuration is ZON, the Config struct below; every model parameter is required. The
//! output is the JSON-lines file of driver.run: the inputs, one record per rectangle and scan
//! energy, and a summary with the poles and timings.
const std = @import("std");
const xb = @import("xb");
const driver = @import("driver");

/// Energies and masses in GeV; energies count from M_th: m_B + m_B* in 1++, 2 m_B* in 2++.
const Config = struct {
    sector: enum { @"1++", @"2++" },
    parameters: struct {
        /// Quark model: m_b, sigma (GeV^2), gamma = -4 alpha_s/3.
        m_b: f64,
        sigma: f64,
        gamma: f64,
        /// The fit: V0 and the contact term C (GeV^-2).
        v0: f64,
        contact: f64,
        /// Couplings: bare-continuum g, axial g_b, F_pi.
        g: f64,
        g_b: f64,
        f_pi: f64,
        /// Tower truncation N and sharp cutoff Lambda.
        n_bare: i32,
        cutoff: f64,
        m_B: f64,
        m_Bstar: f64,
        m_pi: f64,
        m_eta: f64,
        /// 1++ only: the fit's historical PV reduced mass.
        mu_pv: ?f64 = null,
    },
    /// Gauss-Legendre nodes per path panel, the panel length, and the margin path's pole margin.
    quadrature: struct {
        panel_nodes: i32,
        panel_length: f64,
        pole_margin: f64,
    },
    domain: []const driver.Region = &.{},
    scan: ?driver.Scan = null,
    search: driver.Options = .{},
    /// Worker threads; 0 is one per core.
    workers: u32 = 0,
    /// The JSON-lines file, relative to the working directory; its directory is created.
    output: []const u8,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    var args = try std.process.Args.Iterator.initAllocator(init.minimal.args, gpa);
    defer args.deinit();
    _ = args.skip();
    const path = args.next() orelse {
        std.log.err("usage: xb2c <config.zon>", .{});
        return error.Usage;
    };
    const cwd = std.Io.Dir.cwd();
    const source = try cwd.readFileAllocOptions(io, path, gpa, .limited(1 << 20), .of(u8), 0);
    defer gpa.free(source);
    var arena: std.heap.ArenaAllocator = .init(gpa);
    defer arena.deinit();
    var diagnostics: std.zon.parse.Diagnostics = undefined;
    const config = std.zon.parse.fromSlice(Config, .{
        .gpa = gpa,
        .arena = arena.allocator(),
        .source = source,
        .diagnostics = &diagnostics,
    }) catch |err| {
        if (err == error.ParseZon) diagnostics.log(path);
        return err;
    };
    const p = config.parameters;
    const q = config.quadrature;
    const params: xb.xb_params = .{
        .sector = switch (config.sector) {
            .@"1++" => xb.XB_1PP,
            .@"2++" => xb.XB_2PP,
        },
        .n_bare = p.n_bare,
        .panel_nodes = q.panel_nodes,
        .m_b = p.m_b,
        .sigma = p.sigma,
        .gamma = p.gamma,
        .v0 = p.v0,
        .contact = p.contact,
        .g = p.g,
        .g_b = p.g_b,
        .f_pi = p.f_pi,
        .cutoff = p.cutoff,
        .m_B = p.m_B,
        .m_Bstar = p.m_Bstar,
        .m_pi = p.m_pi,
        .m_eta = p.m_eta,
        .mu_pv = p.mu_pv orelse std.math.nan(f64),
        .panel_length = q.panel_length,
        .pole_margin = q.pole_margin,
    };
    const workers: usize = if (config.workers != 0) config.workers else std.Thread.getCpuCount() catch 1;
    if (std.fs.path.dirname(config.output)) |dir| try cwd.createDirPath(io, dir);
    const file = try cwd.createFile(io, config.output, .{});
    defer file.close(io);
    var buffer: [1 << 16]u8 = undefined;
    var writer = file.writer(io, &buffer);
    driver.run(io, gpa, params, .{
        .domain = config.domain,
        .scan = config.scan,
        .options = config.search,
        .workers = workers,
    }, &writer.interface) catch |err| {
        // InvalidArgument from model creation: a missing or nonphysical parameter.
        std.log.err("{s}: the run stopped: {t}", .{ path, if (err == error.WriteFailed) writer.err orelse err else err });
        return err;
    };
}
