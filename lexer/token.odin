package lexer

Token :: struct {
    type: TokenType,
    value: string
}

TokenType :: enum {
    // keywords
    VAR,
    IF,
    FOR,
    FUN,

    // operations
    EQUALITY,
    NOT,
    NOT_EQUALS,
    LESS,
    LESS_EQUALS,
    GREATER,
    GREATER_EQUALS,

    NAME,
    ASSIGNMENT,
    SEMICOLON,
    SPACE,
    NUMBER,
    STRING,
    L_PAREN,
    R_PAREN,
    L_CURLY,
    R_CURLY,
    L_SQUARE,
    R_SQUARE,

    DOT,
    DOT_DOT,
    QUESTION_MARK,
    COLON,
    PLUS,
    PLUS_PLUS,
    MINUS,
    MINUS_MINUS,
}