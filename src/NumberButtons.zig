const ray = @import("raylib");
const NumberButtons = @This();

xPosition: i32,
yPosition: i32,
btn_size: i32,

pub fn checkInput(self: *NumberButtons, mouse_x: i32, mouse_y: i32) ?u8 {
    if (mouse_x < self.xPosition or mouse_x > self.xPosition + 9 * self.btn_size) return null;
    if (mouse_y < self.yPosition or mouse_y > self.yPosition + self.btn_size) return null;
    const ix = @divFloor(mouse_x - self.xPosition, self.btn_size);
    return @intCast(ix + 1);
}

pub fn draw(self: *NumberButtons) void {
    for (0..9) |i| {
        const x_pos = self.xPosition + self.btn_size * @as(i32, @intCast(i));
        ray.drawRectangle(
            x_pos,
            self.yPosition,
            self.btn_size,
            self.btn_size,
            if (i % 2 == 0) .dark_gray else .gray,
        );
        ray.drawTextCodepoint(
            ray.getFontDefault() catch return,
            @intCast(i + '1'),
            .{ .x = @floatFromInt(x_pos + 12), .y = @floatFromInt(self.yPosition + 6) },
            32,
            .white,
        );
    }
}
