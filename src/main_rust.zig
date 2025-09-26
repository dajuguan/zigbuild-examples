const std = @import("std");
pub extern fn rust_add(a: c_int, b: c_int) c_int;

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    const result = rust_add(2, 3);
    std.debug.print("rust add result is :{d}\n", .{result});
}
