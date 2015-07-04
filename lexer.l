/* this will include some C code directly, so we can pull in the
 * header files we want */
%{
#include "parser.h"
#include "helpers.h"
%}

/* this tells us that we're going to output our lexer implementation
 * to `lexer.c` and the associated header to `lexer.h`.
 */
%option outfile="lexer.c" header-file="lexer.h"

/* the int yywrap(void) is used internally by the lexer for the case
 *  where you want to parse multiple files in sequence with the same
 * parser state. Usually, you'd supply your own implementation that
 * would set up the next input stream and let the lexer know whether
 * to keep going. In our case, we disable it; this is effectively
 * the same as a dummy implementation like #define yywrap() 0.
 */
%option noyywrap

/* these define a few literals to use later on */
LPAR  "("
RPAR  ")"
PLUS  "+"
SEMI  ";"
COMMA ","

/* and these define some regular expressions we'll use. We could
 * also use these inline down below. */
HEX   0[Xx][0-9A-Fa-f]+
IDENT [A-Za-z_][A-Za-z0-9_]*
COM   "#"[^\n\r]*
WS    [ \r\n\t]*

/* In the below code, the TOKEN_blah types and the yylval
 * structure are used; these are defined in parser.y */

%%

{WS}        { /* skip whitspace */ }
{COM}       { /* also skip comments */ }
{HEX}		{
	          sscanf(yytext, "%x", &yylval.num);
			  return TOKEN_NUM;
            }
{IDENT}     {
	          /* It's important that we copy the string here,
               * because the `yytext` pointer will get reused
               * as the lexer continues. */
	          yylval.ident = copy_str(yytext);
			  return TOKEN_IDENT;
            }

{LPAR}      { return TOKEN_LPAR; }
{RPAR}      { return TOKEN_RPAR; }
{PLUS}      { return TOKEN_PLUS; }
{SEMI}      { return TOKEN_SEMI; }
{COMMA}     { return TOKEN_COMMA; }

%%

/* In the event of some kind of error, this will get called. */
int
yyerror(const char* msg)
{
    fprintf(stderr, "lexer error: %s\n", msg);
    return 0;
}
