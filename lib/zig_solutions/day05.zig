const beam = @import("beam");
const nif = @import("erl_nif");
const std = @import("std");

pub fn make_map(env: beam.env, _: c_int, _: [*]const beam.term) beam.term {
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

    var iter = map.iterator();
    while (iter.next()) |item| {
        const key: nif.ErlNifTerm = beam.make(item.key_ptr.*, .{}).v;
        const value: nif.ErlNifTerm = beam.make(item.value_ptr.*, .{ .as = .{ .list = .default } }).v;
        var out: nif.ErlNifTerm = undefined;
        if (nif.enif_make_map_put(
            env,
            term,
            key,
            value,
            &out,
        ) == 0) {
            return beam.raise_elixir_exception("RuntimeError", .{ .message = "Failed to make map put" }, .{});
        }
        term = out;
    }

    return beam.make(term, .{ .env = env });
}
