package main

Token :: struct {
    type: TokenType,
    value: string
}

TokenType :: enum {
    VAR,
    NAME,
    EQUALS,
    SEMICOLON,
    SPACE,
    NUMBER
}