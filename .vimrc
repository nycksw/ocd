" ~eater/.vimrc
" http://eater.org/

syntax on

if filereadable(expand("~/.vimrc-local"))
  source ~/.vimrc-local
endif

colorscheme elflord

" Elite crosshairs.
set cursorline
set cursorcolumn

set expandtab
set incsearch
set noautoindent
set nocompatible
set nohlsearch
set ruler
set shortmess+=r
set smartcase
set softtabstop=2
set sw=2
set tabstop=2
set vb t_vb=
set wildmode=list:longest,full

" Line numbering.
set invnumber
nmap <C-N><C-N> :set invnumber <CR>

" Toggle autoindention for X-window clipboard pasting.
set pastetoggle=<F12>

au BufEnter,BufRead,BufNewFile *.py so ~/.vim/py.vim
au BufEnter,BufRead,BufNewFile BUILD set filetype=python
au BufEnter,BufRead,BufNewFile BUILD so ~/.vim/py.vim
