package main

import "core:fmt"
import "util"

main :: proc() {
    input := util.read_file("main.milk")
    defer delete(input)

    fmt.println(input)

    next_new_line(0, 0, &input)
    fmt.println(input[0])
 }

next_new_line :: proc(
    token_start_index: int,
    current_index: int,
    input: ^[]rune
) {
    // can be
    curr := input[current_index]
    fmt.println(curr)
    if (curr == ' ') {
        return;
    }

    next_new_line(token_start_index, current_index+1, input);

    // 1. variable decleration (var)
    // 2. variable ?
    // 3. function call
}



Token :: struct {
   type: TokenType,
}

TokenType :: enum {
    VAR, IDENTIFIER, OPERATION, SEMICOLON
}
