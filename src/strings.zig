const std = @import("std");
const mem = @import("std").mem;
const debug = @import("std").debug;
const ArrayList = @import("std").ArrayList;
const HashMap = @import("std").HashMap;


const Allocator = mem.Allocator;

const english_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const english_lower = "abcdefghijklmnopqrstuvwxyz";

const eng_upper_start: usize = 65;
const eng_upper_end: usize = 90;
const eng_lower_start: usize = 97;
const eng_lower_end: usize = 122;

pub const string = struct {
    buffer: []u8,
    allocator: *Allocator,

    pub fn init(str: []const u8) !string {
        var buf = try std.heap.c_allocator.alloc(u8, str.len);
        for (str) |c, i| {
            buf[i] = c;
        }
        return string {
            .buffer = buf,
            .allocator = std.heap.c_allocator    
        };
    }

    // return the size of the string
    pub fn size(self: *const string) usize {
        return self.buffer.len;
    }

    // check if the string constains a substring
    pub fn contains(self: *const string, subs: []const u8) bool {
        var result = kmp(self, subs) catch unreachable;
        return result.count() > 0;
    }

    // check if the string starts with the prefix
    // passed in as argument
    pub fn startswith(self: *const string, pfx: []const u8) bool {
        return mem.startsWith(u8, self.buffer, pfx);
    }

    // check if the string ends with the suffix
    // passed in as argument
    pub fn endswith(self: *const string, sfx: []const u8) bool {
        return mem.endsWith(u8, self.buffer, sfx);
    }

    // find all occurrences of a substring. returns an ArrayList of indices
    // where there is a substring match.
    pub fn find_all(self: *const string, needle: []const u8) !ArrayList(usize) {
        return kmp(self, needle);
    }

    // Knuth-Morris-Pratt substring search
    pub fn kmp(self: *const string, needle: []const u8) !ArrayList(usize) {
        const m = needle.len;
        var border = try self.allocator.alloc(i64, m+1);
        defer self.allocator.free(border);
        border[0] = -1;

        var i: usize = 0;
        while (i < m): (i += 1) {
            border[i+1] = border[i];
            while (border[i+1] > -1 and needle[usize(border[i+1])] != needle[i]) {
                border[i+1] = border[usize(border[i+1])];
            }
            border[i+1]+=1;
        }

        var results = ArrayList(usize).init(self.allocator);
        var n = self.buffer.len;
        var seen: i64 = 0;
        var j: usize = 0;
        while (j < n): (j += 1) {
            while (seen > -1 and needle[usize(seen)] != self.buffer[j])  {
                seen = border[usize(seen)];
            }
            seen+=1;
            if (seen == i64(m)) {
                results.append(j-m+1) catch unreachable;
            seen = border[m];
            }
        }
        return results;
    }


    // compute the levenshtein edit distance to another string
    pub fn levenshtein(self: *const string, other: []const u8) !usize {
        var prevrow = try self.allocator.alloc(usize, other.len+1);
        var currrow = try self.allocator.alloc(usize, other.len+1);
        defer self.allocator.free(prevrow);
        defer self.allocator.free(currrow);

        var i: usize = 0;
        while (i <= other.len): (i += 1) {
            prevrow[i] = i;
        }

        i = 1;
        while (i <= self.buffer.len): (i += 1) {
            currrow[0] = i;
            var j: usize = 1;
            while (j <= other.len): (j += 1) {
                if (self.buffer[i-1] == other[j-1]) {
                    currrow[j] = prevrow[j-1];
                } else {
                    currrow[j] = @inlineCall(min, prevrow[j]+1,
                    currrow[j-1]+1,
                    prevrow[j-1]+1);
                }
            }
            mem.copy(usize, prevrow, currrow);
        }
        return currrow[other.len];
    }


    // convert all characters to lowercase
    pub fn lower(self: *const string) void {
        for (self.buffer) |c, i| {
            if (eng_upper_start <= c and c <= eng_upper_end) {
                self.buffer[i] = english_lower[upper_map(c)];
            }
        }
    }

    // convert all characters to uppercase
    pub fn upper(self: *const string) void {
        for (self.buffer) |c, i| {
            if (eng_lower_start <= c and c <= eng_lower_end) {
                self.buffer[i] = english_upper[lower_map(c)];
            }
        }
    }
};

pub fn upper_map(c: u8) usize {
    return c - eng_upper_start;
}

pub fn lower_map(c: u8) usize {
    return c - eng_lower_start;
}

pub fn min(x: usize, y: usize, z: usize) usize {
    var result = x;
    if (y < result) {
        result = y;
    } else if (z < result) {
        result = z;
    }
    return result;
}