const std = @import("std");

pub fn getRustTarget(target: std.Build.ResolvedTarget) ?[]const u8 {
    return switch (target.result.os.tag) {
        .linux => switch (target.result.cpu.arch) {
            .x86_64 => "x86_64-unknown-linux-gnu",
            .aarch64 => "aarch64-unknown-linux-gnu",
            else => null,
        },
        .macos => switch (target.result.cpu.arch) {
            .x86_64 => "x86_64-apple-darwin",
            .aarch64 => "aarch64-apple-darwin",
            else => null,
        },
        else => null,
    };
}

fn buildRustlib(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    rust_target: ?[]const u8,
) void {
    const rust_build = b.step("build-rust-workspace", "Build Rust workspace libraries");

    const cargo_build = b.addSystemCommand(&.{ "cargo", "build", "--workspace", "--all-features" });
    if (rust_target) |target_triple| {
        cargo_build.addArg("--target");
        cargo_build.addArg(target_triple);
    }

    rust_build.dependOn(&cargo_build.step);

    const root_module = b.createModule(.{
        // b.createModule defines a new module just like b.addModule but,
        // unlike b.addModule, it does not expose the module to consumers of
        // this package, which is why in this case we don't have to give it a name.
        .root_source_file = b.path("src/main_rust.zig"),
        // Target and optimization levels must be explicitly wired in when
        // defining an executable or library (in the root module), and you
        // can also hardcode a specific target for an executable or library
        // definition if desireable (e.g. firmware for embedded devices).
        .target = target,
        .optimize = optimize,
        // List of modules available for import in source files part of the
        // root module.
    });
    const exe = b.addExecutable(.{
        .name = "rust_add_app",
        .linkage = .static,
        .use_llvm = true,
        // .use_lld = true,
        .root_module = root_module,
    });

    const profile_dir = switch (optimize) {
        .Debug => "debug",
        .ReleaseSafe, .ReleaseSmall => "release",
        .ReleaseFast => "release-fast",
    };

    const lib_path = if (rust_target) |target_triple|
        b.fmt("target/{s}/{s}/librustlib_wrapper.a", .{ target_triple, profile_dir })
    else
        b.fmt("target/{s}/librustlib_wrapper.a", .{profile_dir});
    exe.addObjectFile(b.path(lib_path));
    exe.addIncludePath(b.path("lib/rustlib"));
    // Either linkLibC or linkSystemLibrary("c") can be used.
    exe.linkLibC();
    // exe.linkSystemLibrary("c");

    exe.step.dependOn(rust_build);

    b.installArtifact(exe);
}

pub fn buildClib(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const exe = b.addExecutable(.{ .name = "cmark_add_app", .root_module = b.createModule(.{
        .root_source_file = b.path("src/main_c.zig"),
        .target = target,
        .optimize = optimize,
    }) });

    // Add the C source file to be compiled alongside the Zig code.
    exe.addCSourceFiles(.{
        .files = &[_][]const u8{"lib/clib/cmark_add.c"},
        .flags = &[_][]const u8{},
    });

    // Specify the path to the C header files.
    exe.addIncludePath(b.path("lib/clib"));

    return b.installArtifact(exe);
}

pub fn buildZiglib(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const linkage: std.builtin.LinkMode = .static;
    const libzigadd = b.addLibrary(.{ .name = "zigadd", .linkage = linkage, .root_module = b.createModule(
        .{
            .root_source_file = b.path("lib/ziglib/zig_add.zig"),
            .target = target,
            .optimize = optimize,
        },
    ) });

    if (linkage == .dynamic) {
        libzigadd.rdynamic = true;
        libzigadd.linkLibC();
    }

    const exe = b.addExecutable(.{ .name = "zig_add_app", .root_module = b.createModule(.{
        .root_source_file = b.path("src/main_zig.zig"),
        .target = target,
        .optimize = optimize,
    }) });
    exe.linkLibrary(libzigadd);
    b.installArtifact(libzigadd);
    b.installArtifact(exe);
}

// Although this function looks imperative, it does not perform the build
// directly and instead it mutates the build graph (`b`) that will be then
// executed by an external runner. The functions in `std.Build` implement a DSL
// for defining build steps and express dependencies between them, allowing the
// build runner to parallelize the build automatically (and the cache system to
// know when a step doesn't need to be re-run).
pub fn build(b: *std.Build) void {
    // Standard target options allow the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    // It's also possible to define more custom flags to toggle optional features
    // of this build script using `b.option()`. All defined flags (including
    // target and optimize options) will be listed when running `zig build --help`
    // in this directory.
    //

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    buildClib(b, target, optimize);
    buildZiglib(b, target, optimize);
    const rust_target = getRustTarget(target);
    buildRustlib(b, target, optimize, rust_target);
}
