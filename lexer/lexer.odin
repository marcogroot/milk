package lexer

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "../util"

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
    fmt.println("Performing lexing on\n", input_string)

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
            get() // don't need tokens for space or new lines
        }
        else if (curr == '/') {
            if peek() == '/' {
                get()
                for peek() != '\n' {
                    get()
                }
            }
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
        else if (curr == '@') {
            get()
            add_token(TokenType.DEREF, "[")
        }
        else if (curr == '&') {
            get()
            add_token(TokenType.ADDRESS, "[")
        }
        else if (curr == '^') {
            get()
            add_token(TokenType.POINTER, "[")
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
        else if (curr == ',') {
            get()
            add_token(TokenType.COMMA, ",")
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
            else if peek() == '=' {
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
            get() // dont need tokens for space or newlines
            line += 1;
            line_col = -1;
        }
        else {
            fmt.eprintln("ERROR: Got unknown character: ", curr)
            get()
        }
    }

    delete(input)
    fmt.println("Completed lexing")
    return &tokens
}
