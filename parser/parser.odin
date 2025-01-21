package parser

import "core:fmt"
import "../lexer"

parse :: proc(tokens: ^[dynamic]lexer.Token) -> int {
    fmt.println("Parsing the file here...")
    // todo
    return 1
}