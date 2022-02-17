set termguicolors
set background=dark

let s:BACKGROUND     = { 'gui': '#121212', 'cterm': '0' }
let s:GRAY_0         = { 'gui': '#1c1c1c', 'cterm': 234 }
let s:GRAY_1         = { 'gui': '#262626', 'cterm': 235 }
let s:GRAY_2         = { 'gui': '#3a3a3a', 'cterm': 237 }
let s:GRAY_3         = { 'gui': '#4e4e4e', 'cterm': 239 }
let s:GRAY_4         = { 'gui': '#626262', 'cterm': 241 }
let s:GRAY_5         = { 'gui': '#767676', 'cterm': 243 }
let s:GRAY_6         = { 'gui': '#8a8a8a', 'cterm': 245 }
let s:GRAY_7         = { 'gui': '#9e9e9e', 'cterm': 247 }
let s:GRAY_8         = { 'gui': '#b2b2b2', 'cterm': 249 }
let s:GRAY_9         = { 'gui': '#c6c6c6', 'cterm': 251 }
let s:GRAY_10        = { 'gui': '#dadada', 'cterm': 253 }
let s:GRAY_11        = { 'gui': '#eeeeee', 'cterm': 255 }
let s:WHITE          = { 'gui': '#c0c0c0', 'cterm': 7 }
let s:WHITE_BRIGHT   = { 'gui': '#ffffff', 'cterm': 15 }

let s:RED_DARK_1     = { 'gui': '#5f0000', 'cterm': 52 }
let s:RED_DARK_2     = { 'gui': '#870000', 'cterm': 88 }
let s:RED            = { 'gui': '#ff0000', 'cterm': 1 }
let s:RED_BRIGHT     = { 'gui': '#ff693a', 'cterm': 9 }

let s:GREEN_DARK_1   = { 'gui': '#005f00', 'cterm': 22 }
let s:GREEN_DARK_2   = { 'gui': '#008700', 'cterm': 28 }
let s:GREEN          = { 'gui': '#00c946', 'cterm': 2 }
let s:GREEN_BRIGHT   = { 'gui': '#00ff81', 'cterm': 10 }

let s:YELLOW_DARK_1  = { 'gui': '#5f5f00', 'cterm': 58 }
let s:YELLOW_DARK_2  = { 'gui': '#878700', 'cterm': 100 }
let s:YELLOW         = { 'gui': '#92ab00', 'cterm': 3 }
let s:YELLOW_BRIGHT  = { 'gui': '#d5e800', 'cterm': 11 }

let s:BLUE_DARK_1    = { 'gui': '#00005f', 'cterm': 17 }
let s:BLUE_DARK_2    = { 'gui': '#000087', 'cterm': 18 }
let s:BLUE           = { 'gui': '#009cff', 'cterm': 4 }
let s:BLUE_BRIGHT    = { 'gui': '#00d8ff', 'cterm': 12 }

let s:MAGENTA_DARK_1 = { 'gui': '#5f005f', 'cterm': 53 }
let s:MAGENTA_DARK_2 = { 'gui': '#870087', 'cterm': 90 }
let s:MAGENTA        = { 'gui': '#ff00f2', 'cterm': 5 }
let s:MAGENTA_BRIGHT = { 'gui': '#ff00ff', 'cterm': 13 }

let s:CYAN_DARK_1    = { 'gui': '#005f5f', 'cterm': 23 }
let s:CYAN_DARK_2    = { 'gui': '#008787', 'cterm': 30 }
let s:CYAN           = { 'gui': '#00caff', 'cterm': 6 }
let s:CYAN_BRIGHT    = { 'gui': '#00ffff', 'cterm': 14 }


function! Highlight(group_name, bg, fg, attr)
  let l:bg   = type(a:bg)   == 4  ? 'guibg=' . a:bg.gui   . ' ctermbg=' . a:bg.cterm   :
                  \ a:bg    != '' ? 'guibg=' . a:bg       . ' ctermbg=' . a:bg         : ''
  let l:fg   = type(a:fg)   == 4  ? 'guifg=' . a:fg.gui   . ' ctermfg=' . a:fg.cterm   :
                  \ a:fg    != '' ? 'guifg=' . a:fg       . ' ctermfg=' . a:fg         : ''
  let l:attr = type(a:attr) == 4  ? 'gui='   . a:attr.gui . ' cterm='   . a:attr.cterm :
                  \ a:attr  != '' ? 'gui='   . a:attr     . ' cterm='   . a:attr       : ''
  execute 'highlight ' . a:group_name . ' ' . l:bg . ' ' . l:fg . ' ' . l:attr
endfunction


