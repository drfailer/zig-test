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

fn NodePool(comptime T: type, comptime pool_size: usize) type {
    return struct {
        mem: [pool_size]Node(T) = [_]Node(T){Node(T){ .value = undefined }} ** pool_size,
        head: ?*Node(T) = null,

        const Self = @This();

        fn init(self: *Self) void {
            var i: usize = 0;
            while (i < pool_size - 1) : (i += 1) {
                self.mem[i].next = &self.mem[i + 1];
            }
            self.head = &self.mem[0];
        }

        fn allocate(self: *Self, value: T, next: ?*Node(T)) !*Node(T) {
            if (self.head) |head| {
                var new_node = head;
                self.head = new_node.next;
                new_node.value = value;
                new_node.next = next;
                return new_node;
            } else {
                return ListError.NotEnoughMemory;
            }
        }

        fn deallocate(self: *Self, node: *Node(T)) void {
            node.next = self.head;
            self.head = node;
        }
    };
}

test "node pool" {
    var pool = NodePool(bool, 100){};
    pool.init();

    try std.testing.expect(pool.mem.len == 100);
    try std.testing.expect(pool.head == &pool.mem[0]);

    const new_node = try pool.allocate(true, null);
    try std.testing.expect(new_node.value == true);
    try std.testing.expect(new_node.next == null);
    try std.testing.expect(pool.head == &pool.mem[1]);

    pool.deallocate(new_node);
    try std.testing.expect(pool.head == &pool.mem[0]);
    try std.testing.expect(pool.mem[0].next == &pool.mem[1]);
}

pub fn List(comptime T: type, comptime pool_size: usize) type {
    return struct {
        head: ?NodeType = null,

        const Self = @This();
        const NodeType = *Node(T);

        var pool = NodePool(T, pool_size){};

        pub fn init() void {
            std.debug.print("init list\n", .{});
            Self.pool.init();
        }
        pub fn deinit() !void {}

        pub fn add(self: *Self, value: T) !void {
            self.*.head = try pool.allocate(value, self.head);
        }

        pub fn append(self: *Self, value: T) !void {
            var curr = &self.head;

            while (curr.*) |c| curr = &c.*.next;
            curr.* = try pool.allocate(value, null);
        }

        pub fn insert(self: *Self, value: T, idx: usize) !void {
            var curr = &self.head;
            var curr_idx: usize = 0;

            while (curr.*) |c| {
                if (curr_idx == idx) break;
                curr = &c.*.next;
                curr_idx += 1;
            }
            curr.* = try pool.allocate(value, curr.*);
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
