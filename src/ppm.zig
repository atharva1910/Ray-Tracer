const std = @import("std");
const canvas = @import("canvas.zig").canvas;

pub const ppm = struct {
    const flavour_type = "P3";
    const max_color_value = 255;
    pub fn write_to_file(allocator: *const std.mem.Allocator, file_name: []const u8, pCanvas: *const canvas) !void {
        _ = pCanvas;

        const file = try std.fs.cwd().createFile(file_name, .{ .read = true });
        defer file.close();

        const flavour = try std.fmt.allocPrint(allocator.*, "{s}\n", .{flavour_type});
        defer allocator.free(flavour);
        _ = try file.write(flavour);
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
