const std = @import("std");

const tuple = struct {
    x: f64,
    y: f64,
    z: f64,
    w: u8,

    fn create_point(x: f64, y: f64, z: f64) tuple {
        return tuple{ .x = x, .y = y, .z = z, .w = 1.0 };
    }

    fn create_vector(x: f64, y: f64, z: f64) tuple {
        return tuple{ .x = x, .y = y, .z = z, .w = 0 };
    }

    fn are_tuples_equal(t1: tuple, t2: tuple) bool {
        const epsilon = 0.00001;
        return are_floats_equal(t1.x, t2.x, epsilon) or
            are_floats_equal(t1.y, t2.y, epsilon) or
            are_floats_equal(t1.z, t2.z, epsilon) or
            (t1.w == t2.w);
    }
};

fn are_floats_equal(x: f64, y: f64, epsilon: comptime_float) bool {
    return std.math.complex.abs(x - y) < epsilon;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    const pt1 = tuple.create_point(4.3, -4.2, 3.1);
    const vec1 = tuple.create_vector(4.3, -4.2, 3.1);

    try std.testing.expect(pt1.w == 1);
    try std.testing.expect(vec1.w == 0);
}
