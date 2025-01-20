package lexer

Token :: struct {
    type: TokenType,
    value: string
}

TokenType :: enum {
    ASSIGNMENT,
    COLON,
    DOT,
    DOT_DOT,
    EQUALITY,
    FOR,
    FUN,
    GREATER,
    GREATER_EQUALS,
    IF,
    L_CURLY,
    L_PAREN,
    L_SQUARE,
    LESS,
    LESS_EQUALS,
    MINUS,
    MINUS_MINUS,
    NAME,
    NOT,
    NOT_EQUALS,
    NUMBER,
    PLUS,
    PLUS_PLUS,
    QUESTION_MARK,
    R_CURLY,
    R_PAREN,
    R_SQUARE,
    SEMICOLON,
    SPACE,
    STRING,
    VAR,
}