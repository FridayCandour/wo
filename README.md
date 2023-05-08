# wo

## All your bots are belong to us

Telegram bot API lib in zig

---

### Current apis

```zig
const std = @import("std");
const tm = @import("./tmstruct.zig");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var token = "1234567890:aaaaaaaaaaaaa-bbbbbbbbbbbb-ccccccc";
    const bot = tm.Bot.init(allocator, token);
    // retrieve bot's getMe info
    _ = try bot.getMe();

    // join the api and this path and return the url
    _ = try bot.getUri("/api");
    // https://api.telegram.org/bot1234567890:aaaaaaaaaaaaa-bbbbbbbbbbbb-ccccccc/api
}

```

Currently working adding more apis, create a pr if you want to help support.

## How do i use it?

---

By riping out what you want, am not ready for providing packaging or something till it's mostly usable

## Enjoy
