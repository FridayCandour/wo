///
///? All your bots are belong to us
///
const std = @import("std");
const tm = @import("./tmstruct.zig");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    // const gpaallocator = gpa.allocator();
    const allocator = gpa.allocator();
    // var buf = try gpaallocator.alloc(u8, 1024000);
    // defer gpaallocator.free(buf);
    // var fba = std.heap.FixedBufferAllocator.init(buf);
    // const allocator = fba.allocator();
    var token = "xyz";
    const bot = tm.Bot.init(allocator, token);
    _ = bot.sendMessage("@cradovaframework", "hello people am wo");
    // var botDet = bot.getMe();
    // std.debug.print("{any}", .{botDet});
}

// TODO: next things to work on
// [x] get a basic http server to handle requests and make responses
// [x] maybe do route system and middleware
// [x] maybe
