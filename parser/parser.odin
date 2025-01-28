package parser

import "core:fmt"
import "core:strings"
import "../lexer"

VALUE_TOKEN_TYPES : []lexer.TokenType = {lexer.TokenType.NUMBER, lexer.TokenType.STRING, lexer.TokenType.NAME}
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

    fmt.println("Completed parsing")
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

    if node.left != nil {
        recursive_free_node(node.left)
    }
    if node.right != nil {
        recursive_free_node(node.right)
    }
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
    name := get(lexer.TokenType.NAME)
    next_token := tokens[i]

    if (lexer.is_operation_token(&next_token)) {

    }
    else if (next_token.type == lexer.TokenType.L_PAREN) { // function call
        get(lexer.TokenType.L_PAREN)
        called_params := get_called_param_node()
        node := new_clone(Node{type = NodeType.CALL, value = name.value, left = called_params.left, right = called_params.right})
        add_node(node)
    }
    else {
        fmt.println("unexpected token when parsing ", next_token)
    }
}

get_called_param_node :: proc() -> ^Node {
    if (tokens[i].type == lexer.TokenType.R_PAREN) {
        get()
        return new_clone(Node{type = NodeType.CALLED_PARAMS, left = nil, right = nil})
    }

    left_token := get(VALUE_TOKEN_TYPES)
    left : ^Node
    #partial switch left_token.type {
        case .NUMBER: left = new_clone(Node{type = NodeType.NUMBER, value = left_token.value})
        case .NAME, .STRING: left = new_clone(Node{type = NodeType.VALUE, value = left_token.value})

        case: {
            fmt.println("Unexpected param type", left_token.type, "for function call on line", left_token.line, left_token.line_col)
            panic("")
        }
    }

    if (tokens[i].type == lexer.TokenType.R_PAREN) {
        get(lexer.TokenType.R_PAREN)
        right : ^Node = nil
        return new_clone(Node{type = NodeType.CALLED_PARAMS, left = left, right = right})
    }
    else {
        get(lexer.TokenType.COMMA)

        right : ^Node = get_called_param_node()
        return new_clone(Node{type = NodeType.CALLED_PARAMS, left = left, right = right})
    }
}

parse_var :: proc() {
    get(lexer.TokenType.VAR)
    left := get_next_name()
    get(lexer.TokenType.ASSIGNMENT)
    right := get_next_value()
    get(lexer.TokenType.SEMICOLON)

    assignmentNode := new_clone(Node{type = NodeType.ASSIGNMENT, left = left, right = right})
    add_node(assignmentNode)
    fmt.println("Assigned variable", left.value, "to", right.value)
}

get_next_name :: proc() -> ^Node {
    name := get(lexer.TokenType.NAME).value
    return new_clone(Node{NodeType.NAME, name, nil, nil})
}

get_next_value :: proc() -> ^Node {
    token := get(VALUE_TOKEN_TYPES)

    #partial switch token.type {
        case .NUMBER: return new_clone(Node{NodeType.NUMBER, token.value, nil, nil})
        case .STRING: return new_clone(Node{NodeType.VALUE, token.value, nil, nil})
        case: {
            fmt.println("Unexpected token type", token.type, "getting next value")
            panic("Got unexpected token type")
        }
    }
}

get :: proc{get_expected_token, get_token, get_expected_token_with_types}

get_expected_token :: proc(expectedTokenType: lexer.TokenType) -> lexer.Token {
    token := tokens[i]

    if (token.type != expectedTokenType) {
        fmt.println("Expected", expectedTokenType, "got", token.type)
        panic("Got unexpected token type")
    }

    i += 1;
    return token;
}

get_expected_token_with_types :: proc(expectedTokenTypes: []lexer.TokenType) -> lexer.Token {
    token := tokens[i]

    for expectedTokenType in expectedTokenTypes {
        if (token.type == expectedTokenType) {
            i += 1;
            return token;
        }
    }

    fmt.println("Got unexpected token type", token)
    panic("")
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