const std = @import("std");

pub const ListError = error{
    NotEnoughMemory,
    IndexOutOfBound,
};

pub fn Node(T: type) type {
    return struct {
        value: T,
        next: ?*Node(T) = null,
    };
}

pub fn List(comptime T: type, comptime pool_size: usize) type {
    return struct {
        head: ?NodeType = null,

        const Self = @This();
        const NodeType = *Node(T);

        var pool: [pool_size]Node(T) = undefined;
        var pool_idx: usize = 0;

        pub fn init() !void {}
        pub fn deinit() !void {}

        pub fn add(self: *Self, value: T) !void {
            self.*.head = try allocateNode(value, self.*.head);
        }

        pub fn append(self: *Self, value: T) !void {
            var curr = &self.head;

            while (curr.*) |c| curr = &c.*.next;
            if (pool_idx >= pool.len) return ListError.NotEnoughMemory;
            curr.* = try allocateNode(value, null);
        }

        pub fn insert(self: *Self, value: T, idx: usize) !void {
            var curr = &self.head;
            var curr_idx: usize = 0;

            while (curr.*) |c| {
                if (curr_idx == idx) break;
                curr = &c.*.next;
                curr_idx += 1;
            }
            curr.* = try allocateNode(value, curr.*);
        }

        fn allocateNode(value: T, next: ?NodeType) !NodeType {
            defer pool_idx += 1;
            if (pool_idx >= pool.len) return ListError.NotEnoughMemory;
            pool[pool_idx] = .{
                .value = value,
                .next = next,
            };
            return &pool[pool_idx];
        }

        pub fn print(self: *const Self) void {
            var curr = &self.head;
            std.debug.print("[ ", .{});
            while (curr.*) |c| {
                std.debug.print("{}, ", .{c.*.value});
                curr = &c.*.next;
            }
            std.debug.print("]\n", .{});
        }
    };
}
