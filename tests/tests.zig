const std = @import("std");
const assert = std.debug.assert;
const mem = std.mem;

const String = @import("strings").String;

test "strings.equals" {
    const s = try String.init("this is a string");
    defer s.deinit();
    assert(s.equals("this is a string"));

    const s2 = try String.init("");
    defer s2.deinit();
    assert(s2.equals(""));
}

test "strings.starts_endswith" {
    const s = try String.init("this is some data to work with");
    defer s.deinit();

    // startswith and endswith
    assert(s.startswith("this"));
    assert(s.startswith("this is some data to work with"));

    assert(s.endswith("with"));
    assert(s.endswith("this is some data to work with"));
}

test "strings.size" {
    const s = try String.init("this is some data to work with");
    defer s.deinit();

    assert(s.size() == 30);
}

test "strings.find_substring" {
    // find all instances of substrings
    const s = try String.init("this is some more data, SoMe some hey hey yo. APPLE DOG jump");
    defer s.deinit();

    const results = try s.find_all("some");
    defer s.allocator.free(results);
    assert(results.len == 2);
    assert(results[0] == 8);
    assert(results[1] == 29);

    // check if contains substring
    assert(s.contains("some"));
    assert(!s.contains("fountain"));
}

test "strings.upper_lower" {
    const s = try String.init("this is some more data, SoMe some hey hey yo. APPLE DOG jump");
    defer s.deinit();

    // upper and lowercase
    s.lower();
    assert(mem.eql(u8, s.buffer, "this is some more data, some some hey hey yo. apple dog jump"));
    s.upper();
    assert(mem.eql(u8, s.buffer, "THIS IS SOME MORE DATA, SOME SOME HEY HEY YO. APPLE DOG JUMP"));

    const s2 = try String.init("this is some more data, SoMe some hey hey yo. APPLE DOG jump");
    defer s2.deinit();

    // swap upper to lower and vice versa
    s2.swapcase();
    assert(mem.eql(u8, s2.buffer, "THIS IS SOME MORE DATA, sOmE SOME HEY HEY YO. apple dog JUMP"));
}

test "strings.edit_distance" {
    // levenshtein edit distance
    const s = try String.init("apple");
    defer s.deinit();
    assert((try s.levenshtein("snapple")) == 2);

    const s2 = try String.init("book");
    defer s2.deinit();
    assert((try s2.levenshtein("burn")) == 3);

    const s3 = try String.init("pencil");
    defer s3.deinit();
    assert((try s3.levenshtein("telephone")) == 8);

    const s4 = try String.init("flowers");
    defer s4.deinit();
    assert((try s4.levenshtein("wolf")) == 6);
}

test "strings.replace" {
    var s = try String.init("this is some more data, SoMe some hey hey yo. APPLE DOG jump");
    defer s.deinit();

    // replace all instances of substring with another substring
    try s.replace("some", "apple juice");
    assert(mem.eql(u8, s.buffer, "this is apple juice more data, SoMe apple juice hey hey yo. APPLE DOG jump"));

    try s.replace("apple juice", "mouse");
    assert(mem.eql(u8, s.buffer, "this is mouse more data, SoMe mouse hey hey yo. APPLE DOG jump"));

    try s.replace("jump", "cranberries");
    assert(mem.eql(u8, s.buffer, "this is mouse more data, SoMe mouse hey hey yo. APPLE DOG cranberries"));
}

test "strings.reverse" {
    // reverse a string
    const s = try String.init("this is a string");
    defer s.deinit();

    s.reverse();
    assert(mem.eql(u8, s.buffer, "gnirts a si siht"));
}

test "strings.concat" {
    var s = try String.init("hello there ");
    defer s.deinit();
    try s.concat("friendo");
    assert(mem.eql(u8, s.buffer, "hello there friendo"));
}

test "strings.strip" {
    // strip from the left
    var s = try String.init("  \tthis is a string  \n\r");
    defer s.deinit();
    try s.lstrip();
    assert(mem.eql(u8, s.buffer, "this is a string  \n\r"));

    // strip from the right
    var s2 = try String.init("  \tthis is a string  \n\r");
    defer s2.deinit();
    try s2.rstrip();
    assert(mem.eql(u8, s2.buffer, "  \tthis is a string"));

    // strip both
    var s3 = try String.init("  \tthis is a string  \n\r");
    defer s3.deinit();
    try s3.strip();
    assert(mem.eql(u8, s3.buffer, "this is a string"));
}

test "strings.count" {
    // count the number of occurances of a substring
    const s = try String.init("hello there, this is a string. strings are fun to play with.....string!!!!!");
    defer s.deinit();
    assert((try s.count("string")) == 3);
}

test "strings.split" {
    // split a string into a slice of strings, with single space as separator
    const s = try String.init("this is the string that I am going to split");
    defer s.deinit();

    const result = try s.split_to_u8(" ");
    defer s.allocator.free(result);
    assert(result.len == 10);
    assert(mem.eql(u8, result[0], "this"));
    assert(mem.eql(u8, result[3], "string"));
    assert(mem.eql(u8, result[6], "am"));
    assert(mem.eql(u8, result[9], "split"));

    const result2 = try s.split(" ");
    defer {
        for (result2) |r| {
            r.deinit();
        }
        s.allocator.free(result2);
    }
    assert(result2[0].equals("this"));
    assert(result2[3].equals("string"));
    assert(result2[6].equals("am"));
    assert(result2[9].equals("split"));

    const s2 = try String.init(moby);
    defer s2.deinit();

    const moby_split = try s2.split(" ");
    defer {
        for (moby_split) |r| {
            r.deinit();
        }
        s2.allocator.free(moby_split);
    }
    assert(moby_split.len == 198);

    const s3 = try String.init(@embedFile("fixtures/moby_dick.txt"));
    defer s3.deinit();

    const moby_full_split = try s3.split(" ");
    defer {
        for (moby_full_split) |r| {
            r.deinit();
        }
        s3.allocator.free(moby_full_split);
    }
    assert(moby_full_split.len == 192865);
}

var moby =
    \\Call me Ishmael. Some years ago—never mind how long precisely—having little or 
    \\no money in my purse, and nothing particular to interest me on shore, I thought 
    \\I would sail about a little and see the watery part of the world. It is a way I 
    \\have of driving off the spleen and regulating the circulation. Whenever I find myself 
    \\growing grim about the mouth; whenever it is a damp, drizzly November in my soul; 
    \\whenever I find myself involuntarily pausing before coffin warehouses, and bringing 
    \\up the rear of every funeral I meet; and especially whenever my hypos get such an 
    \\upper hand of me, that it requires a strong moral principle to prevent me from 
    \\deliberately stepping into the street, and methodically knocking people's hats off—then, 
    \\I account it high time to get to sea as soon as I can. This is my substitute for 
    \\pistol and ball. With a philosophical flourish Cato throws himself upon his sword; 
    \\I quietly take to the ship. There is nothing surprising in this. If they but knew it, 
    \\almost all men in their degree, some time or other, cherish very nearly the same feelings 
    \\towards the ocean with me.
;
