const std = @import("std");
const TokenType = @import("TokenType.zig").TokenType;
pub const Token = struct {
    token_type: TokenType,
    lexeme: []const u8,
    literal: []const u8,
    line: u32,

    pub fn init(token_type: TokenType, lexeme: []const u8, literal: []const u8, line: u32) Token {
        return Token{ .token_type = token_type, .lexeme = lexeme, .literal = literal, .line = line };
    }

    pub fn to_string(self: *Token, allocator: *std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator, "{s} {s} {s}", .{
            self.token_type,
            self.lexeme,
            self.literal,
        });
    }
};
