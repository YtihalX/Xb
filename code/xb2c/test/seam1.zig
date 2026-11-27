//! Seam 1: the public C header, called through translate-c as the driver calls it
//! (code/xb2c/SPEC.md, Testing Decisions).
const std = @import("std");
const xb = @import("xb");
const gsl = @import("gsl");
const tables = @import("tables.zig");
const fixtures = @import("fixtures.zig");

const expect = std.testing.expect;
const Complex = std.math.Complex(f64);

const ok = fixtures.ok;
const baseline = fixtures.baseline;
const Model = fixtures.Model;
const Workspace = fixtures.Workspace;
const Plan = fixtures.Plan;
const physical = fixtures.physical;
const recorded_1pp = fixtures.recorded_1pp;

test "quark model: normalisation and tail matching within the reference bounds" {
    var info: [2]xb.xb_info = undefined;
    for ([_]xb.enum_xb_sector{ xb.XB_1PP, xb.XB_2PP }, &info) |sector, *sector_info| {
        const model = try Model.init(baseline(sector));
        defer model.deinit();
        try ok(xb.xb_model_info(model.ptr, sector_info));
        try expect(sector_info.n_bare == 4);
        for (sector_info.bare[0..4]) |bare| {
            try expect(bare.norm_residual <= 1e-10);
            try expect(bare.tail_residual <= 2e-4);
        }
    }
    // CONVENTIONS.md, "Energy origin": one reference mass, energies from m_B + m_B* and 2 m_B*.
    const params = baseline(xb.XB_2PP);
    for (info[0].bare[0..4], info[1].bare[0..4]) |one, two| {
        try expect(one.reference_mass == two.reference_mass);
        try expect(@abs(two.energy - (one.energy - (params.m_Bstar - params.m_B))) <= 1e-14);
    }
}

test "quark model: a missing or nonphysical parameter is an argument error" {
    try ok(xb.xb_init());
    const nan = std.math.nan(f64);
    const good = baseline(xb.XB_2PP);
    var cases: [24]xb.xb_params = @splat(good);
    cases[0].m_b = nan;
    cases[1].sigma = -0.198;
    cases[2].gamma = 0.434;
    cases[3].v0 = nan;
    cases[4].contact = nan;
    cases[5].g = -0.057;
    cases[6].g_b = nan;
    cases[7].f_pi = 0;
    cases[8].cutoff = std.math.inf(f64);
    cases[9].m_B = nan;
    cases[10].m_Bstar = 5.2; // below m_B
    cases[11].m_pi = 0.04; // below m_B* - m_B: no zero-width exchange
    cases[12].m_eta = nan;
    cases[13].mu_pv = 2.65; // 2++ takes its reduced masses from the meson masses
    cases[14].panel_length = 0;
    cases[15].pole_margin = nan;
    cases[16].n_bare = 0;
    cases[17].n_bare = xb.XB_MAX_BARE + 1;
    cases[18].panel_nodes = 0;
    cases[19].sector = 3;
    cases[20] = baseline(xb.XB_1PP);
    cases[20].mu_pv = nan; // 1++ needs the fit's PV reduced mass
    cases[21].gamma = nan;
    cases[22].sigma = nan;
    cases[23].m_b = -4.5;
    for (cases) |params| {
        var model: ?*xb.xb_model = null;
        try expect(xb.xb_model_create(&params, &model) == xb.XB_EARG);
        try expect(model == null);
    }
}

/// The zero of D~ refined from a seed `shift` away from e, on the physical sheet, in a
/// rectangle that straddles the real axis.
fn boundState(model: Model, ws: Workspace, plan: Plan, path: xb.enum_xb_path, e: f64, shift: f64) !Complex {
    const rect: xb.xb_rect = .{ .re_lo = e - 0.002, .re_hi = e + 0.002, .im_lo = -0.001, .im_hi = 0.001 };
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, physical, path, plan.ptr(), &cert));
    try expect(cert.failed == 0);
    var root: xb.xb_root = undefined;
    try ok(xb.xb_refine(model.ptr, ws.ptr, plan.ptr(), .{ .re = e + shift, .im = 0 }, 1e-6, &root));
    try expect(root.converged == 1);
    return cplx(root.energy.re, root.energy.im);
}

test "1++ baseline: on the reference's 24-node rule the bound states match the recorded seeds to 1e-8 GeV" {
    var params = baseline(xb.XB_1PP);
    params.panel_length = 4.0;
    params.panel_nodes = 24;
    const model = try Model.init(params);
    defer model.deinit();
    const ws = try Workspace.init(model);
    defer ws.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    for (recorded_1pp) |e| for ([_]f64{ -0.001, 0.001 }) |shift| {
        const zero = try boundState(model, ws, plan, xb.XB_PATH_S40, e, shift);
        try expect(zero.sub(cplx(e, 0)).magnitude() <= 1e-8);
    };
}

test "1++ baseline: the margin path reproduces the bound states of [0, Lambda] to 1e-10 GeV" {
    const params = baseline(xb.XB_1PP); // the production rule, 16 nodes per 250 MeV panel
    const model = try Model.init(params);
    defer model.deinit();
    const ws = try Workspace.init(model);
    defer ws.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    for (recorded_1pp) |e| {
        const real = try boundState(model, ws, plan, xb.XB_PATH_S40, e, 0.001);
        const margin = try boundState(model, ws, plan, xb.XB_PATH_MARGIN, e, 0.001);
        try expect(margin.sub(real).magnitude() <= 1e-10);
    }
}

fn cplx(re: f64, im: f64) Complex {
    return Complex.init(re, im);
}

/// The time orderings of note 07, S2, from the meson masses: nu = t + h p'^2 + a q^2 - E.
fn ordering(params: xb.xb_params, beta: u8) [3]f64 {
    const m_th = if (params.sector == xb.XB_1PP) params.m_B + params.m_Bstar else 2 * params.m_Bstar;
    const hp = 1 / (2 * params.m_B);
    const hv = 1 / (2 * params.m_Bstar);
    return switch (beta) {
        1 => .{ 2 * params.m_B - m_th, hp, hp },
        2 => .{ 2 * params.m_Bstar - m_th, hv, hv },
        3 => .{ params.m_B + params.m_Bstar - m_th, hv, hp },
        else => .{ params.m_B + params.m_Bstar - m_th, hp, hv },
    };
}

/// x^power [f(x) + (-1)^power f(-x)] on [0, 1], f(x) = 1/[2 s (s + nu)] with
/// s = sqrt(A - B x), A = m^2 + p'^2 + q^2, B = 2 p' q: the angular moment folded onto [0, 1].
/// The odd part uses s(-x) - s(x) = 2 B x / [s(x) + s(-x)], free of cancellation, so the
/// quadrature's error is relative to the moment even where B is small.
const Angular = struct {
    p: Complex,
    q: Complex,
    e: Complex,
    mass: f64,
    nu: [3]f64,
    power: u32,
    imag: bool = false,

    fn eval(x: f64, data: ?*anyopaque) callconv(.c) f64 {
        const d: *const Angular = @ptrCast(@alignCast(data.?));
        const pp = d.p.mul(d.p);
        const qq = d.q.mul(d.q);
        const a = cplx(d.mass * d.mass, 0).add(pp).add(qq);
        const bx = d.p.mul(d.q).mul(cplx(2 * x, 0));
        const s1 = std.math.complex.sqrt(a.sub(bx));
        const s2 = std.math.complex.sqrt(a.add(bx));
        const nu = cplx(d.nu[0], 0).add(pp.mul(cplx(d.nu[1], 0))).add(qq.mul(cplx(d.nu[2], 0))).sub(d.e);
        const z1 = s1.add(nu);
        const z2 = s2.add(nu);
        const sum = s1.add(s2);
        const folded = if (d.power % 2 == 0)
            cplx(1, 0).div(s1.mul(z1).mul(cplx(2, 0))).add(cplx(1, 0).div(s2.mul(z2).mul(cplx(2, 0))))
        else
            bx.mul(cplx(2, 0)).mul(sum.add(nu)).div(sum.mul(s1).mul(s2).mul(z1).mul(z2).mul(cplx(2, 0)));
        var power: f64 = 1;
        for (0..d.power) |_| power *= x;
        const value = folded.mul(cplx(power, 0));
        return if (d.imag) value.im else value.re;
    }

    /// Both parts by GSL's QAG, with the larger of their error estimates.
    fn integrate(self: *Angular, ws: ?*gsl.gsl_integration_workspace) !struct { value: Complex, err: f64 } {
        var part: [2]f64 = undefined;
        var err: [2]f64 = undefined;
        for (&part, &err, [_]bool{ false, true }) |*value, *estimate, imag| {
            self.imag = imag;
            const f = gsl.gsl_function{ .function = eval, .params = self };
            const status = gsl.gsl_integration_qag(&f, 0, 1, 0, 1e-13, 1000, gsl.GSL_INTEG_GAUSS61, ws, value, estimate);
            if (status != gsl.GSL_SUCCESS and status != gsl.GSL_EROUND) return error.Quadrature;
        }
        return .{ .value = cplx(part[0], part[1]), .err = @max(err[0], err[1]) };
    }
};

