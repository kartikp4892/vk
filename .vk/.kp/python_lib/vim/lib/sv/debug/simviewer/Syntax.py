#!/usr/bin/env python

import vim

def highlight ():
  vim.command('hi PassMsg               guifg=forestgreen gui=bold')
  vim.command('hi FailMsg               guifg=Red gui=bold')
  vim.command('hi ReportSeverity        guifg=violetred1 gui=bold')
  vim.command('hi ReportID              guifg=purple guibg=grey98')
  vim.command('hi link UpperString      String')
  vim.command('hi link NumberZero       SpecialComment')
  vim.command('hi link NumberNonZero    Number')
  vim.command('hi SimTime               guifg=Indianred3 gui=bold')

  vim.command('hi InstPath              guifg=forestgreen gui=bold')
  vim.command('hi FileName              guifg=dodgerblue3 ')
  vim.command('hi LineSeperator         guifg=#D80E48 gui=bold')


def syntax ():
  highlight()

  # Match
  vim.command('syn match   UpperString "\<[A-Z][A-Z0-9_]\+\>"')
  vim.command('''syn match   NumberZero "\\v(0x)?('[hdb]?)?0+>"''')
  vim.command('''syn match   NumberNonZero "\\v([0-9]*'h)[0-9a-fA-F]*[1-9a-fA-F]+[0-9a-fA-F]*>"''')
  vim.command('''syn match   NumberNonZero "\\v([0-9]*'b?)[0-1]*1+[0-1]*>"''')
  vim.command('''syn match   NumberNonZero "\\v([0-9]*'d?)?[0-9]*[1-9]+[0-9]*>"''')
  vim.command('''syn match   NumberNonZero "\\v<(0x)?[0-9a-fA-F]*[1-9a-fA-F]+[0-9a-fA-F]*>"''')
  vim.command('syn match   SimTime "@ [0-9]\+\ze:"')
  vim.command('syn match   InstPath "\\vuvm_test_top(\.[^ ]+)*"')
  vim.command('syn match   FileName "\\v[^ ]+\.(sv[hi]?|vhd.v)>"')
  vim.command('syn match   LineSeperator "\\v^#\s*-+\s*$"')

  # Region
  vim.command('syn region  ReportID start="\["  end="\]"')
  vim.command('syn region  UpperString start=+"+  end=+"+')

  # Keyword
  vim.command('syn keyword PassMsg  PASS')
  vim.command('syn keyword FailMsg  FAIL')
  vim.command('syn keyword ReportSeverity  UVM_INFO UVM_ERROR UVM_WARNING UVM_FATAL')




