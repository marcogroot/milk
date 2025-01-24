package parser

NodeData :: struct {
    type: NodeType,
    index: int,
}

AssignmentNode :: struct {
    name: string,
    value: string,
}

NodeType :: enum {
    ASSIGNMENT
}