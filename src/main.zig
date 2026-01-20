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
const screenHeight = 500;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    ray.initWindow(screenWidth, screenHeight, "Sudoku");
    defer ray.closeWindow();

    const game = try Game.init(&alloc, screenWidth, screenHeight);
    const gameScene: *Scene = &game.scene;
    defer game.deinit();

    const menu = try MainMenu.init(&alloc, screenWidth, screenHeight);
    const menuScene: *Scene = &menu.scene;
    defer menu.deinit();

    var activeScene: *Scene = menuScene;

    ray.setExitKey(.null); // do not use Esc for exit
    ray.setTargetFPS(60);

    while (!ray.windowShouldClose() and !activeScene.windowShouldClose) {
        if (activeScene.sceneQueue) |sc| {
            activeScene = switch (sc) {
                .game => gameScene,
                .menu => menuScene,
            };
            activeScene.reset();
        }
        activeScene.update();

        ray.beginDrawing();
        activeScene.draw(screenWidth, screenHeight);
        ray.endDrawing();
    }
}
