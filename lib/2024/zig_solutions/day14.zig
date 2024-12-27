const std = @import("std");
const beam = @import("beam");

pub const InitialCondition = struct {
    px0: i64,
    py0: i64,
    vx0: i64,
    vy0: i64,
};

pub fn parse(input: []const u8) []InitialCondition {
    var iter = std.mem.splitSequence(u8, input, "\n");
    var conditions = std.ArrayList(InitialCondition).init(std.heap.page_allocator);

    while (iter.next()) |line| {
        // p=posx,posy v=velx,vely

        if (line.len < 2) break;

        var conds = std.mem.splitSequence(u8, line, " ");

        const posConds = conds.next() orelse unreachable;
        if (posConds.len < 2) break;
        var posIter = std.mem.splitSequence(u8, posConds[2..], ",");

        const velConds = conds.next() orelse unreachable;
        if (velConds.len < 2) break;
        var velIter = std.mem.splitSequence(u8, velConds[2..], ",");

        const px0 = std.fmt.parseInt(i64, posIter.next().?, 10) catch unreachable;
        const py0 = std.fmt.parseInt(i64, posIter.next().?, 10) catch unreachable;
        const vx0 = std.fmt.parseInt(i64, velIter.next().?, 10) catch unreachable;
        const vy0 = std.fmt.parseInt(i64, velIter.next().?, 10) catch unreachable;

        conditions.append(.{ .px0 = px0, .py0 = py0, .vx0 = vx0, .vy0 = vy0 }) catch unreachable;
    }

    return conditions.items;
}

const Robot = struct {
    x: i64,
    y: i64,
    count: u64,
};

pub fn calculate_robots(input: []InitialCondition, t: i64, max_x: i64, max_y: i64) []Robot {
    var robots = std.AutoHashMap(struct { i64, i64 }, u64).init(std.heap.page_allocator);
    defer robots.deinit();

    for (input) |condition| {
        const px = condition.px0 + condition.vx0 * t;
        const py = condition.py0 + condition.vy0 * t;

        const pos_px: i64 = @rem(@rem(px, max_x) + max_x, max_x);
        const pos_py: i64 = @rem(@rem(py, max_y) + max_y, max_y);

        const count = robots.get(.{ pos_px, pos_py }) orelse 0;
        robots.put(.{ pos_px, pos_py }, count + 1) catch unreachable;
    }

    var robotsList = std.ArrayList(Robot).init(std.heap.page_allocator);

    var iter = robots.iterator();
    while (iter.next()) |entry| {
        robotsList.append(.{ .x = entry.key_ptr[0], .y = entry.key_ptr[1], .count = entry.value_ptr.* }) catch unreachable;
    }

    return robotsList.items;
}

fn get_quadrant(x: i64, y: i64, max_x: i64, max_y: i64) u64 {
    if (x >= 0 and x < @divTrunc(max_x, 2) and y >= 0 and y < @divTrunc(max_y, 2)) {
        return 0;
    }
    if (x > @divTrunc(max_x, 2) and x < max_x and y >= 0 and y < @divTrunc(max_y, 2)) {
        return 1;
    }
    if (x >= 0 and x < @divTrunc(max_x, 2) and y > @divTrunc(max_y, 2) and y < max_y) {
        return 2;
    }
    if (x > @divTrunc(max_x, 2) and x < max_x and y > @divTrunc(max_y, 2) and y < max_y) {
        return 3;
    }
    return 5;
}

pub fn solve_part1(input: []const u8, max_x: i64, max_y: i64) u64 {
    const conditions = parse(input);
    const robots = calculate_robots(conditions, 100, max_x, max_y);

    var quadrantCounts = [4]u64{ 0, 0, 0, 0 };

    for (robots) |robot| {
        const quadrant = get_quadrant(robot.x, robot.y, max_x, max_y);
        if (quadrant != 5) {
            quadrantCounts[quadrant] += robot.count;
        }
    }

    return quadrantCounts[0] * quadrantCounts[1] * quadrantCounts[2] * quadrantCounts[3];
}

pub fn solve_part2(input: []const u8, max_x: i64, max_y: i64) i64 {
    const conditions = parse(input);

    var t: i64 = 0;
    var found = false;
    while (!found) {
        t += 1;
        found = true;
        const robots = calculate_robots(conditions, t, max_x, max_y);
        for (robots) |robot| {
            found = found and robot.count == 1;
        }
    }

    return t;
}
