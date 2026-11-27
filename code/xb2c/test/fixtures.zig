const std = @import("std");
const xb = @import("xb");

pub fn ok(status: xb.xb_status) !void {
    if (status != xb.XB_OK) {
        std.debug.print("status {d}\n", .{status});
        return error.Status;
    }
}

/// Baseline fit, full precision: code/HadronDynamics.jl/data/bochiEFT/central.toml.
/// g = (2/sqrt 3) sqrt 2 g_l with g_l = 35 MeV (CONVENTIONS.md, "Bare–continuum vertex").
pub fn baseline(sector: xb.enum_xb_sector) xb.xb_params {
    return .{
        .sector = sector,
        .n_bare = 4,
        .panel_nodes = 16,
        .m_b = 4.534047672900046,
        .sigma = 0.19840639309997352,
        .gamma = -0.434,
        .v0 = 0.3714694358359325,
        .contact = -16.26782020427067,
        .g = 0.05715476066494084,
        .g_b = 0.56,
        .f_pi = 0.0922,
        .cutoff = 4.0,
        .m_B = 5.27952,
        .m_Bstar = 5.32475,
        .m_pi = 0.138039407,
        .m_eta = 0.548,
        .mu_pv = if (sector == xb.XB_1PP) 2.6509501131648436 else std.math.nan(f64),
        .panel_length = 0.25,
        .pole_margin = 0.05,
    };
}

pub const Model = struct {
    ptr: *xb.xb_model,

    pub fn init(params: xb.xb_params) !Model {
        try ok(xb.xb_init());
        var model: ?*xb.xb_model = null;
        try ok(xb.xb_model_create(&params, &model));
        return .{ .ptr = model.? };
    }

    pub fn deinit(self: Model) void {
        xb.xb_model_destroy(self.ptr);
    }
};

pub const Workspace = struct {
    ptr: *xb.xb_ws,

    pub fn init(model: Model) !Workspace {
        var ws: ?*xb.xb_ws = null;
        try ok(xb.xb_ws_create(model.ptr, &ws));
        return .{ .ptr = ws.? };
    }

    pub fn deinit(self: Workspace) void {
        xb.xb_ws_destroy(self.ptr);
    }
};

pub const Plan = struct {
    bytes: []align(16) u8,

    pub fn init(model: Model) !Plan {
        var size: usize = 0;
        try ok(xb.xb_plan_size(model.ptr, &size));
        return .{ .bytes = try std.testing.allocator.alignedAlloc(u8, .@"16", size) };
    }

    pub fn deinit(self: Plan) void {
        std.testing.allocator.free(self.bytes);
    }

    pub fn ptr(self: Plan) *xb.xb_plan {
        return @ptrCast(self.bytes.ptr);
    }
};

pub const physical = xb.xb_sheet{ .pp = 1, .pv = 1, .vv = 1 };

/// Below BB*, with only BB flipped. The bottom reaches deeper than the real-path pion window;
/// near the top the BB pole lies above the certified bend. Energies in GeV from 2 m_B*.
pub const bb_kernel_box: xb.xb_rect = .{ .re_lo = -0.08046, .re_hi = -0.07446, .im_lo = -0.016, .im_hi = -0.0005 };
pub const bb_sheet: xb.xb_sheet = .{ .pp = -1, .pv = 1, .vv = 1 };

/// The four 1++ seeds of central.toml, [[states]], in GeV from m_B + m_B*. The reference's
/// single 24-node rule is not converged: X_b moves by 6 keV at 256 nodes.
pub const recorded_1pp = [_]f64{ -0.71100611184964, -0.34899381112361444, -0.09099982482230619, -0.06065479103052896 };
