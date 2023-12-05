#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define ERR_ENONE 0x00000000
#define ERR_FATAL 0xffffffff
#define MAX_NUM_ARGVS 0x40
#define MAX_TOKEN_CHARS 0x2000
#define Z_MAGIC 0x1d1d

typedef enum {
	FALSE,
	TRUE
} qboolean;

typedef unsigned char byte;

typedef struct sizebuf_s {
	byte *data;
	qboolean allowoverflow;
	qboolean overflowed;
	int maxsize;
	int cursize;
	int readcount;
} sizebuf_t;

typedef struct zhead_s {
	struct zhead_s *prev;
	struct zhead_s *next;
	short magic;
	short tag;
	int size;
} zhead_t;

typedef void (*xcommand_t) (void);

typedef struct cmd_function_s {
	struct cmd_function_s *next;
	const char *name;
	xcommand_t function;
} cmd_function_t;

int com_argc;
const char *com_argv[MAX_NUM_ARGVS];

sizebuf_t cmd_text;
byte cmd_text_buf[MAX_TOKEN_CHARS];

qboolean cmd_wait = FALSE;

zhead_t z_chain;
int z_count = 0;
int z_bytes = 0;

cmd_function_t *cmd_functions = NULL;

#if defined(__GCC__)
__attribute__ ((access (read_only, 2)))
#endif
int Qcommon_Init(int const argc, const char **argv);
int Cbuf_Init(void);
int Cmd_Init(void);
int Q_Free(void);

#if defined(__GCC__)
__attribute__ ((access (read_only, 2)))
#endif
int main (int const argc, const char **argv)
{
	int rc;
	rc = Qcommon_Init(argc, argv);
	if (rc != ERR_ENONE) {
		return rc;
	}

	rc = Cbuf_Init();
	if (rc != ERR_ENONE) {
		return rc;
	}

	rc = Cmd_Init();
	if (rc != ERR_ENONE) {
		Q_Free();
		return rc;
	}

	printf("%s\n", com_argv[0]);

	rc = Q_Free();
	if (rc != ERR_ENONE) {
		return rc;
	}

	return 0;
}

void Com_Base (FILE *stream, int code, const char *fmt, va_list args)
{
	vfprintf(stream, fmt, args);
}

#if (__GCC__ > 12)
void Com_Printf (const char* fmt, ...)
{
	va_list args;
	va_start(args);
	Com_Base(stdout, 0, fmt, args);
	va_end(args);
}
#else
void Com_Printf (const char* fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	Com_Base(stdout, 0, fmt, args);
	va_end(args);
}
#endif

#if (__GCC__ > 12)
void Com_Error (int const code, const char* fmt, ...)
{
	va_list args;
	va_start(args);
	Com_Base(stderr, code, fmt, args);
	va_end(args);
}
#else
void Com_Error (int const code, const char* fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	Com_Base(stderr, code, fmt, args);
	va_end(args);
}
#endif

#if defined(__GCC__)
__attribute__ ((access (read_only, 2)))
#endif
int COM_InitArgv (int const argc, const char **argv)
{
	com_argc = argc;
	if (com_argc > MAX_NUM_ARGVS) {
		Com_Error(ERR_FATAL, "argc > MAX_NUM_ARGVS");
		return ERR_FATAL;
	}

	for (int i = 0; i != argc; ++i) {
		if (argv[i] == NULL || (strlen(argv[i]) + 1) > MAX_TOKEN_CHARS) {
			com_argv[i] = NULL;
		} else {
			com_argv[i] = argv[i];
		}
	}

	return ERR_ENONE;
}

int Z_Init (void)
{
	z_chain.prev = NULL;
	z_chain.next = NULL;
	z_chain.magic = ~Z_MAGIC;
	z_chain.tag = 0xffff;
	z_chain.size = sizeof(zhead_t);
	return ERR_ENONE;
}

#if defined(__GCC__)
__attribute__ ((access (read_only, 2)))
#endif
int Qcommon_Init (int const argc, const char **argv)
{
	int rc = 0;
	rc = Z_Init();
	if (rc != ERR_ENONE) {
		return rc;
	}

	rc = COM_InitArgv(argc, argv);
	if (rc != ERR_ENONE) {
		return rc;
	}

	return rc;
}

