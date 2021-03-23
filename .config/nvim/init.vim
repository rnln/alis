exec "source " . $XDG_CONFIG_HOME . "/nvim/plugins.vim"


" text rendering
set linebreak " avoid wrapping a line in the middle of a word
set scrolloff=1 " the number of screen lines to keep above and below the cursor
set sidescrolloff=5 " the number of screen columns to keep to the left and right of the cursor
set nowrap " disable line wrapping


" interface
set relativenumber " show line number on the current line and relative numbers on all other lines
set cursorline " highlight the line currently under cursor
set numberwidth=1

set visualbell " flash the screen instead of beeping on errors
set mouse=a " enable mouse for scrolling and resizing
set title " set the window’s title, reflecting the file currently being edited

set noshowmode
set shortmess=aoOstTI


" folding
set foldmethod=indent " fold based on indention levels
" set nofoldenable " disable folding by default
set fillchars=fold:\ 
" " save and load view to keep folds
autocmd BufWinLeave * silent! mkview
autocmd BufWinEnter * silent! loadview

" miscellaneous options
set wildmode=list:longest,full
" set gdefault " use 'g' flag in :s/-sequences
set viewoptions+=unix,slash
" filetype plugin indent on
set backup
set undofile " persistent undo
set tabstop=4 shiftwidth=0
set ignorecase smartcase incsearch
set clipboard=unnamedplus " always use the clipboard for all operations (instead of interactng with '+' and/or '*' registers explicitly)
set formatoptions=cqj,trn1
set hidden " hide files in the background instead of closing them
set wildignore+=.pyc,.swp " ignore files matching these patterns when opening files based on a glob pattern

set fileformats=unix,dos,mac
set fileencodings=ucs-bom,utf-8,default,latin1,cp1251,koi8-r,ucs-2,cp866
set matchpairs=(:),{:},[:],<:>

set list listchars=tab:→\ ,trail:·,extends:…,precedes:…,nbsp:·


exec "source " . $XDG_CONFIG_HOME . "/nvim/keybindings.vim"
exec "source " . $XDG_CONFIG_HOME . "/nvim/colorscheme.vim"
