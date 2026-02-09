const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.addModule("ziglox", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{ .name = "ziglox", .root_module = exe_mod });

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    // run.step
    const run_step = b.step("run", "run the application");
    run_step.dependOn(&run_exe.step);

    // const exe_check = b.addExecutable(.{
    //     .name = "ziglox",
    //     .root_module = exe_mod,
    // });
    // const check = b.step("check", "Check if foo compiles");
    // check.dependOn(&exe_check.step);
}
