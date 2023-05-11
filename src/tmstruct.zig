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
        var url = try std.mem.join(self.allocator, "", &[_][]const u8{ "https://api.telegram.org/bot", self.token, path });
        return url;
    }
    fn getUriRaw(self: *const Self, a: []const u8, b: []const u8) []const u8 {
        var url = std.mem.join(self.allocator, "", &[_][]const u8{ a, b }) catch |err| {
            std.debug.print("{any}", .{err});
            return "boohoo";
        };
        return url;
    }
    pub fn sendMessage(self: *const Self, chatId: []const u8, message: []const u8) []const u8 {
        // joining texts should not be this hard XD
        var chatp = self.getUriRaw("chat_id=", chatId);
        var messagep = self.getUriRaw("&text=", message);
        const needle = &[_]u8{' '};
        const repl = &[_]u8{'+'};
        var messagex: []u8 = "";
        messagex = std.mem.replaceOwned(u8, self.allocator, messagep, needle, repl) catch |err| {
            std.debug.print("{any}", .{err});
            return "";
        };
        const pathg = self.getUriRaw("/sendMessage?", chatp);
        const path = self.getUriRaw(pathg, messagex);
        return fetch(self.allocator, self.getUri(path) catch unreachable, .POST) catch |err| {
            std.debug.print("{any}", .{err});
            return "boohoo";
        };
    }
    // pub fn startUpdateInterface(self: *const Self, offset: []const u8, limit: []const u8, timeout: []const u8) []const u8 {
    //     // joining texts should not be this hard XD
    //     var chatp = self.getUriRaw("/getUpdates?limit=10&offset=0&timeout=0", chatId);
    //     var messagep = self.getUriRaw("&text=", message);
    //     const pathg = self.getUriRaw("/sendMessage?", chatp);
    //     const path = self.getUriRaw(pathg, messagep);
    //     return fetch(self.allocator, self.getUri(path) catch unreachable, .POST) catch |err| {
    //         std.debug.print("{any}", .{err});
    //         return "boohoo";
    //     };
    // }
};
