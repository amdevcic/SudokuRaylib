const ray = @import("raylib");
const Grid = @import("PuzzleGrid.zig");
const PuzzleRenderer = @This();

screenWidth: i32,
screenHeight: i32,
gridSize: i32,
bgTexture: ray.Texture,

pub fn init(w: i32, h: i32, size: i32) !PuzzleRenderer {
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
        .screenWidth = w,
        .screenHeight = h,
        .gridSize = size,
        .bgTexture = bg_tex,
    };
}

pub fn deinit(self: *PuzzleRenderer) void {
    ray.unloadTexture(self.bgTexture);
}

pub fn draw(self: *PuzzleRenderer, grid: *Grid) !void {
    const cell_size: i32 = @divTrunc(self.gridSize, 9);
    const grid_offset_x: i32 = @divTrunc(self.screenWidth - self.gridSize, 2);
    const grid_offset_y: i32 = @divTrunc(self.screenHeight - self.gridSize, 2);

    ray.drawTexture(self.bgTexture, grid_offset_x, grid_offset_y, .white);

    ray.drawRectangle(
        grid_offset_x + @as(i32, grid.current_pos.col) * cell_size,
        grid_offset_y + @as(i32, grid.current_pos.row) * cell_size,
        cell_size,
        cell_size,
        .sky_blue,
    );

    for (0..9) |i| {
        for (0..9) |j| {
            if (grid.getCurrentNumber()) |num| {
                if (num == grid.values[i][j] and !grid.current_pos.equals(@intCast(i), @intCast(j))) {
                    ray.drawRectangle(
                        grid_offset_x + @as(i32, @intCast(j)) * cell_size,
                        grid_offset_y + @as(i32, @intCast(i)) * cell_size,
                        cell_size,
                        cell_size,
                        .light_gray,
                    );
                }
            }
            ray.drawTextCodepoint(
                try ray.getFontDefault(),
                if (grid.values[i][j] > 0) grid.values[i][j] + '0' else ' ',
                .{
                    .x = @floatFromInt(grid_offset_x + @as(i32, @intCast(j)) * cell_size + 12),
                    .y = @floatFromInt(grid_offset_y + @as(i32, @intCast(i)) * cell_size + 8),
                },
                32,
                if (grid.fixed[i][j]) .black else if (grid.current_pos.row == i and grid.current_pos.col == j) .blue else .gray,
            );
        }
    }

    ray.drawLine(
        grid_offset_x,
        grid_offset_y + cell_size * 3,
        grid_offset_x + self.gridSize,
        grid_offset_y + cell_size * 3,
        .dark_gray,
    );
    ray.drawLine(
        grid_offset_x,
        grid_offset_y + cell_size * 6,
        grid_offset_x + self.gridSize,
        grid_offset_y + cell_size * 6,
        .dark_gray,
    );
    ray.drawLine(
        grid_offset_x + cell_size * 3,
        grid_offset_y,
        grid_offset_x + cell_size * 3,
        grid_offset_y + self.gridSize,
        .dark_gray,
    );
    ray.drawLine(
        grid_offset_x + cell_size * 6,
        grid_offset_y,
        grid_offset_x + cell_size * 6,
        grid_offset_y + self.gridSize,
        .dark_gray,
    );
}
