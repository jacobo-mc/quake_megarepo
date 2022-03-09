#include <stdio.h>
#include "gmqcc.h"

#define GMQCC_IS_STDOUT(X) ((X) == stdout)
#define GMQCC_IS_STDERR(X) ((X) == stderr)
#define GMQCC_IS_DEFINE(X) (GMQCC_IS_STDERR(X) || GMQCC_IS_STDOUT(X))

struct con_t {
    FILE *handle_err;
    FILE *handle_out;
    int color_err;
    int color_out;
};

static con_t console;

/*
 * Enables color on output if supported.
 * NOTE: The support for checking colors is nullptr.  On windows this will
 * always work, on *nix it depends if the term has colors.
 *
 * NOTE: This prevents colored output to piped stdout/err via isatty
 * checks.
 */
static void con_enablecolor(void) {
    console.color_err = util_isatty(console.handle_err);
    console.color_out = util_isatty(console.handle_out);
}

/*
 * Does a write to the handle with the format string and list of
 * arguments.  This colorizes for windows as well via translate
 * step.
 */
static int con_write(FILE *handle, const char *fmt, va_list va) {
    return vfprintf(handle, fmt, va);
}

/**********************************************************************
 * EXPOSED INTERFACE BEGINS
 *********************************************************************/

void con_close() {
    if (!GMQCC_IS_DEFINE(console.handle_err))
        fclose(console.handle_err);
    if (!GMQCC_IS_DEFINE(console.handle_out))
        fclose(console.handle_out);
}

void con_color(int state) {
    if (state)
        con_enablecolor();
    else {
        console.color_err = 0;
        console.color_out = 0;
    }
}

void con_init() {
    console.handle_err = stderr;
    console.handle_out = stdout;
    con_enablecolor();
}

void con_reset() {
    con_close();
    con_init();
}

/*
 * Defaultizer because stdio.h shouldn't be used anywhere except here
 * and inside file.c To prevent mis-match of wrapper-interfaces.
 */
FILE *con_default_out() {
    return console.handle_out = stdout;
}

FILE *con_default_err() {
    return console.handle_err = stderr;
}

int con_verr(const char *fmt, va_list va) {
    return con_write(console.handle_err, fmt, va);
}
int con_vout(const char *fmt, va_list va) {
    return con_write(console.handle_out, fmt, va);
}

/*
 * Standard stdout/stderr printf functions used generally where they need
 * to be used.
 */
int con_err(const char *fmt, ...) {
    va_list va;
    int ln = 0;
    va_start(va, fmt);
    con_verr(fmt, va);
    va_end(va);
    return ln;
}
int con_out(const char *fmt, ...) {
    va_list va;
    int ln = 0;
    va_start(va, fmt);
    con_vout(fmt, va);
    va_end (va);
    return ln;
}

/*
 * Utility console message writes for lexer contexts.  These will allow
 * for reporting of file:line based on lexer context, These are used
 * heavily in the parser/ir/ast.
 */
static void con_vprintmsg_c(int level, const char *name, size_t line, size_t column, const char *msgtype, const char *msg, va_list ap, const char *condname) {
    /* color selection table */
    static int sel[] = {
        CON_WHITE,
        CON_CYAN,
        CON_RED
    };

    int  err                             = !!(level == LVL_ERROR);
    int  color                           = (err) ? console.color_err : console.color_out;
    int (*print) (const char *, ...)     = (err) ? &con_err          : &con_out;
    int (*vprint)(const char *, va_list) = (err) ? &con_verr         : &con_vout;

    if (color)
        print("\033[0;%dm%s:%d:%d: \033[0;%dm%s: \033[0m", CON_CYAN, name, (int)line, (int)column, sel[level], msgtype);
    else
        print("%s:%d:%d: %s: ", name, (int)line, (int)column, msgtype);

    vprint(msg, ap);
    if (condname)
        print(" [%s]\n", condname);
    else
        print("\n");
}

void con_vprintmsg(int level, const char *name, size_t line, size_t column, const char *msgtype, const char *msg, va_list ap) {
    con_vprintmsg_c(level, name, line, column, msgtype, msg, ap, nullptr);
}

void con_printmsg(int level, const char *name, size_t line, size_t column, const char *msgtype, const char *msg, ...) {
    va_list   va;
    va_start(va, msg);
    con_vprintmsg(level, name, line, column, msgtype, msg, va);
    va_end  (va);
}

void con_cvprintmsg(lex_ctx_t ctx, int lvl, const char *msgtype, const char *msg, va_list ap) {
    con_vprintmsg(lvl, ctx.file, ctx.line, ctx.column, msgtype, msg, ap);
}

void con_cprintmsg(lex_ctx_t ctx, int lvl, const char *msgtype, const char *msg, ...) {
    va_list   va;
    va_start(va, msg);
    con_cvprintmsg(ctx, lvl, msgtype, msg, va);
    va_end  (va);
}

/* General error interface: TODO seperate as part of the compiler front-end */
size_t compile_errors   = 0;
size_t compile_warnings = 0;
size_t compile_Werrors  = 0;
static lex_ctx_t first_werror;

void compile_show_werrors()
{
    con_cprintmsg(first_werror, LVL_ERROR, "first warning", "was here");
}

void vcompile_error(lex_ctx_t ctx, const char *msg, va_list ap)
{
    ++compile_errors;
    con_cvprintmsg(ctx, LVL_ERROR, "error", msg, ap);
}

void compile_error_(lex_ctx_t ctx, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);
    vcompile_error(ctx, msg, ap);
    va_end(ap);
}

bool GMQCC_WARN vcompile_warning(lex_ctx_t ctx, int warntype, const char *fmt, va_list ap)
{
    const char *msgtype = "warning";
    int         lvl     = LVL_WARNING;
    char        warn_name[1024];

    if (!OPTS_WARN(warntype))
        return false;

    warn_name[0] = '-';
    warn_name[1] = 'W';
    (void)util_strtononcmd(opts_warn_list[warntype].name, warn_name+2, sizeof(warn_name)-2);

    ++compile_warnings;
    if (OPTS_WERROR(warntype)) {
        if (!compile_Werrors)
            first_werror = ctx;
        ++compile_Werrors;
        msgtype = "Werror";
        if (OPTS_FLAG(BAIL_ON_WERROR)) {
            msgtype = "error";
            ++compile_errors;
        }
        lvl = LVL_ERROR;
    }

    con_vprintmsg_c(lvl, ctx.file, ctx.line, ctx.column, msgtype, fmt, ap, warn_name);

    return OPTS_WERROR(warntype) && OPTS_FLAG(BAIL_ON_WERROR);
}

bool GMQCC_WARN compile_warning_(lex_ctx_t ctx, int warntype, const char *fmt, ...)
{
    bool r;
    va_list ap;
    va_start(ap, fmt);
    r = vcompile_warning(ctx, warntype, fmt, ap);
    va_end(ap);
    return r;
}
