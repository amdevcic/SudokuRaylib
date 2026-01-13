const PuzzleGrid = @import("PuzzleGrid.zig");
const PuzzleRenderer = @import("PuzzleRenderer.zig");
const Button = @import("Button.zig");
const Input = @import("Input.zig");
const ray = @import("raylib");
const SceneType = @import("Scene.zig").SceneType;
const Game = @This();

grid: PuzzleGrid,
renderer: PuzzleRenderer,
button: Button,
pauseState: ?UiScreen = null,
sceneQueue: ?SceneType = null,
elapsed: f32 = 0.0,

//const test_puzzle: *const [81:0]u8 = "050703060007000800000816000000030000005000100730040086906000204840572093000409000";
//const test_puzzle: *const [81:0]u8 = "679518243543729618821634957794352186358461729216897534485276391962183475137945862";
const test_puzzle: *const [81:0]u8 = "009518243543729618821634957794352186358461729216897534485276391962183475137945862";

const UiScreen = enum { PAUSE, WIN };

pub fn init(screenWidth: i32, screenHeight: i32) !Game {
    const gridSize = 396;

    const out = Game{
        .grid = PuzzleGrid.init(test_puzzle),
        .renderer = try PuzzleRenderer.init(
            @divFloor(screenWidth - gridSize, 2),
            @divFloor(screenHeight - gridSize, 2),
            gridSize,
        ),
        .button = Button{
            .onClick = &struct {
                fn func() void {}
            }.func,
            .position = .{ .x = @divFloor(screenWidth - 100, 2), .y = 200 },
            .size = .{ .x = 100, .y = 40 },
            .text = "Button",
        },
    };
    return out;
}

pub fn deinit(self: *Game) void {
    self.renderer.deinit();
}

pub fn update(self: *Game) void {
    if (self.pauseState == null) {
        self.elapsed += ray.getFrameTime();
    }
    // const minutes: i32 = @intFromFloat(@divFloor(self.elapsed, 60));
    // const seconds: i32 = @intFromFloat(@mod(self.elapsed, 60));

    // Pause
    if (ray.isKeyPressed(.escape)) {
        self.pauseState = if (self.pauseState == null) .PAUSE else null;
    }

    // Check inputs
    if (self.pauseState) |st| {
        switch (st) {
            .PAUSE => {
                if (Input.pollClick()) |pos| {
                    if (self.button.checkCollision(pos)) self.button.onClick();
                }
            },
            .WIN => {},
        }
    } else {
        self.grid.moveActive(Input.pollMove());

        if (Input.pollNumeric()) |num| {
            const val = self.grid.checkValid(num);
            if (val.result) {
                self.grid.setNumber(num);
                if (self.grid.complete == 81 and self.grid.checkSolved()) {
                    self.pauseState = .WIN;
                }
            } else {
                if (val.conflicts) |conf| {
                    self.renderer.setIncorrect(conf, val.num);
                }
            }
        }
        if (Input.pollDelete()) {
            self.grid.removeNumber();
        }
    }
}

pub fn draw(self: *Game, screenWidth: i32, screenHeight: i32) !void {
    try self.renderer.draw(&self.grid);
    // ray.drawText(ray.textFormat("Time: %02d:%02d", .{ minutes, seconds }), 10, 10, 20, .light_gray);

    if (self.pauseState) |st| {
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
                self.button.draw();
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
    ray.clearBackground(.white);
}
