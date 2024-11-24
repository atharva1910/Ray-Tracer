const std = @import("std");

pub const tuple = struct {
    x: f64,
    y: f64,
    z: f64,
    w: i8,

    pub fn create_point(x: f64, y: f64, z: f64) tuple {
        return tuple{ .x = x, .y = y, .z = z, .w = 1.0 };
    }

    pub fn create_vector(x: f64, y: f64, z: f64) tuple {
        return tuple{ .x = x, .y = y, .z = z, .w = 0 };
    }

    pub fn create_color(red: f64, green: f64, blue: f64) tuple {
        return tuple{ .x = red, .y = green, .z = blue, .w = 0 };        
    }
    
    fn are_floats_equal(x: f64, y: f64, epsilon: comptime_float) bool {
        return @abs(x - y) < epsilon;
    }

    pub fn are_equal(t1: tuple, t2: tuple) bool {
        const epsilon = 0.00001;
        return are_floats_equal(t1.x, t2.x, epsilon) and
            are_floats_equal(t1.y, t2.y, epsilon) and
            are_floats_equal(t1.z, t2.z, epsilon) and
            (t1.w == t2.w);
    }

    pub fn add_tuples(t1: tuple, t2: tuple) tuple {
        std.debug.assert(t1.w + t2.w <= 1);
        return tuple{
            .x = t1.x + t2.x,
            .y = t1.y + t2.y,
            .z = t1.z + t2.z,
            .w = t1.w + t2.w,
        };
    }

    pub fn sub_tuples(t1: tuple, t2: tuple) tuple {
        std.debug.assert(t1.w - t2.w == 1 or t1.w - t2.w == 0);
        return tuple{
            .x = t1.x - t2.x,
            .y = t1.y - t2.y,
            .z = t1.z - t2.z,
            .w = t1.w - t2.w,
        };
    }

    pub fn negate(t: tuple) tuple {
        return tuple{
            .x = -t.x,
            .y = -t.y,
            .z = -t.z,
            .w = -t.w,            
        };
    }

    pub fn multiply(t: tuple, factor: f64) tuple {
        std.debug.assert(t.w == 0);
        return tuple {
            .x = t.x * factor,
            .y = t.y * factor,
            .z = t.z * factor,
            .w = t.w,
        };
    }

    pub fn magnitude(t: tuple) f64 {
        std.debug.assert(t.w == 0);
        // Note : book says to add t.w * t.w as well. But why?
        return @sqrt(t.x * t.x + t.y * t.y + t.z * t.z);
    }

    pub fn normalize(t:tuple) tuple {
        std.debug.assert(t.w == 0);
        const mag = t.magnitude();
        return tuple {
            .x = t.x / mag,
            .y = t.y / mag,
            .z = t.z / mag,
            .w = t.w,
        };
    }

    pub fn dot_product(t1: tuple, t2: tuple) f64 {
        std.debug.assert(t1.w == 0 and t2.w == 0);
        return t1.x * t2.x + t1.y * t2.y + t1.z * t2.z;
    }

    pub fn cross_product(t1: tuple, t2: tuple) tuple {
        std.debug.assert(t1.w == 0 and t2.w == 0);
        return tuple.create_vector(
            t1.y * t2.z - t1.z * t2.y,
            t1.z * t2.x - t1.x * t2.z,
            t1.x * t2.y - t1.y * t2.x);
    }

    pub fn print(t:tuple) void {
        std.log.info("t.x:{} t.y:{} t.z:{} t.w:{}\n", .{t.x, t.y, t.z, t.w});
    }
};

test "tuple test" {
    // Factory    
    const pt1 = tuple.create_point(4.3, -4.2, 3.1);
    const pt2 = tuple.create_point(4.3, -4.2, 3.1);
    try std.testing.expect(pt1.w == 1);
    try std.testing.expect(pt2.w == 1);

    // Factory
    const vec1 = tuple.create_vector(4.3, -4.2, 3.1);
    const vec2 = tuple.create_vector(-4.3, 4.2, -3.1);
    try std.testing.expect(vec1.w == 0);
    try std.testing.expect(vec2.w == 0);

    // Equals
    try std.testing.expect(!tuple.are_equal(vec1, pt1));
    try std.testing.expect(tuple.are_equal(pt1, pt2));        

    // Substraction
    const pt3 = tuple.sub_tuples(pt1, vec1);
    try std.testing.expect(pt3.x == 0 and pt3.y == 0 and pt3.z == 0 and pt3.w == 1);
    try std.testing.expect(pt3.w == 1);
    const vec3 = tuple.sub_tuples(pt1, pt2);
    try std.testing.expect(vec3.x == 0 and vec3.y == 0 and vec3.z == 0 and vec3.w == 0);
    const vec4 = tuple.sub_tuples(vec2, vec1);
    try std.testing.expect(vec4.w == 0);

    // Negate
    const negate_vector = tuple.negate(vec1);
    try std.testing.expect(negate_vector.x == -4.3 and negate_vector.y == 4.2 and negate_vector.z == -3.1 and negate_vector.w == 0);
    const negate_point = tuple.negate(pt1);
    try std.testing.expect(negate_point.x == -4.3 and negate_point.y == 4.2 and negate_point.z == -3.1 and negate_point.w == -1);

    // Div and multiply
    const multiply_vector = tuple.multiply(vec1, 2.0);
    try std.testing.expect(multiply_vector.x == 8.6 and multiply_vector.y == -8.4 and multiply_vector.z == 6.2 and multiply_vector.w == 0);
    const divide_vector = tuple.multiply(multiply_vector, 0.5);
    try std.testing.expect(tuple.are_equal(divide_vector, vec1));

    // Magnitude
    try std.testing.expect(tuple.magnitude(.{.x = 1, .y = 0, .z = 0, .w = 0}) == 1);
    try std.testing.expect(tuple.magnitude(.{.x = 1, .y = 0, .z = 0, .w = 0}) == 1);

    // Normalize
    const vec5 = tuple.create_vector(4,0,0);
    const nvec1 = tuple.normalize(vec5);
    try std.testing.expect(nvec1.x == 1 and nvec1.y == 0 and nvec1.z == 0 and nvec1.z == 0);
    //const vec6 = tuple.create_vector(1,2,3);
    //const nvec2 = tuple.normalize(vec6);
    //tuple.print(nvec2);
    //try std.testing.expect(nvec2.x == 0.26726 and nvec2.y == 0.53452 and nvec2.z == 0.80178 and nvec2.z == 0);

    // Dot Product
    const dp1 = tuple.dot_product(tuple.create_vector(1,2,3), tuple.create_vector(2,3,4));
    try std.testing.expect(dp1 == 20);

    // Color
    const color1 = tuple.create_color(-0.5, 0.4, 1.7);
    try std.testing.expect(color1.x == -0.5 and color1.y == 0.4 and color1.z == 1.7 and color1.w == 0);    
}