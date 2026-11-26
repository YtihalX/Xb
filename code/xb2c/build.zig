const std = @import("std");

const Blas = enum { accelerate, openblas };

const sources = [_][]const u8{ "src/model.c", "src/kernel.c", "src/lse.c" };

// GSL_RANGE_CHECK_OFF also keeps out GSL 2.8's inline range checks, whose {{0, 0}} initialiser
// of a gsl_complex is an error once gsl_complex is a double complex.
const warnings = [_][]const u8{
    "-std=gnu2y",        "-fms-extensions",       "-Wno-microsoft-anon-tag",
    "-Wall",             "-Wextra",               "-Wconversion",
    "-Wsign-conversion", "-Wshadow",              "-Werror",
    "-DHAVE_INLINE",     "-DGSL_RANGE_CHECK_OFF",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const macos = target.result.os.tag == .macos;
    const blas = b.option(Blas, "blas", "BLAS/LAPACK backend (default: accelerate on macOS, openblas elsewhere)") orelse
        if (macos) Blas.accelerate else Blas.openblas;
    const prefix = b.option([]const u8, "prefix", "Prefix of GSL, MPFR, MPC and GMP") orelse
        if (macos) "/opt/homebrew" else "/usr";
    const gcc = b.option([]const u8, "gcc", "GCC for the static-analyzer pass") orelse "gcc-16";
    const backend = switch (blas) {
        .accelerate => "-DXB_BLAS_ACCELERATE",
        .openblas => "-DXB_BLAS_OPENBLAS",
    };
    const include = b.pathJoin(&.{ prefix, "include" });
    const libdir = b.pathJoin(&.{ prefix, "lib" });

    // clang reports __GNUC__ 4; GSL 2.8 makes gsl_complex a double complex only from GCC 7 on.
    const flags = warnings ++ [_][]const u8{"-fgnuc-version=14"};
    const lib_mod = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = true });
    lib_mod.addCSourceFiles(.{ .files = &sources, .flags = &(flags ++ [_][]const u8{backend}) });
    lib_mod.addIncludePath(b.path("include"));
    lib_mod.addSystemIncludePath(.{ .cwd_relative = include });
    lib_mod.addLibraryPath(.{ .cwd_relative = libdir });
    for ([_][]const u8{ "gsl", "mpc", "mpfr", "gmp" }) |name|
        lib_mod.linkSystemLibrary(name, .{ .use_pkg_config = .no });
    switch (blas) {
        .accelerate => lib_mod.linkFramework("Accelerate", .{}),
        .openblas => lib_mod.linkSystemLibrary("openblas", .{ .use_pkg_config = .no }),
    }
    const lib = b.addLibrary(.{ .name = "xb", .root_module = lib_mod });
    b.installArtifact(lib);

    const header = b.addTranslateC(.{
        .root_source_file = b.path("include/xb.h"),
        .target = target,
        .optimize = optimize,
    });
    // The tests' own oracle: GSL's adaptive quadrature, translated like the library header.
    const gsl = b.addTranslateC(.{
        .root_source_file = b.path("test/gsl.h"),
        .target = target,
        .optimize = optimize,
    });
    gsl.addSystemIncludePath(.{ .cwd_relative = include });
    const xb = header.createModule();
    const rectangle = b.createModule(.{
        .root_source_file = b.path("src/rectangle.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "xb", .module = xb }},
    });
    const driver = b.createModule(.{
        .root_source_file = b.path("src/driver.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "xb", .module = xb }, .{ .name = "rectangle", .module = rectangle } },
    });

    const exe = b.addExecutable(.{
        .name = "xb2c",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{ .{ .name = "xb", .module = xb }, .{ .name = "driver", .module = driver } },
        }),
    });
    exe.root_module.linkLibrary(lib);
    exe.root_module.addLibraryPath(.{ .cwd_relative = libdir });
    b.installArtifact(exe);
    const run_exe = b.addRunArtifact(exe);
    run_exe.setCwd(b.path("."));
    run_exe.addPassthruArgs();
    b.step("run", "Run the search on a configuration file: zig build run -- config/search-2pp.zon").dependOn(&run_exe.step);
    const filters = b.option([]const []const u8, "test-filter", "Run only the tests whose names contain this") orelse &.{};
    const test_step = b.step("test", "Run both test seams");
    for ([_][]const u8{ "seam1", "seam2" }) |seam| {
        const test_mod = b.createModule(.{
            .root_source_file = b.path(b.fmt("test/{s}.zig", .{seam})),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{.{ .name = "xb", .module = xb }},
        });
        if (std.mem.eql(u8, seam, "seam1")) {
            test_mod.addImport("gsl", gsl.createModule());
        } else {
            test_mod.addImport("rectangle", rectangle);
            test_mod.addImport("driver", driver);
        }
        test_mod.linkLibrary(lib);
        test_mod.addLibraryPath(.{ .cwd_relative = libdir });
        const tests = b.addTest(.{ .name = seam, .root_module = test_mod, .filters = filters });
        const run = b.addRunArtifact(tests);
        test_step.dependOn(&run.step);
        b.step(b.fmt("test-{s}", .{seam}), b.fmt("Run the {s} tests", .{seam})).dependOn(&run.step);
    }

    // GCC 16 builds every file with the same strict warnings plus its static analyzer. GCC does
    // not implement #pragma STDC CX_LIMITED_RANGE; -fcx-limited-range is its equivalent.
    const analyze = b.step("analyze", "Compile with GCC's static analyzer");
    for (sources) |source| {
        const cmd = b.addSystemCommand(&.{gcc});
        cmd.addArgs(&warnings);
        cmd.addArgs(&.{ backend, "-fcx-limited-range", "-Wno-unknown-pragmas", "-fanalyzer", "-O2", "-c", "-o", "/dev/null", "-isystem", include, "-I" });
        cmd.addDirectoryArg(b.path("include"));
        cmd.addFileArg(b.path(source));
        analyze.dependOn(&cmd.step);
    }
}
