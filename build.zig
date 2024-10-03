const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "meshoptimizer",
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibC();

    lib.addCSourceFile(.{
        .file = b.path("c-src/nuklear.c"),
        .flags = &.{
            "-std=c99",
            "-fno-sanitize=undefined",
        },
    });

    const module = b.addModule("main", .{
        .root_source_file = b.path("src/nuklear.zig"),
    });

    module.linkLibrary(lib);
}