const Species = enum { pp, pv, vv };
const species_1pp = [3]Species{ .pv, .pv, .vv };
const species_2pp = [6]Species{ .pp, .pv, .vv, .vv, .vv, .vv };

/// The time orderings of each block, outgoing species first (note 07, S2); {0, 0}: no exchange.
fn orderings(out: Species, in: Species) [2]u8 {
    return switch (out) {
        .vv => switch (in) {
            .vv => .{ 2, 2 },
            .pv => .{ 2, 3 },
            .pp => .{ 3, 3 },
        },
        .pv => switch (in) {
            .vv => .{ 2, 4 },
            .pv => .{ 1, 2 },
            .pp => .{ 0, 0 },
        },
        .pp => if (in == .vv) .{ 4, 4 } else .{ 0, 0 },
    };
}

/// Every entry of V(p', q; E), pi and eta, against -(g_b^2/(8F_pi^2)) sum_m c_m Delta_m with
/// the moments Delta_m from GSL's adaptive quadrature; returns the largest error over
/// sum_m |c_m Delta_m|, the scale of S22's per-moment target. The quadrature's own error
/// estimate must stay below 1e-12 of that scale.
fn checkKernel(comptime nc: usize, spin: [nc][nc][5][3]f64, species: [nc]Species, params: xb.xb_params, model: Model, ws: Workspace, quad: ?*gsl.gsl_integration_workspace, p: Complex, q: Complex, e: Complex) !f64 {
    var v: [2][nc * nc]xb.xb_cplx = undefined;
    try ok(xb.xb_kernel(model.ptr, ws.ptr, .{ .re = p.re, .im = p.im }, .{ .re = q.re, .im = q.im }, .{ .re = e.re, .im = e.im }, nc * nc, &v[0], &v[1]));
    var moment: [2][4][5]Complex = undefined;
    var err: [2][4][5]f64 = undefined;
    const masses = [2]f64{ params.m_pi, params.m_eta };
    for (0..2) |phi| for (0..4) |b| for (0..5) |m| {
        var angular: Angular = .{ .p = p, .q = q, .e = e, .mass = masses[phi], .nu = ordering(params, @intCast(b + 1)), .power = @intCast(m) };
        const result = try angular.integrate(quad);
        moment[phi][b][m] = result.value;
        err[phi][b][m] = result.err;
    };
    const coupling = params.g_b * params.g_b / (8 * params.f_pi * params.f_pi);
    const mono = [3]Complex{ p.mul(p), p.mul(q), q.mul(q) };
    var worst: f64 = 0;
    for (0..nc) |a| for (0..nc) |b| for (0..2) |phi| {
        const got = v[phi][a * nc + b];
        const pair = orderings(species[a], species[b]);
        var sum = cplx(0, 0);
        var scale: f64 = 0;
        var oracle: f64 = 0;
        if (pair[0] != 0) for (0..5) |m| {
            const c = cplx(spin[a][b][m][0], 0).mul(mono[0]).add(cplx(spin[a][b][m][1], 0).mul(mono[1])).add(cplx(spin[a][b][m][2], 0).mul(mono[2]));
            const term = c.mul(moment[phi][pair[0] - 1][m].add(moment[phi][pair[1] - 1][m]));
            sum = sum.add(term);
            scale += term.magnitude();
            oracle += c.magnitude() * (err[phi][pair[0] - 1][m] + err[phi][pair[1] - 1][m]);
        };
        const weight = -coupling * @as(f64, if (phi == 0) 3.0 else 1.0 / 3.0);
        const diff = cplx(got.re, got.im).sub(sum.mul(cplx(weight, 0))).magnitude();
        try expect(std.math.isFinite(diff));
        if (scale == 0) {
            try expect(diff == 0);
        } else {
            try expect(oracle <= 1e-12 * scale);
            worst = @max(worst, diff / (@abs(weight) * scale));
        }
    };
    return worst;
}

test "kernel: pairs with one small momentum match GSL's adaptive angular quadrature to 1e-10" {
    _ = gsl.gsl_set_error_handler_off();
    const quad = gsl.gsl_integration_workspace_alloc(1000);
    defer gsl.gsl_integration_workspace_free(quad);
    const small = [_]Complex{ cplx(1e-4, 0), cplx(1e-3, -5e-4), cplx(2e-2, -1e-2) };
    const large = [_]Complex{ cplx(0.3, 0), cplx(1.2, -0.15), cplx(3.9, 0) };
    inline for (.{ xb.XB_1PP, xb.XB_2PP }) |sector| {
        const params = baseline(sector);
        const model = try Model.init(params);
        defer model.deinit();
        const ws = try Workspace.init(model);
        defer ws.deinit();
        const energies = if (sector == xb.XB_1PP) [_]Complex{ cplx(-0.091, 0), cplx(-0.02, -0.01) } else [_]Complex{ cplx(-0.06, -0.005), cplx(-0.03, -0.01) };
        for (energies) |e| for (small) |s| for (large) |l| for ([_][2]Complex{ .{ s, l }, .{ l, s } }) |pq| {
            const worst = if (sector == xb.XB_1PP)
                try checkKernel(3, tables.spin_1pp, species_1pp, params, model, ws, quad, pq[0], pq[1], e)
            else
                try checkKernel(6, tables.spin_2pp, species_2pp, params, model, ws, quad, pq[0], pq[1], e);
            try expect(worst <= 1e-10);
        };
    }
}

test "2++ kernel: reciprocity at complex momenta, all entries, pi and eta" {
    const probes = [_][3]Complex{
        .{ cplx(0.35, -0.12), cplx(0.82, -0.05), cplx(-0.03, -0.008) },
        .{ cplx(1.7, -0.3), cplx(0.21, -0.08), cplx(-0.06, -0.002) },
        .{ cplx(0.05, -0.01), cplx(2.4, -0.2), cplx(-0.01, -0.01) },
        .{ cplx(0.6, -0.25), cplx(0.6, -0.1), cplx(0.02, -0.005) },
    };
    inline for (.{ xb.XB_1PP, xb.XB_2PP }) |sector| {
        const nc = if (sector == xb.XB_1PP) 3 else 6;
        const model = try Model.init(baseline(sector));
        defer model.deinit();
        const ws = try Workspace.init(model);
        defer ws.deinit();
        for (probes) |probe| {
            const p = probe[0];
            const q = probe[1];
            const e = probe[2];
            var forward: [2][nc * nc]xb.xb_cplx = undefined;
            var backward: [2][nc * nc]xb.xb_cplx = undefined;
            try ok(xb.xb_kernel(model.ptr, ws.ptr, .{ .re = p.re, .im = p.im }, .{ .re = q.re, .im = q.im }, .{ .re = e.re, .im = e.im }, nc * nc, &forward[0], &forward[1]));
            try ok(xb.xb_kernel(model.ptr, ws.ptr, .{ .re = q.re, .im = q.im }, .{ .re = p.re, .im = p.im }, .{ .re = e.re, .im = e.im }, nc * nc, &backward[0], &backward[1]));
            for (0..2) |phi| {
                var largest: f64 = 0;
                for (forward[phi]) |v| largest = @max(largest, cplx(v.re, v.im).magnitude());
                for (0..nc) |a| for (0..nc) |b| {
                    const x = forward[phi][a * nc + b];
                    const y = backward[phi][b * nc + a];
                    const diff = cplx(x.re - y.re, x.im - y.im).magnitude();
                    try expect(diff <= 4 * std.math.floatEps(f64) * largest);
                };
            }
        }
    }
}

