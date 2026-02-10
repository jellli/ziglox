const std = @import("std");
const Token = @import("Token.zig");
const TokenType = Token.TokenType;
const Allocator = std.mem.Allocator;
const main = @import("main.zig");
const isDigit = std.ascii.isDigit;
const isAlphabetic = std.ascii.isAlphabetic;
const isAlphanumeric = std.ascii.isAlphanumeric;

const Self = @This();

start: u32 = 0,
current: u32 = 0,
line: u32 = 1,
allocator: Allocator,
source: []const u8,
tokens: std.ArrayList(Token),

const keywords = std.StaticStringMap(TokenType).initComptime(.{
    .{ "and", .AND },
    .{ "class", .CLASS },
    .{ "else", .ELSE },
    .{ "false", .FALSE },
    .{ "for", .FOR },
    .{ "fun", .FUN },
    .{ "if", .IF },
    .{ "nil", .NIL },
    .{ "or", .OR },
    .{ "print", .PRINT },
    .{ "return", .RETURN },
    .{ "super", .SUPER },
    .{ "this", .THIS },
    .{ "true", .TRUE },
    .{ "var", .VAR },
    .{ "while", .WHILE },
});

pub fn init(allocator: Allocator, source: []const u8) !@This() {
    return Self{
        .allocator = allocator,
        .source = source,
        .tokens = .empty,
    };
}

pub fn deinit(self: *Self) void {
    self.allocator.free(self.tokens);
    self.allocator.free(self.keywords);
}

pub fn scanTokens(self: *Self) !std.ArrayList(Token) {
    while (!self.isAtEnd()) {
        self.start = self.current;
        try self.scanToken();
    }

    try self.tokens.append(self.allocator, Token.init(.EOF, "", null, self.line));
    return self.tokens;
}

fn scanToken(self: *Self) !void {
    const c: u8 = self.advance();
    try switch (c) {
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

        '!' => self.addToken(if (self.match('=')) TokenType.BANG_EQUAL else TokenType.BANG, null),
        '=' => self.addToken(if (self.match('=')) TokenType.EQUAL_EQUAL else TokenType.EQUAL, null),
        '<' => self.addToken(if (self.match('=')) TokenType.LESS_EQUAL else TokenType.LESS, null),
        '>' => self.addToken(if (self.match('=')) TokenType.GREATER_EQUAL else TokenType.GREATER, null),
        '/' => {
            if (self.match('/')) {
                while (self.peek() != '\n' and !self.isAtEnd()) {
                    _ = self.advance();
                }
            } else {
                try self.addToken(.SLASH, null);
            }
        },

        ' ',
        '\r',
        '\t',
        => {},

        '\n' => self.line = self.line + 1,

        '"' => self.string(),
        '0'...'9' => self.number(),
        'a'...'z', 'A'...'Z', '_' => self.identifier(),

        else => try main.err(self.line, "Unexpected character."),
    };
}

fn addToken(self: *Self, token_type: TokenType, literal: ?Token.LiteralValue) !void {
    const text = self.source[self.start..self.current];
    try self.tokens.append(self.allocator, .{
        .token_type = token_type,
        .lexeme = text,
        .literal = literal,
        .line = self.line,
    });
}

fn match(self: *Self, expected: u8) bool {
    if (self.isAtEnd()) return false;
    if (self.source[self.current] != expected) return false;

    self.current += 1;
    return true;
}

fn advance(self: *Self) u8 {
    const char = self.source[self.current];
    self.current += 1;

    return char;
}
fn isAtEnd(self: *Self) bool {
    return self.current >= self.source.len;
}

fn peek(self: *Self) u8 {
    if (self.isAtEnd()) return 0;
    return self.source[self.current];
}

fn peekNext(self: *Self) u8 {
    if (self.current + 1 >= self.source.len) return 0;
    return self.source[self.current + 1];
}

fn string(self: *Self) !void {
    while (self.peek() != '"' and !self.isAtEnd()) {
        if (self.peek() == '\n') self.line += 1;
        _ = self.advance();
    }

    if (self.isAtEnd()) {
        try main.err(self.line, "Unterminated string.");
        return;
    }

    _ = self.advance();
    const value = self.source[self.start + 1 .. self.current - 1];
    try self.addToken(.STRING, .{ .String = value });
}

fn number(self: *Self) !void {
    while (isDigit(self.peek())) _ = self.advance();

    if (self.peek() == '.' and isDigit(self.peekNext())) {
        _ = self.advance();
        while (isDigit(self.peek())) _ = self.advance();
    }
    try self.addToken(.NUMBER, .{
        .Number = try std.fmt.parseFloat(f32, self.source[self.start..self.current]),
    });
}

fn identifier(self: *Self) !void {
    while (isAlphanumeric(self.peek())) _ = self.advance();
    const text = self.source[self.start..self.current];
    const token_type: TokenType = keywords.get(text) orelse TokenType.IDENTIFIER;

    try self.addToken(token_type, null);
}
