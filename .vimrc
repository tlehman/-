syntax on

set mouse=a
set tabstop=4
set number
set hlsearch
set incsearch

" Cursor line highlighting
set cursorline
autocmd WinEnter * setlocal cursorline


" Docker/Dapper 
autocmd BufNewFile,BufRead *.dapper set syntax=dockerfile

"highlight CursorLine cterm=none ctermbg=darkgray
colors elflord

