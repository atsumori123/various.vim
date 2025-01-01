let s:save_cpo = &cpoptions
set cpoptions&vim

"-------------------------------------------------------
" s:draw_buffer
"-------------------------------------------------------
function! s:draw_buffer(list) abort
	setlocal modifiable

	" Delete the contents of the buffer to the black-hole register
	silent! %delete _

	silent! 0put = a:list

	" Delete the empty line at the end of the buffer
	silent! $delete _

	" Move the cursor to the beginning of the file
	call setpos(".", [0, 1, 1, 0])

	setlocal nomodifiable
endfunction

"-------------------------------------------------------
" common#open_window
"-------------------------------------------------------
function! common#open_window(list, height, buffname) abort
	" If the window is already open, jump to it
	let winnum = bufwinnr(a:buffname)
	if winnum != -1
		if winnr() != winnum
			" If not already in the window, jump to it
			exe winnum.'wincmd w'
			return
		endif
	else
		" Open a new window at the bottom
		exe 'silent! botright '.a:height.' split '.a:buffname
	endif

	setlocal modifiable
	silent! %delete _

	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal noswapfile
	setlocal nobuflisted
	setlocal nowrap
	setlocal nonumber
	setlocal foldcolumn=0
	setlocal filetype=buffer
	setlocal winfixheight winfixwidth

	" Setup the cpoptions properly for the maps to work
	let old_cpoptions = &cpoptions
	set cpoptions&vim

	" Restore the previous cpoptions settings
	let &cpoptions = old_cpoptions

	" draw buffer
	call s:draw_buffer(a:list)
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
