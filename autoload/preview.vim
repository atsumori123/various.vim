let s:save_cpo = &cpoptions
set cpoptions&vim

let s:preview = {}
let s:preview["line"] = ""
let s:preview["bufnr"] = []

"-------------------------------------------------------
" Get bufnr
"-------------------------------------------------------
function! s:get_all_bufnr() abort
	let list = split(execute(":ls"), "\n")
	let bnr_list = []
	for bnr in list
		call add(bnr_list, split(bnr, ' ')[0])
	endfor
	return bnr_list
endfunction

"-------------------------------------------------------
" Open the preview buffer
"-------------------------------------------------------
function! s:open_preview(path, lnum) abort
	if exists('g:lock_oldfiles') | let g:lock_oldfiles = 1 | endif
	execute "pedit +".a:lnum.' '.a:path
	if exists('g:lock_oldfiles') | let g:lock_oldfiles = 0 | endif
endfunction

"---------------------------------------------------------------
" Open preview
"---------------------------------------------------------------
function! preview#Preview() abort
	" if it is not quickfix window, then return
	if &buftype != 'quickfix' | return | endif

	" close preview
	call preview#Close()

	" get current line number of quickfix window
	let line = getline('.')

	" if same line, then preview end
	if line == s:preview["line"]
		let s:preview["line"] = ""
		return
	endif
	let s:preview["line"] = line

	" open preview window
	let s:preview["bufnr"] = s:get_all_bufnr()
	let w = split(line, '|')
	call s:open_preview(w[0], split(w[1], ' ')[0])
endfunction

"---------------------------------------------------------------
" preview#Close
"---------------------------------------------------------------
function! preview#Close() abort
	" jump to preview window
	silent! wincmd P

	" if it is not preview window ?
	if &previewwindow == 0 | return | endif

	" get buffer number of preview
	let bnr = bufnr('%')

	" back to quickfix window
	wincmd p

	" close preview window
	silent! pclose

	" if there is no preview buffer in normal buffer, then delete buffer
	if match(s:preview["bufnr"], bnr) < 0
		silent! execute 'bdelete! '.bnr
	endif
endfunction

"---------------------------------------------------------------
" preview#Quickfix
"---------------------------------------------------------------
function! preview#Quickfix() abort
	let nr = winnr("$")
	copen

	if nr == winnr("$")
		wincmd p
		cclose
		call preview#Close()
	else
		set modifiable
	endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
