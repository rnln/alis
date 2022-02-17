" YouCompleteMe
if empty(glob(stdpath('data') . '/site/autoload/plug.vim'))
  silent execute '!curl -fLo ' . stdpath('data') . '/site/autoload/plug.vim --create-dirs '
      \. 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugInstall --sync | source $MYVIMRC | endif

" YCM Plug do function
function! LoadYCM(info)
  if a:info.status == 'installed' || a:info.force
    !./install.py --all
    !rm -rf "$XDG_DATA_HOME/nvim/site/plugged/YouCompleteMe/third_party/ycmd/third_party/tern_runtime"
    YcmRestartServer
  endif
endfunction

call plug#begin(stdpath('data') . '/site/plugged')
  Plug 'vim-airline/vim-airline'
  Plug 'tpope/vim-fugitive'
  Plug 'ycm-core/YouCompleteMe', { 'do': function('LoadYCM') }
  Plug 'preservim/nerdtree'
call plug#end()

let g:ycm_confirm_extra_conf = 0
let g:ycm_global_ycm_extra_conf = "$XDG_CONFIG_HOME/nvim/.ycm_extra_conf.py"


" NerdTree
nnoremap <M-v> :NERDTreeFind<CR>
nnoremap <M-g> :NERDTreeToggle<CR>
let NERDTreeShowHidden = 1
let NERDTreeIgnore = [
    \ '\.DS_Store$',
    \ '\.egg_info$',
    \ '\.git$',
    \ '\.hg$',
    \ '\.pyc$',
    \ '\.pyo$',
    \ '\.ropeproject$',
    \ '\.sass-cache$',
    \ '\.stversions$',
    \ '\.svn$',
    \ '\.svn$',
    \ '\.svn$',
    \ '\.swp$',
    \ '\\.pyo$',
    \ '^__pycache__$',
    \ ]


" vim-airline
set noshowmode
let g:airline_skip_empty_sections = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_min_count = 2
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#left_alt_sep = ''

let g:airline_symbols = {}
let g:airline_symbols.branch = ''
let g:airline_symbols.linenr = ' ☰ '
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.colnr = ':'
let g:airline_symbols.dirty = '[+]'
" let g:airline_symbols.linenr = ' :'
" let g:airline_symbols.modified = '+'
" let g:airline_symbols.whitespace = '☲'
" let g:airline_symbols.ellipsis = '...'
" let g:airline_symbols.paste = 'PASTE'
" let g:airline_symbols.maxlinenr = '☰ '
" let g:airline_symbols.readonly = ''
" let g:airline_symbols.spell = 'SPELL'
" let g:airline_symbols.space = ' '
" let g:airline_symbols.dirty = '⚡'
" let g:airline_symbols.colnr = ' :'
" let g:airline_symbols.keymap = 'Keymap:'
" let g:airline_symbols.crypt = '🔒'
" let g:airline_symbols.notexists = 'Ɇ'

" let g:airline_section_z = airline#section#create(['windowswap', '%3p%% ', 'linenr', ':%3v'])
