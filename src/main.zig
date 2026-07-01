const std = @import("std");
const astroids = @import("astroids");
const rl = @import("raylib");

const Vec2_i32 = struct {
    x: i32,
    y: i32,
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
    PosX: i32,
    PosY: i32,
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
            .x = self.PosX + @as(i32, @round(tip_dx)),
            .y = self.PosY + @as(i32, @round(tip_dy)),
        };

        const bottom_l = Vec2_i32{
            .x = self.PosX + @as(i32, @round(bl_dx)),
            .y = self.PosY + @as(i32, @round(bl_dy)),
        };

        const bottom_r = Vec2_i32{
            .x = self.PosX + @as(i32, @round(br_dx)),
            .y = self.PosY + @as(i32, @round(br_dy)),
        };

        const back_l = Vec2_i32{
            .x = self.PosX + @as(i32, @round(back_l_dx)),
            .y = self.PosY + @as(i32, @round(back_l_dy)),
        };

        const back_r = Vec2_i32{
            .x = self.PosX + @as(i32, @round(back_r_dx)),
            .y = self.PosY + @as(i32, @round(back_r_dy)),
        };

        rl.drawLine(tip.x, tip.y, bottom_l.x, bottom_l.y, .white);
        rl.drawLine(tip.x, tip.y, bottom_r.x, bottom_r.y, .white);
        rl.drawLine(back_l.x, back_l.y, back_r.x, back_r.y, .white);
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
            .x = self.PosX + @as(i32, @round(back_l_dx)),
            .y = self.PosY + @as(i32, @round(back_l_dy)),
        };

        const back_r = Vec2_i32{
            .x = self.PosX + @as(i32, @round(back_r_dx)),
            .y = self.PosY + @as(i32, @round(back_r_dy)),
        };

        const tip = Vec2_i32{
            .x = self.PosX + @as(i32, @round(tip_dx)),
            .y = self.PosY + @as(i32, @round(tip_dy)),
        };

        rl.drawLine(back_l.x, back_l.y, tip.x, tip.y, .white);
        rl.drawLine(tip.x, tip.y, back_r.x, back_r.y, .white);
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

        self.PosX += @as(i32, @round(dx));
        self.PosY -= @as(i32, @round(dy));
    }

    fn deAccelerate(self: *SpaceShip) void {
        const sin_rot = @sin(self.Rot);
        const cos_rot = @cos(self.Rot);

        if (self.CurrentVelocity > 0.0) {
            self.CurrentVelocity /= self.Acceleration;

            if (self.CurrentVelocity < 0.1) self.CurrentVelocity = 0.0;

            const dx = sin_rot * self.CurrentVelocity;
            const dy = cos_rot * self.CurrentVelocity;

            self.PosX += @as(i32, @round(dx));
            self.PosY -= @as(i32, @round(dy));
        }
    }
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

    while (!rl.windowShouldClose()) {
        defer _ = arena.reset(.retain_capacity);

        rl.beginDrawing();
        defer rl.endDrawing();
        fps = rl.getFPS();
        rl.clearBackground(.black);

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
