" ~eater/.vim/py.vim
" http://eater.org/

"set ai smarttab
set invnumber

" Folding
"setl foldmethod=indent
"setl foldnestmax=3  " class, method, if
"setl foldignore=#   " ignore comments
map F zA
cab fo %foldo!
cab fc %foldc!
"%foldo!


" Debugger set-trace
ino ,st import pdb;pdb.set_trace()
