const ray = @import("raylib");
const Grid = @import("PuzzleGrid.zig");
const PuzzleRenderer = @This();

xPosition: i32,
yPosition: i32,
gridSize: i32,

bgTexture: ray.Texture,
numberTexture: ray.Texture,
cellSize: i32,

incorrect_pos: [3]Grid.Position = .{Grid.Position.Zero} ** 3,
incorrect_alpha: [3]f32 = .{0} ** 3,

inline fn drawTile(self: *PuzzleRenderer, pos: Grid.Position, color: ray.Color) void {
    ray.drawRectangle(
        self.xPosition + @as(i32, pos.col) * self.cellSize,
        self.yPosition + @as(i32, pos.row) * self.cellSize,
        self.cellSize,
        self.cellSize,
        color,
    );
}

pub fn init(x: i32, y: i32, size: i32) !PuzzleRenderer {
    const bg_image: ray.Image = ray.genImageChecked(
        size,
        size,
        @divFloor(size, 9),
        @divFloor(size, 9),
        .white,
        .ray_white,
    );
    const bg_tex = try ray.loadTextureFromImage(bg_image);
    ray.unloadImage(bg_image);

    const num_tex = try ray.loadTexture("Sprites/numbers_small.png");

    return PuzzleRenderer{
        .xPosition = x,
        .yPosition = y,
        .gridSize = size,
        .bgTexture = bg_tex,
        .numberTexture = num_tex,
        .cellSize = @divExact(size, 9),
    };
}

pub fn deinit(self: *PuzzleRenderer) void {
    ray.unloadTexture(self.bgTexture);
    ray.unloadTexture(self.numberTexture);
}

pub fn setIncorrect(self: *PuzzleRenderer, pos: [3]Grid.Position, k: usize) void {
    self.incorrect_alpha = .{0} ** 3;
    for (0..k) |i| {
        self.incorrect_pos[i] = pos[i];
        self.incorrect_alpha[i] = 1.0;
    }
}

pub fn draw(self: *PuzzleRenderer, grid: *Grid) void {
    ray.drawTexture(self.bgTexture, self.xPosition, self.yPosition, .white);
    self.drawTile(grid.current_pos, .sky_blue);

    for (0..3) |i| {
        if (self.incorrect_alpha[i] > 0.0) {
            self.drawTile(self.incorrect_pos[i], ray.Color.alpha(ray.Color.red, self.incorrect_alpha[i]));
            self.incorrect_alpha[i] -= ray.getFrameTime() / 0.5;
        }
    }

    for (0..9) |i| {
        for (0..9) |j| {
            const x: f32 = @floatFromInt(self.xPosition + @as(i32, @intCast(j)) * self.cellSize);
            const y: f32 = @floatFromInt(self.yPosition + @as(i32, @intCast(i)) * self.cellSize);
            if (grid.getCurrentNumber()) |num| {
                if (num == grid.values[i][j] and !grid.current_pos.equals(@intCast(i), @intCast(j))) {
                    self.drawTile(.{ .row = @intCast(i), .col = @intCast(j) }, .light_gray);
                }
            }

            if (grid.values[i][j] > 0) {
                ray.drawTextCodepoint(
                    ray.getFontDefault() catch break,
                    grid.values[i][j] + '0',
                    .{
                        .x = @floatFromInt(self.xPosition + @as(i32, @intCast(j)) * self.cellSize + 12),
                        .y = @floatFromInt(self.yPosition + @as(i32, @intCast(i)) * self.cellSize + 8),
                    },
                    32,
                    if (grid.fixed[i][j]) .black else if (grid.current_pos.row == i and grid.current_pos.col == j) .blue else .gray,
                );
            } else {
                for (0..9) |m| {
                    if (grid.hasMark(@intCast(i), @intCast(j), @intCast(m + 1))) {
                        self.drawMark(x, y, m);
                    }
                }
            }
        }
    }

    // temporary, future texture will have lines
    ray.drawLine(
        self.xPosition,
        self.yPosition + self.cellSize * 3,
        self.xPosition + self.gridSize,
        self.yPosition + self.cellSize * 3,
        .dark_gray,
    );
    ray.drawLine(
        self.xPosition,
        self.yPosition + self.cellSize * 6,
        self.xPosition + self.gridSize,
        self.yPosition + self.cellSize * 6,
        .dark_gray,
    );
    ray.drawLine(
        self.xPosition + self.cellSize * 3,
        self.yPosition,
        self.xPosition + self.cellSize * 3,
        self.yPosition + self.gridSize,
        .dark_gray,
    );
    ray.drawLine(
        self.xPosition + self.cellSize * 6,
        self.yPosition,
        self.xPosition + self.cellSize * 6,
        self.yPosition + self.gridSize,
        .dark_gray,
    );
}

pub fn checkInput(self: PuzzleRenderer, x: i32, y: i32) ?Grid.Position {
    if (x < self.xPosition or x > self.xPosition + self.gridSize) return null;
    if (y < self.yPosition or y > self.yPosition + self.gridSize) return null;

    const x_cell: u8 = @intCast(@divTrunc(x - self.xPosition, self.cellSize));
    const y_cell: u8 = @intCast(@divTrunc(y - self.yPosition, self.cellSize));

    return .{ .col = x_cell, .row = y_cell };
}

pub fn drawMark(self: PuzzleRenderer, x: f32, y: f32, m: usize) void {
    const padding = 6;

    const mod: i32 = @intCast(m % 3);
    const offsetX: i32 = padding + mod * @divTrunc((self.cellSize - 5 - padding * 2), 2);
    const numX: f32 = x + @as(f32, @floatFromInt(offsetX));

    const offsetY: i32 = padding + @as(i32, @intCast(@divTrunc(m, 3))) * @divTrunc((self.cellSize - 6 - padding * 2), 2);
    const numY: f32 = y + @as(f32, @floatFromInt(offsetY));
    ray.drawTexturePro(
        self.numberTexture,
        .{ .x = @floatFromInt(5 * m), .y = 0, .width = 5, .height = 6 },
        .{ .x = numX, .y = numY, .width = 5, .height = 6 },
        .{ .x = 0, .y = 0 },
        0,
        .black,
    );
}
