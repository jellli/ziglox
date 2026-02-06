const std = @import("std");
const Token = @import("Token.zig").Token;

var start: u32 = 0;
var current: u32 = 0;
var line: u32 = 1;

const Scanner = struct {
    source: []const u8,
    tokens: std.ArrayList(Token),

    fn init(source: []const u8) @This() {
        return Scanner{
            .source = source,
            .tokens = .empty,
        };
    }

    fn scanTokens() std.ArrayList(Token) {}

    fn isAtEnd(self: *Scanner) bool {
        return current >= self.source.len;
    }
};
