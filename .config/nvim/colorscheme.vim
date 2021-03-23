syntax on
colorscheme elflord
set termguicolors
set background=dark
highlight Normal guibg=NONE


highlight Comment    guifg=DarkGrey gui=italic
" highlight Constant   guifg=DarkRed
" highlight Special    guifg=DarkGreen
" highlight Identifier guifg=Cyan gui=bold
" highlight Statement  guifg=Magenta
" highlight PreProc    guifg=Yellow
" highlight Type       guifg=Green
" highlight Underlined guifg=Blue gui=underline


" current line highlight
highlight CursorLine guibg=NONE

" line number
highlight LineNr guifg=DarkGrey
highlight! link CursorLineNr LineNr

highlight VertSplit gui=NONE guifg=DarkGrey guibg=bg " vertical split separator

" unprintable characters and 'listchars' whitespaces
highlight SpecialKey guifg=DarkGrey
highlight Whitespace guifg=DarkGrey

highlight Folded guifg=DarkGrey guibg=NONE
highlight FoldColumn guifg=DarkGrey guibg=NONE
