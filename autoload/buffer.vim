let s:save_cpo = &cpoptions
set cpoptions&vim

"-------------------------------------------------------
" warning
"-------------------------------------------------------
function! s:warning(msg) abort
	echohl WarningMsg | echomsg a:msg | echohl None
endfunction

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
		call s:warning("Cannot delete because number of buffers is 1")
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
				call s:warning('qflist: top of stack')
			else
				silent cnewer
				echo "\r"
				setlocal modifiable
			endif
		else
			if qfid <= 1
				call s:warning('qflist: bottom of stack')
			else
				silent colder
				echo "\r"
				setlocal modifiable
			endif
		endif

	else
		if !buflisted(bufnr('%'))
			return
		endif

		if exists('g:stline_buffers')
			let ofs = index(g:stline_buffers, bufnr("%"))
			let ofs += (a:direction == 'bnext' ? 1 : -1)
			let ofs = (ofs < 0) ? len(g:stline_buffers) - 1 : ofs % len(g:stline_buffers)
			execute 'buffer '.g:stline_buffers[ofs]

		else
			" get bufnr list
			let ls = split(execute(":ls"), "\n")
			call map(ls, 'str2nr(split(v:val, " ")[0])')

			" remove special buffer
			let ls = filter(ls, 'getbufvar(v:val, "&buftype") == ""')

			" count of list
			let len = len(ls)

			" get index of current buffer
			let ofs = index(ls, bufnr("%"))

			" if ofs == -1, next(prev) buffer is ls[0]
			if ofs < 0 | let ofs = (a:direction == 'bnext' ? len - 1 : 1) | endif

			if len > 1
				" get next(prev) bufnr
				let ofs += (a:direction == 'bnext' ? 1 : -1)
				let ofs = (ofs + len) % len

				execute 'buffer '.ls[ofs]
			endif
		endif
	endif
endfunction

"---------------------------------------------------
" buffer#Close
"---------------------------------------------------
function! buffer#Close() abort
	let bt = &buftype
	let nr = bufnr('%')

	if &modified
		call s:warning('Discard the changes ? [y/n] ')
		let key = nr2char(getchar())
		redraw
		echo ""
		if key !=# 'y'
			return
		endif
	endif

	if bt ==# 'quickfix'
		" カレントバッファがQuickfixの場合
		cclose
		return
	endif

	if (bt ==# 'nofile' || bt !=# '') && !buflisted(nr)
		" 特別なバッファタイプ(バッファ名はあるがファイルとして存在しない)の場合
		bdelete
		return
	endif

	" カレントバッファ以外で、ファイルとして存在、または新規ファイルのバッファリストを作成
	let buflist = map(getbufinfo({'buflisted': 1}), 'v:val.bufnr')
	call filter(buflist, 'v:val != nr && (filereadable(bufname(v:val)) || empty(getbufvar(v:val, "&buftype")))')

	if len(buflist)
		execute 'buffer' . buflist[0]
	else
		new
	endif

	execute 'bdelete! ' . nr
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
