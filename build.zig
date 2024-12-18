const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "Ray Tracer",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const tuple_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tuple.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_tuple_unit_tests = b.addRunArtifact(tuple_unit_tests);

    const canvas_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/canvas.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_canvas_unit_tests = b.addRunArtifact(canvas_unit_tests);

    const ppm_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/ppm.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_ppm_unit_tests = b.addRunArtifact(ppm_unit_tests);

    const matrix_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/matrix.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_matrix_unit_tests = b.addRunArtifact(matrix_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
    test_step.dependOn(&run_tuple_unit_tests.step);
    test_step.dependOn(&run_canvas_unit_tests.step);
    test_step.dependOn(&run_ppm_unit_tests.step);
    test_step.dependOn(&run_matrix_unit_tests.step);
}
