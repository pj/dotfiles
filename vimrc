set nocompatible              " be iMproved, required
filetype off                  " required

" Plugin manager
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" System plugins
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
Plugin 'flazz/vim-colorschemes'
" Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'bling/vim-airline'
" Plugin 'pthrasher/conqueterm-vim'
" Plugin 'tybenz/vimdeck'
Bundle 'edkolev/tmuxline.vim'
Plugin 'editorconfig/editorconfig-vim'

" File plugins
" Plugin 'Valloric/YouCompleteMe'
" Plugin 'scrooloose/syntastic'
" Plugin 'Lokaltog/vim-easymotion'
" Plugin 'xolox/vim-easytags'
" Plugin 'majutsushi/tagbar'
Bundle 'ntpeters/vim-better-whitespace'
Plugin 'tpope/vim-surround'  " Surround things.
" Plugin 'aperezdc/vim-template'
" Plugin 'SirVer/ultisnips'
" Plugin 'honza/vim-snippets'
Plugin 'godlygeek/tabular'
Plugin 'Raimondi/delimitMate' " Automatically close parens etc.
" Plugin 'junegunn/vim-peekaboo' " Show contents of registers.
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'scrooloose/nerdcommenter'

" Project plugins
Plugin 'mileszs/ack.vim'
" Plugin 'kien/ctrlp.vim'
" Plugin 'scrooloose/nerdtree'
" Plugin 'Xuyuanp/nerdtree-git-plugin'

" Python
Plugin 'ivanov/vim-ipython'
Plugin 'jmcantrell/vim-virtualenv'
Plugin 'klen/python-mode'
Plugin 'amoffat/snake'
Plugin 'hdima/python-syntax'

" Javascript/Node
Plugin 'kchmck/vim-coffee-script'
Plugin 'marijnh/tern_for_vim'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'digitaltoad/vim-jade'
Plugin 'Shougo/vimproc.vim'
Plugin 'Quramy/tsuquyomi'
Plugin 'leafgarland/typescript-vim'
Plugin 'niftylettuce/vim-jinja'

" FSharp/Mono
Plugin 'fsharp/vim-fsharp'

" OCaml
Plugin 'let-def/ocp-indent-vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" ---- System Settings
set undofile " tell it to use an undo file
set history=700 " Sets how many lines of history VIM has to remember
set autoread " Set to auto read when a file is changed from the outside
set t_Co=256 " 256 colors
colorscheme molokai " Theme

" use unicode
set encoding=utf-8
set fileencoding=utf-8

" airline config
set laststatus=2

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" Get the correct symbols
let g:airline_powerline_fonts = 1

" sessions settings
" let g:session_autoload = 'yes'
" let g:session_autosave = 'yes'

" Mouse support in terminal vim
set mouse=a

" ---- Editor Settings
" Use relative numbers when not inserting
set relativenumber
set number

function! Absolute_number ()
    :set rnu!
    :set nu
endfunction

function! Relative_number ()
    :set nu
    :set rnu
endfunction

autocmd InsertEnter * :call Absolute_number()
autocmd InsertLeave * :call Relative_number()
" nnoremap <silent><Leader>r :set rnu! rnu? <cr>
set numberwidth=6

set undofile " Use undo file

set hidden " Hide unwritten buffers rather than forcing them to be written.

" assume the /g flag on :s substitutions to replace all matches in a line
set gdefault
set nofoldenable    " disable folding
set autoindent

" Whitespace chars
set list listchars=tab:»·
",trail:·
set expandtab " Tabs to spaces
set shiftwidth=4
set tabstop=4
set nowrap

syntax enable

" Rulers
execute "set colorcolumn=" . join(range(80,255), ',')
highlight ColorColumn guibg=Gray14 ctermbg=Blue

" Make backspace delete line endings.
set backspace=eol,start,indent
set incsearch
set showcmd
set wildignore+=*/node_modules/*
set path+=**
set wildmenu

" Disable ex command mode
command! Q q
map Q <Nop>

" Don't add the comment prefix when I hit enter or o/O on a comment line.
autocmd FileType * setlocal formatoptions-=r formatoptions-=o

" Keep search matches in the middle of the window.
"nnoremap n nzzzv
"nnoremap N Nzzzv

" disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Store swap files in fixed location, not current directory.
if isdirectory($HOME . '/.vimswap') == 0
    :silent !mkdir -p ~/.vimswap > /dev/null 2>&1
endif
if isdirectory($HOME . '/.vimbackup') == 0
    :silent !mkdir -p ~/.vimbackup > /dev/null 2>&1
endif
if isdirectory($HOME . '/.vimundo') == 0
    :silent !mkdir -p ~/.vimundo > /dev/null 2>&1
endif
set directory=~/.vimswap//,/var/tmp//,/tmp//,.
set backupdir=~/.vimbackup//,/var/tmp//,/tmp//,.
set undodir=~/.vimundo//,/var/tmp//,/tmp//,.

" Utilisnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<C-tab>"

" Hit enter to accept completion
"function! HandleReturn()
    "if pumvisible()
        "return "\<C-y>"
    "else
        "return "\<CR>"
    "endif
"endfunction
":inoremap <expr> <CR> pumvisible() ? "\<c-y>" : "<Plug>delimitMateCR"
":inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
":inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
" ":inoremap <expr> <CR> HandleReturn()

" Tags stuff
" toggle Tagbar display
"nmap <Leader>o :TagbarToggle<CR>
" autofocus on Tagbar open
"let g:tagbar_autofocus = 1
"let g:tagbar_autoclose = 1

" This unsets the "last search pattern" register by hitting return
"nnoremap <CR> :noh<CR><CR>

" Easily rerun vim source file
" nmap <C-s> :w<CR>:source %<CR>

imap kj <Esc>

" Enter new lines easily
"nmap oo o<Esc>k
"nmap OO O<Esc>j

" map <Leader> <Plug>(easymotion-prefix)

" ---- Interfile Settings
" CtrlP
"nmap ,f :CtrlP<CR>
"nmap ,b :CtrlPBuffer<CR>
"nmap ,t :CtrlPBufTag<CR>
"nmap ,T :CtrlPBufTagAll<CR>
"nmap ,l :CtrlPLine<CR>
"nmap ,m :CtrlPMRUFiles<CR>
"let g:ctrlp_working_path_mode = 0
"let g:ctrlp_custom_ignore = {
"\ 'dir':  '\v[\/](\.git|\.hg|\.svn|\.meteor|node_modules)$',
"\ 'file': '\.pyc$\|\.pyo$|\.class$|\.min\..*\.js',
"\}

" nmap ,n :NERDTreeToggle<CR>

nmap ,s :Ack

" --- OCaml Settings
let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . g:opamshare . "/merlin/vim"
let g:syntastic_ocaml_checkers = ['merlin']

" silver searcher config
if executable('ag')
  let g:ackprg = 'ag'

  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects
  " .gitignore
  " let g:ctrlp_user_command = 'ag %s -l --nocolor --ignore node_modules --hidden -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  " let g:ctrlp_use_caching = 0
endif

" Set cursor properly when entering insert mode when using tmux.
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" ---- Load windows local settings
if !empty(glob("~/_vimrc.local"))
   source $HOME\_vimrc.local
endif

" ---- Load local settings
if !empty(glob("~/.vimrc.local"))
   source $HOME/.vimrc.local
endif
