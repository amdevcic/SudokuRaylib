const root = @import("root");
const PuzzleGrid = @This();

const dim: u8 = 9;
pub const Position = struct {
    row: u8,
    col: u8,
    pub fn equals(self: *Position, row: u8, col: u8) bool {
        return (self.row == row and self.col == col);
    }
};

pub const ValidityCheckResult = struct {
    result: bool,
    conflicts: [3:0]Position = .{.{0} ** 3},
};

pub fn init(template: *const [81:0]u8) PuzzleGrid {
    var out = PuzzleGrid{};

    for (template, 0..) |ch, i| {
        const val = ch - '0';
        if (val > 0) {
            out.values[@divFloor(i, dim)][i % dim] = ch - '0';
            out.fixed[@divFloor(i, dim)][i % dim] = true;
        }
    }
    return out;
}

values: [dim][dim]u8 = .{.{0} ** 9} ** 9,
fixed: [dim][dim]bool = .{.{false} ** 9} ** 9,
current_pos: Position = .{ .row = 0, .col = 0 },

pub fn moveActive(self: *PuzzleGrid, offset: root.Vector2i) void {
    self.current_pos.col = @intCast((self.current_pos.col +% dim +% @as(u8, @intCast(@mod(offset.x, dim)))) % dim);
    self.current_pos.row = @intCast((self.current_pos.row +% dim +% @as(u8, @intCast(@mod(offset.y, dim)))) % dim);
}

pub fn setNumber(self: *PuzzleGrid, num: u8) void {
    self.values[self.current_pos.row][self.current_pos.col] = num;
}

pub fn checkValid(self: *PuzzleGrid, num: u8) bool {
    if (self.isCurrentFixed()) return false;
    if (num == 0) return true;

    const a = @divFloor(self.current_pos.row, 3);
    const b = @divFloor(self.current_pos.col, 3);

    for (0..9) |i| {
        if (self.values[self.current_pos.row][i] == num) return false; // row
        if (self.values[i][self.current_pos.col] == num) return false; // column
        if (self.values[a * 3 + @divFloor(i, 3)][b * 3 + i % 3] == num) return false; // square
    }

    return true;
}

pub fn isCurrentFixed(self: *PuzzleGrid) bool {
    return self.fixed[self.current_pos.row][self.current_pos.col];
}

pub fn getCurrentNumber(self: *PuzzleGrid) ?u8 {
    const out = self.values[self.current_pos.row][self.current_pos.col];
    return if (out != 0) out else null;
}
