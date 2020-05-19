#include "Eval.h"
#include "Parser.h"
#include "Lexer.h"
#include <assert.h>

int yyparse(Value** expr, yyscan_t scanner);

Value* getAST(const char *code)
{
  Value* expr = NULL;
  yyscan_t scanner = 0;
  YY_BUFFER_STATE state = 0;
  if (yylex_init(&scanner)) return NULL;
  state = yy_scan_string(code, scanner);
  if (yyparse(&expr, scanner)) return NULL;
  yy_delete_buffer(state, scanner);
  yylex_destroy(scanner);
  return expr;
}

int main(int argc, char* argv[])
{
  char* code = NULL;
  if (argc == 2) {
    code = argv[1];
  } else {
    size_t len = 0;
    getline(&code, &len, stdin);
    assert(code != NULL);
  }
  Value* e = getAST(code);
  code = NULL;
  assert(e != NULL);
  e = eval(e);
  assert(e != NULL);
  printValue(stdout, e);
  return 0;
}