syntax on

set mouse=a
set tabstop=4
set number
set hlsearch
set incsearch
set autoindent

" Cursor line highlighting
set cursorline
autocmd WinEnter * setlocal cursorline


" Docker/Dapper 
autocmd BufNewFile,BufRead *.dapper set syntax=dockerfile


" Cursor line
highlight CursorLine cterm=none ctermbg=234

function LightMode()
	highlight CursorLine cterm=none ctermbg=254
endfunction