/// Recoupling to the heavy basis |(s_H, (s_l L) j_l) J>: literature/Bruschini:2023zkb/bridge.md,
/// "Independent full HQSS rotation", columns in the canonical channel order.
const u_1pp = [3][3]f64{
    .{ 1, 0, 0 },
    .{ 0, -0.5, @sqrt(3.0) / 2.0 },
    .{ 0, @sqrt(3.0) / 2.0, 0.5 },
};
const u_2pp = [6][6]f64{
    .{ 0, 0, 1, 0, 0, 0 },
    .{ @sqrt(15.0) / 10.0, 3.0 * @sqrt(5.0) / 10.0, 0, -@sqrt(5.0) / 10.0, @sqrt(35.0) / 10.0, 0 },
    .{ -0.5, -@sqrt(3.0) / 6.0, 0, @sqrt(3.0) / 6.0, @sqrt(21.0) / 6.0, 0 },
    .{ @sqrt(35.0) / 10.0, -@sqrt(105.0) / 15.0, 0, -@sqrt(105.0) / 30.0, @sqrt(15.0) / 15.0, 0 },
    .{ 0, 0, 0, 0, 0, 1 },
    .{ 0.5, 0, 0, @sqrt(3.0) / 2.0, 0, 0 },
};
/// (s_H, j_l) of the heavy-basis rows of u_2pp.
const heavy2 = [6][2]u8{ .{ 1, 1 }, .{ 1, 1 }, .{ 1, 2 }, .{ 1, 3 }, .{ 1, 3 }, .{ 0, 2 } };

fn rotate(comptime n: usize, u: [n][n]f64, v: [n * n]xb.xb_cplx) [n][n]Complex {
    var out: [n][n]Complex = undefined;
    for (0..n) |i| for (0..n) |j| {
        var sum = cplx(0, 0);
        for (0..n) |a| for (0..n) |b| {
            sum = sum.add(cplx(v[a * n + b].re, v[a * n + b].im).mul(cplx(u[i][a] * u[j][b], 0)));
        };
        out[i][j] = sum;
    };
    return out;
}

test "strict HQSS limit: the j_l = 1 block of the 2++ kernel equals the 1++ kernel" {
    // GLOSSARY.md, "Strict HQSS limit": every heavy-meson mass m_bar = (m_B + 3 m_B*)/4.
    const m_bar: f64 = (5.27952 + 3 * 5.32475) / 4.0;
    var p1 = baseline(xb.XB_1PP);
    var p2 = baseline(xb.XB_2PP);
    for ([_]*xb.xb_params{ &p1, &p2 }) |p| {
        p.m_B = m_bar;
        p.m_Bstar = m_bar;
    }
    p1.mu_pv = m_bar / 2;
    const m1 = try Model.init(p1);
    defer m1.deinit();
    const m2 = try Model.init(p2);
    defer m2.deinit();
    const w1 = try Workspace.init(m1);
    defer w1.deinit();
    const w2 = try Workspace.init(m2);
    defer w2.deinit();
    // The probes of checks/hqss_2pp.py, then complex ones.
    const probes = [_][3]Complex{
        .{ cplx(0.043, 0), cplx(0.117, 0), cplx(-0.031, 0) },
        .{ cplx(0.139, 0), cplx(0.071, 0), cplx(-0.063, 0) },
        .{ cplx(0.091, 0), cplx(0.091, 0), cplx(-0.019, 0) },
        .{ cplx(0.3, -0.1), cplx(0.8, -0.05), cplx(-0.02, -0.01) },
        .{ cplx(1.9, -0.2), cplx(0.02, -0.01), cplx(-0.05, -0.003) },
    };
    for (probes) |probe| {
        const p: xb.xb_cplx = .{ .re = probe[0].re, .im = probe[0].im };
        const q: xb.xb_cplx = .{ .re = probe[1].re, .im = probe[1].im };
        const e: xb.xb_cplx = .{ .re = probe[2].re, .im = probe[2].im };
        var v1: [2][9]xb.xb_cplx = undefined;
        var v2: [2][36]xb.xb_cplx = undefined;
        try ok(xb.xb_kernel(m1.ptr, w1.ptr, p, q, e, 9, &v1[0], &v1[1]));
        try ok(xb.xb_kernel(m2.ptr, w2.ptr, p, q, e, 36, &v2[0], &v2[1]));
        for (0..2) |phi| {
            const h1 = rotate(3, u_1pp, v1[phi]);
            const h2 = rotate(6, u_2pp, v2[phi]);
            var largest: f64 = 1;
            for (v1[phi]) |x| largest = @max(largest, cplx(x.re, x.im).magnitude());
            for (v2[phi]) |x| largest = @max(largest, cplx(x.re, x.im).magnitude());
            // checks/hqss_2pp.py: 2e-10 max(1, |V_2|, |V_1|) GeV^-2, frozen before the derivation.
            const tolerance = 2e-10 * largest;
            for (0..6) |i| for (0..6) |j| {
                const same = heavy2[i][0] == heavy2[j][0] and heavy2[i][1] == heavy2[j][1];
                if (!same) try expect(h2[i][j].magnitude() <= tolerance);
            };
            for (0..2) |i| {
                try expect(h1[i][2].magnitude() <= tolerance and h1[2][i].magnitude() <= tolerance);
                for (0..2) |j| try expect(h2[i][j].sub(h1[i][j]).magnitude() <= tolerance);
            }
        }
    }
}

/// The 2++ thresholds (BB, BB*, B*B*) relative to 2 m_B* and their reduced masses, from the
/// meson masses (note 07, S2).
fn thresholds(params: xb.xb_params) struct { delta: [3]f64, mu: [3]f64 } {
    const dm = params.m_Bstar - params.m_B;
    return .{
        .delta = .{ -2 * dm, -dm, 0 },
        .mu = .{ params.m_B / 2, params.m_B * params.m_Bstar / (params.m_B + params.m_Bstar), params.m_Bstar / 2 },
    };
}

/// One sign per threshold, flipped = -1, ordered (BB, BB*, B*B*).
fn sheetOf(flip: [3]bool) xb.xb_sheet {
    return .{ .pp = if (flip[0]) -1 else 1, .pv = if (flip[1]) -1 else 1, .vv = if (flip[2]) -1 else 1 };
}

/// The closed-fourth-quadrant root of 2 mu (E - delta), the limit from below on the real axis.
fn principal(e: Complex, delta: f64, mu: f64) Complex {
    return std.math.complex.sqrt(cplx(2 * mu * (e.re - delta), if (e.im == 0) -0.0 else 2 * mu * e.im));
}

/// 2 mu [Lambda + k^2 I_sigma(k)] with I_sigma(k) = [Log((Lambda - k)/(Lambda + k)) + sigma i pi]/(2k):
/// the free loop on [0, Lambda] continued to the sheet on which the threshold is flipped
/// (sigma = +) or not (sigma = -).
fn closedLoop(e: Complex, delta: f64, mu: f64, flipped: bool, lambda: f64) Complex {
    const k = principal(e, delta, mu);
    if (k.re == 0 and k.im == 0) return cplx(2 * mu * lambda, 0);
    const cutoff = cplx(lambda, 0);
    const log = std.math.complex.log(cutoff.sub(k).div(cutoff.add(k)));
    const integral = log.add(cplx(0, if (flipped) std.math.pi else -std.math.pi)).div(k.mul(cplx(2, 0)));
    return cplx(2 * mu, 0).mul(cutoff.add(k.mul(k).mul(integral)));
}

const Probe = struct { e: Complex, flip: [3]bool };

