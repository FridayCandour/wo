const std = @import("std");
const f = @import("./fetch.zig");
const fetch = f.fetch;

/// TODO: next things to work on
/// [x] telegram api handles like bot.sendMessage, sendPhoto and more
/// [x] tests
//

pub const Bot = struct {
    token: []const u8,
    allocator: std.mem.Allocator,
    const Self = @This();
    pub fn init(allocator: std.mem.Allocator, token: []const u8) Bot {
        return .{ .allocator = allocator, .token = token };
    }
    pub fn getMe(self: *const Self) []const u8 {
        return fetch(self.allocator, self.getUri("/getMe") catch unreachable, .GET, 1, 2) catch |err| {
            std.debug.print("{any}", .{err});
            return "boohoo";
        };
    }
    pub fn getUri(self: *const Self, path: []const u8) ![]u8 {
        var g = try std.mem.join(self.allocator, "", &[_][]const u8{ "https://api.telegram.org/bot", self.token, path });
        return g;
    }
    pub fn sendMessage(self: *const Self) []const u8 {
        return fetch(self.allocator, self.getUri("/message") catch unreachable, .GET, 1, 2) catch |err| {
            std.debug.print("{any}", .{err});
            return "boohoo";
        };
    }
};
