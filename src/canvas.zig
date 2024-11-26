const std = @import("std");
const tuple = @import("tuple.zig").tuple;

pub const canvas = struct {
    width: u32,
    height: u32,
    allocator: *const std.mem.Allocator,
    pixels: [][]tuple,

    pub fn init_canvas(allocator: *const std.mem.Allocator, width: u32, height: u32) !canvas {
        return canvas{
            .width = width,
            .height = height,
            .allocator = allocator,
            .pixels = try alloc_pixels(allocator, width, height),
        };
    }

    fn alloc_pixels(allocator: *const std.mem.Allocator, width: u64, height: u64) ![][]tuple {
        const arr_ptr = try allocator.alloc([]tuple, height);
        for (arr_ptr, 0..) |_, i| {
            arr_ptr[i] = try allocator.alloc(tuple, width);
            for (arr_ptr[i], 0..) |_, j| {
                arr_ptr[i][j] = tuple.create_color(1, 0.8, 0.6);
            }
        }

        return arr_ptr;
    }

    pub fn free_canvas(self: *const canvas) void {
        const arr_ptr = self.pixels;
        for (arr_ptr, 0..) |_, i| {
            self.allocator.free(arr_ptr[i]);
        }
        self.allocator.free(arr_ptr);
    }

    pub fn write_pixel(self: *const canvas, width: u32, height: u32, color: tuple) void {
        std.debug.assert(width < self.width and height < self.height);
        self.pixels[height][width] = color;
    }

    pub fn pixel_at(self: *const canvas, width: u32, height: u32) tuple {
        std.debug.assert(width < self.width and height < self.height);
        return self.pixels[height][width];
    }
};

test "canvas test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    errdefer _ = gpa.deinit();

    const window = try canvas.init_canvas(&gpa.allocator(), 10, 20);
    defer window.free_canvas();
    try std.testing.expect(window.width == 10 and window.height == 20);

    const red = tuple.create_color(1, 0, 0);
    window.write_pixel(2, 3, red);
    try std.testing.expect(tuple.are_equal(window.pixel_at(2, 3), red));
}
