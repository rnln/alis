if empty(glob("$XDG_DATA_HOME/nvim/site/autoload/plug.vim"))
  silent !curl -fLo "$XDG_DATA_HOME/nvim/site/autoload/plug.vim" --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
endif
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif

call plug#begin("$XDG_DATA_HOME/nvim/site/plugged")
  " Plug 'tomasiser/vim-code-dark'
  Plug 'itchyny/lightline.vim'
  Plug 'vim-scripts/vim-auto-save'
  Plug 'chrisbra/Colorizer'
call plug#end()


" https://github.com/vim-scripts/vim-auto-save
" let g:auto_save = 1 " enable AutoSave
let g:auto_save_no_updatetime = 1 " do not change the 'updatetime' option
let g:auto_save_in_insert_mode = 0 " do not save while in insert mode
let g:auto_save_silent = 1 " do not display the auto-save notification

" https://github.com/chrisbra/Colorizer
let g:colorizer_auto_filetype='css,scss,html'
