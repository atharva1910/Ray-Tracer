const std = @import("std");
const helper = @import("helper.zig");

pub const matrix = struct {
    const MAX_SIZE = 4;
    values: [MAX_SIZE][MAX_SIZE]f64,
    row_size: u8,
    col_size: u8,

    pub fn init(row_size: u8, col_size: u8) matrix {
        return matrix{
            .row_size = row_size,
            .col_size = col_size,
            .values = undefined,
        };
    }

    pub fn init_identity(row_size: u8, col_size: u8) matrix {
        var ret = matrix.init(row_size, col_size);

        for (0..ret.row_size) |i| {
            for (0..ret.col_size) |j| {
                if (i == j) {
                    ret.set(i, j, 1);
                } else {
                    ret.set(i, j, 0);
                }
            }
        }

        return ret;
    }

    pub fn set(self: *matrix, x: usize, y: usize, value: f64) void {
        std.debug.assert(x < self.row_size and y < self.col_size);
        self.values[x][y] = value;
    }

    pub fn set_row(self: *matrix, row_num: u8, data: [4]f64) void {
        std.debug.assert(row_num < self.row_size);
        self.values[row_num] = data;
    }

    pub fn set_col(self: *matrix, col_num: u8, data: [4]f64) void {
        std.debug.assert(col_num < self.col_size);
        for (0..self.col_size) |i| {
            self.values[i][col_num] = data[i];
        }
    }

    pub fn get(self: *const matrix, x: usize, y: usize) f64 {
        std.debug.assert(x < self.row_size and y < self.col_size);
        return self.values[x][y];
    }

    pub fn is_equal(self: *const matrix, other: *const matrix) bool {
        if (self.row_size != other.row_size) return false;
        if (self.col_size != other.col_size) return false;
        for (0..self.row_size) |i| {
            for (0..self.col_size) |j| {
                if (!helper.are_floats_equal(self.values[i][j], other.values[i][j])) return false;
            }
        }
        return true;
    }

    pub fn multiply(self: *const matrix, other: *const matrix) matrix {
        //std.debug.assert(self.row_size != matrix.MAX_SIZE or other.row_size != MAX_SIZE);
        //std.debug.assert(self.col_size != matrix.MAX_SIZE or other.col_size != MAX_SIZE);
        std.debug.assert(self.col_size == other.row_size);

        var ret: matrix = matrix.init(matrix.MAX_SIZE, matrix.MAX_SIZE);

        for (0..ret.row_size) |rowIdx| {
            for (0..ret.col_size) |colIdx| {
                var product: f64 = 0;
                for (0..self.row_size) |i| {
                    product += self.values[rowIdx][i] * other.values[i][colIdx];
                }
                ret.values[rowIdx][colIdx] = product;
            }
        }

        return ret;
    }

    pub fn transpose(self: *const matrix) matrix {
        var ret_matrix = matrix.init(self.col_size, self.row_size);
        for (0..self.row_size) |i| {
            for (0..self.col_size) |j| {
                ret_matrix.values[j][i] = self.values[i][j];
            }
        }

        return ret_matrix;
    }
};

