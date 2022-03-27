syntax on

set mouse=a
set tabstop=4
set number

" Cursor line highlighting
set cursorline
hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine guibg=#303000 ctermbg=234

" Programming Language Support
"source /Users/tobi/.vim/godoc.vim
"autocmd BufNewFile,BufRead *.go map ,d :Godoc<CR>

" Packages
"  NERDTree 
"    % vim -u NONE -c "helptags ~/.vim/pack/vendor/start/nerdtree/doc" -c q


