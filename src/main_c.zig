const std = @import("std");
pub extern fn cmark_add(a: c_int, b: c_int) c_int;

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    const result = cmark_add(5, 5);
    std.debug.print("Call cmark add result is :{d}\n", .{result});
}
