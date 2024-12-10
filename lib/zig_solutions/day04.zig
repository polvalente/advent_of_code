const std = @import("std");

pub fn solve_part1(grid: [][]const u8) u64 {
    var count: u64 = 0;
    const num_cols = grid[0].len;
    const num_rows = grid.len;
    for (0..num_rows) |i| {
        for (0..num_cols) |j| {
            // search right (was "left" in original)
            if (
                j < num_cols - 3
                and grid[i][j] == 'X'
                and grid[i][j + 1] == 'M'
                and grid[i][j + 2] == 'A'
                and grid[i][j + 3] == 'S'
            ) {
                count += 1;
            }
            // search left
            if (
                j >= 3
                and grid[i][j] == 'X'
                and grid[i][j - 1] == 'M'
                and grid[i][j - 2] == 'A'
                and grid[i][j - 3] == 'S'
            ) {
                count += 1;
            }
            // search down
            if (
                i < num_rows - 3
                and grid[i][j] == 'X'
                and grid[i + 1][j] == 'M'
                and grid[i + 2][j] == 'A'
                and grid[i + 3][j] == 'S'
            ) {
                count += 1;
            }
            // search up
            if (
                i >= 3
                and grid[i][j] == 'X'
                and grid[i - 1][j] == 'M'
                and grid[i - 2][j] == 'A'
                and grid[i - 3][j] == 'S'
            ) {
                count += 1;
            }
            // search right down
            if (
                i < num_rows - 3 and j < num_cols - 3
                and grid[i][j] == 'X'
                and grid[i + 1][j + 1] == 'M'
                and grid[i + 2][j + 2] == 'A'
                and grid[i + 3][j + 3] == 'S'
            ) {
                count += 1;
            }
            // search right up
            if (
                i >= 3 and j < num_cols - 3
                and grid[i][j] == 'X'
                and grid[i - 1][j + 1] == 'M'
                and grid[i - 2][j + 2] == 'A'
                and grid[i - 3][j + 3] == 'S'
            ) {
                count += 1;
            }
            // search left down
            if (
                i < num_rows - 3 and j >= 3
                and grid[i][j] == 'X'
                and grid[i + 1][j - 1] == 'M'
                and grid[i + 2][j - 2] == 'A'
                and grid[i + 3][j - 3] == 'S'
            ) {
                count += 1;
            }
            // search left up
            if (
                i >= 3 and j >= 3
                and grid[i][j] == 'X'
                and grid[i - 1][j - 1] == 'M'
                and grid[i - 2][j - 2] == 'A'
                and grid[i - 3][j - 3] == 'S'
            ) {
                count += 1;
            }
        }
    }
    return count;
}

pub fn solve_part2(grid: [][]const u8) u64 {
    var count: u64 = 0;
    const num_cols = grid[0].len;
    const num_rows = grid.len;
    for (1..(num_rows - 1)) |i| {
        for (1..(num_cols - 1)) |j| {
            if (grid[i][j] != 'A') {
                continue;
            }
            // we found an A, now we need to check the surrounding cells

            const subgrid: [4]u8 = .{
                grid[i - 1][j - 1], grid[i - 1][j + 1],
                grid[i + 1][j - 1], grid[i + 1][j + 1],
            };

            if (
                std.mem.eql(u8, &subgrid, "MMSS") or
                std.mem.eql(u8, &subgrid, "MSMS") or
                std.mem.eql(u8, &subgrid, "SSMM") or
                std.mem.eql(u8, &subgrid, "SMSM")
            ) {
                count += 1;
            }
        }
    }
    return count;
}
