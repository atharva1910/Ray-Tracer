const std = @import("std");
const tuple = @import("tuple.zig").tuple;
const ppm = @import("ppm.zig").ppm;

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

    pub fn free_canvas(self: *const canvas) void {
        const arr_ptr = self.pixels;
        for (arr_ptr, 0..) |_, i| {
            self.allocator.free(arr_ptr[i]);
        }
        self.allocator.free(arr_ptr);
    }

    pub fn write_pixel(self: *const canvas, width: u32, height: u32, color: tuple) void {
        if (width >= self.width or self.height - height >= self.height or self.height - height < 0) {
            std.log.debug("Out of bounds write to pixel [{}][{}], canvas size [{}][{}]", .{ height, width, self.height, self.width });
            return;
        }
        self.pixels[self.height - height][width] = color;
    }

    pub fn write_pixel_scale(self: *const canvas, width: f64, height: f64, color: tuple) void {
        return write_pixel(self, scale_pixel(width), scale_pixel(height), color);
    }

    pub fn pixel_at(self: *const canvas, width: u32, height: u32) tuple {
        std.debug.assert(width < self.width or height < self.height or self.height - height < 0);
        return self.pixels[self.height - height][width];
    }

    pub fn save(self: *const canvas, name: []const u8) !void {
        try ppm.write_to_file(self.allocator, name, self);
    }

    pub fn fill_all_pixels(self: *const canvas, color: tuple) void {
        for (self.pixels, 0..) |col, height| {
            for (col, 0..) |_, width| {
                //std.debug.print("{} {}\n", .{ height, width });
                self.pixels[height][width] = color;
            }
        }
    }

    fn scale_pixel(pos: f64) u32 {
        const pos_int: i64 = @intFromFloat(pos);
        return @intCast(pos_int);
    }

    fn alloc_pixels(allocator: *const std.mem.Allocator, width: u64, height: u64) ![][]tuple {
        const arr_ptr = try allocator.alloc([]tuple, height);
        for (arr_ptr, 0..) |_, i| {
            arr_ptr[i] = try allocator.alloc(tuple, width);
            for (arr_ptr[i], 0..) |_, j| {
                arr_ptr[i][j] = tuple.create_color(0, 0, 0);
            }
        }

        return arr_ptr;
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
