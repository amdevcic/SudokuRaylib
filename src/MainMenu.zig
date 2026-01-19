const ray = @import("raylib");
const Input = @import("Input.zig");
const SceneType = @import("Scene.zig").SceneType;
const SimpleMenu = @import("SimpleMenu.zig");
const std = @import("std");
const MainMenu = @This();

sceneQueue: ?SceneType = null,
simpleMenu: SimpleMenu,
windowShouldClose: bool = false,

pub fn init(alloc: *const std.mem.Allocator, screenWidth: i32, screenHeight: i32) !*MainMenu {
    _ = screenHeight;

    const out = try alloc.create(MainMenu);
    out.* = MainMenu{
        .simpleMenu = try SimpleMenu.init(alloc, 2),
    };

    const exitButton: SimpleMenu.ButtonCommand = .{
        .func = &exitGame,
        .text = "Exit game",
        .context = out,
    };
    const startButton: SimpleMenu.ButtonCommand = .{
        .func = &startGame,
        .text = "Start game",
        .context = out,
    };

    out.simpleMenu.addButton(startButton);
    out.simpleMenu.addButton(exitButton);
    out.simpleMenu.position = .{ .x = @divFloor(screenWidth - out.simpleMenu.width, 2), .y = 200 };

    return out;
}

pub fn reset(self: *MainMenu) void {
    self.sceneQueue = null;
    self.windowShouldClose = false;
}

pub fn deinit(self: *MainMenu) void {
    _ = self;
}

pub fn update(self: *MainMenu) void {
    if (ray.isMouseButtonPressed(.left)) {
        const pos = ray.getMousePosition();
        self.simpleMenu.checkInput(.{ .x = @intFromFloat(pos.x), .y = @intFromFloat(pos.y) });
    }
}

pub fn draw(self: *MainMenu, screenWidth: i32, screenHeight: i32) !void {
    _ = screenHeight;
    ray.clearBackground(.dark_blue);
    ray.drawText(
        "Sudoku",
        @divFloor((screenWidth - ray.measureText("Sudoku", 32)), 2),
        150,
        32,
        .white,
    );
    self.simpleMenu.draw();
}

fn startGame(menu_ptr: *anyopaque) void {
    const menu: *MainMenu = @ptrCast(@alignCast(menu_ptr));
    menu.sceneQueue = .game;
}

fn exitGame(menu_ptr: *anyopaque) void {
    const menu: *MainMenu = @ptrCast(@alignCast(menu_ptr));
    menu.windowShouldClose = true;
}
