const std = @import("std");
const tuple = @import("tuple.zig").tuple;

const game1 = struct {
    const projectile = struct{
        position: tuple,
        velocity: tuple,
    };

    const environment = struct {
        gravity: tuple,
        wind: tuple,
    };

    proj: projectile,
    env: environment,

    fn init(t1:tuple, t2:tuple, t3:tuple, t4:tuple) game1{
        return .{
            .proj = .{
                .position = t1,
                .velocity = t2,
            },
            .env = .{
                .gravity = t3,
                .wind = t4,
            }
        };
    }

	fn tick(self: *game1) void {
	    self.proj = projectile {
	        .position = tuple.add_tuples(self.proj.position, self.proj.velocity),
	        .velocity = tuple.add_tuples(tuple.add_tuples(self.proj.velocity, self.env.gravity), self.env.wind)
	    };
	}

};

pub fn main() void {
    var state = game1.init(tuple.create_point(0,1,0),
                           tuple.normalize(tuple.create_vector(1,1,0)),
                           tuple.create_vector(0, -0.1,0),
                           tuple. create_vector(-0.01, 0, 0));

    tuple.print(state.proj.position);

    while (true) {
        state.tick();
        tuple.print(state.proj.position);
        if (state.proj.position.y < 0) break;
    }
}
