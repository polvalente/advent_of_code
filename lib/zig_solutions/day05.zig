const beam = @import("beam");
const nif = @import("erl_nif");
const std = @import("std");

fn make_map(env: beam.env, _: c_int, _: [*]const nif.ErlNifTerm) nif.ErlNifTerm {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();
    var map = std.AutoHashMap(i64, []i64).init(allocator);

    // Add key-value pairs

    var val1 = std.ArrayList(i64).init(allocator);
    val1.append(1) catch unreachable;
    val1.append(2) catch unreachable;
    val1.append(3) catch unreachable;
    var val2 = std.ArrayList(i64).init(allocator);
    val2.append(4) catch unreachable;
    val2.append(5) catch unreachable;
    map.put(1, val1.items) catch unreachable;
    map.put(2, val2.items) catch unreachable;

    var term = nif.enif_make_new_map(env);
    var out: nif.ErlNifTerm = undefined;

    var iter = map.iterator();
    while (iter.next()) |item| {
        const key: nif.ErlNifTerm = beam.make(item.key_ptr.*, .{ .env = env }).v;
        const value: nif.ErlNifTerm = beam.make(item.value_ptr.*, .{ .env = env, .as = .{ .list = .default } }).v;
        if (nif.enif_make_map_put(
            env,
            term,
            key,
            value,
            &out,
        ) == 0) {
            return beam.raise_elixir_exception("RuntimeError", .{ .message = "Failed to make map put" }, .{ .env = env }).v;
        }
        term = out;
    }

    return term;
}

pub fn solve_part1(input: []const u8) i64 {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();
    var before_requirements = std.AutoHashMap(i64, std.ArrayList(i64)).init(allocator);

    var split_iter = std.mem.splitSequence(u8, input, "\n\n");

    const requirements = split_iter.next().?;
    const updates = split_iter.next().?;

    var requirements_iter = std.mem.splitSequence(u8, requirements, "\n");
    while (requirements_iter.next()) |requirement| {
        var rule_iter = std.mem.splitSequence(u8, requirement, "|");
        const page = rule_iter.next().?;
        const before_than = rule_iter.next().?;

        const page_int = std.fmt.parseInt(i64, page, 10) catch unreachable;
        const before_than_int = std.fmt.parseInt(i64, before_than, 10) catch unreachable;

        const current = before_requirements.getPtr(page_int);

        if (current) |current_list| {
            current_list.*.append(before_than_int) catch unreachable;
        } else {
            var new_list = std.ArrayList(i64).init(allocator);
            new_list.append(before_than_int) catch unreachable;
            before_requirements.put(page_int, new_list) catch unreachable;
        }
    }

    var updates_iter = std.mem.splitSequence(u8, updates, "\n");
    var result: i64 = 0;
    while (updates_iter.next()) |update| {
        if (update.len == 0) {
            break;
        }
        var step_iter = std.mem.splitSequence(u8, update, ",");
        var steps = std.ArrayList(i64).init(allocator);
        var len: usize = 0;
        while (step_iter.next()) |step| {
            if (step.len < 1) {
                break;
            }
            const step_int = std.fmt.parseInt(i64, step, 10) catch unreachable;
            steps.append(step_int) catch unreachable;
            len += 1;
        }

        if (is_ordered(steps.items, before_requirements)) {
            const middle = steps.items[@divTrunc(len, 2)];
            result += middle;
        }
    }

    return result;
}

fn is_ordered(steps: []const i64, before_requirements: std.AutoHashMap(i64, std.ArrayList(i64))) bool {
    for (0..steps.len - 1) |i| {
        const current = steps[i];
        const after_than = steps[i + 1 ..];

        const before_reqs = before_requirements.get(current);

        if (before_reqs) |before_reqs_list| {
            for (after_than) |b| {
                const needle = [1]i64{b};
                if (!std.mem.containsAtLeast(i64, before_reqs_list.items, 1, &needle)) {
                    return false;
                }
            }
        } else {
            return false;
        }
    }
    return true;
}

pub fn solve_part2(input: []const u8) i64 {
    var gpa = beam.make_general_purpose_allocator_instance();
    const allocator = gpa.allocator();
    var before_requirements = std.AutoHashMap(i64, std.ArrayList(i64)).init(allocator);
    var rules = std.ArrayList([2]i64).init(allocator);

    var split_iter = std.mem.splitSequence(u8, input, "\n\n");

    const requirements = split_iter.next().?;
    const updates = split_iter.next().?;

    var requirements_iter = std.mem.splitSequence(u8, requirements, "\n");
    while (requirements_iter.next()) |requirement| {
        var rule_iter = std.mem.splitSequence(u8, requirement, "|");
        const page = rule_iter.next().?;
        const before_than = rule_iter.next().?;

        const page_int = std.fmt.parseInt(i64, page, 10) catch unreachable;
        const before_than_int = std.fmt.parseInt(i64, before_than, 10) catch unreachable;

        const rule = [2]i64{ page_int, before_than_int };
        rules.append(rule) catch unreachable;

        const current = before_requirements.getPtr(page_int);

        if (current) |current_list| {
            current_list.*.append(before_than_int) catch unreachable;
        } else {
            var new_list = std.ArrayList(i64).init(allocator);
            new_list.append(before_than_int) catch unreachable;
            before_requirements.put(page_int, new_list) catch unreachable;
        }
    }

    var updates_iter = std.mem.splitSequence(u8, updates, "\n");
    var toOrder = std.ArrayList([]i64).init(allocator);
    while (updates_iter.next()) |update| {
        if (update.len == 0) {
            break;
        }
        var step_iter = std.mem.splitSequence(u8, update, ",");
        var steps = std.ArrayList(i64).init(allocator);
        var len: usize = 0;
        while (step_iter.next()) |step| {
            if (step.len < 1) {
                break;
            }
            const step_int = std.fmt.parseInt(i64, step, 10) catch unreachable;
            steps.append(step_int) catch unreachable;
            len += 1;
        }

        if (!is_ordered(steps.items, before_requirements)) {
            toOrder.append(steps.items) catch unreachable;
        }
    }

    var result: i64 = 0;
    for (toOrder.items) |l| {
        const reordered = reorder(allocator, l, rules, before_requirements);

        const middle = reordered[@divTrunc(reordered.len, 2)];
        result += middle;
    }

    return result;
}

fn reorder(allocator: std.mem.Allocator, in_list: []i64, rules: std.ArrayList([2]i64), requirements: std.AutoHashMap(i64, std.ArrayList(i64))) []i64 {
    var list = std.ArrayList(i64).fromOwnedSlice(allocator, in_list);

    while (true) {
        for (rules.items) |rule| {
            const x_idx = std.mem.indexOfScalar(i64, list.items, rule[0]);
            const y_idx = std.mem.indexOfScalar(i64, list.items, rule[1]);

            if (x_idx != null and y_idx != null and y_idx.? < x_idx.?) {
                std.mem.swap(i64, &list.items[x_idx.?], &list.items[y_idx.?]);
            }
        }

        if (is_ordered(list.items, requirements)) {
            return list.items;
        }
    }
}