" cursor highlight
call Highlight( 'CursorLine'  , s:BACKGROUND     , ''               , 'NONE' )
" line number
call Highlight( 'LineNr'      , ''               , s:GRAY_5         , '' )
call Highlight( 'CursorLineNr', ''               , s:GRAY_5         , 'NONE' )
" end of buffer
call Highlight( 'EndOfBuffer' , ''               , s:BACKGROUND     , '' )
" popup menu
call Highlight( 'Pmenu'       , s:GRAY_2         , s:WHITE          , '' )
call Highlight( 'PmenuSel'    , s:GRAY_3         , s:WHITE_BRIGHT   , '' )
call Highlight( 'PmenuSbar'   , s:GRAY_2         , ''               , '' )
call Highlight( 'PmenuThumb'  , s:GRAY_3         , ''               , '' )
" buffer separators
call Highlight( 'VertSplit'   , s:GRAY_1         , s:GRAY_1         , 'NONE' )
call Highlight( 'VertSplit'   , s:BACKGROUND     , s:GRAY_1         , 'NONE' )
" syntax
call Highlight( 'Comment'     , ''               , s:GRAY_5         , 'italic' )
call Highlight( 'String'      , ''               , s:YELLOW_BRIGHT  , '' )
call Highlight( 'Identifier'  , ''               , s:BLUE           , 'bold' )
call Highlight( 'Boolean'     , ''               , s:BLUE_BRIGHT    , '' )
call Highlight( 'Number'      , ''               , s:CYAN_BRIGHT    , '' )
call Highlight( 'Statement'   , ''               , s:CYAN_BRIGHT    , 'bold' )
call Highlight( 'Todo'        , s:YELLOW_DARK_1  , s:YELLOW_BRIGHT  , 'italic' )
call Highlight( 'Folded'      , ''               , s:GRAY_5         , '' )
call Highlight( 'FoldColumn'  , ''               , s:GRAY_5         , '' )
call Highlight( 'MatchParen'  , s:GRAY_2         , ''               , '' )
" unprintable characters and 'listchars' whitespaces
call Highlight( 'SpecialKey'  , s:MAGENTA_BRIGHT , s:BACKGROUND     , 'NONE' )
call Highlight( 'Whitespace'  , ''               , s:GRAY_2         , '' )

" selection in visual mode"
call Highlight( 'Visual'      , s:BLUE_DARK_2    , ''               , '' )

" search
call Highlight( 'Search'      , s:MAGENTA_DARK_2 , ''               , 'NONE' )
call Highlight( 'IncSeacrh'   , s:YELLOW_DARK_2  , ''               , 'NONE' )


" vim-airline theme
function! GenerateAirlineColorMap(palette)
  return airline#themes#generate_color_map(a:palette, a:palette, a:palette)
endfunction

call Highlight( 'StatusLine'  , ''               , s:GRAY_1         , '' )
call Highlight( 'StatusLineNC', ''               , s:GRAY_1         , '' )

let g:airline#themes#dark#palette = {}
let g:airline#themes#dark#palette.tabline = {
  \  'airline_tabsel'                                                 : [ s:WHITE_BRIGHT.gui , s:GRAY_3.gui         , s:WHITE_BRIGHT.cterm , s:GRAY_3.cterm ],
  \  'airline_tab'                                                    : [ s:WHITE.gui        , s:GRAY_2.gui         , s:WHITE.cterm        , s:GRAY_2.cterm ],
  \  'airline_tabfill'                                                : [ s:WHITE.gui        , s:GRAY_1.gui         , s:WHITE.cterm        , s:GRAY_1.cterm ],
  \  'airline_tabtype'                                                : [ s:WHITE.gui        , s:GRAY_1.gui         , s:WHITE.cterm        , s:GRAY_1.cterm ],
  \  'airline_tabhid'                                                 : [ s:WHITE.gui        , s:GRAY_1.gui         , s:WHITE.cterm        , s:GRAY_1.cterm ],
  \  'airline_tabmod'                                                 : [ s:WHITE_BRIGHT.gui , s:GRAY_3.gui         , s:WHITE_BRIGHT.cterm , s:GRAY_3.cterm         , 'bold' ],
  \  'airline_tabmod_unsel'                                           : [ s:WHITE.gui        , s:GRAY_2.gui         , s:WHITE.cterm        , s:GRAY_2.cterm         , 'bold' ] }
let g:airline#themes#dark#palette.normal      = GenerateAirlineColorMap([ s:WHITE_BRIGHT.gui , s:GRAY_1.gui         , s:WHITE_BRIGHT.cterm , s:GRAY_1.cterm         , '' ])
let g:airline#themes#dark#palette.insert      = GenerateAirlineColorMap([ s:WHITE_BRIGHT.gui , s:GREEN_DARK_1.gui   , s:WHITE_BRIGHT.cterm , s:GREEN_DARK_1.cterm   , '' ])
let g:airline#themes#dark#palette.replace     = GenerateAirlineColorMap([ s:WHITE_BRIGHT.gui , s:RED_DARK_1.gui     , s:WHITE_BRIGHT.cterm , s:RED_DARK_1.cterm     , '' ])
let g:airline#themes#dark#palette.visual      = GenerateAirlineColorMap([ s:WHITE_BRIGHT.gui , s:BLUE_DARK_1.gui    , s:WHITE_BRIGHT.cterm , s:BLUE_DARK_1.cterm    , '' ])
let g:airline#themes#dark#palette.commandline = GenerateAirlineColorMap([ s:WHITE_BRIGHT.gui , s:MAGENTA_DARK_1.gui , s:WHITE_BRIGHT.cterm , s:MAGENTA_DARK_1.cterm , '' ])
let g:airline#themes#dark#palette.inactive    = GenerateAirlineColorMap([ s:GRAY_5.gui       , s:GRAY_1.gui         , s:GRAY_5.cterm       , s:GRAY_1.cterm         , '' ])
let g:airline#themes#dark#palette.accents     =                { 'red': [ s:RED_BRIGHT.gui   , ''                   , s:RED_BRIGHT.cterm   , '' ] }
let g:airline#themes#dark#palette.terminal    = g:airline#themes#dark#palette.insert


set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10
