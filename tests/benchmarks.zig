const std = @import("std");
const Timer = std.time.Timer;
const warn = std.debug.warn;
const String = @import("strings").String;

pub fn main() !void {
    const test_cout = 1000;

    warn("Splitting Moby Dick in words a {} times…\n\n", .{test_cout});
    const all_moby_dick = @embedFile("fixtures/moby_dick.txt");

    var timer = try Timer.start();
    var i: usize = 0;
    const moby_full = try String.init(all_moby_dick);

    var results: [test_cout]usize = undefined;

    const start = timer.lap();
    while (i < test_cout) : (i += 1) {
        // var x = try moby_full.single_space_indices();
        var x = try moby_full.split_to_u8(" ");
        results[i] = x.len;
    }
    const end = timer.read();

    warn("Done!\n - words count: {}\n", .{results[0]});
    const elapsed_s = @intToFloat(f64, end - start) / std.time.ns_per_s;
    warn(" - elapsed seconds: {d:.3}\n\n", .{elapsed_s});
}
