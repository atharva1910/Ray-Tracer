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

        var list = std.ArrayList(u8).init(allocator.*);
        defer list.deinit();

        var buff: [11]u8 = undefined;

        for (pCanvas.pixels) |col| {
            for (col, 0..) |pixel, width| {
                if (width > 0) {
                    if (width % 70 == 0) {
                        try list.append('\n');
                    } else {
                        try list.append(' ');
                    }
                }

                const red = scale_color(pixel.x);
                const blue = scale_color(pixel.y);
                const green = scale_color(pixel.z);
                const str = try std.fmt.bufPrint(&buff, "{} {} {}", .{ red, blue, green });
                try list.appendSlice(str);
            }

            try list.append('\n');
        }

        try list.append('\n');
        _ = try file.write(list.items);
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
