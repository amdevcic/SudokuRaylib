const root = @import("root");
const ray = @import("raylib");
const Button = @This();

position: root.Vector2i,
size: root.Vector2i,
text: [:0]const u8,
onClick: *const fn () void,

pub fn checkCollision(self: *Button, pos: root.Vector2i) bool {
    return (pos.x > self.position.x and pos.x < self.position.x + self.size.x and
        pos.y > self.position.y and pos.y < self.position.y + self.size.y);
}

pub fn draw(self: *Button) void {
    const text_size = ray.measureText(self.text, 20);
    ray.drawRectangle(self.position.x, self.position.y, self.size.x, self.size.y, .blue);
    ray.drawText(
        self.text,
        self.position.x + @divFloor(self.size.x - text_size, 2),
        self.position.y + @divFloor(self.size.y - 20, 2),
        20,
        .white,
    );
}
