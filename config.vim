
if has('macunix')
    " markdown chrome browse
    " autocmd BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} map <Leader>md :! $chrome_app"/Contents/MacOS/Google Chrome" "%:p"<CR>
    autocmd BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} map <Leader>md :! open -a "Google Chrome" "%:p"<CR>
endif


" vim-inspector
let g:vimspector_enable_mappings = 'HUMAN'
" F9: add breakpoint
" <leader>F9: add conditional breakpoint
" <leader>F8: run to Cursor

" for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval

nnoremap <Leader>dd :call vimspector#Launch() \| set mouse=a<CR>
" end vim-inspector
nnoremap <Leader>de :call vimspector#Reset()  \| set mouse-=a<CR>

" toggle break point
nnoremap <Leader>dt :call vimspector#ToggleBreakpoint()<CR>
" clean all break points
nnoremap <Leader>dT :call vimspector#ClearBreakpoints()<CR>

