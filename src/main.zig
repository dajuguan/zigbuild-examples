const std = @import("std");
pub extern fn add(a: i32, b: i32) i32;

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    const result = add(2, 3);
    std.debug.print("Result is :{d}\n", .{result});
}
