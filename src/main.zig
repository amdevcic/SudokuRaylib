const ray = @import("raylib");
const Input = @import("Input.zig");
const PuzzleGrid = @import("PuzzleGrid.zig");
const PuzzleRenderer = @import("PuzzleRenderer.zig");
const Button = @import("Button.zig");

const std = @import("std");

/// i32 vector because raylib uses i32 for ints
pub const Vector2i = struct {
    x: i32,
    y: i32,
};

const test_puzzle: *const [81:0]u8 = "050703060007000800000816000000030000005000100730040086906000204840572093000409000";

var pause: bool = false;

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;
    ray.initWindow(screenWidth, screenHeight, "Sudoku");
    defer ray.closeWindow();

    var grid = PuzzleGrid.init(test_puzzle);
    var renderer = try PuzzleRenderer.init(screenWidth, screenHeight, 396);
    defer renderer.deinit();

    var butt = Button{
        .onClick = &struct {
            fn func() void {
                std.debug.print("button pressed\n", .{});
            }
        }.func,
        .position = .{ .x = (screenWidth - 100) / 2, .y = 200 },
        .size = .{ .x = 100, .y = 40 },
        .text = "Button",
    };

    ray.setExitKey(.null); // do not use Esc for exit
    ray.setTargetFPS(60);

    const start_time = ray.getTime();

    while (!ray.windowShouldClose()) {

        // Pause
        if (ray.isKeyPressed(.escape)) {
            pause = !pause;
        }

        // Check inputs
        if (!pause) {
            grid.moveActive(Input.pollMove());

            if (Input.pollNumeric()) |num| {
                if (grid.checkValid(num)) grid.setNumber(num);
            }
        } else {
            if (Input.pollClick()) |pos| {
                if (butt.checkCollision(pos)) butt.onClick();
            }
        }

        const elapsed = ray.getTime() - start_time;
        const minutes: i32 = @intFromFloat(@divFloor(elapsed, 60));
        const seconds: i32 = @intFromFloat(@mod(elapsed, 60));

        // Draw scene
        ray.beginDrawing();
        try renderer.draw(&grid);
        ray.drawText(ray.textFormat("Time: %02d:%02d", .{ minutes, seconds }), 10, 10, 20, .light_gray);

        if (pause) {
            ray.drawRectangle(0, 0, screenWidth, screenHeight, ray.Color.black.alpha(0.6));
            ray.drawText(
                "Paused",
                @divFloor((screenWidth - ray.measureText("paused", 32)), 2),
                100,
                32,
                .white,
            );
            butt.draw();
        }
        ray.clearBackground(.white);
        ray.endDrawing();
    }
}