/// The Stage 3 SP probes of checks/_rank_one_sp.jl (r1sp_probes), flips ordered (BB, BB*, B*B*):
/// Im E = -10 MeV at Re E = -88 to +45 MeV, Im E = -1, -10, -50 MeV at Re E = -67.85 and
/// -22.62 MeV, and every threshold's real part at Im E = -10 MeV, on their adjacent sheets;
/// the other adjacent sheet at each threshold; channels flipped 1-3 MeV below their thresholds.
fn stage3Probes(delta: [3]f64, buffer: []Probe) []Probe {
    var energies: [150]Complex = undefined;
    var n: usize = 0;
    var x: f64 = -88;
    while (x <= 45) : (x += 1) {
        energies[n] = cplx(x / 1000, -0.010);
        n += 1;
    }
    for ([_]f64{ -67.85, -22.62 }) |re| for ([_]f64{ 1, 10, 50 }) |y| {
        energies[n] = cplx(re / 1000, -y / 1000);
        n += 1;
    };
    for (delta) |d| {
        const e = cplx(d, -0.010);
        for (energies[0..n]) |seen| {
            if (seen.re == e.re and seen.im == e.im) break;
        } else {
            energies[n] = e;
            n += 1;
        }
    }
    var count: usize = 0;
    for (energies[0..n]) |e| {
        var flip: [3]bool = undefined;
        for (&flip, delta) |*f, d| f.* = d < e.re;
        buffer[count] = .{ .e = e, .flip = flip };
        count += 1;
        for (0..3) |s| if (e.re == delta[s]) {
            var other = flip;
            other[s] = !other[s];
            buffer[count] = .{ .e = e, .flip = other };
            count += 1;
        };
    }
    const Extra = struct { flip: [3]bool, re: []const f64 };
    const extras = [_]Extra{
        .{ .flip = .{ true, true, false }, .re = &.{ 1, 3, -46, -48 } },
        .{ .flip = .{ true, true, true }, .re = &.{ -1, -3 } },
        .{ .flip = .{ true, false, false }, .re = &.{ -44, -42, -91, -93 } },
    };
    for (extras) |set| for (set.re) |re| for ([_]f64{ 10, 2 }) |y| {
        buffer[count] = .{ .e = cplx(re / 1000, -y / 1000), .flip = set.flip };
        count += 1;
    };
    return buffer[0..count];
}

/// The worst relative error of the free loops against closedLoop at a probe, on the certified
/// 1 x 1 MeV rectangle centred on it (checks/rank_one_sp.jl).
fn probeLoopError(model: Model, plan: Plan, params: xb.xb_params, probe: Probe) !f64 {
    const th = thresholds(params);
    const rect: xb.xb_rect = .{ .re_lo = probe.e.re - 0.0005, .re_hi = probe.e.re + 0.0005, .im_lo = probe.e.im - 0.0005, .im_hi = probe.e.im + 0.0005 };
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, sheetOf(probe.flip), xb.XB_PATH_S40, plan.ptr(), &cert));
    try expect(cert.failed == 0);
    var loop: [6]xb.xb_cplx = undefined;
    try ok(xb.xb_loop(model.ptr, plan.ptr(), .{ .re = probe.e.re, .im = probe.e.im }, 6, &loop));
    var worst: f64 = 0;
    for (loop, species_2pp) |value, species| {
        const t = @backingInt(species);
        const closed = closedLoop(probe.e, th.delta[t], th.mu[t], probe.flip[t], params.cutoff);
        worst = @max(worst, cplx(value.re, value.im).sub(closed).magnitude() / closed.magnitude());
    }
    return worst;
}

test "on-shell nodes: on every sheet the free loop of each channel matches its closed form" {
    const params = baseline(xb.XB_2PP);
    const model = try Model.init(params);
    defer model.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    var buffer: [200]Probe = undefined;
    const probes = stage3Probes(thresholds(params).delta, &buffer);
    try expect(probes.len == 165);
    var worst: f64 = 0;
    for (probes) |probe| worst = @max(worst, try probeLoopError(model, plan, params, probe));
    // Above the B*B* threshold all nodes are mandatory on every sheet; the signs enter
    // through sigma, independently of the contour.
    for ([_]f64{ 1, 20, 45 }) |re| for (0..8) |bits| {
        const flip = [3]bool{ bits & 1 != 0, bits & 2 != 0, bits & 4 != 0 };
        worst = @max(worst, try probeLoopError(model, plan, params, .{ .e = cplx(re / 1000, -0.010), .flip = flip }));
    };
    // The reference's quadrature level on the Stage 3 probes and rule (checks/rank_one_sp.jl).
    try expect(worst <= 5e-14);
}

/// xb_certify on the S40 path for a rectangle given in MeV.
fn certifyMeV(model: Model, plan: Plan, re: [2]f64, im: [2]f64, flip: [3]bool) !xb.xb_cert {
    const rect: xb.xb_rect = .{ .re_lo = re[0] / 1000, .re_hi = re[1] / 1000, .im_lo = im[0] / 1000, .im_hi = im[1] / 1000 };
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, sheetOf(flip), xb.XB_PATH_S40, plan.ptr(), &cert));
    return cert;
}

test "certificate: use the real path when certified, bend for the kernel, and reject a mandatory node cut" {
    const model = try Model.init(baseline(xb.XB_2PP));
    defer model.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    // notes/07-continued-lse/cert_conditions.jl; (-,-,+) flips BB and BB*, (-,+,+) flips BB.
    const a = try certifyMeV(model, plan, .{ -25, -20 }, .{ -10, -5 }, .{ true, true, false });
    try expect(a.failed == 0 and a.node[0] == 1 and a.node[1] == 1 and a.node[2] == 0);
    try std.testing.expectEqual(0.0, a.depth);
    var bent: xb.xb_cert = undefined;
    const r = fixtures.bb_kernel_box;
    try ok(xb.xb_certify(model.ptr, r, fixtures.bb_sheet, xb.XB_PATH_S40, plan.ptr(), &bent));
    try expect(bent.failed == 0 and bent.node[0] == 1 and bent.node[1] == 0 and bent.node[2] == 0);
    const params = baseline(xb.XB_2PP);
    const th = thresholds(params);
    const bottom = principal(cplx(r.re_lo, r.im_lo), th.delta[0], th.mu[0]);
    const centre = principal(cplx((r.re_lo + r.re_hi) / 2, (r.im_lo + r.im_hi) / 2), th.delta[0], th.mu[0]);
    // The real path cannot meet the pion window at the bottom, but the bend need not reach k.
    try expect(-bottom.im > params.m_pi and bent.depth > 0 and bent.depth < -centre.im);
    std.debug.print("S40: BB kernel-window test depth {d:.3} MeV (centre pole depth {d:.3} MeV)\n", .{
        bent.depth * 1000, -centre.im * 1000,
    });
    const bd = try certifyMeV(model, plan, .{ -46.70, -46.60 }, .{ -0.40, -0.30 }, .{ true, false, false });
    try expect(bd.failed == 0 and bd.node[0] == 1 and bd.node[1] == 0 and bd.dropped[1] == 5);
    const f5 = try certifyMeV(model, plan, .{ -46.6, -46.4 }, .{ -0.2, -0.1 }, .{ true, true, false });
    // s40-proposal.tex, (C5): Re Z = -34.7 MeV at the BB* node-node pair; its bound lies below.
    try expect(f5.failed == 5 and f5.depth == 0 and f5.margin[4] * 1000 <= -34.7 and f5.margin[4] * 1000 >= -35.7);
}

/// A coverage check, not a census of the reference polygon's subdivisions.
const Tiling = struct { flat: usize = 0, bent: usize = 0, excluded: usize = 0 };

