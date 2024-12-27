const std = @import("std");
const beam = @import("beam");

pub fn parse(input: []const u8) []u64 {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();
    var lines = std.mem.splitSequence(u8, input, "\n");

    var numbers = std.ArrayList(u64).init(allocator);
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const number = std.fmt.parseInt(u64, line, 10) catch unreachable;
        numbers.append(number) catch unreachable;
    }

    return numbers.items;
}

pub fn solve_part1(numbers: []u64) u64 {
    var result: u64 = 0;
    for (numbers) |number| {
        result += secret_rounds(number, 2000);
    }
    return result;
}

pub fn solve_part2(numbers: []u64) i64 {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();

    var data = std.ArrayList(struct { changes: std.ArrayList(i64), prices: std.ArrayList(i64) }).init(allocator);

    for (numbers) |init_secret| {
        var secret = init_secret;
        var secrets = std.ArrayList(u64).init(allocator);
        for (0..2001) |_| {
            secrets.append(secret) catch unreachable;
            secret = next_secret(secret);
        }

        var prices = std.ArrayList(i64).init(allocator);
        for (secrets.items) |s| {
            prices.append(@as(i64, @intCast(s % 10))) catch unreachable;
        }

        var changes = std.ArrayList(i64).init(allocator);
        var previous_price: i64 = 0;
        for (prices.items) |p| {
            changes.append(p - previous_price) catch unreachable;
            previous_price = p;
        }

        data.append(.{ .changes = changes, .prices = prices }) catch unreachable;
    }

    var sequenceAccumulator = std.AutoHashMap([4]i64, i64).init(allocator);
    for (data.items) |entry| {
        var seen = std.AutoHashMap([4]i64, bool).init(allocator);
        for (3..(entry.changes.items.len - 1)) |i| {
            var tuple: [4]i64 = undefined;
            @memcpy(&tuple, entry.changes.items[(i - 3)..(i + 1)]);
            if (seen.contains(tuple)) {
                continue;
            }
            seen.put(tuple, true) catch unreachable;

            if (sequenceAccumulator.get(tuple)) |value| {
                sequenceAccumulator.put(tuple, value + entry.prices.items[i]) catch unreachable;
            } else {
                sequenceAccumulator.put(tuple, entry.prices.items[i]) catch unreachable;
            }
        }
    }

    var max: i64 = 0;
    var iter = sequenceAccumulator.valueIterator();
    while (iter.next()) |value| {
        if (value.* > max) {
            max = value.*;
        }
    }
    return max;
}

pub fn secret_rounds(secret: u64, rounds: u64) u64 {
    var next = secret;
    for (0..rounds) |_| {
        next = next_secret(next);
    }
    return next;
}

pub fn next_secret(secret: u64) u64 {
    var next = (secret << 6) ^ secret;
    next &= 0xFFFFFF;

    next = (next >> 5) ^ next;
    next &= 0xFFFFFF;

    next = (next << 11) ^ next;
    return next & 0xFFFFFF;
}
