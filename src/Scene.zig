const Game = @import("Game.zig");
const MainMenu = @import("MainMenu.zig");

pub const SceneType = enum {
    game,
    menu,
};

pub const Scene = union(SceneType) {
    game: Game,
    menu: MainMenu,

    pub fn init(self: *Scene, screenWidth: i32, screenHeight: i32) void {
        switch (self.*) {
            .game => |*g| g.init(screenWidth, screenHeight),
            .menu => |*m| m.init(screenWidth, screenHeight),
        }
    }

    pub fn deinit(self: *Scene) void {
        switch (self.*) {
            .game => |*g| g.deinit(),
            .menu => |*m| m.deinit(),
        }
    }

    pub fn update(self: *Scene) void {
        switch (self.*) {
            .game => |*g| g.update(),
            .menu => |*m| m.update(),
        }
    }

    pub fn draw(self: *Scene, screenWidth: i32, screenHeight: i32) !void {
        switch (self.*) {
            .game => |*g| try g.draw(screenWidth, screenHeight),
            .menu => |*m| try m.draw(screenWidth, screenHeight),
        }
    }

    pub fn pollSwitchScene(self: *Scene) ?SceneType {
        return switch (self.*) {
            .game => |*g| g.sceneQueue,
            .menu => |*m| m.sceneQueue,
        };
    }
};
