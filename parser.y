/* If we want to use other functions, we have to put the relevant
 * header includes here. */
%{
	#include "helpers.h"
	#include <stdio.h>
	int yylex(void);
	void yyerror(const char*);
%}

/* These declare our output file names. */
%output "parser.c"
%defines "parser.h"

/* This union defines the possible return types of both lexer and
 * parser rules. We'll refer to these later on by the field name */
%union {
	int         num;
	char       *ident;
	struct arg *arg;
}

/* These define the tokens that we use in the lexer.
 * All of these have no meaningful return value. */
%token TOKEN_LPAR
%token TOKEN_RPAR
%token TOKEN_PLUS
%token TOKEN_SEMI
%token TOKEN_COMMA

/* These are ALSO used in the lexer, but in addition to
 * being tokens, they also have return values associated
 * with them. We name those according to the names we used
 * above, in the %union declaration. So, the TOKEN_NUM
 * rule will return a value of the same type as num, which
 * (in this case) is an int. */
%token <num>   TOKEN_NUM
%token <ident> TOKEN_IDENT

/* These are non-terminals in our grammar, by which I mean, parser
 * rules down below. Each of these also has a meaningful return type,
 * which is declared in the same way. */
%type <arg> arg;
%type <ident> rname;

%%

/* A program is defined recursively as either empty or an instruction
 * followed by another program. In this case, there's nothing meaningful
 * for us to do or return as an action, so we omit any action after the
 * rules. */
prog
  :
  | instr prog
  ;

/* An instruction, in our toy assembly, is always an identifier (which
 * is the instruction name) and possibly arguments. The numbers in the
 * variable here refer to the position of the argument we want, and
 * will refer to either the result of the rule (in the case of other
 * parser rules) or the contents of yylval (in the case of lexer
 * tokens.) */
instr
  : TOKEN_IDENT TOKEN_SEMI
    { mk_instruction($1, NULL); }
  | TOKEN_IDENT arg TOKEN_SEMI
    { mk_instruction($1, $2); }
  | TOKEN_IDENT arg TOKEN_COMMA arg TOKEN_SEMI
    { /* The contents of these blocks can be arbitrary C code; in this
       * case, we'll parse all the recursive bits, but then stitch
       * together the returned `arg` values before creating the new
       * instruction. */
	  struct arg *first_arg = $2;
	  first_arg->next = $4;
	  mk_instruction($1, $2);
    }
  ;

/* An argument in this case has multiple choices: it can be a register
 * plus an offset, in which case it must be surrounded by parens, or
 * it can be just a register, in which case the parens are optional.
 *
 * The 'return value' of a rule is always stored in the $$ variable.
 * Here, I also name the results of terminals and non-terminals, instead
 * of addressing them by number.
 */
arg
  : TOKEN_LPAR rname[tok] TOKEN_PLUS TOKEN_NUM[num] TOKEN_RPAR
    { $$ = mk_argument($tok, $num); }
  | TOKEN_LPAR TOKEN_NUM[num] TOKEN_PLUS rname[tok] TOKEN_RPAR
    { $$ = mk_argument($tok, $num); }
  | TOKEN_LPAR rname[tok] TOKEN_RPAR
    { $$ = mk_argument($tok, 0); }
  | rname[tok]
    { $$ = mk_argument($tok, 0); }
  ;

/* In this case, I'm being a little bit obtuse: I should encode the
 * register name rule as a regular expression (i.e. all registers could
 * be identified by the regex r.*x) but instead I'm doing a check in the
 * body of the rule and returning out of the generated parser. */
rname
  : TOKEN_IDENT
    { if (!is_register($1)) {
		fprintf(stderr, "bad register name: %s\n", $1);
		return;
	  }
	  $$ = $1;
	}
  ;

%%
