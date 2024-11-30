const std = @import("std");

const matrix = struct {
    const MAX_SIZE = 4;
    values: [MAX_SIZE][MAX_SIZE]f64,
    row_size: u8,
    col_size: u8,

    pub fn init(row_size: u8, col_size: u8) matrix {
        std.debug.assert(row_size >= 2 and row_size <= MAX_SIZE);
        std.debug.assert(col_size >= 2 and col_size <= MAX_SIZE);

        return matrix{
            .row_size = row_size,
            .col_size = col_size,
            .values = undefined,
        };
    }

    pub fn set(self: *matrix, x: u8, y: u8, value: f64) void {
        std.debug.assert(x < self.row_size and y < self.col_size);
        self.values[x][y] = value;
    }

    pub fn set_row(self: *matrix, row_num: u8, data: [4]f64) void {
        std.debug.assert(row_num < self.row_size);
        self.values[row_num] = data;
    }

    pub fn set_col(self: *matrix, col_num: u8, data: [4]f64) void {
        std.debug.assert(col_num < self.col_size);
        self.values[0][col_num] = data[0];
        self.values[1][col_num] = data[1];
        self.values[2][col_num] = data[2];
        self.values[3][col_num] = data[3];
    }

    pub fn get(self: *const matrix, x: u8, y: u8) f64 {
        std.debug.assert(x < self.row_size and y < self.col_size);
        return self.values[x][y];
    }
};

test "matrix test" {
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
}
