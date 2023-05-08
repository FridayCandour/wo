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
    pub fn getMe(self: *const Self) ![]u8 {
        return try fetch(self.allocator, try self.getUri("/getMe"), .GET);
    }
    pub fn getUri(self: *const Self, path: []const u8) ![]u8 {
        var g = try std.mem.join(self.allocator, "", &[_][]const u8{ "https://api.telegram.org/bot", self.token, path });
        return g;
    }
};
