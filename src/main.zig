const std = @import("std");
const list = @import("list.zig");

const ListInt = list.List(i32, 100);

pub fn main() !void {
    ListInt.init();
    var l1 = ListInt{};
    var l2 = ListInt{};

    std.debug.print("{any}\n", .{l1});
    try l1.append(1);
    try l1.append(2);
    try l1.append(3);
    try l1.insert(5, 0);
    try l1.insert(6, 2);
    try l1.prepend(4);
    try l2.append(4);
    std.debug.print("{any}\n", .{l1});
    std.debug.print("{any}\n", .{l2});

    l1.print();
    l2.popBack();
    std.debug.print("{any}\n", .{l2});
}
