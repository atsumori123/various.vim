let s:save_cpo = &cpoptions
set cpoptions&vim

"-------------------------------------------------------
" selected_buffer
"-------------------------------------------------------
function! s:selected_buffer(pos) abort
	let bnr = split(getline(a:pos))
	silent! close
	let winnum = bufwinnr(bnr[0] + 0)
	if winnum != -1
		execute winnum.'wincmd w'
	else
		execute 'wincmd p'
		execute 'buffer '.bnr[0]
	endif
endfunction

"-------------------------------------------------------
" delete_buffer
"-------------------------------------------------------
function! s:delete_buffer(pos) abort
	if line('$') <= 1
		echohl WarningMsg | echomsg "Cannot delete because number of buffers is 1" | echohl None
		return
	endif

	let bnr1 = split(getline(a:pos))[0]
	let bnr2 = split(getline(a:pos == 1 ? a:pos + 1 : a:pos - 1))[0]

	setlocal modifiable
	normal! dd
	normal! 0
	setlocal nomodifiable

	if !getbufinfo(str2nr(bnr1, 10))[0].hidden
		wincmd p
		execute "b".bnr2
		wincmd p
	endif
	execute 'bdelete! '.bnr1
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
	nnoremap <buffer> <silent> <CR> :call <SID>selected_buffer(line('.'))<CR>
	nnoremap <buffer> <silent> d :call <SID>delete_buffer(line('.'))<CR>
	nnoremap <buffer> <silent> q :close<CR>
endfunction

"-------------------------------------------------------
" buffer#buffers
"-------------------------------------------------------
function! buffer#Buffers() abort
	" get buffer list
	let ls = split(execute(":ls"), "\n")
	call map(ls, 'substitute(v:val, "\"", "", "g")')
	call map(ls, 'substitute(v:val," 行 .*$", "", "")')

	" make menu list
	let list = []
	for s in ls
		let temp = split(s)
		if len(temp) != 4 | call insert(temp, "", 2) | endif
		call add(list, printf("%4s %s %3s %s   %-16s  (%s)",
							\ temp[0],
							\ stridx(temp[1], 'a') >= 0 ? '*' : ' ',
							\ temp[1],
							\ temp[2],
							\ fnamemodify(temp[3], ":t"), temp[3]))
	endfor

	" open buffers window
	call common#open_window(list, 8, "-buffers-")

	" set custom settings
	call s:custom_settings()
endfunction

"---------------------------------------------------------------
" buffer#NextPrevBuffer
"---------------------------------------------------------------
function! buffer#NextPrevBuffer(direction) abort
	if &buftype == 'quickfix'
		let qfnum = getqflist({'nr':'$'}).nr
		let qfid = getqflist({'nr':0}).nr

		if a:direction == 'bnext'
			if qfid >= qfnum
				echohl WarningMsg | echomsg 'qflist: top of stack' | echohl None
			else
				silent cnewer
				echo "\r"
				setlocal modifiable
			endif
		else
			if qfid <= 1
				echohl WarningMsg | echomsg 'qflist: bottom of stack' | echohl None
			else
				silent colder
				echo "\r"
				setlocal modifiable
			endif
		endif

	else
		if empty(&buftype)
			execute a:direction
			if &buftype == 'quickfix'
				execute a:direction
			endif
		endif
	endif
endfunction

"---------------------------------------------------
" buffer#Close
"---------------------------------------------------
function! buffer#Close() abort
	let bnr = bufnr('%')

	" Check buffer modified
	if getbufinfo(bnr)[0].changed
		echohl WarningMsg | echomsg 'No changes saved. Please select operation. [w:Write, c:Cancel, d:Discard ] ? ' | echohl None
		let key = nr2char(getchar())
		if key == 'w'
			let filename = ''
			if bufname("%") == ""
				let filename = input('input filename ? ', getcwd().'\', 'file')
				if empty(filename) | return | endif
			endif
			silent! execute 'write '.filename

		elseif key == 'd'

		else
			return
		endif
	endif

	" list up buffers exclude special buffer
	let bufs = filter(range(1, bufnr('$')), '
			\ buflisted(v:val)
			\ && getbufvar(v:val, "&buftype") == ""
			\ && v:val != bnr
			\ ')

	if &buftype == 'quickfix'
		" current window is QuickFix
		cclose

	elseif &buftype != ''
		" current window is special buffer
		bdelete

	else
		" list up hidden buffers
		let hidden_bufs = filter(copy(bufs),'len(getbufinfo(v:val)[0].windows) == 0')

		if len(hidden_bufs)
			execute 'buffer'.hidden_bufs[0]
		endif

		if !len(bufs)
			cclose
		endif

		execute 'bdelete! '.bnr
	endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
