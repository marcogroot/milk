package main

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "core:mem"
import "util"
import "lexer"

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer {
        for _, entry in track.allocation_map {
            fmt.eprintfln("%v leaked %v bytes", entry.location, entry.size)
        }
        for entry in track.bad_free_array {
            fmt.eprintfln("%v bad free", entry.location)
        }
        mem.tracking_allocator_destroy(&track)
    }

    input_string := "var age = 5;"
    tokens := lexer.parse_file(&input_string)
    defer(delete_dynamic_array(tokens^))

    fmt.println("-----------------------------")
    fmt.println("got tokens : ")
    for token in tokens {
        fmt.println(token.type, token.value)
    }
}


