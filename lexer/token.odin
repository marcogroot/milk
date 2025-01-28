package lexer

Token :: struct {
    type: TokenType,
    value: string,
    line: int,
    line_col: int,
}

TokenType :: enum {
    ASSIGNMENT,
    COLON,
    COMMA,
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
    MINUS_EQUALS,
    MINUS_MINUS,
    NAME,
    NEW_LINE,
    NOT,
    NOT_EQUALS,
    NUMBER,
    PLUS,
    PLUS_EQUALS,
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