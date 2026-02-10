const std = @import("std");
const Dir = std.Io.Dir;
const Allocator = std.mem.Allocator;
const Scanner = @import("scanner.zig");
const Writer = std.Io.File.Writer;

var had_error = false;

var stdout_buffer: [1024]u8 = undefined;
var stdout_writer: Writer = undefined;
var stdout: *std.Io.Writer = undefined;

var stderr_buffer: [1024]u8 = undefined;
var stderr_writer: Writer = undefined;
var stderr: *std.Io.Writer = undefined;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena.allocator();

    stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    stdout = &stdout_writer.interface;

    stderr_writer = std.Io.File.stderr().writer(io, &stderr_buffer);
    stderr = &stderr_writer.interface;

    const args = try init.minimal.args.toSlice(allocator);
    defer allocator.free(args);

    switch (args.len) {
        1 => {
            try runPrompt(io, allocator);
        },
        2 => {
            try runFile(io, allocator, args[1]);
        },
        else => {
            try stdout.print("Usage: zlox [script]", .{});
            try stdout.flush();
            std.process.exit(64);
        },
    }
}

fn runFile(io: std.Io, allocator: Allocator, path: []const u8) !void {
    const cwd = std.Io.Dir.cwd();
    const source_code = cwd.readFileAlloc(io, path, allocator, .unlimited) catch |e| switch (e) {
        error.FileNotFound => {
            try stderr.print("Error: {s} not found\n", .{path});
            try stderr.flush();
            return;
        },
        else => return e,
    };
    defer allocator.free(source_code);
    try run(allocator, source_code);
    if (had_error) std.process.exit(65);
}

fn runPrompt(io: std.Io, allocator: Allocator) !void {
    var stdin_buffer: [1024]u8 = undefined;
    var stdin_reader = std.Io.File.stdin().reader(io, &stdin_buffer);
    const stdin = &stdin_reader.interface;
    while (true) {
        try stdout.writeAll("> ");
        try stdout.flush();
        const line = try stdin.takeDelimiter('\n') orelse unreachable;
        if (line.len == 0) {
            break;
        }
        try run(allocator, line);
        had_error = false;
    }
}

fn run(allocator: Allocator, source: []const u8) !void {
    var scanner = try Scanner.init(allocator, source);
    const tokens = try scanner.scanTokens();
    for (tokens.items) |token| {
        std.debug.print("{}\n", .{token});
    }
}

pub fn err(line: u32, msg: []const u8) !void {
    try report(line, "", msg);
}

pub fn report(line: u32, where: []const u8, msg: []const u8) !void {
    try stderr.print("[line {d}] Error {s}:{s}\n", .{ line, where, msg });
    try stderr.flush();
    had_error = true;
}
