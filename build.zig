const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const build_mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("strings", "src/strings.zig");
    lib.setBuildMode(build_mode);
    lib.linkLibC();
    lib.install();

    const test_step = b.addTest("test.zig");
    test_step.addPackagePath("strings", "src/strings.zig");
    test_step.setBuildMode(build_mode);
    test_step.linkLibrary(lib);

    const test_cmd = b.step("test", "Run the tests");
    test_cmd.dependOn(&test_step.step);

    const benchmark_exe = b.addExecutable("benchmark", "benchmark.zig");
    benchmark_exe.addPackagePath("strings", "src/strings.zig");
    benchmark_exe.setBuildMode(build_mode);
    benchmark_exe.linkLibrary(lib);
    benchmark_exe.install();

    const benchmark_cmd = benchmark_exe.run();
    benchmark_cmd.step.dependOn(&benchmark_exe.step);

    const benchmark_step = b.step("benchmark", "Benchmark some features");
    benchmark_step.dependOn(&benchmark_cmd.step);
}
