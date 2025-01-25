package parser

import "core:fmt"
import "../lexer"

i := 0
tokens : ^[dynamic]lexer.Token
nodes := [dynamic]Node{}

tokens_length : int
parse :: proc(input_tokens: ^[dynamic]lexer.Token) ->  ^[dynamic]Node {
    defer(delete(nodes))
    i = 0
    tokens = input_tokens
    tokens_length = len(input_tokens)
    nodes = {}
    parse_token()

    for node in nodes {
        fmt.println(node)
    }

    return &nodes
}

parse_token :: proc() {
    for i < tokens_length -1 {
        token := tokens[i]

        #partial switch token.type {
            case .VAR: parse_var()
            case .NAME: parse_name()
            case: {
                fmt.printf("error occured during compile. Unexpected token type %s on line %d", token.type, token.line)
                return;
            }

        }
    }
}

parse_name ::proc() {
    get(lexer.TokenType.NAME)
    next_token := peek()

    if (lexer.is_operation_token(&next_token)) {

    }
    else {
        fmt.println("unexpected token when parsing ")
    }
}

parse_var :: proc() {
    get(lexer.TokenType.VAR)
    name := get(lexer.TokenType.NAME).value
    get(lexer.TokenType.ASSIGNMENT)
    value := get(lexer.TokenType.NUMBER).value
    get(lexer.TokenType.SEMICOLON)

    assignmentNode := AssignmentNode{name, value}
    add_node(&assignmentNode)
    fmt.println("Assigned variable", name, "to", value)
}

get :: proc(expectedTokenType: lexer.TokenType) -> lexer.Token {
    token := tokens[i]

    if (token.type != expectedTokenType) {
        fmt.println("Expected", expectedTokenType, "got", token.type)
        panic("Got unexpected token type")
    }

    i += 1;
    return token;
}

peek :: proc() -> lexer.Token {
    if i + 1 <  tokens_length{
        return tokens[i+1]
    }
    fmt.println("Reached EOF, cant peek")
    return tokens[i-1];
}

add_node :: proc{add_assignment_node}

add_assignment_node :: proc(assignmentNode: ^AssignmentNode) {
    append(&nodes, assignmentNode^)
}