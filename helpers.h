struct arg {
	char       *reg;
	int         off;
	struct arg *next;
};

struct instr {
	char         *name;
	struct arg   *args;
	struct instr *prev;
};

struct instr *global_prev;

int is_register(const char*);
char* copy_str(const char*);

struct arg* mk_argument(char*, int);
struct instr* mk_instruction(char*, struct arg*);

void print_instrs(const struct instr *);
void free_instrs(struct instr*);
