///
///? All your bots are belong to us
///
const std = @import("std");
const tm = @import("./tmstruct.zig");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpaallocator = gpa.allocator();
    var buf = try gpaallocator.alloc(u8, 1024000);
    defer gpaallocator.free(buf);
    var fba = std.heap.FixedBufferAllocator.init(buf);
    const allocator = fba.allocator();
    var token = "yours";
    const bot = tm.Bot.init(allocator, token);
    _ = try bot.getMe();
    // a basic server
    const port = 8080;
    const listen_address = std.net.Address.parseIp(
        "0.0.0.0",
        port,
    ) catch unreachable;

    var server = std.net.StreamServer.init(.{
        .reuse_address = true,
    });
    std.debug.print("server is listening on http://localhost:{d} ..", .{port});
    defer server.deinit();
    try server.listen(listen_address);
    while (true) {
        var conn = try server.accept();
        // TODO: Read the request and make decisions based on it
        try conn.stream.writeAll(
            \\HTTP/1.1 200 OK
            \\Content-Type: text/plain
            \\Connection: close
            \\
            \\Hello, World!
            \\
        );
        conn.stream.close();
    }
}

// TODO: next things to work on
// [x] get a basic http server to handle requests and make responses
// [x] maybe do route system and middleware
// [x] maybe
