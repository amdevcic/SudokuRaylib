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

//const test_puzzle: *const [81:0]u8 = "050703060007000800000816000000030000005000100730040086906000204840572093000409000";
//const test_puzzle: *const [81:0]u8 = "679518243543729618821634957794352186358461729216897534485276391962183475137945862";
const test_puzzle: *const [81:0]u8 = "009518243543729618821634957794352186358461729216897534485276391962183475137945862";

var pause: bool = false;
const UiScreen = enum { PAUSE, WIN };

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;
    ray.initWindow(screenWidth, screenHeight, "Sudoku");
    defer ray.closeWindow();

    var grid = PuzzleGrid.init(test_puzzle);
    const gridSize = 396;
    var renderer = try PuzzleRenderer.init(
        (screenWidth - gridSize) / 2,
        (screenHeight - gridSize) / 2,
        gridSize,
    );
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

    var pauseState: ?UiScreen = null;

    ray.setExitKey(.null); // do not use Esc for exit
    ray.setTargetFPS(60);

    var elapsed: f32 = 0.0;

    while (!ray.windowShouldClose()) {
        if (pauseState == null) {
            elapsed += ray.getFrameTime();
        }
        const minutes: i32 = @intFromFloat(@divFloor(elapsed, 60));
        const seconds: i32 = @intFromFloat(@mod(elapsed, 60));

        // Pause
        if (ray.isKeyPressed(.escape)) {
            pauseState = if (pauseState == null) .PAUSE else null;
        }

        // Check inputs
        if (pauseState) |st| {
            switch (st) {
                .PAUSE => {
                    if (Input.pollClick()) |pos| {
                        if (butt.checkCollision(pos)) butt.onClick();
                    }
                },
                .WIN => {},
            }
        } else {
            grid.moveActive(Input.pollMove());

            if (Input.pollNumeric()) |num| {
                const val = grid.checkValid(num);
                if (val.result) {
                    grid.setNumber(num);
                    if (grid.complete == 81 and grid.checkSolved()) {
                        pauseState = .WIN;
                    }
                } else {
                    if (val.conflicts) |conf| {
                        renderer.setIncorrect(conf, val.num);
                    }
                }
            }
            if (Input.pollDelete()) {
                grid.removeNumber();
            }
        }

        // Draw scene
        ray.beginDrawing();
        try renderer.draw(&grid);
        ray.drawText(ray.textFormat("Time: %02d:%02d", .{ minutes, seconds }), 10, 10, 20, .light_gray);

        if (pauseState) |st| {
            ray.drawRectangle(0, 0, screenWidth, screenHeight, ray.Color.black.alpha(0.6));
            switch (st) {
                .PAUSE => {
                    ray.drawText(
                        "Paused",
                        @divFloor((screenWidth - ray.measureText("paused", 32)), 2),
                        100,
                        32,
                        .white,
                    );
                    butt.draw();
                },
                .WIN => {
                    ray.drawText(
                        "You win!",
                        @divFloor((screenWidth - ray.measureText("You win!", 32)), 2),
                        100,
                        32,
                        .white,
                    );
                },
            }
        }
        if (pause) {
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
