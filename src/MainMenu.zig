const ray = @import("raylib");
const SimpleMenu = @import("SimpleMenu.zig");
const std = @import("std");
const MainMenu = @This();

const Scene = @import("Scene.zig").Scene;

scene: Scene,
simpleMenu: SimpleMenu,

pub fn init(alloc: *const std.mem.Allocator, screenWidth: i32, screenHeight: i32) !*MainMenu {
    _ = screenHeight;

    const out = try alloc.create(MainMenu);
    out.* = MainMenu{
        .simpleMenu = try SimpleMenu.init(alloc, 2),
        .scene = .{
            .context = out,
            .draw_fn = draw,
            .update_fn = update,
            .reset_fn = reset,
        },
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

pub fn reset(menu_ptr: *anyopaque) void {
    _ = menu_ptr;
}

pub fn deinit(self: *MainMenu) void {
    self.simpleMenu.deinit();
}

pub fn update(menu_ptr: *anyopaque) void {
    const self: *MainMenu = @ptrCast(@alignCast(menu_ptr));
    if (ray.isMouseButtonPressed(.left)) {
        const pos = ray.getMousePosition();
        self.simpleMenu.checkInput(.{ .x = @intFromFloat(pos.x), .y = @intFromFloat(pos.y) });
    }
}

pub fn draw(menu_ptr: *anyopaque, screenWidth: i32, screenHeight: i32) void {
    const self: *MainMenu = @ptrCast(@alignCast(menu_ptr));
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
    const self: *MainMenu = @ptrCast(@alignCast(menu_ptr));
    self.scene.sceneQueue = .game;
}

fn exitGame(menu_ptr: *anyopaque) void {
    const self: *MainMenu = @ptrCast(@alignCast(menu_ptr));
    self.scene.windowShouldClose = true;
}
