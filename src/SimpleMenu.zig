const ray = @import("raylib");
const SimpleMenu = @This();
const std = @import("std");
const root = @import("root");

position: root.Vector2i = .{ .x = 0, .y = 0 },
width: i32 = 200,
button_height: i32 = 40,
spacing: i32 = 8,
button_color: ray.Color = .blue,

alloc: *const std.mem.Allocator,
buttons: std.ArrayList(ButtonCommand),

pub const ButtonCommand = struct {
    func: *const fn (*anyopaque) void,
    text: [:0]const u8,
    context: *anyopaque,
    pub fn onClick(self: *const ButtonCommand) void {
        self.func(self.context);
    }
};

pub fn init(alloc: *const std.mem.Allocator, comptime n_buttons: usize) !SimpleMenu {
    return SimpleMenu{
        .alloc = alloc,
        .buttons = try std.ArrayList(ButtonCommand).initCapacity(alloc.*, n_buttons),
    };
}

pub fn addButton(self: *SimpleMenu, button: ButtonCommand) void {
    const ptr = self.buttons.addOneBounded() catch return;
    ptr.* = button;
}

pub fn draw(self: *SimpleMenu) void {
    for (self.buttons.items, 0..) |b, i| {
        const text_size = ray.measureText(b.text, 20);
        ray.drawRectangle(
            self.position.x,
            self.position.y + @as(i32, @intCast(i)) * (self.button_height + self.spacing),
            self.width,
            self.button_height,
            self.button_color,
        );
        ray.drawText(
            b.text,
            self.position.x + @divFloor(self.width - text_size, 2),
            self.position.y + @as(i32, @intCast(i)) * (self.button_height + self.spacing) + @divFloor(self.button_height - 20, 2),
            20,
            .white,
        );
    }
}

pub fn checkInput(self: *SimpleMenu, mouse_position: root.Vector2i) void {
    const len = @as(i32, @intCast(self.buttons.items.len));
    if (mouse_position.x < self.position.x or mouse_position.x > self.position.x + self.width)
        return;
    if (mouse_position.y < self.position.y or mouse_position.y > self.position.y + (self.button_height + self.spacing) * len)
        return;
    const ix = @divTrunc(mouse_position.y - self.position.y, self.button_height + self.spacing);
    const button_y = self.position.y + ix * (self.button_height + self.spacing);
    if (mouse_position.y <= button_y + self.button_height) {
        self.buttons.items[@intCast(ix)].onClick();
    }
}

pub fn deinit(self: *SimpleMenu) void {
    self.alloc.destroy(&self.buttons);
}
