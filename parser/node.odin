package parser

import "../lexer"

Node :: struct {
    type: NodeType,
    value: string,
    left: ^Node,
    right: ^Node,
}

NodeType :: enum {
    ADDRESS,
    ASSIGNMENT,
    NAME,
    VALUE,
    NUMBER,
    CALL,
    CALLED_PARAMS,
    PLUS_EQUALS,
    PLUS_PLUS,
}

get_node_type :: proc (token_type: lexer.TokenType) -> NodeType {
    #partial switch token_type {
        case .PLUS_EQUALS: return NodeType.PLUS_EQUALS
        case .PLUS_PLUS: return NodeType.PLUS_PLUS
    }

    return NodeType.VALUE
}