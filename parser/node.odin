package parser

Node :: union {
    AssignmentNode,
    OperationNode,
}

AssignmentNode :: struct {
    name: string,
    value: string,
}

OperationNode :: struct {
    left: string,
    right: string,
}

NodeType :: enum {
    ASSIGNMENT
}