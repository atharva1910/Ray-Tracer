const std = @import("std");
const canvas = @import("canvas.zig").canvas;

pub const ppm = struct {
    const flavour = "P3\n";
    const max_color_value = "255\n";
    const max_color_val = 255;

    fn scale_color(color: f64) u8 {
        const color_int: i64 = @intFromFloat(color);
        return @intCast(@max(@min(color_int, 255), 0));
    }

    pub fn write_to_file(allocator: *const std.mem.Allocator, file_name: []const u8, pCanvas: *const canvas) !void {
        const file = try std.fs.cwd().createFile(file_name, .{ .read = true });
        defer file.close();

        //_ = try file.write(flavour);

        const dimensions = try std.fmt.allocPrint(allocator.*, "{} {}\n", .{ pCanvas.width, pCanvas.height });
        _ = try file.write(dimensions);
        allocator.free(dimensions);

        _ = try file.write(max_color_value);

        for (pCanvas.pixels) |row| {
            for (row) |pixel| {
                const red = scale_color(pixel.x);
                const blue = scale_color(pixel.y);
                const green = scale_color(pixel.z);
                const buff = try std.fmt.allocPrint(allocator.*, "{} {} {} ", .{ red, blue, green });
                _ = try file.write(buff);
                allocator.free(buff);
            }

            _ = try file.write("\n");
        }
    }
};

test "ppm test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    errdefer _ = gpa.deinit();

    const window = try canvas.init_canvas(&allocator, 10, 20);
    defer window.free_canvas();
    try std.testing.expect(window.width == 10 and window.height == 20);

    try ppm.write_to_file(&allocator, "image.ppm", &window);
}