#if defined(__GCC__)
__attribute__ ((access (write_only, 1), access (read_only, 2)))
#endif
void SZ_Init (sizebuf_t *buf, byte *data, int length)
{
	memset(buf, 0, sizeof(sizebuf_t));
	// most fields were set by memset but being explicit does not hurt
	buf->data = data;
	buf->allowoverflow = FALSE;
	buf->overflowed = FALSE;
	buf->maxsize = length;
	buf->cursize = 0;
	buf->readcount = 0;
}

int Cbuf_Init (void)
{
	SZ_Init(&cmd_text, cmd_text_buf, sizeof(cmd_text_buf));
	return ERR_ENONE;
}

void *Z_Free (void *ptr)
{
	if (!ptr) {
		return NULL;
	}

	zhead_t *z = ((zhead_t *) ptr) - 1;

	if (z->magic != Z_MAGIC) {
		Com_Error(ERR_FATAL, "Z_Free: bad magic\n");
		return ptr;
	}

	if (z->prev) {
		z->prev->next = z->next;
	}

	if (z->next) {
		z->next->prev = z->prev;
	}

	--z_count;
	z_bytes -= z->size;

	free(z);
	z = NULL;
	return z;
}

int Z_TagFree (short const tag)
{
	zhead_t *z;
	zhead_t *next;
	qboolean sw = FALSE;
	for (z = z_chain.next; z; z = next) {
		next = z->next;
		if (tag == z->tag) {
			void *ptr = ((void *) (z + 1));
			ptr = Z_Free(ptr);
			if (ptr) {
				Com_Error(ERR_FATAL, "Z_TagFree\n");
				sw = TRUE;
			}
		}
	}

	int rc = (sw)? ERR_FATAL : ERR_ENONE;
	return rc;
}

void *Z_TagMalloc (int const sizeObj, short const tag)
{
	int const size = sizeObj + sizeof(zhead_t);
	zhead_t *z = malloc(size);
	if (!z) {
		Com_Error(ERR_FATAL, "Z_TagMalloc: failed to allocate %d bytes\n", size);
		return NULL;
	}

	memset(z, 0, size);
	z->magic = Z_MAGIC;
	z->tag = tag;
	z->size = size;

	z->next = z_chain.next;
	z->prev = &z_chain;

	if (z_chain.next) {
		z_chain.next->prev = z;
	}

	z_chain.next = z;

	++z_count;
	z_bytes += size;

	return ((void *) (z + 1));
}

void *Z_Malloc (int size)
{
	short const tag = 0;
	return Z_TagMalloc(size, tag);
}

void Cmd_List_f (void)
{
	int count = 0;
	cmd_function_t *cmd = NULL;
	for (cmd = cmd_functions; cmd; cmd = cmd->next, ++count) {
		Com_Printf("%s\n", cmd->name);
	}

	Com_Printf("%d commands\n", count);
}

void Cmd_Wait_f (void)
{
	cmd_wait = TRUE;
}

#if defined(__GCC__)
__attribute__ ((access (read_only, 1)))
#endif
int Cmd_AddCommand (const char* name, xcommand_t function)
{
	cmd_function_t *cmd = NULL;
	for (cmd = cmd_functions; cmd; cmd = cmd->next) {
		if (!strcmp(name, cmd->name)) {
			Com_Printf("Cmd_AddCommand: %s already defined\n", name);
			return ERR_ENONE;
		}
	}

	void *ptr = Z_Malloc(sizeof(cmd_function_t));
	if (!ptr) {
		return ERR_FATAL;
	}

	cmd = ((cmd_function_t*) ptr);
	cmd->name = name;
	cmd->function = function;
	cmd->next = cmd_functions;
	cmd_functions = cmd;

	return ERR_ENONE;
}

int Cmd_Init (void)
{
	int rc;
	rc = Cmd_AddCommand("cmdlist", Cmd_List_f);
	if (rc != ERR_ENONE) {
		return rc;
	}

	rc = Cmd_AddCommand("wait", Cmd_Wait_f);
	if (rc != ERR_ENONE) {
		return rc;
	}

	return rc;
}

int Q_Free (void)
{
	return Z_TagFree(0);
}
