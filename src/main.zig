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
    const pixel_color = tuple.create_color(1, 0, 0);

    proj: projectile,
    env: environment,
    window: canvas,

    fn init(allocator: *const std.mem.Allocator, t1: tuple, t2: tuple, t3: tuple, t4: tuple) !game {
        var gameState: game = undefined;
        gameState.window = try canvas.init_canvas(allocator, 900, 900);
        gameState.window.fill_all_pixels(tuple.create_color(0, 0, 0));

        gameState.proj = .{ .position = t1, .velocity = t2 };
        gameState.env = .{ .gravity = t3, .wind = t4 };

        return gameState;
    }

    fn draw_pixel(self: *game) void {
        const fheight: f64 = @floatFromInt(self.window.height);
        self.window.write_pixel_scale(self.proj.position.x, fheight - self.proj.position.y, pixel_color);
    }

    fn tick(self: *game) bool {
        self.proj.position = tuple.add_tuples(self.proj.position, self.proj.velocity);
        self.proj.velocity = tuple.add_tuples(tuple.add_tuples(self.proj.velocity, self.env.gravity), self.env.wind);
        draw_pixel(self);

        if (self.proj.position.y < 0) {
            self.window.save("game.ppm") catch |e| {
                std.log.err("Failed to save ppm {}\n", .{e});
            };
            return false;
        }
        return true;
    }

    fn deinit(self: *game) void {
        self.window.free_canvas();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    errdefer _ = gpa.deinit();

    const position = tuple.create_point(0, 1, 0);
    const velocity = tuple.normalize(tuple.create_vector(1, 1, 0));
    const gravity = tuple.create_vector(0, -0.1, 0);
    const wind = tuple.create_vector(-0.01, 0, 0);

    var state = game.init(&gpa.allocator(), position, velocity, gravity, wind) catch |err| {
        std.log.err("Failed to init the game state {}\n", .{err});
        return;
    };
    defer state.deinit();

    while (state.tick()) {}
}
