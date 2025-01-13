const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-test",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const exe_cmd = b.addRunArtifact(exe);

    exe_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| exe_cmd.addArgs(args);

    const tst = b.addTest(.{
        .root_source_file = b.path("src/list.zig"),
        .target = target,
        .optimize = optimize,
    });
    const tst_cmd = b.addRunArtifact(tst);

    b.step("run", "Run the app").dependOn(&exe_cmd.step);
    b.step("test", "Run unit tests").dependOn(&tst_cmd.step);
}
