set nocompatible

let mapleader=","

" For when you forget to use sudo to edit a file.
cmap w!! w !sudo tee % >/dev/null

" Open/close the quickfix window.
nmap <leader>co :copen<CR><c-j>
nmap <leader>cc :cclose<CR>

""" General settings.
syntax on  " syntax highlighing

" Line numbering.
set number  " Display line numbers
set numberwidth=1  " using only 1 column (and 1 space) while possible

" Toggle line numbers.
nmap <C-N><C-N> :set invnumber <CR>

set background=dark  " We are using dark background in vim
set title  " show title in console title bar
set wildmenu  " Menu completion in command mode on <Tab>
set wildmode=full  " <Tab> cycles between all matching choices.

" Ignore these files when completing
set wildignore+=*.o,*.obj,.git,*.pyc

" Show a line at column 80. (Vim 7.3+)
 if exists("&colorcolumn")
    set colorcolumn=80
endif

""" Moving around/editing.

" Elite crosshairs.
set cursorline
set cursorcolumn

set scrolloff=200  " Keep context centered.
set ruler  " show the cursor position all the time.
set nostartofline  " Avoid moving cursor to BOL when jumping around.
set virtualedit=block  " Let cursor move past the last char in <C-v> mode.
set backspace=2  " Allow backspacing over autoindent, EOL, and BOL.
set showmatch  " Briefly jump to a paren once it's balanced.
set matchtime=2  " (for only .2 seconds).
set linebreak  " Don't wrap textin the middle of a word.
set autoindent  " Always set autoindenting on
set tabstop=2  " <tab> inserts 2 spaces.
set shiftwidth=2  " An indent level is 2 spaces wide.
set softtabstop=2  " <BS> over an autoindent deletes both spaces.
set expandtab  " Use spaces, not tabs, for autoindent/tab key.
set shiftround  " Rounds indent to a multiple of shiftwidth.
set matchpairs+=<:>  " Show matching <> (html mainly) as well.

""" Reading/Writing
set noautowrite  " Never write a file unless I request it.
set noautowriteall  " NEVER.
set noautoread  " Don't automatically re-read changed files.
set modeline  " Allow vim options to be embedded in files;
set modelines=5  " They must be within the first or last 5 lines.

""" Messages, info, and status.
set ls=2  " Always show status line.
set vb t_vb=  " Disable all bells. No ringing or flashing.
set confirm  " Y-N-C prompt if closing with unsaved changes.
set showcmd  " Show incomplete normal mode commands as I type.
set report=0  " : commands always print changed line count.
set shortmess+=a  " Use [+]/[RO]/[w] for modified/readonly/written.
set ruler  " Show some info, even without statuslines.
set laststatus=2  " Always show statusline, even if only 1 window.

" Displays tabs with :set list & displays when a line runs off-screen
set listchars=tab:>-,eol:$,trail:-,precedes:<,extends:>
nmap <C-L><C-L> :set invlist<CR>

""" Searching and patterns.
set ignorecase  " Default to using case insensitive searches,
set smartcase  " ... unless uppercase letters are used in the regex.
set hlsearch  " Highlight searches by default.
set incsearch  " Incrementally search while typing a /regex.

""" Display.
colorscheme eater

" Highlight extra whitespace at the end of lines.
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+\%#\@<!$/

""" File types.
au BufEnter,BufRead,BufNewFile *.py so ~/.vim/py.vim
au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/yaml.vim
au BufRead *.js set makeprg=jslint\ %

""" Local configuration.
if filereadable(expand("~/.vimrc-local"))
    source ~/.vimrc-local
endif

au BufRead,BufNewFile *.py source ~/.vim/py.vim

filetype plugin indent on
