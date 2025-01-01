let s:save_cpo = &cpoptions
set cpoptions&vim

"---------------------------------------------------------------
" etc#display_in_center
"---------------------------------------------------------------
function! etc#DisplayInCenter() abort
	let dic = getwininfo(win_getid())
	let pos = getcurpos()
	let x = pos[4]
	let center_x = dic[0].width / 2 - 4

	if x <= center_x
		return
	else
		let zl = x - center_x
		execute "normal! 0"
		execute "normal! ".zl."zl"
		call setpos(".", pos)
		execute "normal! zz"
	endif
endfunction

"---------------------------------------------------------------
" etc#replace
"---------------------------------------------------------------
function! etc#Replace(range) abort
	if a:range
		let temp = @@
		silent normal gvy
		let target_pattern = @@
		let @@ = temp
	else
		let target_pattern = expand('<cword>')
	endif

	let target_pattern = input('# Target pattern: ', target_pattern)
	if empty(target_pattern) | return | endif

	let replace_pattern = input('# Replace pattern: ', target_pattern)
	if empty(replace_pattern) | return | endif

	let opt = input("# Replace option [w(Word Search)] [r(RegExp)] [Start line Number]: ")
	if empty(opt) | let opt = "1" | endif

	" Regular expression
	let regexp = stridx(opt, 'r') >= 0 ? "\\v" : ""

	" Replace start line
	let start = substitute(opt, "\[^0-9\]", "", "g")
	if empty(start) | let start = 1 | endif

	if stridx(opt, 'w') >= 0
    	exe start.",$s/".regexp."\\<".target_pattern."\\>/".replace_pattern."/gc"
	else
    	exe start.",$s/".regexp.target_pattern."/".replace_pattern."/gc"
	endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
