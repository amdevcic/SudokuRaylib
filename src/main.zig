const ray = @import("raylib");
const Game = @import("Game.zig");
const MainMenu = @import("MainMenu.zig");
const Scene = @import("Scene.zig").Scene;
const std = @import("std");

/// i32 vector because raylib uses i32 for ints
pub const Vector2i = struct {
    x: i32,
    y: i32,
    pub fn add(self: *const Vector2i, x: i32, y: i32) Vector2i {
        return .{
            .x = self.x + x,
            .y = self.y + y,
        };
    }
};

const screenWidth = 800;
const screenHeight = 450;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    ray.initWindow(screenWidth, screenHeight, "Sudoku");
    defer ray.closeWindow();

    // const game = try alloc.create(Game);
    const game = try Game.init(&alloc, screenWidth, screenHeight);
    var gameScene = Scene{ .game = game };
    defer gameScene.deinit();

    const menu = try alloc.create(MainMenu);
    menu.* = try MainMenu.init(screenWidth, screenHeight);
    var menuScene = Scene{ .menu = menu };
    defer menuScene.deinit();

    // var activeScene: Scene = menuScene;
    var activeScene: Scene = gameScene;

    ray.setExitKey(.null); // do not use Esc for exit
    ray.setTargetFPS(60);

    while (!ray.windowShouldClose() and !game.windowShouldClose) {
        if (activeScene.pollSwitchScene()) |sc| {
            activeScene = switch (sc) {
                .game => gameScene,
                .menu => menuScene,
            };
        }
        activeScene.update();

        ray.beginDrawing();
        try activeScene.draw(screenWidth, screenHeight);

        ray.endDrawing();
    }
}
