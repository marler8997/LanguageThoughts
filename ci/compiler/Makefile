CC=gcc
YACC=yacc
LEXER=flex

LEXER_C_SOURCE=ciTokenizer.c
PARSER_C_SOURCE=ciParser.c

all: lexer parser

parser: ciParserMain.c ciParser.c
	${CC} -o parser ciParserMain.c ciParser.c ciTokenizer.c


ciParser.c: ciParser.yacc
	${YACC}	-o ciParser.c ciParser.yacc

lexer: ${LEXER_C_SOURCE} ciTokenizerMain.c
	${CC} -o lexer ciTokenizerMain.c ${LEXER_C_SOURCE}

${LEXER_C_SOURCE}: ciTokenizer.flex
	${LEXER} -t < ciTokenizer.flex > ${LEXER_C_SOURCE}




clean:
	rm -f *~ lexer parser ${LEXER_C_SOURCE} ${PARSER_C_SOURCE}