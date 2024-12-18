const beam = @import("beam");
const std = @import("std");

const Direction = enum {
    up,
    down,
    left,
    right,
};

pub fn solve_part1(input: []const u8) i64 {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();

    var matrix = std.ArrayList(std.ArrayList(u8)).init(allocator);

    var iter = std.mem.split(u8, input, "\n");
    var pos: [2]usize = undefined;

    var i: usize = 0;
    while (iter.next()) |line| {
        var row = std.ArrayList(u8).init(allocator);
        var j: usize = 0;
        for (line) |c| {
            if (c == '^') {
                pos = .{ i, j };
            }
            row.append(c) catch unreachable;
            j += 1;
        }
        if (row.items.len > 0) {
            matrix.append(row) catch unreachable;
        }
        i += 1;
    }

    const num_rows = matrix.items.len;
    const num_cols: usize = matrix.items[0].items.len;

    var direction = Direction.up;

    var visited = std.AutoHashMap([2]usize, void).init(allocator);

    while (true) {
        const next_pos = move(pos, direction) catch break;

        if (next_pos[0] < 0 or next_pos[0] >= num_rows or next_pos[1] < 0 or next_pos[1] >= num_cols) {
            break;
        }

        if (matrix.items[next_pos[0]].items[next_pos[1]] == '#') {
            direction = turn_right(direction);
        } else {
            matrix.items[pos[0]].items[pos[1]] = '.';
            pos = next_pos;
            var c: u8 = '^';
            if (direction == .down) {
                c = 'v';
            } else if (direction == .left) {
                c = '<';
            } else if (direction == .right) {
                c = '>';
            }
            matrix.items[pos[0]].items[pos[1]] = c;
        }

        visited.put(pos, {}) catch unreachable;
    }

    return visited.count();
}

fn print_matrix(matrix: std.ArrayList(std.ArrayList(u8))) void {
    for (matrix.items) |row| {
        for (row.items) |c| {
            std.debug.print("{c}", .{c});
        }
        std.debug.print("\r\n", .{});
    }
}

fn move(pos: [2]usize, direction: Direction) ![2]usize {
    switch (direction) {
        .up => return if (pos[0] == 0) error.OutOfBounds else .{ pos[0] - 1, pos[1] },
        .down => return .{ pos[0] + 1, pos[1] },
        .left => return if (pos[1] == 0) error.OutOfBounds else .{ pos[0], pos[1] - 1 },
        .right => return .{ pos[0], pos[1] + 1 },
    }
}

fn turn_right(direction: Direction) Direction {
    return switch (direction) {
        .up => .right,
        .right => .down,
        .down => .left,
        .left => .up,
    };
}

pub fn solve_part2(input: []const u8) i64 {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();

    var matrix = std.ArrayList(std.ArrayList(u8)).init(allocator);

    var iter = std.mem.split(u8, input, "\n");
    var start: [2]usize = undefined;

    var r: usize = 0;
    while (iter.next()) |line| {
        var row = std.ArrayList(u8).init(allocator);
        var j: usize = 0;
        for (line) |c| {
            if (c == '^') {
                start = .{ r, j };
            }
            row.append(c) catch unreachable;
            j += 1;
        }
        if (row.items.len > 0) {
            matrix.append(row) catch unreachable;
        }
        r += 1;
    }

    const num_rows = matrix.items.len;
    const num_cols: usize = matrix.items[0].items.len;
    var count: i64 = 0;

    for (0..num_rows) |i| {
        for (0..num_cols) |j| {
            var pos = start;
            var direction = Direction.up;
            var visited = std.AutoHashMap(struct { pos: [2]usize, direction: Direction }, bool).init(allocator);
            var results_in_cycle = false;
            while (true) {
                const next_pos = move(pos, direction) catch break;
                if (next_pos[0] < 0 or next_pos[0] >= num_rows or next_pos[1] < 0 or next_pos[1] >= num_cols) {
                    results_in_cycle = false;
                    break;
                }

                if ((next_pos[0] == i and next_pos[1] == j) or matrix.items[next_pos[0]].items[next_pos[1]] == '#') {
                    direction = turn_right(direction);
                } else {
                    matrix.items[pos[0]].items[pos[1]] = '.';
                    pos = next_pos;
                    var c: u8 = '^';
                    if (direction == .down) {
                        c = 'v';
                    } else if (direction == .left) {
                        c = '<';
                    } else if (direction == .right) {
                        c = '>';
                    }
                    matrix.items[pos[0]].items[pos[1]] = c;
                }

                const key = .{ .pos = pos, .direction = direction };

                if (visited.get(key)) |_| {
                    results_in_cycle = true;
                    break;
                }

                visited.put(key, true) catch unreachable;
            }

            if (results_in_cycle) {
                count += 1;
            }
        }
    }

    return count;
}
