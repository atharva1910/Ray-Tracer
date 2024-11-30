const std = @import("std");

const matrix = struct {
    m: [4][4]f64,

    fn init(m00: f64, m01: f64, m02: f64, m03: f64, m10: f64, m11: f64, m12: f64, m13: f64, m20: f64, m21: f64, m22: f64, m23: f64, m30: f64, m31: f64, m32: f64, m33: f64) matrix {
        return matrix{ .m = .{ .{ m00, m01, m02, m03 }, .{ m10, m11, m12, m13 }, .{ m20, m21, m22, m23 }, .{ m30, m31, m32, m33 } } };
    }

    fn get_value_at(self: *const matrix, x: u8, y: u8) f64 {
        std.debug.assert(x < 4 and y < 4);
        return self.m[x][y];
    }
};

test "matrix test" {
    const m1 = matrix.init(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5);

    try std.testing.expect(m1.get_value_at(0, 0) == 1);
    try std.testing.expect(m1.get_value_at(0, 3) == 4);
    try std.testing.expect(m1.get_value_at(1, 0) == 5.5);
    try std.testing.expect(m1.get_value_at(1, 2) == 7.5);
    try std.testing.expect(m1.get_value_at(2, 2) == 11);
    try std.testing.expect(m1.get_value_at(3, 0) == 13.5);
    try std.testing.expect(m1.get_value_at(3, 2) == 15.5);
}
