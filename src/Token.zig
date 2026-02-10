const std = @import("std");

token_type: TokenType,
lexeme: []const u8,
literal: ?LiteralValue,
line: u32,
const Self = @This();

pub fn init(token_type: TokenType, lexeme: []const u8, literal: ?LiteralValue, line: u32) Self {
    return Self{ .token_type = token_type, .lexeme = lexeme, .literal = literal, .line = line };
}

pub fn to_string(self: *Self, allocator: *std.mem.Allocator) []const u8 {
    return std.fmt.allocPrint(allocator, "{s} {s} {s}", .{
        self.token_type,
        self.lexeme,
        self.literal,
    });
}

pub const LiteralValue = union(enum) { Nil: void, String: []const u8, Number: f32 };

pub const TokenType = enum {
    // Single-character tokens.
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    COMMA,
    DOT,
    MINUS,
    PLUS,
    SEMICOLON,
    SLASH,
    STAR,

    // One or two character tokens.
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,

    // Literals.
    IDENTIFIER,
    STRING,
    NUMBER,

    // Keywords.
    AND,
    CLASS,
    ELSE,
    FALSE,
    FUN,
    FOR,
    IF,
    NIL,
    OR,
    PRINT,
    RETURN,
    SUPER,
    THIS,
    TRUE,
    VAR,
    WHILE,

    EOF,
};
