const std = @import("std");

extern fn zig_add(a: i32, b: i32) i32;
extern fn rust_add(a: c_int, b: c_int) c_int;

pub fn main() !void {
    std.debug.print("zig_add res: {d}\n", .{zig_add(6, 6)});
    std.debug.print("rust_add res: {d}\n", .{rust_add(6, 6)});
}
