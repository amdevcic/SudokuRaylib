const PuzzleGrid = @import("PuzzleGrid.zig");
const PuzzleRenderer = @import("PuzzleRenderer.zig");
const Input = @import("Input.zig");
const ray = @import("raylib");
const SceneType = @import("Scene.zig").SceneType;
const SimpleMenu = @import("SimpleMenu.zig");
const std = @import("std");
const Game = @This();

grid: PuzzleGrid,
renderer: PuzzleRenderer,
pauseState: ?UiScreen = null,
sceneQueue: ?SceneType = null,
elapsed: f32 = 0.0,
windowShouldClose: bool = false,

pauseMenu: SimpleMenu,
winMenu: SimpleMenu,
alloc: *const std.mem.Allocator,

//const test_puzzle: *const [81:0]u8 = "050703060007000800000816000000030000005000100730040086906000204840572093000409000";
//const test_puzzle: *const [81:0]u8 = "679518243543729618821634957794352186358461729216897534485276391962183475137945862";
const test_puzzle: *const [81:0]u8 = "009518243543729618821634957794352186358461729216897534485276391962183475137945862";

const UiScreen = enum { PAUSE, WIN };

pub fn init(alloc: *const std.mem.Allocator, screenWidth: i32, screenHeight: i32) !*Game {
    const gridSize = 396;

    const out = try alloc.create(Game);
    errdefer alloc.destroy(out);

    out.* = Game{
        .grid = PuzzleGrid.init(test_puzzle),
        .renderer = try PuzzleRenderer.init(
            @divFloor(screenWidth - gridSize, 2),
            @divFloor(screenHeight - gridSize, 2),
            gridSize,
        ),
        .pauseMenu = try SimpleMenu.init(alloc, 2),
        .winMenu = try SimpleMenu.init(alloc, 2),
        .alloc = alloc,
    };
    const menuButton: SimpleMenu.ButtonCommand = .{
        .func = &returnToMenu,
        .text = "Return to menu",
        .context = out,
    };

    out.pauseMenu.addButton(menuButton);
    out.winMenu.addButton(menuButton);

    const exitButton: SimpleMenu.ButtonCommand = .{
        .func = &exitGame,
        .text = "Exit game",
        .context = out,
    };

    out.pauseMenu.addButton(exitButton);
    out.winMenu.addButton(exitButton);

    out.pauseMenu.position = .{ .x = @divFloor(screenWidth - out.pauseMenu.width, 2), .y = 150 };
    out.winMenu.position = .{ .x = @divFloor(screenWidth - out.winMenu.width, 2), .y = 150 };

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
                if (ray.isMouseButtonPressed(.left)) {
                    const pos = ray.getMousePosition();
                    self.pauseMenu.checkInput(.{ .x = @intFromFloat(pos.x), .y = @intFromFloat(pos.y) });
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
                self.pauseMenu.draw();
            },
            .WIN => {
                ray.drawText(
                    "You win!",
                    @divFloor((screenWidth - ray.measureText("You win!", 32)), 2),
                    100,
                    32,
                    .white,
                );
                self.winMenu.draw();
            },
        }
    }
    ray.clearBackground(.white);
}

fn returnToMenu(game_ptr: *anyopaque) void {
    const game: *Game = @ptrCast(@alignCast(game_ptr));
    game.sceneQueue = .menu;
}

fn exitGame(game_ptr: *anyopaque) void {
    // ray.closeWindow();
    const game: *Game = @ptrCast(@alignCast(game_ptr));
    game.windowShouldClose = true;
}
