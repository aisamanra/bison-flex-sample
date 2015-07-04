#include "helpers.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_IDENT_SIZE 32

int
is_register(const char *in)
{
	int last = 0;
	while (in[last+1]) last++;
	return in[0] == 'r' && in[last] == 'x';
}

/* all of these, in this case, will malloc and create
 * structures; we can do whatever we want here. Depending
 * on what you're parsing, you might even want to start
 * executing as you're parsing. */
char*
copy_str(const char *in)
{
	size_t len = strnlen(in, MAX_IDENT_SIZE);
	char* buf = malloc(len + 1);
	strncpy(buf, in, len);
	buf[len] = '\0';
	return buf;
}

struct arg*
mk_argument(char *reg, int off)
{
	struct arg* a = malloc(sizeof(struct arg));
	a->reg  = reg;
	a->off  = off;
	a->next = NULL;
	return a;
}

struct instr*
mk_instruction(char *name, struct arg *args)
{
	struct instr* i = malloc(sizeof(struct instr));
	i->name = name;
	i->args = args;
	i->prev = global_prev;
	global_prev = i;
	return i;
}

void
print_arg(const struct arg *arg)
{
	if (arg->off)
		printf("(%s+0x%x)", arg->reg, arg->off);
	else
		printf("%s", arg->reg);
}

/* We'll use this at the end to pretty-print our
 * 'assembly program'
 */
void
print_instrs(const struct instr *instr)
{
	if (!instr) return;

	print_instrs(instr->prev);

	if (!instr->args) {
		printf("%s;\n", instr->name);
	} else if (instr->args->next) {
		printf("%s ", instr->name);
		print_arg(instr->args);
		printf(", ");
		print_arg(instr->args->next);
		printf(";\n");
	} else  {
		printf("%s ", instr->name);
		print_arg(instr->args);
		printf(";\n");
	}
}

/* and for cleaning up at the end */
void
free_args(struct arg *args)
{
	if (!args) return;
	free_args(args->next);
	free(args->reg);
	free(args);
}
void
free_instrs(struct instr *instr)
{
	if (!instr) return;
	free_instrs(instr->prev);
	free_args(instr->args);
	free(instr->name);
	free(instr);
}
