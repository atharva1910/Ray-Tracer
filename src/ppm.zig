const std = @import("std");
const canvas = @import("canvas.zig").canvas;
const tuple = @import("tuple.zig").tuple;

pub const ppm = struct {
    const flavour = "P3\n";
    const max_color_value = "255\n";
    const max_color_val = 255;

    fn scale_color(color: f64) u8 {
        const color_int: i64 = @intFromFloat(@ceil(color * max_color_val));
        return @intCast(@max(@min(color_int, 255), 0));
    }

    pub fn write_to_file(allocator: *const std.mem.Allocator, file_name: []const u8, pCanvas: *const canvas) !void {
        const file = try std.fs.cwd().createFile(file_name, .{ .read = true });
        defer file.close();

        _ = try file.write(flavour);

        const dimensions = try std.fmt.allocPrint(allocator.*, "{} {}\n", .{ pCanvas.width, pCanvas.height });
        _ = try file.write(dimensions);
        allocator.free(dimensions);

        _ = try file.write(max_color_value);

        for (pCanvas.pixels) |row| {
            for (row, 0..) |pixel, i| {
                if (i > 0) {
                    if (i % 70 == 0) {
                        _ = try file.write("\n");
                    } else {
                        _ = try file.write(" ");
                    }
                }
                const red = scale_color(pixel.x);
                const blue = scale_color(pixel.y);
                const green = scale_color(pixel.z);
                const buff = try std.fmt.allocPrint(allocator.*, "{} {} {}", .{ red, blue, green });
                _ = try file.write(buff);
                allocator.free(buff);
            }

            _ = try file.write("\n");
        }

        _ = try file.write("\n");
    }
};

test "ppm test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    errdefer _ = gpa.deinit();

    const window = try canvas.init_canvas(&allocator, 5, 3);
    defer window.free_canvas();
    try std.testing.expect(window.width == 5 and window.height == 3);

    window.write_pixel(0, 0, tuple.create_color(1.5, 0, 0));
    window.write_pixel(2, 1, tuple.create_color(0, 0.5, 0));
    window.write_pixel(4, 2, tuple.create_color(-0.5, 0, 1));

    try ppm.write_to_file(&allocator, "image.ppm", &window);

    const window1 = try canvas.init_canvas(&allocator, 10, 2);
    defer window1.free_canvas();
    try std.testing.expect(window1.width == 10 and window1.height == 2);
    try ppm.write_to_file(&allocator, "image1.ppm", &window1);
}