/// The reference's tile_rectangles (sp_contours.jl): a cell that fails is quartered at its
/// centre until its longer side falls below the floor.
fn tile(model: Model, plan: Plan, rect: xb.xb_rect, sheet: xb.xb_sheet, floor: f64, tiling: *Tiling) anyerror!void {
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, sheet, xb.XB_PATH_S40, plan.ptr(), &cert));
    if (cert.failed == 0) {
        if (cert.depth == 0) {
            tiling.flat += 1;
        } else {
            tiling.bent += 1;
        }
    } else if (@max(rect.re_hi - rect.re_lo, rect.im_hi - rect.im_lo) < floor) {
        tiling.excluded += 1;
    } else {
        const x = (rect.re_lo + rect.re_hi) / 2;
        const y = (rect.im_lo + rect.im_hi) / 2;
        for ([_][2]f64{ .{ rect.re_lo, x }, .{ x, rect.re_hi } }) |re| for ([_][2]f64{ .{ rect.im_lo, y }, .{ y, rect.im_hi } }) |im| {
            try tile(model, plan, .{ .re_lo = re[0], .re_hi = re[1], .im_lo = im[0], .im_hi = im[1] }, sheet, floor, tiling);
        };
    }
}

/// Grid line i of n equal steps from lo to hi, both ends exact.
fn gridLine(lo: f64, hi: f64, n: usize, i: usize) f64 {
    if (i == n) return hi;
    return lo + @as(f64, @floatFromInt(i)) * ((hi - lo) / @as(f64, @floatFromInt(n)));
}

test "certificate: real-path-first covers both Stage 4 search strips" {
    const params = baseline(xb.XB_2PP);
    const model = try Model.init(params);
    defer model.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    const th = thresholds(params);
    // The Stage 4 domain and initial 10 x 2 grid, at the same 0.1 MeV floor.
    const regions = [_]struct { flip: [3]bool, re: [2]f64 }{
        .{ .flip = .{ true, false, false }, .re = .{ th.delta[0], th.delta[1] } },
        .{ .flip = .{ true, true, false }, .re = .{ th.delta[1], th.delta[2] } },
    };
    for (regions) |region| {
        var tiling: Tiling = .{};
        for (0..10) |i| for (0..2) |j| {
            const rect: xb.xb_rect = .{ .re_lo = gridLine(region.re[0], region.re[1], 10, i), .re_hi = gridLine(region.re[0], region.re[1], 10, i + 1), .im_lo = gridLine(-0.010, 0, 2, j), .im_hi = gridLine(-0.010, 0, 2, j + 1) };
            try tile(model, plan, rect, sheetOf(region.flip), 1e-4, &tiling);
        };
        try expect(tiling.excluded == 0 and tiling.flat > 0 and tiling.bent > 0);
        std.debug.print("S40 strip {d} to {d} MeV: {d} flat, {d} bent, {d} excluded\n", .{
            1000 * region.re[0], 1000 * region.re[1], tiling.flat, tiling.bent, tiling.excluded,
        });
    }
}

/// Gauss–Legendre nodes and weights of n points on [-1, 1], from GSL.
fn gaussLegendre(comptime n: usize) ![2][n]f64 {
    const table = gsl.gsl_integration_glfixed_table_alloc(n);
    if (table == null) return error.OutOfMemory;
    defer gsl.gsl_integration_glfixed_table_free(table);
    var rule: [2][n]f64 = undefined;
    for (0..n) |i| {
        if (gsl.gsl_integration_glfixed_point(-1, 1, i, &rule[0][i], &rule[1][i], table) != gsl.GSL_SUCCESS) return error.Quadrature;
    }
    return rule;
}

/// D~ from its logarithm, scaled by exp(-shift).
fn detValue(ld: xb.xb_cplx, shift: f64) Complex {
    const size = @exp(ld.re - shift);
    return cplx(size * @cos(ld.im), size * @sin(ld.im));
}

fn logDet(model: Model, ws: Workspace, plan: Plan, e: Complex) !xb.xb_cplx {
    var ld: xb.xb_cplx = undefined;
    try ok(xb.xb_det(model.ptr, ws.ptr, plan.ptr(), .{ .re = e.re, .im = e.im }, &ld, 0, null));
    return ld;
}

/// The integral of D~ exp(-shift) counterclockwise around the rectangle by n-point
/// Gauss–Legendre on each side, and the largest |D~| exp(-shift) among the samples.
fn contourIntegral(comptime n: usize, model: Model, ws: Workspace, plan: Plan, rect: xb.xb_rect, shift: f64) !struct { integral: Complex, largest: f64 } {
    const rule = try gaussLegendre(n);
    const corners = [4]Complex{ cplx(rect.re_lo, rect.im_lo), cplx(rect.re_hi, rect.im_lo), cplx(rect.re_hi, rect.im_hi), cplx(rect.re_lo, rect.im_hi) };
    var integral = cplx(0, 0);
    var largest: f64 = 0;
    for (0..4) |side| {
        const a = corners[side];
        const half = corners[(side + 1) % 4].sub(a).mul(cplx(0.5, 0));
        for (rule[0], rule[1]) |x, w| {
            const d = detValue(try logDet(model, ws, plan, a.add(half.mul(cplx(x + 1, 0)))), shift);
            integral = integral.add(d.mul(half).mul(cplx(w, 0)));
            largest = @max(largest, d.magnitude());
        }
    }
    return .{ .integral = integral, .largest = largest };
}

/// In this fixture BB is the only mandatory node and its bend is in the first half of [0, Λ].
/// The steeper leg is the first, so the reported depth and slope locate the single corner.
fn bbKernelTestPath(cert: xb.xb_cert, cutoff: f64) ![3]Complex {
    try expect(cert.depth > 0 and cert.slope > 0);
    return .{ cplx(0, 0), cplx(cert.depth / cert.slope, -cert.depth), cplx(cutoff, 0) };
}

/// The height of the graph path through the vertices at Re q = x.
fn pathHeight(vertices: []const Complex, x: f64) f64 {
    var j: usize = 0;
    while (j + 2 < vertices.len and vertices[j + 1].re <= x) j += 1;
    const a = vertices[j];
    const b = vertices[j + 1];
    return a.im + (x - a.re) * (b.im - a.im) / (b.re - a.re);
}

test "Cauchy: D~ integrates to zero around a certified rectangle in which a flipped pole crosses the path" {
    var params = baseline(xb.XB_2PP);
    // D~ is analytic on a certified rectangle for every rule; a coarse one keeps the 64
    // evaluations short.
    params.panel_nodes = 8;
    params.panel_length = 0.5;
    const model = try Model.init(params);
    defer model.deinit();
    const ws = try Workspace.init(model);
    defer ws.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    const rect = fixtures.bb_kernel_box;
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, fixtures.bb_sheet, xb.XB_PATH_S40, plan.ptr(), &cert));
    try expect(cert.failed == 0 and cert.node[0] == 1 and cert.node[1] == 0 and cert.node[2] == 0);
    // The BB pole is below the selected contour at the bottom and above it at the top.
    const th = thresholds(params);
    const centre = cplx((rect.re_lo + rect.re_hi) / 2, (rect.im_lo + rect.im_hi) / 2);
    const vertices = try bbKernelTestPath(cert, params.cutoff);
    var sides: [2]f64 = undefined;
    for (&sides, [_]f64{ rect.im_lo, rect.im_hi }) |*side, im| {
        const k = principal(cplx(centre.re, im), th.delta[0], th.mu[0]);
        side.* = k.im - pathHeight(&vertices, k.re);
    }
    try expect(sides[0] * sides[1] < 0);
    const shift = (try logDet(model, ws, plan, centre)).re;
    const result = try contourIntegral(16, model, ws, plan, rect, shift);
    const perimeter = 2 * ((rect.re_hi - rect.re_lo) + (rect.im_hi - rect.im_lo));
    // Provisional: the bar of the reference's S40 Cauchy test (code/Xb2Continuation/test/sp_contours.jl).
    try expect(result.integral.magnitude() <= 1e-10 * result.largest * perimeter);
}

/// log D~ at e on the 1 x 1 MeV rectangle centred on it, certified for the path family.
fn probeLogDet(model: Model, ws: Workspace, plan: Plan, probe: Probe, path: xb.enum_xb_path) !xb.xb_cplx {
    const e = probe.e;
    const rect: xb.xb_rect = .{ .re_lo = e.re - 0.0005, .re_hi = e.re + 0.0005, .im_lo = e.im - 0.0005, .im_hi = e.im + 0.0005 };
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, sheetOf(probe.flip), path, plan.ptr(), &cert));
    try expect(cert.failed == 0);
    return logDet(model, ws, plan, e);
}

