package parser

Node :: struct {
    type: NodeType,
    value: string,
    left: ^Node,
    right: ^Node,
}

NodeType :: enum {
    ASSIGNMENT,
    NAME,
    VALUE,
    NUMBER,
    CALL,
    CALLED_PARAMS,
}