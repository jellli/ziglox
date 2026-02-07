const std = @import("std");

const Self = @This();

io: std.Io,




pub fn main(args: []const u8) void {
    if (args.len > 1) {
        std.process.exit(64);
    } else if (args.len == 1) {} else {}
}

fn runFile(_: *Self, io: std.Io, path: []const u8) void {
var buffer: [1024]u8 = undefined;
var stdout:std.Io.File = std.Io.File.stdout();
var sw:std.Io.Writer = std.Io.File.writer(, io, &buffer),
    var buffer: [1024]u8 = undefined;
    const file = try std.Io.Dir.openFileAbsolute(io, path, .{
        .mode = .read_only,
    });
    const file_reader = std.Io.File.readerStreaming(file, io, &buffer);
    const reader = &file_reader.interface;
}
