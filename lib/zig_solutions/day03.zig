const std = @import("std");

const Kind = enum {
    mul,
    do,
    dont,
};

const Operation = struct {
    kind: Kind,
    l: u64,
    r: u64,
};

pub fn solve(str: []const u8, part: u8) u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var operations = std.ArrayList(Operation).init(allocator);
    defer operations.deinit();

    var i: usize = 0;
    var op: ?Operation = null;
    while (i < str.len) {
        const result = parse_operation(str[i..]);
        op = result[0];
        const len = result[1];
        i += len;
        if (op == null or (part == 1 and op.?.kind != Kind.mul)) {
            continue;
        }
        operations.append(op.?) catch unreachable;
    }

    var result: u64 = 0;
    var do = true;
    for (operations.items) |entry| {
        if (entry.kind == Kind.mul and do) {
            result += entry.l * entry.r;
        } else if (entry.kind == Kind.do) {
            do = true;
        } else if (entry.kind == Kind.dont) {
            do = false;
        }
    }
    return result;
}

fn parse_operation(str: []const u8) struct { ?Operation, u64 } {
    if (str.len >= 4 and std.mem.eql(u8, str[0..4], "do()")) {
        return .{
            Operation {
                .kind = Kind.do,
                .l = 0,
                .r = 0,
            },
            4,
        };
    }
    else if (str.len < 7) {
        return .{ null, 1 };
    }
    else if (std.mem.eql(u8, str[0..7], "don't()")) {
        return .{
            Operation {
                .kind = Kind.dont,
                .l = 0,
                .r = 0,
            },
            4,
        };
    }
    else if (std.mem.eql(u8, str[0..4], "mul(")) {
        var j: usize = 4;  // Start after "mul("

        // Find first number
        var l: u64 = 0;
        while (j < str.len and str[j] != ',') {
            const c = str[j];
            if (c < '0' or c > '9') return .{ null, 1 };
            l = l * 10 + (c - '0');
            j += 1;
        }
        if (j >= str.len or str[j] != ',') return .{ null, 1 };
        j += 1;

        // Find second number
        var r: u64 = 0;
        while (j < str.len and str[j] != ')') {
            const c = str[j];
            if (c < '0' or c > '9') return .{ null, 1 } ;
            r = r * 10 + (c - '0');
            j += 1;
        }
        if (j >= str.len or str[j] != ')') return .{ null, 1 };

        const op = Operation{
            .kind = Kind.mul,
            .l = l,
            .r = r,
        };

        return .{ op, j };
    } else {
        return .{ null, 1 };
    }
}
