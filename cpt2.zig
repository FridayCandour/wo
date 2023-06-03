const std = @import("std");
const http = @import("http");


 // Function to get updates from the Telegram API
    pub fn getUpdates(offset: ?std.json.Token, allocator: *std.mem.Allocator) ?std.json.Token {
        const url = "https://api.telegram.org/bot{}/getUpdates".format(botToken);
        
        var request = try http.Request.init(url, .{});
        if (offset != null) {
            request.query.put("offset", offset.?.value);
        }
        
        const response = try request.send(allocator);
        if (response.statusCode != 200) {
            std.log.warn("Failed to fetch updates. Status code: {}. Body: {}", .{response.statusCode, response.body});
            return null;
        }
        
        var parser = try std.json.Parser.init(&arena.allocator);
        return try parser.parse(response.body);
    }


    // Function to send a message to a chat
    pub fn sendMessage(chatId: i64, text: []const u8, allocator: *std.mem.Allocator) bool {
        const url = "https://api.telegram.org/bot{}/sendMessage".format(botToken);
        
        var request = try http.Request.init(url, .{});
        request.method = .POST;
        request.bodyWriter.put("{}\n", .{text});
        
        request.headers.put("Content-Type", "application/json");
        request.headers.put("Content-Length", "{}", .{@intCast(u32, request.bodyWriter.bytesWritten)});
        
        const response = try request.send(allocator);
        if (response.statusCode != 200) {
            std.log.warn("Failed to send message. Status code: {}. Body: {}", .{response.statusCode, response.body});
            return false;
        }
        
        return true;
    }
    
    // Function to handle incoming messages
    pub fn handleIncomingMessages(updates: ?std.json.Token) void {
        if (updates == null) return;
        
        var updateArray = std.json.Array.init(&arena.allocator);
        updateArray = updates.ArrayOrUndefined(.{});
        
        for (update in updateArray) |index| {
            var messageObject = update.ObjectOrUndefined(.{});
            const chatId = messageObject.get("message").?.ObjectOrUndefined(.{}).get("chat").?.ObjectOrUndefined(.{}).get("id").?.IntegerOrUndefined(.{}).value;
            const text = "Thanks for your message!";
            
            std.log.debug("Received message: {}", .{text});
            
            // Add your logic to handle the message here
            // For example, you can send a response back to the user
            _ = sendMessage(chatId, text, &arena.allocator);
        }
    }
    
    // Function to continuously poll for updates
    pub fn pollUpdates() !void {
        var offset: ?std.json.Token = null;
        
        while (true) {
            const updates = getUpdates(offset, &arena.allocator);
            handleIncomingMessages(updates);
            
            if (updates != null) {
                var updateArray = updates.ArrayOrUndefined(.{});
                if (updateArray.len > 0) {
                    const lastUpdate = updateArray[updateArray.len - 1];
                    offset = lastUpdate.ObjectOrUndefined(.{}).get("update_id").?.IntegerOrUndefined(.{});
                }
            }
            
            // Delay between requests to avoid hitting API limits
            std.time.sleep(std.time.Duration{.seconds = 1});
        }
    }


pub fn main() !void {
    const allocator = std.heap.le_allocator;
    var arena = std.mem.ArenaAllocator.init(allocator);
    
    // Replace 'YOUR_BOT_TOKEN' with your actual bot token
    const botToken = "YOUR_BOT_TOKEN";
    var urlBuffer: [4096]u8 = undefined;    
    // Start polling for updates
    const result = pollUpdates();
    if (result.err != null) {
        std.log.error("Failed to poll updates: {}", .{result.err});
    }
}
