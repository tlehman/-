syntax on

set mouse=a
set tabstop=4
set number

" Cursor line highlighting
set cursorline
autocmd WinEnter * setlocal cursorline


" Docker/Dapper 
autocmd BufNewFile,BufRead *.dapper set syntax=dockerfile

highlight CursorLine guibg=#303000 cterm=none ctermbg=darkgray

