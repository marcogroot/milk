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
    tokens := lexer.parse_file(&input)
    delete_dynamic_array(tokens^)

    expected_tokens_len :: 8
    expected_tokens := [expected_tokens_len]lexer.Token{
        lexer.Token{lexer.TokenType.VAR, "var"},
        lexer.Token{lexer.TokenType.SPACE, " "},
        lexer.Token{lexer.TokenType.NAME, "abc"},
        lexer.Token{lexer.TokenType.SPACE, " "},
        lexer.Token{lexer.TokenType.ASSIGNMENT, "="},
        lexer.Token{lexer.TokenType.SPACE, " "},
        lexer.Token{lexer.TokenType.NUMBER, "5"},
        lexer.Token{lexer.TokenType.SEMICOLON, ";"},
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
    input := "var if for fun == ! != < <= > >= = test ;   1234 ( ) { } [ ] . .. ? : + ++ - --"
    //                               testing space here ^

    tokens := lexer.parse_file(&input)
    delete_dynamic_array(tokens^)

    expected_tokens_len :: 30
    expected_tokens := [expected_tokens_len]lexer.Token{
        lexer.Token{lexer.TokenType.VAR, "var"},
        lexer.Token{lexer.TokenType.IF, "if"},
        lexer.Token{lexer.TokenType.FOR, "for"},
        lexer.Token{lexer.TokenType.FUN, "fun"},
        lexer.Token{lexer.TokenType.EQUALITY, "=="},
        lexer.Token{lexer.TokenType.NOT, "!"},
        lexer.Token{lexer.TokenType.NOT_EQUALS, "!="},
        lexer.Token{lexer.TokenType.LESS, "<"},
        lexer.Token{lexer.TokenType.LESS_EQUALS, "<="},
        lexer.Token{lexer.TokenType.GREATER, ">"},
        lexer.Token{lexer.TokenType.GREATER_EQUALS, ">="},
        lexer.Token{lexer.TokenType.ASSIGNMENT, "="},
        lexer.Token{lexer.TokenType.NAME, "test"},
        lexer.Token{lexer.TokenType.SEMICOLON, ";"},
        lexer.Token{lexer.TokenType.SPACE, " "},
        lexer.Token{lexer.TokenType.NUMBER, "1234"},
        lexer.Token{lexer.TokenType.L_PAREN, "("},
        lexer.Token{lexer.TokenType.R_PAREN, ")"},
        lexer.Token{lexer.TokenType.L_CURLY, "{"},
        lexer.Token{lexer.TokenType.R_CURLY, "}"},
        lexer.Token{lexer.TokenType.L_SQUARE, "["},
        lexer.Token{lexer.TokenType.R_SQUARE, "]"},
        lexer.Token{lexer.TokenType.DOT, "."},
        lexer.Token{lexer.TokenType.DOT_DOT, ".."},
        lexer.Token{lexer.TokenType.QUESTION_MARK, "?"},
        lexer.Token{lexer.TokenType.COLON, ":"},
        lexer.Token{lexer.TokenType.PLUS, "+"},
        lexer.Token{lexer.TokenType.PLUS_PLUS, "++"},
        lexer.Token{lexer.TokenType.MINUS, "-"},
        lexer.Token{lexer.TokenType.MINUS_MINUS, "--"},
    }

    log.info(len(tokens), expected_tokens_len)
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