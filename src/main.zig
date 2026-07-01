const std = @import("std");
const astroids = @import("astroids");
const rl = @import("raylib");

const Vec2_i32 = struct {
    x: f32,
    y: f32,
};

const Circle = struct {
    x: i32,
    y: i32,
    raduis: f32,
};

const Triangle = struct {
    v1: rl.Vector2,
    v2: rl.Vector2,
    v3: rl.Vector2,
};

const SpaceShip = struct {
    PosX: f32,
    PosY: f32,
    Rot: f32,
    MaxVelocity: f32,
    CurrentVelocity: f32,
    Acceleration: f32,

    const width: i32 = 25;
    const height: i32 = 40;

    fn draw(self: SpaceShip) void {
        const w_half = @as(f32, @floatFromInt(width)) / 2.0;
        const h_half = @as(f32, @floatFromInt(height)) / 2.0;

        const cos_rot = @cos(self.Rot);
        const sin_rot = @sin(self.Rot);

        const crossbar_pct = 0.8;

        const tip_dx = (0.0 * cos_rot) - (-h_half * sin_rot);
        const tip_dy = (0.0 * sin_rot) + (-h_half * cos_rot);

        const bl_dx = (-w_half * cos_rot) - (h_half * sin_rot);
        const bl_dy = (-w_half * sin_rot) + (h_half * cos_rot);

        const br_dx = (w_half * cos_rot) - (h_half * sin_rot);
        const br_dy = (w_half * sin_rot) + (h_half * cos_rot);

        const local_back_l_x = -w_half * crossbar_pct;
        const local_back_l_y = -h_half + (2.0 * h_half * crossbar_pct);
        const back_l_dx = (local_back_l_x * cos_rot) - (local_back_l_y * sin_rot);
        const back_l_dy = (local_back_l_x * sin_rot) + (local_back_l_y * cos_rot);

        const local_back_r_x = w_half * crossbar_pct;
        const local_back_r_y = local_back_l_y;
        const back_r_dx = (local_back_r_x * cos_rot) - (local_back_r_y * sin_rot);
        const back_r_dy = (local_back_r_x * sin_rot) + (local_back_r_y * cos_rot);

        const tip = Vec2_i32{
            .x = self.PosX + tip_dx,
            .y = self.PosY + tip_dy,
        };

        const bottom_l = Vec2_i32{
            .x = self.PosX + bl_dx,
            .y = self.PosY + bl_dy,
        };

        const bottom_r = Vec2_i32{
            .x = self.PosX + br_dx,
            .y = self.PosY + br_dy,
        };

        const back_l = Vec2_i32{
            .x = self.PosX + back_l_dx,
            .y = self.PosY + back_l_dy,
        };

        const back_r = Vec2_i32{
            .x = self.PosX + back_r_dx,
            .y = self.PosY + back_r_dy,
        };

        rl.drawLine(@round(tip.x), @round(tip.y), @round(bottom_l.x), @round(bottom_l.y), .white);
        rl.drawLine(@round(tip.x), @round(tip.y), @round(bottom_r.x), @round(bottom_r.y), .white);
        rl.drawLine(@round(back_l.x), @round(back_l.y), @round(back_r.x), @round(back_r.y), .white);
    }

    fn drawBoosters(self: SpaceShip) void {
        const w_half = @as(f32, @floatFromInt(width)) / 2.0;
        const h_half = @as(f32, @floatFromInt(height)) / 2.0;

        const cos_rot = @cos(self.Rot);
        const sin_rot = @sin(self.Rot);

        const tip_dx = (0.0 * cos_rot) + (-h_half * sin_rot);
        const tip_dy = (0.0 * sin_rot) - (-h_half * cos_rot);

        const crossbar_pct = 0.85;
        const local_back_l_x = -w_half * crossbar_pct;
        const local_back_l_y = -h_half + (2.0 * h_half * crossbar_pct);
        const back_l_dx = (local_back_l_x * cos_rot) - (local_back_l_y * sin_rot);
        const back_l_dy = (local_back_l_x * sin_rot) + (local_back_l_y * cos_rot);

        const local_back_r_x = w_half * crossbar_pct;
        const local_back_r_y = local_back_l_y;
        const back_r_dx = (local_back_r_x * cos_rot) - (local_back_r_y * sin_rot);
        const back_r_dy = (local_back_r_x * sin_rot) + (local_back_r_y * cos_rot);

        const back_l = Vec2_i32{
            .x = self.PosX + back_l_dx,
            .y = self.PosY + back_l_dy,
        };

        const back_r = Vec2_i32{
            .x = self.PosX + back_r_dx,
            .y = self.PosY + back_r_dy,
        };

        const tip = Vec2_i32{
            .x = self.PosX + tip_dx,
            .y = self.PosY + tip_dy,
        };

        rl.drawLine(@round(back_l.x), @round(back_l.y), @round(tip.x), @round(tip.y), .white);
        rl.drawLine(@round(tip.x), @round(tip.y), @round(back_r.x), @round(back_r.y), .white);
    }

    fn rotate(self: *SpaceShip, direction: []const u8) void {
        const rotation_speed = 5.0;
        const dt = rl.getFrameTime();

        if (std.mem.eql(u8, direction, "clockWise")) {
            self.Rot += rotation_speed * dt;
        }
        if (std.mem.eql(u8, direction, "counterClockWise")) {
            self.Rot -= rotation_speed * dt;
        }
    }

    fn fly(self: *SpaceShip) void {
        const sin_rot = @sin(self.Rot);
        const cos_rot = @cos(self.Rot);

        self.CurrentVelocity *= self.Acceleration;

        if (self.CurrentVelocity < 1) self.CurrentVelocity = 1;
        if (self.CurrentVelocity > self.MaxVelocity) self.CurrentVelocity = self.MaxVelocity;

        const dx = sin_rot * self.CurrentVelocity;
        const dy = cos_rot * self.CurrentVelocity;

        self.PosX += dx;
        self.PosY -= dy;
    }

    fn deAccelerate(self: *SpaceShip) void {
        const sin_rot = @sin(self.Rot);
        const cos_rot = @cos(self.Rot);

        if (self.CurrentVelocity > 0.0) {
            self.CurrentVelocity /= self.Acceleration;

            if (self.CurrentVelocity < 0.1) self.CurrentVelocity = 0.0;

            const dx = sin_rot * self.CurrentVelocity;
            const dy = cos_rot * self.CurrentVelocity;

            self.PosX += dx;
            self.PosY -= dy;
        }
    }

    fn shoot() void {}
};

