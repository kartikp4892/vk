"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

function! cpp#sqlite3#sqlite3_open()
  let str = '/* FIXME_REMOVE: '. 
            \ '#include <stdlib.h> for visibility of stderr' .
            \ '*/'

  let str .= '/* FIXME_KEEP_OR_REMOVE: ' . 
          \ printf('sqlite3 *%s;', s:GetTemplete('a', 'db')) .
          \ '*/'

  let str .= printf('rc = sqlite3_open(maa%s, &%s);', s:GetTemplete('a', 'file'), s:GetTemplete('a', 'db')) .
          \ s:_set_indent(0) . 'if( rc ) {' .
          \ s:_set_indent(&shiftwidth) . 'fprintf(stderr, "Can not open database: %s\n", sqlite3_errmsg(db));' .
          \ s:_set_indent(0) . 'exit(1);' .
          \ s:_set_indent(-&shiftwidth) . '}`aa'

   return str
endfunction

function! cpp#sqlite3#sqlite3_close()
  let str = printf('sqlite3_close(%s);', s:GetTemplete('a', '/db'))

   return str
endfunction

function! cpp#sqlite3#sqlite3_exec()
  let str = '/* FIXME_KEEP_OR_REMOVE: ' . 
          \ 'char *err_msg = 0;' .
          \ 'int rc;' .
          \ 'const char *sqlstmt;' .
          \ '// TODO: data - var decl of data pointer;' .
          \ '*/'

  let str .= 'sqlstmt = "maa";' .
          \ s:_set_indent(0) . printf('rc = sqlite3_exec(%s, sqlstmt, %s, %s, &err_msg);', s:GetTemplete('a', '/db'), s:GetTemplete('a', '/callback'), s:GetTemplete('a', '/(void*)data')) .
          \ s:_set_indent(0) . 'if( rc != SQLITE_OK ) {' . 
          \ s:_set_indent(&shiftwidth) . 'fprintf(stderr, "SQL error: %s\n", err_msg);' .
          \ s:_set_indent(0) . 'sqlite3_free(err_msg);' .
          \ s:_set_indent(-&shiftwidth) . '}`aa'

   return str
endfunction

function! cpp#sqlite3#sqlite3_exec_callback()

  let str = 'static int callback('
  let str .= s:_set_indent(&shiftwidth) . 'void *data,      /* Data provided in the 4th argument of sqlite3_exec() */'
  let str .= s:_set_indent(0) . 'int  argc,       /* The number of columns in row */'
  let str .= s:_set_indent(0) . 'char **argv,     /* An array of strings representing fields in the row */'
  let str .= s:_set_indent(0) . 'char **colnames  /* An array of strings representing column names */'
  let str .= s:_set_indent(-&shiftwidth) . ')'
  let str .= s:_set_indent(0) . '{'
  let str .= s:_set_indent(&shiftwidth) . 'int i;'
  let str .= s:_set_indent(0) . ''
  let str .= s:_set_indent(0) . 'for(i = 0; i<argc; i++){'
  let str .= s:_set_indent(&shiftwidth) . 'printf("%s = %s\n", colnames[i], argv[i] ? argv[i] : "NULL");'
  let str .= s:_set_indent(-&shiftwidth) . '}'
  let str .= s:_set_indent(0) . ''
  let str .= s:_set_indent(0) . 'printf("\n");'
  let str .= s:_set_indent(0) . 'return 0;'
  let str .= s:_set_indent(-&shiftwidth) . '}'

  return str
endfunction

