const std = @import("std");

/// TODO: next things to work on
/// [x] no need to handle http errors
/// [x] use body content
/// [x] use headers
//

pub fn fetch(allocator: std.mem.Allocator, url: []const u8, method: std.http.Method) ![]u8 {
    // let's begin work
    var client = std.http.Client{
        .allocator = allocator,
    };
    const encoded = try std.Uri.escapeQuery(allocator, url);
    defer allocator.free(encoded);
    std.debug.print("{s} \n ", .{encoded});
    const uri = try std.Uri.parse(encoded);
    std.debug.print("{s} \n ", .{uri});
    var headers = std.http.Headers{ .allocator = allocator };
    defer headers.deinit();
    try headers.append("accept", "*/*");
    try headers.append("Content-Type", "application/json");
    var req = try client.request(method, uri, headers, .{});
    defer req.deinit();
    try req.start();
    try req.finish();
    try req.wait();
    _ = req.response.headers.getFirstValue("content-type") orelse "text/plain";
    const httpbody = req.reader().readAllAlloc(allocator, 8192) catch unreachable;
    std.debug.print("{s}", .{httpbody});
    // defer allocator.free(httpbody);
    return httpbody;
}
