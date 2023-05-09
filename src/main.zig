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
    var token = "5818432259:AAFN6GGjp1D10-76xMflBTPFdzG-jV9ZGKM";
    const bot = tm.Bot.init(allocator, token);
    var botDet = bot.getMe();
    std.debug.print("{any}", .{botDet});
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

        std.debug.print("\n \n server listed on {any} \n ..", .{conn.address});
        conn.stream.close();
    }
}

// TODO: next things to work on
// [x] get a basic http server to handle requests and make responses
// [x] maybe do route system and middleware
// [x] maybe
