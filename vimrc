set nocompatible              " be iMproved, required
filetype off                  " required

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin manager
call plug#begin('~/.vim/plugged')

" System plugins
Plug 'xolox/vim-misc'
"Plug 'xolox/vim-session'
Plug 'flazz/vim-colorschemes'
" Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
"Plug 'bling/vim-airline'
" Plug 'pthrasher/conqueterm-vim'
" Plug 'tybenz/vimdeck'
"Bundle 'edkolev/tmuxline.vim'
Plug 'xolox/vim-session'
Plug 'flazz/vim-colorschemes'
" Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline'
" Plug 'pthrasher/conqueterm-vim'
" Plug 'tybenz/vimdeck'
Plug 'edkolev/tmuxline.vim'
Plug 'editorconfig/editorconfig-vim'

" Editing plugins
Plug 'kana/vim-textobj-user'
Plug 'bps/vim-textobj-python'
Plug 'tpope/vim-ragtag'
Plug 'kana/vim-textobj-line'

" File plugins
" Plug 'Valloric/YouCompleteMe'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'Shougo/deoplete.nvim'
Plug 'scrooloose/syntastic'
" Plug 'Lokaltog/vim-easymotion'
" Plug 'xolox/vim-easytags'
" Plug 'majutsushi/tagbar'
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-surround'  " Surround things.
" Plug 'aperezdc/vim-template'
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'
Plug 'godlygeek/tabular'
Plug 'Raimondi/delimitMate' " Automatically close parens etc.
" Plug 'junegunn/vim-peekaboo' " Show contents of registers.
Plug 'michaeljsmith/vim-indent-object'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'scrooloose/nerdcommenter'
Plug 'ludovicchabant/vim-gutentags'

" Project plugins
Plug 'mileszs/ack.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" Plug 'scrooloose/nerdtree'
" Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'junkblocker/patchreview-vim'
Plug 'codegram/vim-codereview'

" Python
"Plug 'ivanov/vim-ipython'
"Plug 'jmcantrell/vim-virtualenv'
"Plug 'klen/python-mode'
"Plug 'amoffat/snake'
Plug 'hdima/python-syntax'

" Javascript/Node
"Plug 'kchmck/vim-coffee-script'
Plug 'marijnh/tern_for_vim'
Plug 'jelera/vim-javascript-syntax'
Plug 'digitaltoad/vim-jade'
Plug 'Shougo/vimproc.vim'
Plug 'Quramy/tsuquyomi'
Plug 'leafgarland/typescript-vim'
Plug 'niftylettuce/vim-jinja'
Plug 'pangloss/vim-javascript'
Plug 'carlitux/deoplete-ternjs'

" FSharp/Mono
" Plug 'fsharp/vim-fsharp'

" OCaml
" Plug 'let-def/ocp-indent-vim'

" Idris
" Plug 'idris-hackers/idris-vim'

" Rust
" Plug 'rust-lang/rust.vim'

" Hack lang
" Plug 'hhvm/vim-hack'

" Postgres
Plug 'lifepillar/pgsql.vim'

" Clojure
Plug 'tpope/vim-fireplace'
Plug 'guns/vim-sexp'

" All of your Plugins must be added before the following line
" All of your Plugs must be added before the following line
call plug#end()            " required
filetype plugin indent on    " required

let g:deoplete#enable_at_startup = 1

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
"set laststatus=2

" Enable the list of buffers
"let g:airline#extensions#tabline#enabled = 1

" Show just the filename
"let g:airline#extensions#tabline#fnamemod = ':t'

" Get the correct symbols
"let g:airline_powerline_fonts = 1

" sessions settings
" let g:session_autoload = 'yes'
" let g:session_autosave = 'yes'
":let g:session_autosave = 'no'

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
set shiftwidth=2
set tabstop=2
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

" Commenting settings
" Align line-wise comment delimiters flush left instead of following code
" indentation
let g:NERDDefaultAlign = 'left'

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

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
nmap <Leader>ff :CtrlPMixed<CR>
nmap <Leader>fb :CtrlPBuffer<CR>
nmap <Leader>ft :CtrlPTag<CR>
nmap <Leader>fc :CtrlPBufTag<CR>
"nmap ,l :CtrlPLine<CR>
nmap <Leader>fm :CtrlPMRUFiles<CR>
"let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = {
\ 'dir':  '\v[\/](\.git|\.hg|\.svn|\.meteor|node_modules)$',
\ 'file': '\.pyc$\|\.pyo$|\.class$|\.min\..*\.js',
\}
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_match_window = 'results:100' " overcome limit imposed by max height
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif

" nmap ,n :NERDTreeToggle<CR>

" nmap ,s :Ack
map <Leader>s <ESC>:Ack<SPACE>

" --- OCaml Settings
"let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
"execute "set rtp+=" . g:opamshare . "/merlin/vim"
"let g:syntastic_ocaml_checkers = ['merlin']

" silver searcher config
if executable('ag')
  let g:ackprg = 'ag --nogroup --nocolor --column'

  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

" Set cursor properly when entering insert mode when using tmux.
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

"let g:tmuxline_preset = {
"        \ 'a': '🇳🇿 ',
"        \ 'b': '#S',
"        \ 'win': ['#I | #W'],
"        \ 'cwin': ['#I | #W'],
"        \ 'x': ['#(python -c "import pypower; print pypower.nice_format()")' ],
"        \ 'y': '%R %a %b %d',
"        \ 'z': '#(if [ "$(hostname)" = "Paul-Johnsons-MacBook-Pro.local" ] || [ "$(hostname)" = "PaulJohnsonsMBP.home" ]; then echo "🏠 "; else echo "$(hostname)"; fi)',
"        \'options' : {'status-justify' : 'left'}}

" Syntastic recommended defaults
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'passive_filetypes': ['html'] }

let g:gutentags_define_advanced_commands = 1
let g:gutentags_cache_dir = $HOME . '/.cache/gutentags'

au BufNewFile,BufRead *.html,*.htm, *.njk set ft=jinja
au BufRead,BufNewFile *.FCMacro set filetype=python

" ---- Load windows local settings
if !empty(glob("~/_vimrc.local"))
   source $HOME\_vimrc.local
endif

" ---- Load local settings
if !empty(glob("~/.vimrc.local"))
   source $HOME/.vimrc.local
endif
