"===============================================================
" Reference plugins
"
" https://zenn.dev/taro0079/articles/6094881dcadf4d
"
" iaalm/terminal-drawer.vim
" https://github.com/iaalm/terminal-drawer.vim
"
"===============================================================
let s:save_cpo = &cpoptions
set cpoptions&vim

let s:terminal_height = -1

"---------------------------------------------------------------
" s:get_terminal_height
"---------------------------------------------------------------
function! s:get_terminal_height() abort
	let dic = getwininfo(win_getid())
	let s:terminal_height = dic[0].height
endfunction

"---------------------------------------------------------------
" s:set_terminal_height
"---------------------------------------------------------------
function! s:set_terminal_height() abort
	if s:terminal_height > 0
		execute "resize ".s:terminal_height
	endif
endfunction

"---------------------------------------------------------------
" terminal#ToggleTerminal
"---------------------------------------------------------------
function! terminal#ToggleTerminal() abort
	let termNums = filter(map(getbufinfo(), 'v:val.bufnr'), 'getbufvar(v:val, "&buftype") is# "terminal"')
	let termWins = filter(getwininfo(), 'v:val.terminal')

	if &buftype == 'terminal'
		" If the current buffer is a terminal, close terminal window
		execute "buffer #"
		call s:get_terminal_height()
		execute "close"

	elseif len(termWins) > 0
		" Terminal buffer exists but is not current
		execute 'tabn'.termWins[0].tabnr
		execute termWins[0].winnr.'wincmd w'
		"
	elseif len(termNums) > 0
		" If the terminal buffer exists but is not visible, show terminal buffer
		execute 'split'
		execute "buffer " . termNums[0]
		execute "normal i"
		call s:set_terminal_height()

	else
		" If no terminal buffer exists, create a new one and save its buffer number
		execute 'lcd '.expand("%:h")
		terminal
		call s:set_terminal_height()
	endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

