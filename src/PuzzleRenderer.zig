const ray = @import("raylib");
const Grid = @import("PuzzleGrid.zig");
const PuzzleRenderer = @This();

xPosition: i32,
yPosition: i32,
gridSize: i32,
bgTexture: ray.Texture,
cellSize: i32,

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

    return PuzzleRenderer{
        .xPosition = x,
        .yPosition = y,
        .gridSize = size,
        .bgTexture = bg_tex,
        .cellSize = @divExact(size, 9),
    };
}

pub fn deinit(self: *PuzzleRenderer) void {
    ray.unloadTexture(self.bgTexture);
}

pub fn draw(self: *PuzzleRenderer, grid: *Grid) !void {
    ray.drawTexture(self.bgTexture, self.xPosition, self.yPosition, .white);
    self.drawTile(grid.current_pos, .sky_blue);

    for (0..9) |i| {
        for (0..9) |j| {
            if (grid.getCurrentNumber()) |num| {
                if (num == grid.values[i][j] and !grid.current_pos.equals(@intCast(i), @intCast(j))) {
                    self.drawTile(.{ .row = @intCast(i), .col = @intCast(j) }, .light_gray);
                }
            }
            ray.drawTextCodepoint(
                try ray.getFontDefault(),
                if (grid.values[i][j] > 0) grid.values[i][j] + '0' else ' ',
                .{
                    .x = @floatFromInt(self.xPosition + @as(i32, @intCast(j)) * self.cellSize + 12),
                    .y = @floatFromInt(self.yPosition + @as(i32, @intCast(i)) * self.cellSize + 8),
                },
                32,
                if (grid.fixed[i][j]) .black else if (grid.current_pos.row == i and grid.current_pos.col == j) .blue else .gray,
            );
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
