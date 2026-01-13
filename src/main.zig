const ray = @import("raylib");
const Game = @import("Game.zig");
const MainMenu = @import("MainMenu.zig");
const Scene = @import("Scene.zig").Scene;

/// i32 vector because raylib uses i32 for ints
pub const Vector2i = struct {
    x: i32,
    y: i32,
};

const screenWidth = 800;
const screenHeight = 450;

pub fn main() anyerror!void {
    ray.initWindow(screenWidth, screenHeight, "Sudoku");
    defer ray.closeWindow();

    var gameScene = Scene{ .game = try Game.init(screenWidth, screenHeight) };
    defer gameScene.deinit();
    var menuScene = Scene{ .menu = try MainMenu.init(screenWidth, screenHeight) };
    defer menuScene.deinit();

    // var activeScene: Scene = menuScene;
    var activeScene: Scene = gameScene;

    ray.setExitKey(.null); // do not use Esc for exit
    ray.setTargetFPS(60);

    while (!ray.windowShouldClose()) {
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
