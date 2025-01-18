package main

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "util"

IDENTIFIERS := []rune{'v', 'a', 'r', 'a', 'b', 'c'}
KEYWORDS := []string{"var"}

Token :: struct {
    type: TokenType
}

NameToken :: struct {
    name: string,
    using token: Token
}

KeywordToken :: struct {
    keyword: string,
    using token: Token
}

TokenType :: enum {
    KEYWORD,
    VALUE,
    NAME,
    OPERATION,
    SEMICOLON,
}

i := 0
input_string := util.read_file("main.milk")
input := utf8.string_to_runes(input_string)

tokens := [5]Token{};

main :: proc() {
    token_index := 0
    fmt.println(input)

    curr := input[i]
    if (is_identifier(&curr)) {
        identifier := get_identifier()
        if (is_keyword(identifier)) {
            token := KeywordToken{ keyword = identifier, type = TokenType.KEYWORD }
            tokens[token_index] = token
        } else {
            token := NameToken{ name = identifier, type = TokenType.VALUE }
            tokens[token_index] = token
        }
        delete(identifier)
    }

    token_index += 1
}

is_keyword :: proc(word: string) -> bool {
    for keyword in KEYWORDS {
        if word == keyword {
            return true
        }
    }
    return false
}


get_identifier :: proc() -> string {
    start_index := i
    curr := peek()
    for is_identifier(&curr) {
        get()
        curr = peek()
    }
    identifier, ok := strings.substring(input_string, start_index, i-1)
    fmt.println(identifier)
    if !ok {
        fmt.println("There was an error getting identifier between {0:d} {1:d}", start_index, i-1)
    }
    fmt.println("Got identifier %s", identifier)
    return identifier
}

get :: proc() -> rune {
    temp := input[i]
    i += 1;
    return temp;
}

peek :: proc() -> rune {
    return input[i];
}

is_identifier :: proc(r: ^rune) -> bool {
    for identifier_rune in IDENTIFIERS {
        if r^ == identifier_rune {
            return true
        }
    }
    return false
}

is_var :: proc(r: rune) -> bool {
    identifiers := []rune{'a', 'b', 'c'}
    for identifier_rune in identifiers {
        if r == identifier_rune {
            return true
        }
    }
    return false
}

