const root = @import("root");
const PuzzleGrid = @This();

const dim: u8 = 9;
pub const Position = struct {
    row: u8,
    col: u8,
    pub const Zero = Position{ .row = 0, .col = 0 };
    pub fn equals(self: *Position, row: u8, col: u8) bool {
        return (self.row == row and self.col == col);
    }
};

pub const ValidityCheckResult = struct {
    result: bool,
    conflicts: ?[3]Position = null,
    num: u2 = 0,
};

values: [dim][dim]u8 = .{.{0} ** 9} ** 9,
fixed: [dim][dim]bool = .{.{false} ** 9} ** 9,
current_pos: Position = .{ .row = 0, .col = 0 },
complete: [9]u8 = .{0} ** 9,
marks: [9][9]u9 = .{.{0} ** 9} ** 9,

pub fn init(template: *const [81:0]u8) PuzzleGrid {
    var out = PuzzleGrid{};

    for (template, 0..) |ch, i| {
        const val = ch - '0';
        if (val > 0) {
            out.values[@divFloor(i, dim)][i % dim] = ch - '0';
            out.fixed[@divFloor(i, dim)][i % dim] = true;
            out.complete[val - 1] += 1;
        }
    }
    return out;
}

pub fn moveActive(self: *PuzzleGrid, offset: root.Vector2i) void {
    self.current_pos.col = @intCast((self.current_pos.col +% dim +% @as(u8, @intCast(@mod(offset.x, dim)))) % dim);
    self.current_pos.row = @intCast((self.current_pos.row +% dim +% @as(u8, @intCast(@mod(offset.y, dim)))) % dim);
}

pub fn setNumber(self: *PuzzleGrid, num: u8) void {
    if (num == 0 or num > 9) return;
    self.values[self.current_pos.row][self.current_pos.col] = num;
    self.complete[num - 1] += 1;
}

pub fn removeNumber(self: *PuzzleGrid) void {
    if (self.isCurrentFixed()) return;
    if (self.getCurrentNumber()) |num| {
        self.values[self.current_pos.row][self.current_pos.col] = 0;
        self.complete[num - 1] -= 1;
    }
}

pub fn checkValid(self: *PuzzleGrid, num: u8) ValidityCheckResult {
    if (self.isCurrentFixed()) return .{ .result = false };
    if (self.complete[num - 1] == 9) return .{ .result = false };
    if (num == 0) return .{ .result = false };

    var out = ValidityCheckResult{ .result = true };
    var k: u2 = 0;
    var pos: [3]Position = .{Position.Zero} ** 3;

    const a = @divFloor(self.current_pos.row, 3);
    const b = @divFloor(self.current_pos.col, 3);

    for (0..9) |i| {
        if (self.values[self.current_pos.row][i] == num) {
            out.result = false;
            pos[k] = .{ .row = self.current_pos.row, .col = @intCast(i) };
            k += 1;
        } // row

        if (self.values[i][self.current_pos.col] == num) {
            out.result = false;
            pos[k] = .{ .row = @intCast(i), .col = self.current_pos.col };
            for (0..k) |j| {
                if (pos[j].equals(pos[k].row, pos[k].col)) {
                    break;
                }
            } else k += 1;
        } // column

        if (self.values[a * 3 + @divFloor(i, 3)][b * 3 + i % 3] == num) {
            out.result = false;
            pos[k] = .{ .row = @intCast(a * 3 + @divFloor(i, 3)), .col = @intCast(b * 3 + i % 3) };
            for (0..k) |j| {
                if (pos[j].equals(pos[k].row, pos[k].col)) {
                    break;
                }
            } else k += 1;
        } // square
    }

    if (k > 0) {
        out.conflicts = pos;
        out.num = k;
    }
    return out;
}

pub inline fn isCurrentFixed(self: *PuzzleGrid) bool {
    return self.fixed[self.current_pos.row][self.current_pos.col];
}

pub fn getCurrentNumber(self: *PuzzleGrid) ?u8 {
    const out = self.values[self.current_pos.row][self.current_pos.col];
    return if (out != 0) out else null;
}

pub fn checkSolved(self: *PuzzleGrid) bool {
    for (0..9) |j| {
        if (self.complete[j] != 9) return false;
        var row_flags: [9]bool = .{false} ** 9;
        var col_flags: [9]bool = .{false} ** 9;
        var sqr_flags: [9]bool = .{false} ** 9;

        for (0..9) |i| {
            const row: u8 = self.values[j][i];
            const col: u8 = self.values[i][j];

            const a = @divFloor(j, 3);
            const b = j % 3;
            const sqr = self.values[a * 3 + @divFloor(i, 3)][b * 3 + i % 3];

            if (row == 0 or col == 0 or sqr == 0) return false;
            if (row_flags[row - 1]) return false else row_flags[row - 1] = true;
            if (col_flags[col - 1]) return false else col_flags[col - 1] = true;
            if (sqr_flags[sqr - 1]) return false else sqr_flags[sqr - 1] = true;
        }
    }
    return true;
}

pub fn toggleMark(self: *PuzzleGrid, row: u8, col: u8, num: u8) void {
    if (self.values[row][col] != 0) return;
    self.marks[row][col] ^= @as(u9, 1) << @intCast(num - 1);
}

pub fn removeMark(self: *PuzzleGrid, row: u8, col: u8, num: u8) void {
    self.marks[row][col] &= ~(@as(u9, 1) << @intCast(num - 1));
}

pub fn hasMark(self: *PuzzleGrid, row: u8, col: u8, num: u8) bool {
    return (self.marks[row][col] & (@as(u9, 1) << @intCast(num - 1))) != 0;
}