test "path independence: D~ on the S40 plan and on the margin-path plan agree at probe energies" {
    // The two recorded Stage 3 regions, followed by a BB probe where the kernel needs a bend.
    const probes = [_]Probe{
        .{ .e = cplx(-0.06785, -0.010), .flip = .{ true, false, false } },
        .{ .e = cplx(-0.02262, -0.010), .flip = .{ true, true, false } },
        .{ .e = cplx(-0.07746, -0.016), .flip = .{ true, false, false } },
    };
    // Both plans on the production rule and with their nodes doubled; the margin path at
    // d_k = 100 MeV, since its quadrature error falls with d_k / L_p.
    var ld: [2][2][probes.len]xb.xb_cplx = undefined; // [rule][S40, margin][probe]
    for ([_]i32{ 16, 32 }, 0..) |nodes, r| {
        var params = baseline(xb.XB_2PP);
        params.panel_nodes = nodes;
        params.pole_margin = 0.1;
        const model = try Model.init(params);
        defer model.deinit();
        const ws = try Workspace.init(model);
        defer ws.deinit();
        const plan = try Plan.init(model);
        defer plan.deinit();
        for (probes, 0..) |probe, i| {
            ld[r][0][i] = try probeLogDet(model, ws, plan, probe, xb.XB_PATH_S40);
            ld[r][1][i] = try probeLogDet(model, ws, plan, probe, xb.XB_PATH_MARGIN);
        }
    }
    for (0..probes.len) |i| {
        // D~ relative to its S40 value on the production rule.
        const shift = ld[0][0][i].re;
        const s40 = detValue(ld[0][0][i], shift);
        const margin = detValue(ld[0][1][i], shift);
        const estimate = s40.sub(detValue(ld[1][0][i], shift)).magnitude() + margin.sub(detValue(ld[1][1][i], shift)).magnitude();
        // Provisional, the rule of the reference's S40 path-independence test
        // (code/Xb2Continuation/test/sp_contours.jl): four times the doubling estimate of both
        // plans, plus a rounding allowance.
        try expect(s40.sub(margin).magnitude() <= 4 * estimate + 1e-12);
    }
}

test "margin path: a rectangle may end at a threshold line away from the real axis" {
    const params = baseline(xb.XB_2PP);
    const model = try Model.init(params);
    defer model.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    const pv = thresholds(params).delta[1];
    const rect: xb.xb_rect = .{ .re_lo = pv - 0.001, .re_hi = pv, .im_lo = -0.0101, .im_hi = -0.0099 };
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, sheetOf(.{ true, false, false }), xb.XB_PATH_MARGIN, plan.ptr(), &cert));
    try expect(cert.failed == 0 and cert.margin[2] >= params.pole_margin);
    try ok(xb.xb_certify(model.ptr, rect, physical, xb.XB_PATH_MARGIN, plan.ptr(), &cert));
    try expect(cert.failed == 3); // The margin contour would continue across the open PP cut.
}

/// The path nodes of note 07, S40(b): the fewest equal panels no longer than L_p per segment,
/// np Gauss–Legendre nodes each. Returns their number.
fn pathNodes(comptime np: usize, vertices: []const Complex, panel_length: f64, nodes: []Complex) !usize {
    const rule = try gaussLegendre(np);
    var count: usize = 0;
    for (vertices[0 .. vertices.len - 1], vertices[1..]) |a, b| {
        const panels = @max(1, @ceil(b.sub(a).magnitude() / panel_length));
        const step = b.sub(a).mul(cplx(1 / panels, 0));
        var p: f64 = 0;
        while (p < panels) : (p += 1) for (rule[0]) |x| {
            nodes[count] = a.add(step.mul(cplx(p, 0))).add(step.mul(cplx((x + 1) / 2, 0)));
            count += 1;
        };
    }
    return count;
}

/// The mean of D~ exp(-shift) over m points of the circle of radius r about e.
fn circleMean(comptime m: usize, model: Model, ws: Workspace, plan: Plan, e: Complex, r: f64, shift: f64) !Complex {
    var sum = cplx(0, 0);
    for (0..m) |i| {
        const t = 2 * std.math.pi * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(m));
        sum = sum.add(detValue(try logDet(model, ws, plan, e.add(cplx(r * @cos(t), r * @sin(t)))), shift));
    }
    return sum.mul(cplx(1 / @as(f64, @floatFromInt(m)), 0));
}

test "removable 0/0: where a node momentum meets a path node, D~ equals its mean on a circle about that energy" {
    var params = baseline(xb.XB_2PP);
    params.panel_nodes = 8;
    params.panel_length = 0.5;
    const model = try Model.init(params);
    defer model.deinit();
    const ws = try Workspace.init(model);
    defer ws.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    const rect = fixtures.bb_kernel_box;
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, fixtures.bb_sheet, xb.XB_PATH_S40, plan.ptr(), &cert));
    try expect(cert.failed == 0);
    const th = thresholds(params);
    const vertices = try bbKernelTestPath(cert, params.cutoff);
    var nodes: [200]Complex = undefined;
    const count = try pathNodes(8, &vertices, params.panel_length, &nodes);
    try expect(count == cert.n_path);
    // Use the path node nearest the bend; its BB collision energy is in the box.
    var j: usize = 0;
    for (nodes[0..count], 0..) |q, i| {
        if (q.sub(vertices[1]).magnitude() < nodes[j].sub(vertices[1]).magnitude()) j = i;
    }
    const q = nodes[j];
    const s = @min(nodes[j + 1].sub(q).magnitude(), q.sub(nodes[j - 1]).magnitude());
    const normal = nodes[j + 1].sub(q).mul(cplx(0, 1 / nodes[j + 1].sub(q).magnitude()));
    // At the node itself, and so close that direct LU loses digits (SPEC.md, Removable 0/0).
    for ([_]f64{ 0, 1e-9 * q.magnitude() }) |offset| {
        const k = q.add(normal.mul(cplx(offset, 0)));
        const e = cplx(th.delta[0], 0).add(k.mul(k).mul(cplx(1 / (2 * th.mu[0]), 0)));
        const ld = try logDet(model, ws, plan, e);
        // A circle of radius s/8 in the k plane, whose points stay clear of every path node.
        const mean = try circleMean(16, model, ws, plan, e, s / 8 * k.magnitude() / th.mu[0], ld.re);
        try expect(detValue(ld, ld.re).sub(mean).magnitude() <= 1e-10 * mean.magnitude());
    }
}

/// Contact-only closed form of note 07, S44, plus one decoupled bare energy.
/// With C in the VV S wave only: T_SS = C/(1+CJ), Jhat_CC = J, D~ = (E-eps)(1+CJ).
fn checkContactHit(params: xb.xb_params, rect: xb.xb_rect, flip: [3]bool, e: Complex, tolerance: f64) !void {
    const model = try Model.init(params);
    defer model.deinit();
    const ws = try Workspace.init(model);
    defer ws.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    const th = thresholds(params);
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, sheetOf(flip), xb.XB_PATH_S40, plan.ptr(), &cert));
    errdefer std.debug.print("contact collision E=({d}, {d}), cutoff={d}, certificate={any}\n", .{
        e.re, e.im, params.cutoff, cert,
    });
    try expect(cert.failed == 0 and cert.node[2] == 1);
    const energy: xb.xb_cplx = .{ .re = e.re, .im = e.im };
    var t: [36]xb.xb_cplx = undefined;
    var jhat: [4]xb.xb_cplx = undefined;
    var loops: [6]xb.xb_cplx = undefined;
    var ld: xb.xb_cplx = undefined;
    var info: xb.xb_info = undefined;
    try ok(xb.xb_det(model.ptr, ws.ptr, plan.ptr(), energy, &ld, t.len, &t));
    try ok(xb.xb_jhat(model.ptr, ws.ptr, plan.ptr(), energy, jhat.len, &jhat));
    try ok(xb.xb_loop(model.ptr, plan.ptr(), energy, loops.len, &loops));
    try ok(xb.xb_model_info(model.ptr, &info));
    for (loops, species_2pp) |value, species| {
        const s = @backingInt(species);
        try expect(cert.node[s] == 1);
        const want = closedLoop(e, th.delta[s], th.mu[s], flip[s], params.cutoff);
        try std.testing.expectApproxEqAbs(0.0, cplx(value.re, value.im).sub(want).magnitude() / want.magnitude(), 5e-14);
    }
    const j = closedLoop(e, th.delta[2], th.mu[2], flip[2], params.cutoff).mul(cplx(1.0 / (2 * std.math.pi * std.math.pi), 0));
    const c = cplx(params.contact, 0);
    const d = cplx(1, 0).add(c.mul(j));
    const want_t = c.div(d);
    const want_det = e.sub(cplx(info.bare[0].energy, 0)).mul(d);
    const det_error = detValue(ld, 0).sub(want_det).magnitude() / want_det.magnitude();
    const j_error = cplx(jhat[3].re, jhat[3].im).sub(j).magnitude() / j.magnitude();
    errdefer std.debug.print("contact collision relative errors: D~={d}, Jhat={d}\n", .{ det_error, j_error });
    try std.testing.expectApproxEqAbs(0.0, det_error, tolerance);
    try std.testing.expectApproxEqAbs(0.0, j_error, tolerance);
    for (t, 0..) |value, i| {
        const want = if (i == 2 * 6 + 2) want_t else cplx(0, 0);
        try std.testing.expectApproxEqAbs(0.0, cplx(value.re, value.im).sub(want).magnitude() / want_t.magnitude(), tolerance);
    }
}

