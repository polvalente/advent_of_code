const std = @import("std");

pub fn solve(input_data: []const u64, num_ticks: u64, return_list: bool) struct { u64, []u64 } {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();

  var stone_map = std.AutoHashMap(u64, u64).init(allocator);
  defer stone_map.deinit();

  var cache = std.AutoHashMap(u64, []const u64).init(allocator);
  defer cache.deinit();

  for (input_data) |stone| {
    if (stone_map.get(stone) == null) {
      stone_map.put(stone, 1) catch unreachable;
    } else {
      stone_map.put(stone, stone_map.get(stone).? + 1) catch unreachable;
    }
  }

  for (0..num_ticks) |_| {
    var next_map = std.AutoHashMap(u64, u64).init(allocator);
    defer next_map.deinit();

    var iter = stone_map.iterator();
    while (iter.next()) |entry| {
      const stone = entry.key_ptr.*;
      const count = entry.value_ptr.*;

      for (update_stone(stone, &cache)) |new_stone| {
        const current_count = next_map.get(new_stone);
        if (current_count == null) {
          next_map.put(new_stone, count) catch unreachable;
        } else {
          next_map.put(new_stone, current_count.? + count) catch unreachable;
        }
      }
    }

    stone_map.clearAndFree();
    var next_iter = next_map.iterator();
    while (next_iter.next()) |entry| {
      stone_map.put(entry.key_ptr.*, entry.value_ptr.*) catch unreachable;
    }
  }

  var stones = std.ArrayList(u64).init(allocator);

  if (return_list) {
    var iter = stone_map.iterator();
    while (iter.next()) |entry| {
      const stone = entry.key_ptr.*;
      const count = entry.value_ptr.*;
      for (0..count) |_| {
        stones.append(stone) catch unreachable;
      }
    }
    std.sort.block(u64, stones.items, {}, std.sort.asc(u64));
    return .{ stones.items.len, stones.items };
  }

  var iter = stone_map.iterator();
  var total_count: u64 = 0;
  while (iter.next()) |entry| {
    total_count += entry.value_ptr.*;
  }
  return .{ total_count, stones.items };
}


fn update_stone(stone: u64, cache: *std.AutoHashMap(u64, []const u64)) []const u64 {
    const cached = cache.*.get(stone);
    if (cached != null) {
        return cached.?;
    }

    var allocator = cache.*.allocator;

    if (stone == 0) {
        const result = allocator.alloc(u64, 1) catch unreachable;
        result[0] = 1;
        cache.*.put(0, result) catch unreachable;
        return result;
    }

    const num_digits = blk: {
        var n = stone;
        var count: u64 = 1;
        while (n >= 10) : (n /= 10) {
            count += 1;
        }
        break :blk count;
    };

    if (num_digits % 2 == 0) {
        const result = allocator.alloc(u64, 2) catch unreachable;
        const mod = std.math.pow(u64, 10, num_digits / 2);
        result[0] = stone / mod;
        result[1] = stone % mod;
        cache.*.put(stone, result) catch unreachable;
        return result;
    }

    const result = allocator.alloc(u64, 1) catch unreachable;
    result[0] = stone * 2024;
    cache.*.put(stone, result) catch unreachable;
    return result;
}