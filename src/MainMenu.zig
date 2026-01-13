const ray = @import("raylib");
const Input = @import("Input.zig");
const SceneType = @import("Scene.zig").SceneType;
const MainMenu = @This();

sceneQueue: ?SceneType = null,

pub fn init(screenWidth: i32, screenHeight: i32) !MainMenu {
    _ = screenWidth;
    _ = screenHeight;
    return MainMenu{};
}

pub fn deinit(self: *MainMenu) void {
    _ = self;
}
pub fn update(self: *MainMenu) void {
    _ = self;
}

pub fn draw(self: *MainMenu, screenWidth: i32, screenHeight: i32) !void {
    _ = self;
    ray.drawRectangle(50, 50, screenWidth - 100, screenHeight - 100, .sky_blue);
    ray.clearBackground(.blue);
}