test "removable 0/0: contact-only amplitudes and determinant match the closed form at node collisions" {
    var params = baseline(xb.XB_2PP);
    params.panel_nodes = 8;
    params.panel_length = 0.5;
    params.n_bare = 1;
    params.g = 0;
    params.g_b = 0;
    params.contact = 1;
    const th = thresholds(params);
    const rule = try gaussLegendre(8);
    // A VV collision with one of the nodes of the first real panel [0, 0.5].
    const q = params.panel_length * (1 + rule[0][4]) / 2;
    try checkContactHit(params, .{ .re_lo = 0.016, .re_hi = 0.024, .im_lo = -0.003, .im_hi = 0 },
        .{ true, true, true }, cplx(q * q / (2 * th.mu[2]), 0), 1e-10);

    // Put the last real quadrature node at k_PP(0). Use short panels so the
    // stencil that clears this hit stays local to the VV threshold.
    const k_pp = @sqrt(-2 * th.mu[0] * th.delta[0]);
    const last = (1 + rule[0][7]) / 2;
    const panels = 40;
    params.cutoff = panels * k_pp / (panels - 1 + last);
    params.panel_length = params.cutoff / (panels - 0.5);
    try checkContactHit(params, .{ .re_lo = -0.0007, .re_hi = 0, .im_lo = -1e-12, .im_hi = 0 },
        .{ true, true, false }, cplx(0, 0), 1e-8);

    // In the degenerate-mass toy every threshold is at E=0. Put the one real Gauss node
    // at k(scale), so a narrow rectangle still has room for the removable-hit stencil.
    const scale: f64 = 0x1p-44;
    params.panel_nodes = 1;
    params.m_B = params.m_Bstar;
    params.cutoff = 2 * @sqrt(params.m_Bstar * scale);
    try checkContactHit(params, .{ .re_lo = scale / 8, .re_hi = 15 * scale / 8, .im_lo = -scale, .im_hi = 0 },
        .{ true, true, true }, cplx(scale, 0), 1e-10);
}

test "determinant: an exact zero pivot at a decoupled bare energy returns zero, not a GSL error" {
    var params = baseline(xb.XB_2PP);
    params.n_bare = 2;
    params.panel_nodes = 1;
    params.panel_length = params.cutoff;
    params.contact = 0;
    params.g = 0;
    params.g_b = 0;
    const model = try Model.init(params);
    defer model.deinit();
    const ws = try Workspace.init(model);
    defer ws.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    var info: xb.xb_info = undefined;
    try ok(xb.xb_model_info(model.ptr, &info));
    const bare = info.bare[1].energy;
    const rect: xb.xb_rect = .{ .re_lo = bare - 0.001, .re_hi = bare + 0.001, .im_lo = -0.001, .im_hi = 0.001 };
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, physical, xb.XB_PATH_S40, plan.ptr(), &cert));
    try expect(cert.failed == 0);
    const ld = try logDet(model, ws, plan, cplx(bare, 0));
    try expect(ld.re == -std.math.inf(f64) and ld.im == 0);
}

/// The determinant of a small complex matrix by Gaussian elimination with partial pivoting.
fn smallDet(comptime n: usize, matrix: [n][n]Complex) Complex {
    var a = matrix;
    var det = cplx(1, 0);
    for (0..n) |k| {
        var p = k;
        for (k + 1..n) |i| {
            if (a[i][k].magnitude() > a[p][k].magnitude()) p = i;
        }
        if (p != k) {
            const row = a[p];
            a[p] = a[k];
            a[k] = row;
            det = det.neg();
        }
        if (a[k][k].magnitude() == 0) return cplx(0, 0);
        det = det.mul(a[k][k]);
        for (k + 1..n) |i| {
            const f = a[i][k].div(a[k][k]);
            for (k..n) |j| a[i][j] = a[i][j].sub(f.mul(a[k][j]));
        }
    }
    return det;
}

test "factorisation: D~ equals D~(OME) det(1 + v^ J^) away from the bare energies" {
    const Case = struct { sector: xb.enum_xb_sector, probe: Probe };
    const cases = [_]Case{
        // 2++ on (-,+,+) with the BB node; on (-,-,-) with every node, the S-wave channel's among them.
        .{ .sector = xb.XB_2PP, .probe = .{ .e = cplx(-0.06785, -0.010), .flip = .{ true, false, false } } },
        .{ .sector = xb.XB_2PP, .probe = .{ .e = cplx(0.020, -0.010), .flip = .{ true, true, true } } },
        // 1++ above the BB* threshold, its node on the S-wave channel.
        .{ .sector = xb.XB_1PP, .probe = .{ .e = cplx(0.020, -0.010), .flip = .{ false, true, false } } },
    };
    for (cases) |case| {
        var params = baseline(case.sector);
        // The identity holds on every rule; a coarse one keeps the case short.
        params.panel_nodes = 8;
        params.panel_length = 0.5;
        var ome = params; // the OME-only model of SPEC.md, test 11
        ome.g = 0;
        ome.contact = 0;
        const full_model = try Model.init(params);
        defer full_model.deinit();
        const full_ws = try Workspace.init(full_model);
        defer full_ws.deinit();
        const full_plan = try Plan.init(full_model);
        defer full_plan.deinit();
        const ome_model = try Model.init(ome);
        defer ome_model.deinit();
        const ome_ws = try Workspace.init(ome_model);
        defer ome_ws.deinit();
        const ome_plan = try Plan.init(ome_model);
        defer ome_plan.deinit();
        const e = case.probe.e;
        const ld = try probeLogDet(full_model, full_ws, full_plan, case.probe, xb.XB_PATH_S40);
        const ld_ome = try probeLogDet(ome_model, ome_ws, ome_plan, case.probe, xb.XB_PATH_S40);
        var jhat: [25]xb.xb_cplx = undefined;
        try ok(xb.xb_jhat(full_model.ptr, full_ws.ptr, full_plan.ptr(), .{ .re = e.re, .im = e.im }, 25, &jhat));
        var info: xb.xb_info = undefined;
        try ok(xb.xb_model_info(full_model.ptr, &info));
        // 1 + v^ J^ with v^ = diag(g^2 / (E - epsilon_n), C) (note 07, S10).
        var m: [5][5]Complex = undefined;
        for (0..5) |r| for (0..5) |c| {
            const v = if (r < 4) cplx(params.g * params.g, 0).div(e.sub(cplx(info.bare[r].energy, 0))) else cplx(params.contact, 0);
            m[r][c] = v.mul(cplx(jhat[r * 5 + c].re, jhat[r * 5 + c].im)).add(cplx(if (r == c) 1 else 0, 0));
        };
        const det = smallDet(5, m);
        const ratio = detValue(.{ .re = ld.re - ld_ome.re, .im = ld.im - ld_ome.im }, 0);
        // Provisional: an algebraic identity on one rule, so rounding alone; the bar leaves room
        // for the conditioning of two LU factorisations.
        try expect(ratio.sub(det).magnitude() <= 1e-10 * det.magnitude());
    }
}

