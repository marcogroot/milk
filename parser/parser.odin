package parser

import "core:fmt"
import "../lexer"

i := 0
tokens : ^[dynamic]lexer.Token
nodesData := [dynamic]NodeData{}
assignmentNodes := [dynamic]AssignmentNode{}

tokens_length : int
parse :: proc(tkns: ^[dynamic]lexer.Token) -> int {
    defer(delete(nodesData))
    defer(delete(assignmentNodes))
    i = 0
    tokens = tkns
    tokens_length = len(tkns)
    nodesData = {}
    parse_token()

    for node in nodesData {
        fmt.println(node)
    }

    return 1
}

parse_token :: proc() {
    token := tokens[i]

    #partial switch token.type {
       case .VAR: parse_var()
       case: fmt.println("Dont know how to parse")
    }
}

parse_var :: proc() {
    get(lexer.TokenType.VAR)
    get(lexer.TokenType.SPACE)
    name := get(lexer.TokenType.NAME).value
    get(lexer.TokenType.SPACE)
    get(lexer.TokenType.ASSIGNMENT)
    get(lexer.TokenType.SPACE)
    value := get(lexer.TokenType.NUMBER).value
    get(lexer.TokenType.SEMICOLON)

    assignmentNode := AssignmentNode{name, value}
    add_assignment_node(&assignmentNode)
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

add_assignment_node :: proc(node: ^AssignmentNode) {
    nodeData := NodeData{NodeType.ASSIGNMENT, len(assignmentNodes)}
    append(&nodesData, nodeData)
    append(&assignmentNodes, node^)
}