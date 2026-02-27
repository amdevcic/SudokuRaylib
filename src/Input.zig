const ray = @import("raylib");
const key = ray.KeyboardKey;
const root = @import("root");

pub fn pollNumeric() ?u8 {
    for (1..10) |i| {
        const key_code = @intFromEnum(key.one) + @as(c_int, @intCast(i - 1));
        if (ray.isKeyPressed(@enumFromInt(key_code))) {
            return @intCast(i);
        }
    }
    return null;
}

pub fn pollMove() root.Vector2i {
    return .{
        .x = if (ray.isKeyPressed(key.left)) -1 else if (ray.isKeyPressed(key.right)) 1 else 0,
        .y = if (ray.isKeyPressed(key.up)) -1 else if (ray.isKeyPressed(key.down)) 1 else 0,
    };
}

pub fn pollClick() ?root.Vector2i {
    if (ray.isMouseButtonPressed(.left)) {
        const ray_pos = ray.getMousePosition();
        return root.Vector2i{ .x = @intFromFloat(ray_pos.x), .y = @intFromFloat(ray_pos.y) };
    } else return null;
}

pub fn pollDelete() bool {
    return (ray.isKeyPressed(key.zero) or ray.isKeyPressed(key.backspace));
}