function! cpp#sqlite3#sqlite3_prepare_select()
  let str = '//##############################################################################'
  let str .= '/* FIXME_KEEP_OR_REMOVE: ' . 
          \ 'sqlite3_stmt *stmt = NULL;' .
          \ 'char *szSQL = NULL;' .
          \ 'int rc;' .
          \ '*/'

  let str .= s:_set_indent(0) . '// TODO: Sql statement'
  let str .= s:_set_indent(0) . printf('asprintf(&szSQL, "SELECT %s FROM %s ");', s:GetTemplete('a', 'col1...'), s:GetTemplete('a', 'table'))

  let str .= s:_set_indent(0) . printf('rc = sqlite3_prepare_v2(%s,              /* Database handle */', s:GetTemplete('a', '/db'))
  let str .= s:_set_indent(21) . 'szSQL,           /* SQL statement, UTF-8 encoded */'
  let str .= s:_set_indent(0) . 'strlen(szSQL),   /* Maximum length of zSql in bytes. */'
  let str .= s:_set_indent(0) . '&stmt,           /* OUT: Statement handle */'
  let str .= s:_set_indent(0) . 'NULL             /* OUT: Pointer to unused portion of zSql */'
  let str .= s:_set_indent(0) . ');'

  let str .= s:_set_indent(-21) . 'if( rc != SQLITE_OK ) {'
  let str .= s:_set_indent(&shiftwidth) . 'fprintf(stderr, "Failed to prepare query = %s!!!\n", szSQL);'
  let str .= s:_set_indent(0) . 'exit(1);'
  let str .= s:_set_indent(-&shiftwidth) . '}'

  let str .= s:_set_indent(0) . '/* TODO: update below logic */'
  let str .= s:_set_indent(0) . '// If the fifth argument is the special value SQLITE_STATIC,' 
  let str .= s:_set_indent(0) . '// then SQLite assumes that the information is in static, unmanaged' 
  let str .= s:_set_indent(0) . '// space and does not need to be freed. If the fifth argument has the'
  let str .= s:_set_indent(0) . '// value SQLITE_TRANSIENT, then SQLite makes its own private copy of' 
  let str .= s:_set_indent(0) . '// the data immediately, before the sqlite3_bind_*() routine returns.'

  let str .= s:_set_indent(0) . 'sqlite3_bind_text(stmt, 1, bind1val, strlen(bind1val), SQLITE_STATIC );'
  let str .= s:_set_indent(0) . 'sqlite3_bind_text(stmt, 2, bind2val, strlen(bind2val), SQLITE_STATIC );'
  let str .= s:_set_indent(0) . 'sqlite3_bind_int(stmt, 3, bind3val);'

  let str .= s:_set_indent(0) . 'while( true ) {'
  let str .= s:_set_indent(&shiftwidth)  . 'rc = sqlite3_step(stmt);'
  let str .= s:_set_indent(0)  . 'if ( rc != SQLITE_ROW ) {'
  let str .= s:_set_indent(&shiftwidth)  . 'break;'
  let str .= s:_set_indent(-&shiftwidth)  . '}'
  let str .= s:_set_indent(0)  . '/* TODO: Updated below logic */'
  let str .= s:_set_indent(0)            . 'col1text = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0));'
  let str .= s:_set_indent(0)            . 'col2text = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1));'
  let str .= s:_set_indent(0)            . 'col3int = sqlite3_column_int(stmt, 2);'
  let str .= s:_set_indent(-&shiftwidth) . '}'
  let str .= s:_set_indent(0)            . 'if (rc != SQLITE_DONE) {'
  let str .= s:_set_indent(&shiftwidth)  . 'fprintf(stderr, "Failed while stepping query %s!!!\n", szSQL);'
  let str .= s:_set_indent(0)  . 'exit(1);'
  let str .= s:_set_indent(-&shiftwidth) . '}'
  let str .= s:_set_indent(0)            . 'sqlite3_finalize(stmt);'
  let str .= s:_set_indent(0)            . 'free(szSQL);'

  let str .= '//##############################################################################'

  return str
endfunction


function! cpp#sqlite3#sqlite3_prepare_insert()
  let str = '//##############################################################################'
  let str .= '/* FIXME_KEEP_OR_REMOVE: ' . 
          \ 'sqlite3_stmt *stmt = NULL;' .
          \ 'char *szSQL = NULL;' .
          \ 'int rc;' .
          \ '*/'

  let str .= s:_set_indent(0) . '// TODO: Sql statement'
  let str .= s:_set_indent(0) . printf('asprintf(&szSQL, "INSERT INTO %s (%s) values (?)");', s:GetTemplete('a', 'table'), s:GetTemplete('a', 'col1...'))

  let str .= s:_set_indent(0) . printf('rc = sqlite3_prepare_v2(%s,              /* Database handle */', s:GetTemplete('a', '/db'))
  let str .= s:_set_indent(21) . 'szSQL,           /* SQL statement, UTF-8 encoded */'
  let str .= s:_set_indent(0) . 'strlen(szSQL),   /* Maximum length of zSql in bytes. */'
  let str .= s:_set_indent(0) . '&stmt,           /* OUT: Statement handle */'
  let str .= s:_set_indent(0) . 'NULL             /* OUT: Pointer to unused portion of zSql */'
  let str .= s:_set_indent(0) . ');'

  let str .= s:_set_indent(-21) . 'if( rc != SQLITE_OK ) {'
  let str .= s:_set_indent(&shiftwidth) . 'fprintf(stderr, "Failed to prepare query = %0s!!!\n", szSQL);'
  let str .= s:_set_indent(0) . 'exit(1);'
  let str .= s:_set_indent(-&shiftwidth) . '}'

  let str .= s:_set_indent(0) . '/* TODO: update below logic */'
  let str .= s:_set_indent(0) . '// If the fifth argument is the special value SQLITE_STATIC,' 
  let str .= s:_set_indent(0) . '// then SQLite assumes that the information is in static, unmanaged' 
  let str .= s:_set_indent(0) . '// space and does not need to be freed. If the fifth argument has the'
  let str .= s:_set_indent(0) . '// value SQLITE_TRANSIENT, then SQLite makes its own private copy of' 
  let str .= s:_set_indent(0) . '// the data immediately, before the sqlite3_bind_*() routine returns.'

  let str .= s:_set_indent(0) . 'sqlite3_bind_text(stmt, 1, bind1val, strlen(bind1val), SQLITE_STATIC );'
  let str .= s:_set_indent(0) . 'sqlite3_bind_text(stmt, 2, bind2val, strlen(bind2val), SQLITE_STATIC );'
  let str .= s:_set_indent(0) . 'sqlite3_bind_int(stmt, 3, bind3val);'

  let str .= s:_set_indent(0) . 'if( sqlite3_step(stmt) != SQLITE_DONE ) {'
  let str .= s:_set_indent(&shiftwidth)  . 'fprintf(stderr, "Failed while stepping query %s!!!\n", szSQL);'
  let str .= s:_set_indent(0)  . 'exit(1);'
  let str .= s:_set_indent(-&shiftwidth) . '}'
  let str .= s:_set_indent(0)            . 'sqlite3_finalize(stmt);'
  let str .= s:_set_indent(0)            . 'free(szSQL);'

  let str .= '//##############################################################################'

  return str
endfunction




