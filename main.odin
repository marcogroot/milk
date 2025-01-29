package main

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "core:mem"
import "util"
import "lexer"
import "parser"
import "tools"
import "transpiler"

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

    input_string := util.read_file("milk_files/test2.milk")
    tokens := lexer.lex(&input_string)
    ast_nodes := parser.parse(tokens)
    //tools.visualise_ast(ast_nodes)
    transpiler.interpret_ast(ast_nodes)


    parser.delete_nodes(ast_nodes)
    delete(input_string)
    delete_dynamic_array(tokens^)
}


