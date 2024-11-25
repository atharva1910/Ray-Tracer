const std = @import("std");
const canvas = @import("canvas.zig").canvas;

pub const ppm = struct {
    pub fn write_to_file(comptime file_name: []u8, pCanvas: *const canvas) void {
        _ = file_name;
        _ = pCanvas;
    }
};

test "ppm test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    errdefer _ = gpa.deinit();

    const window = try canvas.init_canvas(&gpa.allocator(), 10, 20);
    defer window.free_canvas();
    try std.testing.expect(window.width == 10 and window.height == 20);
}
