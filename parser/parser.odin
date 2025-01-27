package parser

import "core:fmt"
import "core:strings"
import "../lexer"

i := 0
tokens : ^[dynamic]lexer.Token
nodes := [dynamic]Node{}

tokens_length : int
parse :: proc(input_tokens: ^[dynamic]lexer.Token) ->  ^[dynamic]Node {
    i = 0
    tokens = input_tokens
    tokens_length = len(input_tokens)
    nodes = {}
    parse_token()

    return &nodes
}

delete_nodes :: proc(nodes: ^[dynamic]Node) {
    for &node in nodes {
        recursive_free_node(&node)
    }
}

recursive_free_node :: proc(node: ^Node) {
    if node == nil {
        return
    }
    recursive_free_node(node.left)
    recursive_free_node(node.right)
    free(node)
}

parse_token :: proc() {
    for i < tokens_length -1 {
        token := tokens[i]

        #partial switch token.type {
            case .VAR: {
                parse_var()
            }
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
    left := get_next_name()
    get(lexer.TokenType.ASSIGNMENT)
    right := get_next_value()
    get(lexer.TokenType.SEMICOLON)

    assignmentNode := Node{type = NodeType.ASSIGNMENT, left = left, right = right}
    add_node(&assignmentNode)
    fmt.println("Assigned variable", left.value, "to", right.value)
}

get_next_name :: proc() -> ^Node {
    name := get(lexer.TokenType.NAME).value
    return new_clone(Node{NodeType.NAME, name, nil, nil})
}

get_next_value :: proc() -> ^Node {
    token := get()

    #partial switch token.type {
        case .NUMBER: return new_clone(Node{NodeType.VALUE, token.value, nil, nil})
        case .STRING: return new_clone(Node{NodeType.VALUE, token.value, nil, nil})
        case: {
            fmt.println("Unexpected token type", token.type, "getting next value")
            panic("Got unexpected token type")
        }
    }
}

get :: proc{get_expected_token, get_token}

get_expected_token :: proc(expectedTokenType: lexer.TokenType) -> lexer.Token {
    token := tokens[i]

    if (token.type != expectedTokenType) {
        fmt.println("Expected", expectedTokenType, "got", token.type)
        panic("Got unexpected token type")
    }

    i += 1;
    return token;
}

get_token :: proc() -> lexer.Token {
    token := tokens[i]
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

add_node :: proc(node: ^Node) {
    append(&nodes, node^)
}