const PuzzleGrid = @import("PuzzleGrid.zig");
const PuzzleRenderer = @import("PuzzleRenderer.zig");
const Input = @import("Input.zig");
const ray = @import("raylib");
const SimpleMenu = @import("SimpleMenu.zig");
const std = @import("std");
const Game = @This();
const NumberButtons = @import("NumberButtons.zig");

const Scene = @import("Scene.zig").Scene;

grid: PuzzleGrid,
renderer: PuzzleRenderer,
num_buttons: NumberButtons,
pauseState: ?UiScreen = null,
elapsed: f32 = 0.0,

pauseMenu: SimpleMenu,
winMenu: SimpleMenu,
alloc: *const std.mem.Allocator,
scene: Scene,

// const test_puzzle: *const [81:0]u8 = "050703060007000800000816000000030000005000100730040086906000204840572093000409000";
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
            @divFloor(screenHeight - gridSize, 2) - 32,
            gridSize,
        ),
        .num_buttons = .{
            .btn_size = 40,
            .xPosition = @divTrunc(screenWidth - 9 * 40, 2),
            .yPosition = screenHeight - 64,
        },
        .pauseMenu = try SimpleMenu.init(alloc, 3),
        .winMenu = try SimpleMenu.init(alloc, 2),
        .alloc = alloc,
        .scene = .{
            .context = out,
            .draw_fn = draw,
            .update_fn = update,
            .reset_fn = reset,
        },
    };

    for (out.grid.complete, 1..) |comp, i| {
        out.num_buttons.setDisabled(@intCast(i), comp == 9);
    }

    const menuButton: SimpleMenu.ButtonCommand = .{
        .func = &returnToMenu,
        .text = "Return to menu",
        .context = out,
    };

    const exitButton: SimpleMenu.ButtonCommand = .{
        .func = &exitGame,
        .text = "Exit game",
        .context = out,
    };

    const resumeButton: SimpleMenu.ButtonCommand = .{
        .func = &returnToGame,
        .text = "Resume",
        .context = out,
    };

    out.pauseMenu.addButton(resumeButton);
    out.pauseMenu.addButton(menuButton);
    out.pauseMenu.addButton(exitButton);

    out.winMenu.addButton(menuButton);
    out.winMenu.addButton(exitButton);

    out.pauseMenu.position = .{ .x = @divFloor(screenWidth - out.pauseMenu.width, 2), .y = 180 };
    out.winMenu.position = .{ .x = @divFloor(screenWidth - out.winMenu.width, 2), .y = 220 };

    return out;
}

pub fn deinit(self: *Game) void {
    self.renderer.deinit();
}

pub fn update(game_ptr: *anyopaque) void {
    const self: *Game = @ptrCast(@alignCast(game_ptr));
    if (self.pauseState == null) {
        self.elapsed += ray.getFrameTime();
    }

    // Pause
    if (ray.isKeyPressed(.escape) and self.pauseState != .WIN) {
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
            .WIN => {
                if (ray.isMouseButtonPressed(.left)) {
                    const pos = ray.getMousePosition();
                    self.winMenu.checkInput(.{ .x = @intFromFloat(pos.x), .y = @intFromFloat(pos.y) });
                }
            },
        }
    } else {
        self.grid.moveActive(Input.pollMove());

        if (ray.isMouseButtonPressed(.left)) {
            const pos = ray.getMousePosition();
            const cell = self.renderer.checkInput(@intFromFloat(pos.x), @intFromFloat(pos.y));
            if (cell) |click_pos| {
                self.grid.current_pos = click_pos;
            } else {
                const num_btn = self.num_buttons.checkInput(@intFromFloat(pos.x), @intFromFloat(pos.y));
                if (num_btn) |num| {
                    self.setNumber(num);
                }
            }
        }

        if (Input.pollNumeric()) |num| {
            self.setNumber(num);
        }
        if (Input.pollDelete()) {
            self.grid.removeNumber();
        }
    }
}

pub fn reset(game_ptr: *anyopaque) void {
    const self: *Game = @ptrCast(@alignCast(game_ptr));
    self.grid = PuzzleGrid.init(test_puzzle);
    for (self.grid.complete, 1..) |comp, i| {
        self.num_buttons.setDisabled(@intCast(i), comp == 9);
    }
    self.pauseState = null;
    self.elapsed = 0.0;
}

pub fn draw(game_ptr: *anyopaque, screenWidth: i32, screenHeight: i32) void {
    const self: *Game = @ptrCast(@alignCast(game_ptr));
    self.renderer.draw(&self.grid);
    self.num_buttons.draw();

    const minutes: i32 = @intFromFloat(@divFloor(self.elapsed, 60));
    const seconds: i32 = @intFromFloat(@mod(self.elapsed, 60));

    ray.drawText(ray.textFormat("Time: %02d:%02d", .{ minutes, seconds }), 10, 10, 20, .light_gray);

    if (self.pauseState) |st| {
        ray.drawRectangle(0, 0, screenWidth, screenHeight, ray.Color.black.alpha(0.6));
        switch (st) {
            .PAUSE => {
                ray.drawText(
                    "Paused",
                    @divFloor((screenWidth - ray.measureText("paused", 40)), 2),
                    120,
                    40,
                    .white,
                );
                self.pauseMenu.draw();
            },
            .WIN => {
                ray.drawText(
                    "You win!",
                    @divFloor((screenWidth - ray.measureText("You win!", 40)), 2),
                    120,
                    40,
                    .white,
                );
                const txt = ray.textFormat("Time taken: %02i:%02i", .{ minutes, seconds });
                ray.drawText(
                    txt,
                    @divFloor((screenWidth - ray.measureText(txt, 20)), 2),
                    170,
                    20,
                    .white,
                );
                self.winMenu.draw();
            },
        }
    }
    ray.clearBackground(.white);
}

fn setNumber(self: *Game, num: u8) void {
    const val = self.grid.checkValid(num);
    if (val.result) {
        self.grid.setNumber(num);
        if (self.grid.checkSolved()) {
            self.pauseState = .WIN;
        }
        if (self.grid.complete[num - 1] == 9) {
            self.num_buttons.setDisabled(num, true);
        }
    } else {
        if (val.conflicts) |conf| {
            self.renderer.setIncorrect(conf, val.num);
        }
    }
}

fn returnToGame(game_ptr: *anyopaque) void {
    const self: *Game = @ptrCast(@alignCast(game_ptr));
    self.pauseState = null;
}

fn returnToMenu(game_ptr: *anyopaque) void {
    const self: *Game = @ptrCast(@alignCast(game_ptr));
    self.scene.sceneQueue = .menu;
}

fn exitGame(game_ptr: *anyopaque) void {
    const self: *Game = @ptrCast(@alignCast(game_ptr));
    self.scene.windowShouldClose = true;
}
