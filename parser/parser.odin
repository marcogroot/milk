package parser

import "core:fmt"
import "core:strings"
import "../lexer"

VALUE_TOKEN_TYPES : []lexer.TokenType = {
    lexer.TokenType.NUMBER,
    lexer.TokenType.STRING,
    lexer.TokenType.NAME,
    lexer.TokenType.ADDRESS
}

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
    fmt.println("Finished del")
}

recursive_free_node :: proc(node: ^Node) {
    if node == nil {
        return
    }

    recursive_free_node(node.left)
    recursive_free_node(node.right)

    //free(node)
}

parse_token :: proc() {
    for i < tokens_length -1 {
        token := tokens[i]

        #partial switch token.type {
            case .STACK, .TEMP, .HEAP: {
                parse_assignment(token.type)
            }
            case .NAME: parse_name()
            case: {
                fmt.printfln("error occured during compile. Unexpected token type %s on line %d", token.type, token.line)
                return;
            }
        }
    }
}

parse_name ::proc() {
    name := get(lexer.TokenType.NAME)
    next_token := tokens[i]

    if (lexer.is_operation_token(&next_token)) {
        operation_token := get()
        node_type := get_node_type(operation_token.type)
        if is_no_param_operation(operation_token.type) {
            node := new_clone(Node{type = node_type, value = name.value })
            add_node(node)
            get(lexer.TokenType.SEMICOLON)
        } else {
            val := get_value_node()
            node := new_clone(Node{type = node_type, value = name.value, left = val, })
            add_node(node)
            get(lexer.TokenType.SEMICOLON)
        }

    }
    else if (next_token.type == lexer.TokenType.L_PAREN) { // function call
        get(lexer.TokenType.L_PAREN)
        called_params := get_called_param_node()
        node := new_clone(Node{type = NodeType.CALL, value = name.value, left = called_params.left, right = called_params.right})
        add_node(node)
    }
    else {
        fmt.eprintln("unexpected token when parsing ", next_token)
    }
}

is_no_param_operation :: proc (type: lexer.TokenType) -> bool {
    if (type == lexer.TokenType.PLUS_PLUS || type == lexer.TokenType.MINUS_MINUS) {
        return true;
    }
    return false
}

get_called_param_node :: proc() -> ^Node {
    if (tokens[i].type == lexer.TokenType.R_PAREN) {
        get()
        return new_clone(Node{type = NodeType.CALLED_PARAMS, left = nil, right = nil})
    }

    left := get_value_node()

    if (tokens[i].type == lexer.TokenType.R_PAREN) {
        get(lexer.TokenType.R_PAREN)
        return new_clone(Node{type = NodeType.CALLED_PARAMS, left = left, right = nil})
    }
    else {
        get(lexer.TokenType.COMMA)
        right : ^Node = get_called_param_node()
        return new_clone(Node{type = NodeType.CALLED_PARAMS, left = left, right = right})
    }
}

get_value_node :: proc() -> ^Node {
    left_token := get(VALUE_TOKEN_TYPES)
    #partial switch left_token.type {
        case .NUMBER: return new_clone(Node{type = NodeType.NUMBER, value = left_token.value})
        case .NAME, .STRING: return new_clone(Node{type = NodeType.VALUE, value = left_token.value})
        case .ADDRESS: {
            value := get(VALUE_TOKEN_TYPES)
            value_node := new_clone(Node{type = NodeType.VALUE, value = value.value})
            return new_clone(Node{type = NodeType.ADDRESS, value = left_token.value, left = value_node})
        }

        case: {
            fmt.eprintln("Unexpected value", left_token.type, "line", left_token.line, left_token.line_col)
            return nil
        }
    }
}

parse_assignment :: proc(token_type: lexer.TokenType) {
    token_type_name : string
    get(token_type)
    #partial switch token_type {
        case .STACK: token_type_name = "stack"
        case .HEAP: token_type_name = "heap"
        case .TEMP: token_type_name = "temp"

    case: {
        fmt.printfln("unexpected token for assignment parse %d", token_type)
        return;
        }
    }

    left := get_next_name()
    get(lexer.TokenType.ASSIGNMENT)
    right := get_value_node()
    get(lexer.TokenType.SEMICOLON)

    assignmentNode := new_clone(Node{type = NodeType.ASSIGNMENT, value=token_type_name, left = left, right = right})
    add_node(assignmentNode)
    //fmt.println("Assigned variable", left.value, "to", right.value)
}

get_next_name :: proc() -> ^Node {
    name := get(lexer.TokenType.NAME).value
    return new_clone(Node{NodeType.NAME, name, nil, nil})
}

get :: proc{get_expected_token, get_token, get_expected_token_with_types}

get_expected_token :: proc(expectedTokenType: lexer.TokenType) -> lexer.Token {
    token := tokens[i]

    if (token.type != expectedTokenType) {
        fmt.println("Expected", expectedTokenType, "got", token.type, "line:col", token.line, token.line_col)
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

    fmt.println("Got unexpected token types. Expected one of", expectedTokenTypes, "got", token.type)
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