/// The inverse of the leading n x n block of a, by Gauss–Jordan elimination with partial pivoting.
fn invert(n: usize, a: [6][6]Complex) ![6][6]Complex {
    var m = a;
    var inv: [6][6]Complex = undefined;
    for (0..n) |i| for (0..n) |j| {
        inv[i][j] = cplx(if (i == j) 1 else 0, 0);
    };
    for (0..n) |k| {
        var p = k;
        for (k + 1..n) |i| {
            if (m[i][k].magnitude() > m[p][k].magnitude()) p = i;
        }
        if (m[p][k].magnitude() == 0) return error.Singular;
        std.mem.swap([6]Complex, &m[p], &m[k]);
        std.mem.swap([6]Complex, &inv[p], &inv[k]);
        const pivot = m[k][k];
        for (0..n) |j| {
            m[k][j] = m[k][j].div(pivot);
            inv[k][j] = inv[k][j].div(pivot);
        }
        for (0..n) |i| if (i != k) {
            const f = m[i][k];
            for (0..n) |j| {
                m[i][j] = m[i][j].sub(f.mul(m[k][j]));
                inv[i][j] = inv[i][j].sub(f.mul(inv[k][j]));
            }
        };
    }
    return inv;
}

/// The on-shell T at e between the node channels of the plan certified for the rectangle,
/// compressed to those channels: their indices and the block.
fn onshellT(model: Model, ws: Workspace, plan: Plan, rect: xb.xb_rect, flip: [3]bool, e: Complex) !struct { n: usize, channel: [6]usize, t: [6][6]Complex, log_det: xb.xb_cplx } {
    var cert: xb.xb_cert = undefined;
    try ok(xb.xb_certify(model.ptr, rect, sheetOf(flip), xb.XB_PATH_S40, plan.ptr(), &cert));
    try expect(cert.failed == 0);
    var ld: xb.xb_cplx = undefined;
    var t: [36]xb.xb_cplx = undefined;
    try ok(xb.xb_det(model.ptr, ws.ptr, plan.ptr(), .{ .re = e.re, .im = e.im }, &ld, 36, &t));
    var out: [6][6]Complex = undefined;
    var channel: [6]usize = undefined;
    var n: usize = 0;
    for (0..6) |r| {
        const row_node = cert.node[@backingInt(species_2pp[r])] != 0;
        if (row_node) {
            channel[n] = r;
            n += 1;
        }
        for (0..6) |c| {
            const value = t[r * 6 + c];
            if (row_node and cert.node[@backingInt(species_2pp[c])] != 0) {
                try expect(std.math.isFinite(value.re) and std.math.isFinite(value.im));
            } else {
                try expect(std.math.isNan(value.re) and std.math.isNan(value.im));
            }
        }
    }
    for (0..n) |i| for (0..n) |j| {
        const v = t[channel[i] * 6 + channel[j]];
        out[i][j] = cplx(v.re, v.im);
    };
    return .{ .n = n, .channel = channel, .t = out, .log_det = ld };
}

test "continuity: the on-shell T at E - i eta tends to T(E + i0), where Im T^-1 = rho" {
    const params = baseline(xb.XB_2PP);
    const model = try Model.init(params);
    defer model.deinit();
    const ws = try Workspace.init(model);
    defer ws.deinit();
    const plan = try Plan.init(model);
    defer plan.deinit();
    const th = thresholds(params);
    // The continuity energies of checks/rank_one_sp.jl, each on its adjacent sheet: BB open;
    // BB and BB* open; all three open.
    for ([_]f64{ -0.06785, -0.02262, 0.020 }) |x| {
        var flip: [3]bool = undefined;
        for (&flip, th.delta) |*f, d| f.* = d < x;
        // T(E + i0) on a rectangle 1e-12 GeV deep under the real axis: its path runs along
        // [0, Lambda] to that depth, the node at the real on-shell momentum.
        const axis: xb.xb_rect = .{ .re_lo = x - 0.0005, .re_hi = x + 0.0005, .im_lo = -1e-12, .im_hi = 0 };
        const real = try onshellT(model, ws, plan, axis, flip, cplx(x, 0));
        // The node channels are the open ones.
        var open: usize = 0;
        for (species_2pp) |s| {
            if (flip[@backingInt(s)]) open += 1;
        }
        try expect(real.n == open);
        // CONVENTIONS.md, "Multichannel S matrix and unitarity": Im (T^-1)_{a'a} = rho_a delta_{a'a},
        // rho_a = mu_a k_a / (2 pi), over the open channels.
        const inverse = try invert(real.n, real.t);
        var largest: f64 = 0;
        for (0..real.n) |i| for (0..real.n) |j| {
            largest = @max(largest, inverse[i][j].magnitude());
        };
        for (0..real.n) |i| for (0..real.n) |j| {
            const s = @backingInt(species_2pp[real.channel[i]]);
            const rho = if (i == j) th.mu[s] * @sqrt(2 * th.mu[s] * (x - th.delta[s])) / (2 * std.math.pi) else 0;
            // Provisional: the identity holds on the discrete equation with real nodes, up to
            // the path's 1e-12 depth and rounding.
            try expect(@abs(inverse[i][j].im - rho) <= 1e-9 * largest);
        };
        // Independent on-axis check: reversing the open nodes' signs subtracts 2i rho.
        // The determinant lemma gives D_lower/D_upper = det(I - 2i T_upper rho).
        var cert: xb.xb_cert = undefined;
        try ok(xb.xb_certify(model.ptr, axis, physical, xb.XB_PATH_S40, plan.ptr(), &cert));
        try expect(cert.failed == 0);
        const lower = try logDet(model, ws, plan, cplx(x, 0));
        var jump: [6][6]Complex = undefined;
        for (0..6) |r| for (0..6) |j| {
            jump[r][j] = cplx(if (r == j) 1 else 0, 0);
            if (r < real.n and j < real.n) {
                const s = @backingInt(species_2pp[real.channel[j]]);
                const two_rho = th.mu[s] * @sqrt(2 * th.mu[s] * (x - th.delta[s])) / std.math.pi;
                jump[r][j] = jump[r][j].sub(real.t[r][j].mul(cplx(0, two_rho)));
            }
        };
        const ratio = detValue(.{ .re = lower.re - real.log_det.re, .im = lower.im - real.log_det.im }, 0);
        try expect(ratio.sub(smallDet(6, jump)).magnitude() <= 1e-9 * ratio.magnitude());
        // T(E - i eta) on rectangles centred there, eta/2 high, so that the path changes with eta.
        var largest_t: f64 = 0;
        for (0..real.n) |i| for (0..real.n) |j| {
            largest_t = @max(largest_t, real.t[i][j].magnitude());
        };
        var diff: [3]f64 = undefined;
        for (&diff, [_]f64{ 1e-3, 1e-4, 1e-5 }) |*d, eta| {
            const t = try onshellT(model, ws, plan, .{ .re_lo = x - 0.0005, .re_hi = x + 0.0005, .im_lo = -1.5 * eta, .im_hi = -0.5 * eta }, flip, cplx(x, -eta));
            try expect(t.n == real.n);
            d.* = 0;
            for (0..real.n) |i| for (0..real.n) |j| {
                d.* = @max(d.*, t.t[i][j].sub(real.t[i][j]).magnitude() / largest_t);
            };
        }
        // T(E - i eta) - T(E + i0) = -i eta T'(E) + O(eta^2): the difference falls tenfold per
        // decade of eta. Provisional: the reference's 9.9-10.0 (NOTEBOOK.md, S40 contours).
        for (0..2) |k| try expect(diff[k] / diff[k + 1] >= 9 and diff[k] / diff[k + 1] <= 11);
    }
}
