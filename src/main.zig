const std = @import("std");
const astroids = @import("astroids");
const rl = @import("raylib");

const screenWidth = 900;
const screenHeight = 600;
const pi = 3.14;

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

    fn inScreen(self: SpaceShip) bool {
        return (self.PosX <= screenWidth and self.PosX >= 0 and self.PosY >= 0 and self.PosY <= screenHeight);
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

        if (self.inScreen()) {
            self.PosX += dx;
            self.PosY -= dy;
        } else {
            if (self.PosX > screenWidth) self.PosX = 0;
            if (self.PosX < 0) self.PosX = screenWidth;
            if (self.PosY > screenHeight) self.PosY = 0;
            if (self.PosY < 0) self.PosY = screenHeight;
        }
    }

    fn deAccelerate(self: *SpaceShip) void {
        const sin_rot = @sin(self.Rot);
        const cos_rot = @cos(self.Rot);

        if (self.CurrentVelocity > 0.0) {
            self.CurrentVelocity /= self.Acceleration;

            if (self.CurrentVelocity < 0.1) self.CurrentVelocity = 0.0;

            const dx = sin_rot * self.CurrentVelocity;
            const dy = cos_rot * self.CurrentVelocity;

            if (self.inScreen()) {
                self.PosX += dx;
                self.PosY -= dy;
            } else {
                if (self.PosX > screenWidth) self.PosX = 0;
                if (self.PosX < 0) self.PosX = screenWidth;
                if (self.PosY > screenHeight) self.PosY = 0;
                if (self.PosY < 0) self.PosY = screenHeight;
            }
        }
    }

    fn shoot(self: SpaceShip) Bullet {
        const h_half = @as(f32, @floatFromInt(height)) / 2.0;

        const cos_rot = @cos(self.Rot);
        const sin_rot = @sin(self.Rot);

        const tip_dx = (0.0 * cos_rot) - (-h_half * sin_rot);
        const tip_dy = (0.0 * sin_rot) + (-h_half * cos_rot);

        const tip = Vec2_i32{
            .x = self.PosX + 1.5 * tip_dx,
            .y = self.PosY + 1.5 * tip_dy,
        };

        return Bullet{
            .PosX = tip.x,
            .PosY = tip.y,
            .Rot = self.Rot,
        };
    }
};

const Bullet = struct {
    PosX: f32,
    PosY: f32,
    Rot: f32,

    const length = 20;
    const Velocity = 20;

    fn draw(self: Bullet) void {
        const cos_rot = @cos(self.Rot);
        const sin_rot = @sin(self.Rot);
        const end_x = self.PosX - (sin_rot * length);
        const end_y = self.PosY + (cos_rot * length);
        const startPos = rl.Vector2{
            .x = self.PosX,
            .y = self.PosY,
        };

        const endPos = rl.Vector2{
            .x = end_x,
            .y = end_y,
        };
        const thicc: f32 = 2;
        rl.drawLineEx(startPos, endPos, thicc, .white);
    }

    fn move(self: *Bullet) void {
        const cos_rot = @cos(self.Rot);
        const sin_rot = @sin(self.Rot);
        const dx = sin_rot * Velocity;
        const dy = cos_rot * Velocity;
        self.PosX += dx;
        self.PosY -= dy;
    }

    fn inScreen(self: Bullet) bool {
        const top = 0 - 100;
        const bottom = screenHeight + 100;
        const left = 0 - 100;
        const right = screenWidth + 100;
        return (self.PosX <= right and self.PosX >= left and self.PosY >= top and self.PosY <= bottom);
    }
};

const Star = struct {
    x: i32,
    y: i32,
    size: f32,
};

fn removeBullet(bullets: []Bullet, nBullets: *usize, index: usize) void {
    for (index..nBullets.* - 1) |i| {
        bullets[i] = bullets[i + 1];
    }
    nBullets.* -= 1;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

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
        .MaxVelocity = 8,
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

    var bullets: [100]Bullet = undefined;
    var nBullets: usize = 0;
    const coolDown: f32 = 0.15;
    var elapsedTime: f32 = coolDown;

    while (!rl.windowShouldClose()) {
        defer _ = arena.reset(.retain_capacity);

        const dt = rl.getFrameTime();
        if (elapsedTime < coolDown) {
            elapsedTime += dt;
        }
        rl.beginDrawing();
        defer rl.endDrawing();
        fps = rl.getFPS();
        rl.clearBackground(.black);

        for (stars) |star| {
            rl.drawCircle(star.x, star.y, star.size, .white);
        }

        if (rl.isKeyDown(.space)) {
            if (elapsedTime >= coolDown) {
                bullets[nBullets] = spaceship.shoot();
                nBullets += 1;
                elapsedTime = 0;
            }
        }
        for (0..nBullets) |i| {
            if (bullets[i].inScreen()) {
                bullets[i].move();
                bullets[i].draw();
            } else {
                removeBullet(&bullets, &nBullets, i);
            }
        }

        if (rl.isKeyDown(.right) or rl.isKeyDown(.d)) {
            spaceship.rotate("clockWise");
        }
        if (rl.isKeyDown(.left) or rl.isKeyDown(.a)) {
            spaceship.rotate("counterClockWise");
        }
        if (rl.isKeyDown(.up) or rl.isKeyDown(.w)) {
            spaceship.fly();
            spaceship.drawBoosters();
        } else {
            spaceship.deAccelerate();
        }
        spaceship.draw();

        info = try std.fmt.allocPrintSentinel(allocator, "fps : {d:0>3} screen : {d}x{d}", .{ fps, screenWidth, screenHeight }, 0);
        rl.drawText(info, 5, 5, 10, .red);
        info = try std.fmt.allocPrintSentinel(allocator, "Velocity : {} rot : {}", .{ spaceship.CurrentVelocity, spaceship.Rot / pi * 180 }, 0);
        rl.drawText(info, 5, 25, 10, .red);
        info = try std.fmt.allocPrintSentinel(allocator, "x : {} y : {}", .{ spaceship.PosX, spaceship.PosY }, 0);
        rl.drawText(info, 5, 45, 10, .red);

        for (0..nBullets) |i| {
            info = try std.fmt.allocPrintSentinel(allocator, "bullet n:{} PosX: {}  PosY: {}", .{ i, bullets[i].PosX, bullets[i].PosY }, 0);
            const i_32: i32 = @intCast(i);
            rl.drawText(info, 5, 65 + i_32 * 20, 10, .red);
        }
    }
}
