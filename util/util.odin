package util

import "core:os"
import "core:strings"
import "core:fmt"
import "core:unicode/utf8"

read_file :: proc(filepath: string) -> []rune {
    data, ok := os.read_entire_file(filepath, context.allocator)
    if !ok {
        return {}
    }
    defer delete(data, context.allocator)
    return utf8.string_to_runes(string(data))
}