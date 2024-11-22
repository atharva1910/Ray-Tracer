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

    fn add_tuples(tup1: tuple, tup2: tuple) tuple {
        std.debug.assert(tup1.w + tup2.w <= 1);
        return tuple{
            .x = tup1.x + tup2.x,
            .y = tup1.y + tup2.y,
            .z = tup1.z + tup2.z,
            .w = tup1.w + tup2.w,
        };
    }

    fn sub_tuples(tup1: tuple, tup2: tuple) tuple {
        std.debug.assert(tup1.w - tup2.w == 1 or tup1.w - tup2.w == 0);
        return tuple{
            .x = tup1.x - tup2.x,
            .y = tup1.y - tup2.y,
            .z = tup1.z - tup2.z,
            .w = tup1.w - tup2.w,
        };
    }
};

fn are_floats_equal(x: f64, y: f64, epsilon: comptime_float) bool {
    return std.math.complex.abs(x - y) < epsilon;
}

test "simple test" {
    const pt1 = tuple.create_point(4.3, -4.2, 3.1);
    const vec1 = tuple.create_vector(-4.3, 4.2, -3.1);
    const vec2 = tuple.create_vector(-4.3, 4.2, -3.1);
    try std.testing.expect(pt1.w == 1);
    try std.testing.expect(vec1.w == 0);

    const pt2 = tuple.add_tuples(pt1, vec1);
    const pt3 = tuple.sub_tuples(pt1, vec1);
    const vec3 = tuple.sub_tuples(vec2, vec1);
    try std.testing.expect(pt2.x == 0 and pt2.y == 0 and pt2.z == 0 and pt2.w == 1);
    try std.testing.expect(pt3.w == 1);
    try std.testing.expect(vec3.w == 0);
}
