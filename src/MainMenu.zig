const MainMenu = @This();

pub fn init(screenWidth: i32, screenHeight: i32) !MainMenu {
    _ = screenWidth;
    _ = screenHeight;
}

pub fn deinit(self: *MainMenu) void {
    _ = self;
}
pub fn update(self: *MainMenu) void {
    _ = self;
}

pub fn draw(self: *MainMenu, screenWidth: i32, screenHeight: i32) !void {
    _ = self;
    _ = screenWidth;
    _ = screenHeight;
}
