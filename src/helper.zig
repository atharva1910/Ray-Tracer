const std = @import("std");

pub fn scale_color(color: f64, max_color_val: comptime_int) u8 {
    const color_int: i64 = @intFromFloat(@ceil(color * max_color_val));
    return @intCast(@max(@min(color_int, 255), 0));
}

pub fn are_floats_equal(x: f64, y: f64) bool {
    // isn't mem.cmp easier?
    const epsilon = 0.00001;
    return @abs(x - y) < epsilon;
}
