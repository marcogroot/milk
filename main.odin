package main

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "util"

IDENTIFIERS := []rune{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
NUMBERS := []rune{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
KEYWORDS := []string{"var"}

i := 0
input_string := "var age = 5 ;"
input := utf8.string_to_runes(input_string)
input_length := len(input_string)
tokens := [dynamic]Token{}

main :: proc() {
    fmt.println(input_string)

    curr := input[i]

    token : Token
    for i < input_length {
        curr = input[i]
        fmt.println(curr)
        if (is_identifier(&curr)) {
            word := get_word()
            token = get_word_token(&word)
            add_token(&token)
        }
        else if (is_number(&curr)) {
            number := get_number()
            add_token(TokenType.NUMBER, &number)
        }
        else if (curr == '=') {
            if peek() == '=' {
                get()
                add_token(TokenType.EQUALITY, "==")
            }
            else {
                add_token(TokenType.ASSIGNMENT, "=")
            }
            get()
        }
        else if (curr == '!') {
            if peek() == '=' {
                get()
                add_token(TokenType.NOT_EQUALS, "!=")
            }
            else {
                add_token(TokenType.NOT, "!")
            }
            get()
        }
        else if (curr == '<') {
            if peek() == '=' {
                get()
                add_token(TokenType.LESS_EQUALS, "<=")
            }
            else {
                add_token(TokenType.LESS, "<")
            }
            get()
        }
        else if (curr == '>') {
            if peek() == '=' {
                get()
                add_token(TokenType.GREATER_EQUALS, ">=")
            }
            else {
                add_token(TokenType.GREATER, ">")
            }
            get()
        }
        else if (curr == ' ') {
            add_token(TokenType.SPACE, " ")
            get()
        }
        else if (curr == ';') {
            add_token(TokenType.SEMICOLON, ";")
            get()
        }
        else if (curr == '"') {
            str := get_string()
            add_token(TokenType.STRING, str)
            get()
        }
        else if (curr == '(') {
            add_token(TokenType.L_PAREN, "(")
            get()
        }
        else if (curr == ')') {
            add_token(TokenType.R_PAREN, ")")
            get()
        }
        else if (curr == '{') {
            add_token(TokenType.L_CURLY, "{")
            get()
        }
        else if (curr == '}') {
            add_token(TokenType.R_CURLY, "}")
            get()
        }
        else if (curr == '[') {
            add_token(TokenType.L_SQUARE, "[")
            get()
        }
        else if (curr == ']') {
            add_token(TokenType.R_SQUARE, "]")
            get()
        }
        else if (curr == '.') {
            if peek() == '.' {
                get()
                add_token(TokenType.DOT_DOT, "..")
            }
            else {
                add_token(TokenType.DOT, ".")
            }
            get()
        }
        else if (curr == '?') {
            add_token(TokenType.QUESTION_MARK, "?")
            get()
        }
        else if (curr == ':') {
            add_token(TokenType.COLON, ":")
            get()
        }
        else if (curr == '+') {
            if peek() == '+' {
                get()
                add_token(TokenType.PLUS_PLUS, "++")
            }
            else {
                add_token(TokenType.PLUS, "+")
            }
            get()
        }
        else if (curr == '-') {
            if peek() == '-' {
                get()
                add_token(TokenType.MINUS_MINUS, "--")
            }
            else {
                add_token(TokenType.MINUS, "-")
            }
            get()
        }
        else {
            fmt.println("ERROR: Got unknown character: ", curr)
            get()
        }
    }

    for token in tokens {
        fmt.println(token.type, token.value)
    }
}

add_token :: proc{add_token_with_string_pointer, add_token_symbol, add_pure_token}

add_token_with_string_pointer :: proc(type: TokenType, value: ^string) {
    append(&tokens, Token{type, value^})
}

add_token_symbol :: proc(type: TokenType, value: string) {
    append(&tokens, Token{type, value})
}

add_pure_token :: proc(token: ^Token) {
    append(&tokens, token^)
}

get_word_token :: proc(word: ^string) -> Token {
    switch word^ {
         case "var": return Token{TokenType.VAR, word^}
         case "if": return Token{TokenType.IF, word^}
         case "for": return Token{TokenType.VAR, word^}
    }
    return Token{TokenType.NAME, word^}
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
    return temp;
}

peek :: proc() -> rune {
    if i + 1 < input_length {
        return input[i+1]
    }
    fmt.println("Reached EOF, cant peek")
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

is_number :: proc(r: ^rune) -> bool {
    for number_rune in NUMBERS {
        if r^ == number_rune {
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

