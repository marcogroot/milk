package test

import "core:testing"
import "core:log"
import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "../lexer"

@(test)
basic_lex_test :: proc(t: ^testing.T) {
    input := "var abc = 5;"
    tokens := lexer.lex(&input)
    delete_dynamic_array(tokens^)

    expected_tokens_len :: 8
    expected_tokens := [expected_tokens_len]lexer.Token{
        lexer.Token{lexer.TokenType.VAR, "var", 0, 2},
        lexer.Token{lexer.TokenType.SPACE, " ", 0, 3},
        lexer.Token{lexer.TokenType.NAME, "abc", 0, 6},
        lexer.Token{lexer.TokenType.SPACE, " ", 0, 7},
        lexer.Token{lexer.TokenType.ASSIGNMENT, "=", 0, 8},
        lexer.Token{lexer.TokenType.SPACE, " ", 0, 9},
        lexer.Token{lexer.TokenType.NUMBER, "5", 0, 10},
        lexer.Token{lexer.TokenType.SEMICOLON, ";", 0, 11},
    }

    testing.expect(t, len(tokens) == expected_tokens_len, "incorrect token length")

    for token, i in tokens {
        assert_failed := !(token == expected_tokens[i])
        if assert_failed {
            log.info(i, token, expected_tokens[i])
            testing.expect(t, false, "incorrect token")
        }
    }
}

@(test)
test_keywords_and_operations :: proc(t: ^testing.T) {
    input := "var if for fun == ! != < <= > >= = test ;   1234 ( ) { } [ ] . .. ? : + += ++ - -= -- \n"
    //                               testing space here ^

    tokens := lexer.lex(&input)
    delete_dynamic_array(tokens^)

    expected_tokens_len :: 33
    expected_tokens := [expected_tokens_len]lexer.Token{
        lexer.Token{lexer.TokenType.VAR, "var", 0, 2},
        lexer.Token{lexer.TokenType.IF, "if", 0, 5},
        lexer.Token{lexer.TokenType.FOR, "for", 0, 9},
        lexer.Token{lexer.TokenType.FUN, "fun", 0, 13},
        lexer.Token{lexer.TokenType.EQUALITY, "==", 0, 16},
        lexer.Token{lexer.TokenType.NOT, "!", 0, 18},
        lexer.Token{lexer.TokenType.NOT_EQUALS, "!=", 0, 21},
        lexer.Token{lexer.TokenType.LESS, "<", 0, 23},
        lexer.Token{lexer.TokenType.LESS_EQUALS, "<=", 0, 26},
        lexer.Token{lexer.TokenType.GREATER, ">", 0, 28},
        lexer.Token{lexer.TokenType.GREATER_EQUALS, ">=", 0, 31},
        lexer.Token{lexer.TokenType.ASSIGNMENT, "=", 0, 33},
        lexer.Token{lexer.TokenType.NAME, "test", 0, 38},
        lexer.Token{lexer.TokenType.SEMICOLON, ";", 0, 40},
        lexer.Token{lexer.TokenType.SPACE, " ", 0, 42},
        lexer.Token{lexer.TokenType.NUMBER, "1234", 0, 47},
        lexer.Token{lexer.TokenType.L_PAREN, "(", 0, 49},
        lexer.Token{lexer.TokenType.R_PAREN, ")", 0, 51},
        lexer.Token{lexer.TokenType.L_CURLY, "{", 0, 53},
        lexer.Token{lexer.TokenType.R_CURLY, "}", 0, 55},
        lexer.Token{lexer.TokenType.L_SQUARE, "[", 0, 57},
        lexer.Token{lexer.TokenType.R_SQUARE, "]", 0, 59},
        lexer.Token{lexer.TokenType.DOT, ".", 0, 61},
        lexer.Token{lexer.TokenType.DOT_DOT, "..", 0, 64},
        lexer.Token{lexer.TokenType.QUESTION_MARK, "?", 0, 66},
        lexer.Token{lexer.TokenType.COLON, ":", 0, 68},
        lexer.Token{lexer.TokenType.PLUS, "+", 0, 70},
        lexer.Token{lexer.TokenType.PLUS_EQUALS, "+=", 0, 73},
        lexer.Token{lexer.TokenType.PLUS_PLUS, "++", 0, 76},
        lexer.Token{lexer.TokenType.MINUS, "-", 0, 78},
        lexer.Token{lexer.TokenType.MINUS_EQUALS, "-=", 0, 81},
        lexer.Token{lexer.TokenType.MINUS_MINUS, "--", 0, 84},
        lexer.Token{lexer.TokenType.NEW_LINE, "", 0, 86},
    }

    testing.expect(t, (len(tokens)+1)/2 == expected_tokens_len, "incorrect token length")

    expected_token_index := 0
    for token, i in tokens {
        if i % 2 == 0 {
            assert_failed := !(token == expected_tokens[expected_token_index])
            if assert_failed {
                log.info(expected_token_index, token, expected_tokens[expected_token_index])
                testing.expect(t, false, "incorrect token")
            }
            expected_token_index += 1
        }
    }

}