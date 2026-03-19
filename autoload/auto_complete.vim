"===============================================================
" Reference plugins
"
" Vimの手動補完を自動でトリガーすれば自動補完になります
" https://zenn.dev/kawarimidoll/articles/c14c8bc0d7d73d
"
" Vim scriptで関数のdebounceとthrottle
" https://zenn.dev/vim_jp/articles/9b1db46217a27d
"
"===============================================================
let s:save_cpo = &cpoptions
set cpoptions&vim

" 補完動作の設定
" auto_cmp_startが何度も呼ばれないようにmenuoneでpumを表示
" 自動で選択までされないようnoselect
set completeopt=menuone,noselect

" 補完の最低文字数
" 1にしたら流石に候補が多すぎてちょっと動作が重かったので3くらいが妥当かと思われる
let s:MINIMUM_COMPLETE_LENGTH = 3

" 補完関数
function! s:auto_cmp_start() abort
	" 既に補完ウィンドウが表示されている場合は何もせず終了
	if pumvisible()
		return
	endif

	" カーソルより左側の範囲を取得し、[:keyword:]を使って補完に使えない記号などを除去
	let prev_str = (slice(getline('.'), 0, charcol('.')-1) .. v:char) ->substitute('.*[^[:keyword:]]', '', '')

	" カーソル直前の部分（補完元文字列）が最低文字数に満たなければ終了
	if strchars(prev_str) < s:MINIMUM_COMPLETE_LENGTH
		return
	endif

	" <c-n>を実行して補完スタート
	call feedkeys("\<c-n>", 'ni')
endfunction

function! auto_complete#auto_cmp_close() abort
	" ファイルパス補完の場合は区切り文字が違うので無視
	if complete_info(['mode']).mode == "files"
		return
	endif

	" カーソル直前の部分（補完元文字列）の文字列を調査
	let prev_str = slice(getline('.'), 0, charcol('.')-1) ->substitute('.*[^[:keyword:]]', '', '')

	" 最低文字数に満たなければ`<c-x><c-z>`で補完を終了する
	if strchars(prev_str) < s:MINIMUM_COMPLETE_LENGTH
		call feedkeys("\<c-x>\<c-z>", 'ni')
	endif
endfunction

let s:debounce_timers = {}
function auto_complete#Debounce(fn, wait, args = []) abort
	let timer_name = string(a:fn)
	call get(s:debounce_timers, timer_name, 0)->timer_stop()
	let s:debounce_timers[timer_name] = timer_start(a:wait, {-> call(a:fn, a:args) })
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