const Star = struct {
    x: i32,
    y: i32,
    size: f32,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const screenWidth = 900;
    const screenHeight = 600;

    rl.setConfigFlags(.{ .msaa_4x_hint = true });
    rl.initWindow(screenWidth, screenHeight, "Astroids");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    var fps: i32 = undefined;
    var info: [:0]const u8 = undefined;

    var spaceship = SpaceShip{
        .PosX = screenWidth / 2,
        .PosY = screenHeight / 2,
        .Rot = 0,
        .MaxVelocity = 5,
        .CurrentVelocity = 0,
        .Acceleration = 1.05,
    };

    const MAX_STARS = 50;
    var stars: [MAX_STARS]Star = undefined;
    for (&stars) |*star| {
        star.x = rl.getRandomValue(0, screenWidth);
        star.y = rl.getRandomValue(0, screenHeight);
        const rand: f32 = @floatFromInt(rl.getRandomValue(8, 12));
        star.size = rand / 10;
    }

    while (!rl.windowShouldClose()) {
        defer _ = arena.reset(.retain_capacity);

        rl.beginDrawing();
        defer rl.endDrawing();
        fps = rl.getFPS();
        rl.clearBackground(.black);
        for (stars) |star| {
            rl.drawCircle(star.x, star.y, star.size, .white);
        }

        if (rl.isKeyDown(.right)) {
            spaceship.rotate("clockWise");
        }
        if (rl.isKeyDown(.left)) {
            spaceship.rotate("counterClockWise");
        }
        if (rl.isKeyDown(.up)) {
            spaceship.fly();
            spaceship.drawBoosters();
        } else {
            spaceship.deAccelerate();
        }
        spaceship.draw();

        info = try std.fmt.allocPrintSentinel(allocator, "fps : {d:0>3} screen : {d}x{d}", .{ fps, screenWidth, screenHeight }, 0);
        rl.drawText(info, 5, 5, 10, .red);
        info = try std.fmt.allocPrintSentinel(allocator, "Velocity : {} rot : {}", .{ spaceship.CurrentVelocity, spaceship.Rot }, 0);
        rl.drawText(info, 5, 20, 10, .red);
    }
}
