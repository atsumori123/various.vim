let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:loaded_various')
	finish
endif
let g:loaded_various = 1

noremap <silent> <Plug>(various-buffers) :<C-U>call buffer#Buffers()
noremap <silent> <Plug>(various-next-buffer) :<C-U>call buffer#NextPrevBuffer("bnext")
noremap <silent> <Plug>(various-prev-buffer) :<C-U>call buffer#NextPrevBuffer("bprev")
noremap <silent> <Plug>(various-close) :<C-U>call buffer#Close()
noremap <silent> <Plug>(various-marks) :<C-U>call mark#Marks()
noremap <silent> <Plug>(various-preview) :<C-U>call preview#Preview()
noremap <silent> <Plug>(various-quickfix) :<C-U>call preview#Quickfix()
noremap <silent> <Plug>(various-display-in-center) :<C-U>call etc#DisplayInCenter()

command! -nargs=0 -range Replace call etc#Replace(<range>)
command! -nargs=0 -range Tips call tips#Tips(<range>, <line1>, <line2>)

let &cpoptions = s:save_cpo
unlet s:save_cpo
