const std = @import("std");
const tuple = @import("tuple.zig").tuple;
const canvas = @import("canvas.zig").canvas;
const ppm = @import("ppm.zig").ppm;

const game = struct {
    const projectile = struct {
        position: tuple,
        velocity: tuple,
    };

    const environment = struct {
        gravity: tuple,
        wind: tuple,
    };

    proj: projectile,
    env: environment,

    fn init(t1: tuple, t2: tuple, t3: tuple, t4: tuple) game {
        return .{ .proj = .{
            .position = t1,
            .velocity = t2,
        }, .env = .{
            .gravity = t3,
            .wind = t4,
        } };
    }

    fn tick(self: *game) void {
        self.proj.position = tuple.add_tuples(self.proj.position, self.proj.velocity);
        self.proj.velocity = tuple.add_tuples(tuple.add_tuples(self.proj.velocity, self.env.gravity), self.env.wind);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    errdefer _ = gpa.deinit();

    const window = try canvas.init_canvas(&gpa.allocator(), 900, 900);
    defer window.free_canvas();

    const red = tuple.create_color(1, 0, 0);
    const fheight: f64 = @floatFromInt(window.height);

    window.fill_all_pixels(tuple.create_color(0, 0, 0));

    var state = game.init(tuple.create_point(0, 1, 0), tuple.normalize(tuple.create_vector(1, 1, 0)), tuple.create_vector(0, -0.1, 0), tuple.create_vector(-0.01, 0, 0));

    window.write_pixel_scale(state.proj.position.x, fheight - state.proj.position.y, red);

    while (true) {
        state.tick();
        window.write_pixel_scale(state.proj.position.x, fheight - state.proj.position.y, red);
        if (state.proj.position.y < 0) break;
    }

    window.save("game.ppm") catch |e| {
        std.log.err("Failed to save ppm {}\n", .{e});
    };
}
