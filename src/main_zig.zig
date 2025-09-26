const std = @import("std");

extern fn zig_add(a: i32, b: i32) i32;

pub fn main() !void {
    const res = zig_add(6, 6);
    std.debug.print("zig_add res: {d}\n", .{res});
}
