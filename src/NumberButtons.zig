const ray = @import("raylib");
const NumberButtons = @This();

xPosition: i32,
yPosition: i32,
btn_size: i32,
numberTexture: ray.Texture,

pub fn init(x: i32, y: i32, btn_size: i32) !NumberButtons {
    const num_tex = try ray.loadTexture("Sprites/numbers_small.png");

    return NumberButtons{
        .xPosition = x,
        .yPosition = y,
        .btn_size = btn_size,
        .numberTexture = num_tex,
    };
}

pub fn deinit(self: *NumberButtons) void {
    ray.unloadTexture(self.numberTexture);
}

pub fn checkInput(self: *NumberButtons, mouse_x: i32, mouse_y: i32) ?u8 {
    if (mouse_x < self.xPosition or mouse_x > self.xPosition + 9 * self.btn_size) return null;
    if (mouse_y < self.yPosition or mouse_y > self.yPosition + self.btn_size) return null;
    const ix = @divFloor(mouse_x - self.xPosition, self.btn_size);
    return @intCast(ix + 1);
}

pub fn draw(self: *NumberButtons, complete: [9]u8) void {
    for (0..9) |i| {
        const x_pos = self.xPosition + self.btn_size * @as(i32, @intCast(i));
        ray.drawRectangle(
            x_pos,
            self.yPosition,
            self.btn_size,
            self.btn_size,
            if (complete[i] == 9) .white else .gray,
        );
        ray.drawTextCodepoint(
            ray.getFontDefault() catch return,
            @intCast(i + '1'),
            .{ .x = @floatFromInt(x_pos + 12), .y = @floatFromInt(self.yPosition + 6) },
            32,
            if (complete[i] == 9) .gray else .white,
        );
        const n: i32 = @intCast(9 - complete[i]);
        if (n == 0) continue;
        ray.drawTextureRec(
            self.numberTexture,
            .{ .x = @floatFromInt(5 * (n - 1)), .y = 0, .width = 5, .height = 6 },
            .{
                .x = @floatFromInt(x_pos + @divTrunc(self.btn_size - 5, 2)),
                .y = @floatFromInt(self.yPosition + self.btn_size + 4),
            },
            .gray,
        );
    }
}
