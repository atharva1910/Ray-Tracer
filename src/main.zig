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

    fn add_vector(point: tuple, vector: tuple) tuple {
        return tuple{
            .x = point.x + vector.x,
            .y = point.y + vector.y,
            .z = point.z + vector.z,
            .w = 1,
        };
    }
};

fn are_floats_equal(x: f64, y: f64, epsilon: comptime_float) bool {
    return std.math.complex.abs(x - y) < epsilon;
}

test "simple test" {
    const pt1 = tuple.create_point(4.3, -4.2, 3.1);
    const vec1 = tuple.create_vector(-4.3, 4.2, -3.1);
    const pt2 = tuple.add_vector(pt1, vec1);
    try std.testing.expect(pt1.w == 1);
    try std.testing.expect(vec1.w == 0);
    try std.testing.expect(pt2.x == 0 and pt2.y == 0 and pt2.z == 0 and pt2.w == 1);
}
