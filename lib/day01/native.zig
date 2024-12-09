const std = @import("std");

pub fn solve_part1(input: [][2]u64) u64 {
  var total: u64 = 0;
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var left = std.ArrayList(u64).init(allocator);
  var right = std.ArrayList(u64).init(allocator);

  for (input) |row| {
    const a = row[0];
    const b = row[1];
    left.append(a) catch unreachable;
    right.append(b) catch unreachable;
  }

  std.sort.block(u64, left.items, {}, std.sort.asc(u64));
  std.sort.block(u64, right.items, {}, std.sort.asc(u64));

  for (left.items, right.items) |a, b| {
    if (a < b) {
      total += b - a;
    } else {
      total += a - b;
    }
  }

  return total;
}


pub fn solve_part2(input: [][2]u64) u64 {
  var similarity: u64 = 0;
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var left = std.ArrayList(u64).init(allocator);
  var right = std.ArrayList(u64).init(allocator);

  for (input) |row| {
    const a = row[0];
    const b = row[1];
    left.append(a) catch unreachable;
    right.append(b) catch unreachable;
  }

  std.sort.block(u64, left.items, {}, std.sort.asc(u64));
  std.sort.block(u64, right.items, {}, std.sort.asc(u64));

  for (left.items) |a| {
    var occurences: u64 = 0;
    for (right.items) |b| {
      if (a == b) {
        occurences += 1;
      } else if (b > a) {
        break;
      }
    }
    similarity += occurences * a;
  }

  return similarity;
}
