const std = @import("std");

/// TODO: next things to work on
/// [x] no need to handle http errors
/// [x] use body content
/// [x] use headers
//

pub fn fetch(allocator: std.mem.Allocator, url: []const u8, method: std.http.Method, header: anytype, body: anytype) ![]u8 {
    // dumped here at the moment
    _ = body;
    _ = header;
    // let's begin work
    var client = std.http.Client{
        .allocator = allocator,
    };
    const uri = try std.Uri.parse(url);
    var headers = std.http.Headers{ .allocator = allocator };
    defer headers.deinit();
    try headers.append("accept", "*/*");
    var req = try client.request(method, uri, headers, .{});
    defer req.deinit();
    try req.start();
    // ! this is bugging hence the http body will be worked on a later
    // try req.writer().writeAll("Hello, World!\n");
    try req.finish();
    try req.wait();
    _ = req.response.headers.getFirstValue("content-type") orelse "text/plain";
    const httpbody = req.reader().readAllAlloc(allocator, 8192) catch unreachable;
    std.debug.print("{s}", .{httpbody});
    defer allocator.free(httpbody);
    return httpbody;
}
