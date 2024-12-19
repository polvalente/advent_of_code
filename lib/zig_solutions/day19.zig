const std = @import("std");
const beam = @import("beam");

pub const ParseResult = struct {
    available_patterns: [][]const u8,
    desired_designs: [][]const u8,
};

pub fn parse(input: []const u8) ParseResult {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();
    var lines = std.mem.splitSequence(u8, input, "\n");
    const available_patterns_str = lines.next().?;

    // skip the empty line
    _ = lines.next();

    var available_patterns = std.ArrayList([]const u8).init(allocator);
    var pattern_iter = std.mem.splitSequence(u8, available_patterns_str, ", ");
    while (pattern_iter.next()) |pattern| {
        if (pattern.len == 0) {
            break;
        }

        available_patterns.append(pattern) catch unreachable;
    }

    var desired_designs = std.ArrayList([]const u8).init(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        desired_designs.append(line) catch unreachable;
    }

    return ParseResult{ .available_patterns = available_patterns.items, .desired_designs = desired_designs.items };
}

pub fn solve_part1(parse_result: ParseResult) i64 {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();
    const available_patterns = parse_result.available_patterns;
    const desired_designs = parse_result.desired_designs;

    var count: i64 = 0;
    var cache = std.StringHashMap(bool).init(allocator);
    defer cache.deinit();

    for (desired_designs) |str| {
        const result = check_if_possible(str, available_patterns, &cache);
        if (result) {
            count += 1;
        }
    }

    return count;
}

fn check_if_possible(str: []const u8, available_patterns: [][]const u8, cache: *std.StringHashMap(bool)) bool {
    if (cache.*.get(str)) |result| {
        return result;
    }

    for (available_patterns) |pattern| {
        if (std.mem.eql(u8, str, pattern)) {
            cache.*.put(str, true) catch unreachable;
            return true;
        }

        if (std.mem.startsWith(u8, str, pattern)) {
            const result = check_if_possible(str[pattern.len..], available_patterns, cache);
            cache.*.put(str, result) catch unreachable;
            if (result) {
                return result;
            }
        }
    }

    return false;
}

pub fn solve_part2(parse_result: ParseResult) i64 {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();
    const available_patterns = parse_result.available_patterns;
    const desired_designs = parse_result.desired_designs;

    var count: i64 = 0;
    var cache = std.StringHashMap(i64).init(allocator);
    defer cache.deinit();

    for (desired_designs) |str| {
        count += count_possible_ways(str, available_patterns, &cache);
    }

    return count;
}

fn count_possible_ways(str: []const u8, available_patterns: [][]const u8, cache: *std.StringHashMap(i64)) i64 {
    if (cache.*.get(str)) |result| {
        return result;
    }

    if (str.len == 0) {
        return 1;
    }

    var count: i64 = 0;
    for (available_patterns) |pattern| {
        if (std.mem.startsWith(u8, str, pattern)) {
            const result = count_possible_ways(str[pattern.len..], available_patterns, cache);
            count += result;
        }
    }

    cache.*.put(str, count) catch unreachable;

    return count;
}