test "matrix test" {
    // 4x4
    var m1 = matrix.init(4, 4);
    m1.set_row(0, .{ 1, 2, 3, 4 });
    m1.set_row(1, .{ 5.5, 6.5, 7.5, 8.5 });
    m1.set_row(2, .{ 9, 10, 11, 12 });
    m1.set_row(3, .{ 13.5, 14.5, 15.5, 16.5 });

    try std.testing.expect(m1.get(0, 0) == 1);
    try std.testing.expect(m1.get(0, 3) == 4);
    try std.testing.expect(m1.get(1, 0) == 5.5);
    try std.testing.expect(m1.get(1, 2) == 7.5);
    try std.testing.expect(m1.get(2, 2) == 11);
    try std.testing.expect(m1.get(3, 0) == 13.5);
    try std.testing.expect(m1.get(3, 2) == 15.5);

    // 2x2
    var m2 = matrix.init(2, 2);
    m2.set_row(0, .{ -3, 5, 0, 0 });
    m2.set_row(1, .{ 1, -2, 0, 0 });

    try std.testing.expect(m2.get(0, 0) == -3);
    try std.testing.expect(m2.get(0, 1) == 5);
    try std.testing.expect(m2.get(1, 0) == 1);
    try std.testing.expect(m2.get(1, 1) == -2);

    // 3x3
    var m3 = matrix.init(3, 3);
    m3.set_row(0, .{ -3, 5, 0, 0 });
    m3.set_row(1, .{ 1, -2, -7, 0 });
    m3.set_row(2, .{ 0, 1, 1, 0 });

    try std.testing.expect(m3.get(0, 0) == -3);
    try std.testing.expect(m3.get(0, 1) == 5);
    try std.testing.expect(m3.get(1, 0) == 1);
    try std.testing.expect(m3.get(1, 1) == -2);
    try std.testing.expect(m3.get(2, 2) == 1);

    // Equal
    try std.testing.expect(m1.is_equal(&m2) == false);

    var m2_copy = matrix.init(2, 2);
    m2_copy.set_row(0, .{ -3, 5, 0, 0 });
    m2_copy.set_row(1, .{ 1, -2, 0, 0 });
    try std.testing.expect(m2.is_equal(&m2_copy) == true);

    // Multiply
    var mul1 = matrix.init(4, 4);
    mul1.set_row(0, .{ 1, 2, 3, 4 });
    mul1.set_row(1, .{ 5, 6, 7, 8 });
    mul1.set_row(2, .{ 9, 8, 7, 6 });
    mul1.set_row(3, .{ 5, 4, 3, 2 });

    var mul2 = matrix.init(4, 4);
    mul2.set_row(0, .{ -2, 1, 2, 3 });
    mul2.set_row(1, .{ 3, 2, 1, -1 });
    mul2.set_row(2, .{ 4, 3, 6, 5 });
    mul2.set_row(3, .{ 1, 2, 7, 8 });

    var mul_ret = matrix.init(4, 4);
    mul_ret.set_row(0, .{ 20, 22, 50, 48 });
    mul_ret.set_row(1, .{ 44, 54, 114, 108 });
    mul_ret.set_row(2, .{ 40, 58, 110, 102 });
    mul_ret.set_row(3, .{ 16, 26, 46, 42 });

    try std.testing.expect(mul1.multiply(&mul2).is_equal(&mul_ret));

    // Identity matrix
    var mul3 = matrix.init(4, 4);
    mul3.set_row(0, .{ 0, 1, 2, 4 });
    mul3.set_row(1, .{ 1, 2, 4, 8 });
    mul3.set_row(2, .{ 2, 4, 8, 16 });
    mul3.set_row(3, .{ 4, 8, 16, 32 });
    const identity_matrix = matrix.init_identity(4, 4);
    try std.testing.expect(mul3.multiply(&identity_matrix).is_equal(&mul3));

    // Transpose
    var trans_matrix = matrix.init(4, 4);
    trans_matrix.set_row(0, .{ 0, 9, 3, 0 });
    trans_matrix.set_row(1, .{ 9, 8, 0, 8 });
    trans_matrix.set_row(2, .{ 1, 8, 5, 3 });
    trans_matrix.set_row(3, .{ 0, 0, 5, 8 });

    var ret_trans_matrix = matrix.init(4, 4);
    ret_trans_matrix.set_row(0, .{ 0, 9, 1, 0 });
    ret_trans_matrix.set_row(1, .{ 9, 8, 8, 0 });
    ret_trans_matrix.set_row(2, .{ 3, 0, 5, 5 });
    ret_trans_matrix.set_row(3, .{ 0, 8, 3, 8 });

    try std.testing.expect(trans_matrix.transpose().is_equal(&ret_trans_matrix));
    try std.testing.expect(identity_matrix.transpose().is_equal(&identity_matrix));
}
