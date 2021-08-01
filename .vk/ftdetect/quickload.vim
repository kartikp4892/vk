" Vim global plugin for demonstrating quick loading
" Last Change:	2005 Feb 25
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" License:	This file is placed in the public domain.

if !exists("s:did_load")
	command -nargs=* BNRead  call BufNetRead(<f-args>)
	map <F12> :call BufNetWrite('something')<CR>

	let s:did_load = 1
	exe 'au FuncUndefined BufNet* source ' . expand('<sfile>')
	finish
endif

function BufNetRead(...)
	echo 'BufNetRead(' . string(a:000) . ')'
	" read functionality here
endfunction

function BufNetWrite(...)
	echo 'BufNetWrite(' . string(a:000) . ')'
	" write functionality here
endfunction
