" toggle line wrapping
noremap <silent> <M-z> :set wrap!<CR>
inoremap <silent> <M-z> <C-o>:set wrap!<CR>

" range format with Prettier
vmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)
