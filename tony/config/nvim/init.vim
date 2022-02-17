set linebreak " avoid wrapping a line in the middle of a word
set scrolloff=5 " the number of screen lines to keep above and below the cursor
set sidescrolloff=5 " the number of screen columns to keep to the left and right of the cursor
set nowrap " disable line wrapping
set relativenumber " show line number on the current line and relative numbers on all other lines
set cursorline " highlight the line currently under cursor
set mouse=a " enable mouse for scrolling and resizing
set title " set the window’s title, reflecting the file currently being edited
set shortmess=aoOstTI
set completeopt+=longest
set fillchars+=vert:│

exec 'source ' . stdpath('config') . '/plugins.vim'
exec 'source ' . stdpath('config') . '/keybindings.vim'
exec 'source ' . stdpath('config') . '/colorscheme.vim'
