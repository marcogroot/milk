package lexer

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "../util"

IDENTIFIERS :: []rune{
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
}

NUMBERS :: []rune{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

i : int
line_col : int
line : int
input : []rune
input_string : string
input_length : int
tokens := [dynamic]Token{}

lex :: proc(input_text: ^string) -> ^[dynamic]Token {
    i = 0
    line_col = -1
    line = 0
    input = utf8.string_to_runes(input_text^)
    input_string = input_text^
    input_length = len(input_string)
    tokens = {}
    fmt.println("Performing lexing on \n", input_string)

    curr := input[i]

    token : Token
    for i < input_length {
        curr = input[i]
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
        // keep this structur of double calling get to make sure all gets come before the token addition
        // this keeps the line's column count consistent
            if peek() == '=' {
                get()
                get()
                add_token(TokenType.EQUALITY, "==")
            }
            else {
                get()
                add_token(TokenType.ASSIGNMENT, "=")
            }
        }
        else if (curr == '!') {
            if peek() == '=' {
                get()
                get()
                add_token(TokenType.NOT_EQUALS, "!=")
            }
            else {
                get()
                add_token(TokenType.NOT, "!")
            }
        }
        else if (curr == '<') {
            if peek() == '=' {
                get()
                get()
                add_token(TokenType.LESS_EQUALS, "<=")
            }
            else {
                get()
                add_token(TokenType.LESS, "<")
            }
        }
        else if (curr == '>') {
            if peek() == '=' {
                get()
                get()
                add_token(TokenType.GREATER_EQUALS, ">=")
            }
            else {
                get()
                add_token(TokenType.GREATER, ">")
            }
        }
        else if (curr == ' ') {
            get()
            add_token(TokenType.SPACE, " ")
        }
        else if (curr == ';') {
            get()
            add_token(TokenType.SEMICOLON, ";")
        }
        else if (curr == '"') {
            get()
            str := get_string()
            get()
            add_token(TokenType.STRING, str)
        }
        else if (curr == '(') {
            get()
            add_token(TokenType.L_PAREN, "(")
        }
        else if (curr == ')') {
            get()
            add_token(TokenType.R_PAREN, ")")
        }
        else if (curr == '{') {
            get()
            add_token(TokenType.L_CURLY, "{")
        }
        else if (curr == '}') {
            get()
            add_token(TokenType.R_CURLY, "}")
        }
        else if (curr == '[') {
            get()
            add_token(TokenType.L_SQUARE, "[")
        }
        else if (curr == ']') {
            get()
            add_token(TokenType.R_SQUARE, "]")
        }
        else if (curr == '.') {
            if peek() == '.' {
                get()
                get()
                add_token(TokenType.DOT_DOT, "..")
            }
            else {
                get()
                add_token(TokenType.DOT, ".")
            }
        }
        else if (curr == '?') {
            get()
            add_token(TokenType.QUESTION_MARK, "?")
        }
        else if (curr == ':') {
            get()
            add_token(TokenType.COLON, ":")
        }
        else if (curr == '+') {
            if peek() == '+' {
                get()
                get()
                add_token(TokenType.PLUS_PLUS, "++")
            }
            if peek() == '=' {
                get()
                get()
                add_token(TokenType.PLUS_EQUALS, "+=")
            }
            else {
                get()
                add_token(TokenType.PLUS, "+")
            }
        }
        else if (curr == '-') {
            if peek() == '-' {
                get()
                get()
                add_token(TokenType.MINUS_MINUS, "--")
            }
            if peek() == '=' {
                get()
                get()
                add_token(TokenType.MINUS_EQUALS, "-=")
            }
            else {
                get()
                add_token(TokenType.MINUS, "-")
            }
        }
        else if (curr == '\n') {
            get()
            add_token(TokenType.NEW_LINE, "")
            line += 1;
            line_col = -1;
        }
        else {
            fmt.println("ERROR: Got unknown character: ", curr)
            get()
        }
    }

    delete(input)
    return &tokens
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
    case "var": return Token{TokenType.VAR, word^, line, line_col}
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
