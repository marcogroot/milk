package lexer

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"

IDENTIFIERS :: []rune{
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
}

NUMBERS :: []rune{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

OPERATION_TOKEN_TYPES :: []TokenType{ TokenType.PLUS_PLUS, TokenType.PLUS, TokenType.MINUS_MINUS, TokenType.MINUS, TokenType.PLUS_EQUALS}

is_operation_token :: proc(token: ^Token) -> bool {
    for type in OPERATION_TOKEN_TYPES {
        if token.type == type {
            return true
        }
    }
    return false
}

is_identifier :: proc(r: ^rune) -> bool {
    for identifier_rune in IDENTIFIERS {
        if r^ == identifier_rune {
            return true
        }
    }
    return false
}

is_number :: proc(r: ^rune) -> bool {
    for number_rune in NUMBERS {
        if r^ == number_rune {
            return true
        }
    }
    return false
}

add_token :: proc{add_token_with_string_pointer, add_token_symbol, add_pure_token}

add_token_with_string_pointer :: proc(type: TokenType, value: ^string) {
    append(&tokens, Token{type, value^, line, line_col})
}

add_token_symbol :: proc(type: TokenType, value: string) {
    append(&tokens, Token{type, value, line, line_col})
}

add_pure_token :: proc(token: ^Token) {
    append(&tokens, token^)
}

get_word_token :: proc(word: ^string) -> Token {
    switch word^ {
    case "stack": return Token{TokenType.STACK, word^, line, line_col}
    case "heap": return Token{TokenType.HEAP, word^, line, line_col}
    case "temp": return Token{TokenType.TEMP, word^, line, line_col}
    case "if": return Token{TokenType.IF, word^, line, line_col}
    case "for": return Token{TokenType.FOR, word^, line, line_col}
    case "fun": return Token{TokenType.FUN, word^, line, line_col}
    }
    return Token{TokenType.NAME, word^, line, line_col}
}

get_word :: proc() -> string {
    start_index := i
    curr := input[i]
    for is_identifier(&curr) {
        get()
        curr = input[i]
    }

    identifier, ok := strings.substring(input_string, start_index, i)
    if !ok {
        fmt.println("There was an error getting identifier between ", start_index, i)
    }
    return identifier
}

get_string :: proc() -> string {
    start_index := i
    curr := input[i]
    for i < input_length && curr != '"'  {
        get()
        curr = input[i]
    }

    if (curr != '"') {
        fmt.println("String was not terminated, first double quote at", start_index)
    }

    str, ok := strings.substring(input_string, start_index, i)
    if !ok {
        fmt.println("There was an error getting string between ", start_index, i)
    }
    return str
}

get_number :: proc() -> string {
    start_index := i
    curr := input[i]
    for is_number(&curr) {
        get()
        curr = input[i]
    }

    number, ok := strings.substring(input_string, start_index, i)
    if !ok {
        fmt.println("There was an error getting number between ", start_index, i)
    }
    return number
}

get :: proc() -> rune {
    temp := input[i]
    i += 1;
    line_col += 1;
    return temp;
}

peek :: proc() -> rune {
    if i + 1 < input_length {
        return input[i+1]
    }
    fmt.println("Reached EOF, cant peek")
    return input[i-1];
}