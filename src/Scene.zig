pub const SceneType = enum {
    game,
    menu,
};

pub const Scene = struct {
    context: *anyopaque,
    draw_fn: *const fn (*anyopaque, screenWidth: i32, screenHeight: i32) void,
    update_fn: *const fn (*anyopaque) void,
    reset_fn: *const fn (*anyopaque) void,

    sceneQueue: ?SceneType = null,
    windowShouldClose: bool = false,

    pub fn draw(self: *Scene, screenWidth: i32, screenHeight: i32) void {
        self.draw_fn(self.context, screenWidth, screenHeight);
    }

    pub fn update(self: *Scene) void {
        self.update_fn(self.context);
    }

    pub fn reset(self: *Scene) void {
        self.windowShouldClose = false;
        self.sceneQueue = null;
        self.reset_fn(self.context);
    }
};
