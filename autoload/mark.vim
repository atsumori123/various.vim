let s:save_cpo = &cpoptions
set cpoptions&vim

"-------------------------------------------------------
" get_mark_text()
"-------------------------------------------------------
function! s:get_mark_text(key) abort
	let temp = split(execute(":marks ".a:key), "\n")
	if len(temp) <= 1
		return ""
	endif
	let text = split(temp[1])

	" get text only (remove key, line, culum)
	call remove(text, 0, 2)

	return join(text)
endfunction

"-------------------------------------------------------
" get_unused_key()
"-------------------------------------------------------
function! s:get_unused_key() abort
	let markrement_char = [
	\	  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
	\	  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
	\ ]

	let unused_key = 'A'
	for key in markrement_char
		if stridx(s:used_keys, key) == -1
			let unused_key = key
			break
		endif
	endfor

	return unused_key
endfunction

"-------------------------------------------------------
" selected_mark
"-------------------------------------------------------
function! s:selected_mark(pos) abort
	let winnr = winnr()
	let key = split(getline(a:pos))
	execute 'wincmd p'
	execute "'".key[0]
	silent! winnr.close
endfunction

"-------------------------------------------------------
" delete_mark
"-------------------------------------------------------
function! s:delete_mark(pos) abort
	let key = split(getline(a:pos))
	if len(key) == 0 | return | endif
	setlocal modifiable
	normal! dd
	normal! 0
	setlocal nomodifiable
	execute ":delmarks ".key[0]
	let s:used_keys = substitute(s:used_keys, key[0], "", "gc")
endfunction

"-------------------------------------------------------
" add_mark
"-------------------------------------------------------
function! s:add_mark() abort
	silent! close
	execute ":mark ".s:get_unused_key()
	call mark#Marks()
endfunction

"-------------------------------------------------------
" s:custom_settings
"-------------------------------------------------------
function! s:custom_settings() abort
	" set hightlight
	syn match bufferKey '^  .[A-Z|[0-9] '
	syn match bufferText '\*.*$'
	hi! def link bufferKey Function
	hi! def link bufferText Label

	" set keymap
	nnoremap <buffer> <silent> <CR> :call <SID>selected_mark(line('.'))<CR>
	nnoremap <buffer> <silent> dd :call <SID>delete_mark(line('.'))<CR>
	nnoremap <buffer> <silent> a :call <SID>add_mark()<CR>
	nnoremap <buffer> <silent> q :close<CR>
endfunction

"-------------------------------------------------------
" mark#Marks
"-------------------------------------------------------
function! mark#Marks() abort
	" make marks menu
	let list = []
	let s:used_keys = ""
	let all_marks = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	let cbnr = bufnr('%')
	for i in range(len(all_marks))
		let key = all_marks[i]
	    let [ bnr, line ] = getpos("'".key)[0:1]
		if line
			let temp = printf("   %s %s %6d    %s",
				\ key,
				\ bnr == cbnr ? "*" : " ",
				\ line,
				\ s:get_mark_text(key))
			call add(list, temp)
			let s:used_keys .= key
		endif
	endfor

	" open marks window
	call common#open_window(list, 8, "-marks-")

	" set custom settings
	call s:custom_settings()
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
