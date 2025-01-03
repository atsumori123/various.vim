let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:loaded_various')
	finish
endif
let g:loaded_various = 1

nnoremap <silent> <Plug>(various-buffers) :<C-U>call buffer#Buffers()
nnoremap <silent> <Plug>(various-next-buffer) :<C-U>call buffer#NextPrevBuffer("bnext")
nnoremap <silent> <Plug>(various-prev-buffer) :<C-U>call buffer#NextPrevBuffer("bprev")
nnoremap <silent> <Plug>(various-close) :<C-U>call buffer#Close()
nnoremap <silent> <Plug>(various-marks) :<C-U>call mark#Marks()
nnoremap <silent> <Plug>(various-preview) :<C-U>call preview#Preview()
nnoremap <silent> <Plug>(various-quickfix) :<C-U>call preview#Quickfix()
nnoremap <silent> <Plug>(various-display-in-center) :<C-U>call etc#DisplayInCenter()
nnoremap <silent> <Plug>(various-toggle-terminal) :<C-U>call terminal#ToggleTerminal()
tnoremap <silent> <Plug>(various-toggle-terminal) :<C-U> <C-\><C-n>:call terminal#ToggleTerminal()

command! -nargs=0 -range Replace call etc#Replace(<range>)
command! -nargs=0 -range Tips call tips#Tips(<range>, <line1>, <line2>)

let &cpoptions = s:save_cpo
unlet s:save_cpo
