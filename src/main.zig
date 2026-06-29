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
    const width: i32 = 25;
    const height: i32 = 50;
    fn draw(self: SpaceShip) void {
        const w_half = @as(f32, @floatFromInt(width)) / 2.0;
        const h_half = @as(f32, @floatFromInt(height)) / 2.0;

        const cos_rot = @cos(self.Rot);
        const sin_rot = @sin(self.Rot);

        const tip_dx = h_half * sin_rot;
        const tip_dy = -h_half * cos_rot;

        const bl_dx = -w_half * cos_rot - h_half * sin_rot;
        const bl_dy = -w_half * sin_rot + h_half * cos_rot;

        const br_dx = w_half * cos_rot - h_half * sin_rot;
        const br_dy = w_half * sin_rot + h_half * cos_rot;

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

        const dx = @divTrunc((bottom_r.x - tip.x) * 70, 100);
        const dy = @divTrunc((bottom_r.y - tip.y) * 30, 100);

        const back_r = Vec2_i32{
            .x = self.PosX + dx + @as(i32, @round(br_dx)),
            .y = self.PosY + dy + @as(i32, @round(br_dy)),
        };

        const back_l = Vec2_i32{
            .x = self.PosX - dx + @as(i32, @round(bl_dx)),
            .y = self.PosY + dy + @as(i32, @round(bl_dy)),
        };

        rl.drawLine(tip.x, tip.y, bottom_l.x, bottom_l.y, .white);
        rl.drawLine(tip.x, tip.y, bottom_r.x, bottom_r.y, .white);
        rl.drawLine(back_r.x, back_r.y, back_l.x, back_l.y, .white);
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

    // fn fly() void {}
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const screenWidth = 1600;
    const screenHeight = 900;

    rl.initWindow(screenWidth, screenHeight, "Astroids");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    var fps: i32 = undefined;
    var info: [:0]const u8 = undefined;
    const velocity = 5;
    _ = velocity;

    var spaceship = SpaceShip{
        .PosX = screenWidth / 2,
        .PosY = screenHeight / 2,
        .Rot = 0,
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
        spaceship.draw();

        info = try std.fmt.allocPrintSentinel(allocator, "fps : {d:0>3} screen : {d}x{d}", .{ fps, screenWidth, screenHeight }, 0);
        rl.drawText(info, 5, 5, 10, .red);
    }
}
