package main

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "util"
import "lexer"

main :: proc() {
    input_string := "var age = 5;"
    tokens := lexer.parse_file(strings.clone(input_string))

    fmt.println("-----------------------------")
    fmt.println("got tokens : ")
    for token in tokens {
        fmt.println(token.type, token.value)
    }
}


