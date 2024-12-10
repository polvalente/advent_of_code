const std = @import("std");

pub fn solve_part1(input: [][]i64) u64 {
    var safe_count: u64 = 0;
    for (input) |report| {
        if (is_safe1(report)) {
            safe_count += 1;
        }
    }

    return safe_count;
}

pub fn solve_part2(input: [][]i64) u64 {
    var safe_count: u64 = 0;
    for (input) |report| {
        if (is_safe2(report)) {
            safe_count += 1;
        }
    }

    return safe_count;
}

fn is_safe1(report: []i64) bool {
    var previous = report[0];

    var increasing = true;
    if (previous < report[1]) {
        increasing = true;
    } else if (previous > report[1]) {
        increasing = false;
    } else {
        return false;
    }

    for (report[1..]) |entry| {
        if (increasing and entry < previous) {
            return false;
        }

        if (!increasing and entry > previous) {
            return false;
        }

        if (@abs(entry - previous) < 1 or @abs(entry - previous) > 3) {
            return false;
        }

        previous = entry;
    }

    return true;
}

fn is_safe2(report: []i64) bool {
    if (is_safe1(report)) {
        return true;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var new_report = std.ArrayList(i64).init(allocator);
    defer new_report.deinit();
    new_report.resize(report.len - 1) catch unreachable;

    for (0..report.len) |skip_idx| {
        var current_copy_idx: u64 = 0;
        for (0..report.len) |idx| {
            if (idx != skip_idx) {
                new_report.items[current_copy_idx] = report[idx];
                current_copy_idx += 1;
            }
        }

        if (is_safe1(new_report.items)) {
            return true;
        }
    }

    return false;
}

