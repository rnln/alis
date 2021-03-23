set pastetoggle=<F3>
" mapping from Q and W to q and w
command! -bang -range=% -complete=file -nargs=* W <line1>,<line2>write<bang> <args>
command! -bang Q quit<bang>


" lighten
function! LightenView()
  set relativenumber!
endfunction

function! LightenLoad()
  set lazyredraw!
  " syntax sync minlines=64

  if &bufhidden == "unload"
    setlocal bufhidden=
  else
    setlocal bufhidden=unload
  endif
endfunction

noremap <M-l> :call LightenView()<CR>
noremap <M-f> :call LightenLoad()<CR>

noremap <M-z> :set wrap!<CR>
