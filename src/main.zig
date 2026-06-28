const std = @import("std");
const astroids = @import("astroids");
const rl = @import("raylib");

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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const screenWidth = 800;
    const screenHeight = 600;

    rl.initWindow(screenWidth, screenHeight, "Astroids");
    defer rl.closeWindow();

    rl.setTargetFPS(360);
    var fps: i32 = undefined;
    var info: [:0]const u8 = undefined;
    var circle = Circle{
        .x = screenWidth / 2,
        .y = screenHeight / 2,
        .raduis = 50,
    };
    const triangle = Triangle{
        .v1 = .{ .x = 0, .y = 100 },
        .v2 = .{ .x = 250, .y = 300 },
        .v3 = .{ .x = 100, .y = 100 },
    };
    const velocity = 5;

    while (!rl.windowShouldClose()) {
        defer _ = arena.reset(.retain_capacity);

        rl.beginDrawing();
        defer rl.endDrawing();
        fps = rl.getFPS();
        rl.clearBackground(.black);

        if (rl.isKeyDown(.right)) {
            if (@as(f32, @floatFromInt(circle.x)) + circle.raduis < @as(f32, @floatFromInt(screenWidth))) {
                circle.x += velocity;
            }
        }
        if (rl.isKeyDown(.left)) {
            if (@as(f32, @floatFromInt(circle.x)) - circle.raduis > @as(f32, @floatFromInt(0))) {
                circle.x -= velocity;
            }
        }
        if (rl.isKeyDown(.up)) {
            if (@as(f32, @floatFromInt(circle.y)) - circle.raduis > @as(f32, @floatFromInt(0))) {
                circle.y -= velocity;
            }
        }
        if (rl.isKeyDown(.down)) {
            if (@as(f32, @floatFromInt(circle.y)) + circle.raduis < @as(f32, @floatFromInt(screenHeight))) {
                circle.y += velocity;
            }
        }

        rl.drawCircle(circle.x, circle.y, circle.raduis, .white);

        info = try std.fmt.allocPrintSentinel(allocator, "fps : {d}", .{fps}, 0);
        rl.drawText(info, 5, 5, 10, .red);
        rl.drawTriangleLines(triangle.v1, triangle.v2, triangle.v3, .magenta);
    }
}
