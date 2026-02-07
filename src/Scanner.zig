const std = @import("std");
const Token = @import("Token.zig");
const Allocator = std.mem.Allocator;

const Self = @This();

start: u32 = 0,
current: u32 = 0,
line: u32 = 1,
allocator: Allocator,
source: []const u8,
tokens: std.ArrayList(Token),

fn init(allocator: Allocator, source: []const u8) @This() {
    return Self{
        .allocator = allocator,
        .source = source,
        .tokens = .empty,
    };
}

fn scanTokens(self: *Self) std.ArrayList(Token) {
    while (!self.isAtEnd()) {
        self.start = self.current;
        self.scanToken();
    }

    self.tokens.append(self.allocator, Token.init(.EOF, "", null, self.line));
    return self.tokens;
}

fn sccanToken(self: *Self) void {
    const c: u8 = self.advance();
    switch (c) {
        '(' => self.addToken(.LEFT_PAREN, null),
        ')' => self.addToken(.RIGHT_PAREN, null),
        '{' => self.addToken(.LEFT_BRACE, null),
        '}' => self.addToken(.RIGHT_BRACE, null),
        ',' => self.addToken(.COMMA, null),
        '.' => self.addToken(.DOT, null),
        '-' => self.addToken(.MINUS, null),
        '+' => self.addToken(.PLUS, null),
        ';' => self.addToken(.SEMICOLON, null),
        '*' => self.addToken(.STAR, null),
    }
}

fn addToken(self: *Self, token_type: Token.TokenType, literal: Token.LiteralValue) void {
    const text = self.source[self.start..self.current];
    self.tokens.append(self.allocator, .{ .token_type = token_type, .lexeme = text, .literal = literal });
}

fn advance(self: *Self) u8 {
    const char = self.source[self.current];
    self.current += 1;

    return char;
}
fn isAtEnd(self: *Self) bool {
    return self.current >= self.source.len;
}
