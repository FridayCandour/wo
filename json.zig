const std = @import("std");

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

const my_json =
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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const struc = try fromJson(my_json, allocator);
    std.debug.print("\n {any}", .{struc});
    defer std.json.parseFree(Config, struc, .{ .allocator = allocator });
    try std.testing.expect(struc.ok == true);
}
