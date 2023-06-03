const std = @import("std");
const f = @import("./fetch.zig");
const fetch = f.fetch;

/// TODO: next things to work on
/// [x] telegram api handles like bot.sendMessage, sendPhoto and more
/// [x] tests
//

// All Evil Types here XD

const Update = struct {
    update_id: u32,
    message: Message,
};

const Message = struct {
    message_id: u32,
    from: User,
    chat: Chat,
    date: u32,
    text: []const u8,
    entities: []Entity,
};

const User = struct {
    id: u32,
    is_bot: bool,
    first_name: []const u8,
    username: []const u8,
    language_code: []const u8,
};

const Chat = struct {
    id: u32,
    first_name: []const u8,
    username: []const u8,
    type: []const u8,
};

const Entity = struct {
    offset: u32,
    length: u32,
    type: []const u8,
};

const my_json_sample =
    \\{
    \\ "ok":true,"result":[
    \\{"update_id":157100682,
    \\"message": { 
    \\"message_id": 6,
    \\"from": { 
    \\"id": 1233058250, 
    \\"is_bot":false, 
    \\"first_name": "Friday Candour [ask to pm]", 
    \\"username":"Procal",
    \\"language_code": "en"},
    \\"chat": {  
    \\"id":1233058250, 
    \\"first_name": "Friday Candour [ask to pm]",
    \\"username":"Procal",
    \\"type":"private"
    \\},
    \\"date":1685808524,
    \\"text":"/start",
    \\"entities": [
    \\{
    \\"offset": 0,
    \\"length":6,
    \\"type": "bot_command"
    \\}
    \\]
    \\ }
    \\ }
    \\ ]
    \\}
;

const Config = struct {
    ok: bool,
    result: []Update,
};

fn fromJson(x: []const u8, alloc: std.mem.Allocator) !Config {
    // desirialisation
    var stream = std.json.TokenStream.init(x);
    const parsedData = try std.json.parse(Config, &stream, .{ .allocator = alloc });
    return parsedData;
}

pub fn proccess(data: []u8) !void {
    // std.debug.print("{any}", .{data});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const struc = try fromJson(data, allocator);
    std.debug.print("\n {any}", .{struc});
    defer std.json.parseFree(Config, struc, .{ .allocator = allocator });
    try std.testing.expect(struc.ok == true);
}

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
    fn getUriRaw(self: *const Self, a: []const u8, b: []const u8) []u8 {
        var url = std.mem.join(self.allocator, "", &[_][]const u8{ a, b }) catch unreachable;
        return url;
    }
    pub fn sendMessage(self: *const Self, chatId: []const u8, message: []const u8) []const u8 {
        // joining texts should not be this hard XD
        var chatp = self.getUriRaw("chat_id=", chatId);
        defer self.allocator.free(chatp);
        var messagep = self.getUriRaw("&text=", message);
        defer self.allocator.free(messagep);
        const needle = &[_]u8{' '};
        const repl = &[_]u8{'+'};
        var messagex: []u8 = "";
        messagex = std.mem.replaceOwned(u8, self.allocator, messagep, needle, repl) catch unreachable;
        defer self.allocator.free(messagex);
        const pathg = self.getUriRaw("/sendMessage?", chatp);
        const path = self.getUriRaw(pathg, messagex);
        defer self.allocator.free(path);
        defer self.allocator.free(pathg);
        const url = self.getUri(path) catch unreachable;
        defer self.allocator.free(url);
        return fetch(self.allocator, url, .POST) catch |err| {
            std.debug.print("{any}", .{err});
            return "boohoo";
        };
    }
    pub fn startUpdateInterface(self: *const Self) !void {
        var path = try self.getUri("/getUpdates?limit=10&offset=0&timeout=4");
        std.debug.print("{s}", .{"wo is polling for updates ... "});
        while (true) {
            const data = try fetch(self.allocator, path, .POST);
            if (@TypeOf(data) == []u8) {
                try proccess(data);
            }
            // Delay between requests to avoid hitting API limits
            std.time.sleep(1000);
        }
    }
};
