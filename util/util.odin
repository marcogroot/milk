package util

import "core:os"
import "core:strings"
import "core:fmt"
import "core:unicode/utf8"

read_file :: proc(filepath: string) -> string {
    data, ok := os.read_entire_file(filepath, context.allocator)
    defer(delete(data))

    if !ok {
        return {}
    }

    return strings.clone(string(data))
}