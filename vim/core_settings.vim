set undofile " tell it to use an undo file
set history=700 " Sets how many lines of history VIM has to remember
set autoread " Set to auto read when a file is changed from the outside
set t_Co=256 " 256 colors
colorscheme molokai " Theme
set encoding=utf-8 " use unicode
set fileencoding=utf-8 " use unicode
set mouse=a " Mouse support in terminal vim
set numberwidth=6 " Set width of number column
set undofile " Use undo file
set hidden " Hide unwritten buffers rather than forcing them to be written.
set gdefault " assume the /g flag on :s substitutions to replace all matches in a line
set nofoldenable    " disable folding
set autoindent
set backspace=eol,start,indent " Make backspace delete line endings.
set incsearch
set showcmd
set wildignore+=*/node_modules/*
set path+=**
set wildmenu
set list listchars=tab:»· " Show tabs
set expandtab " Tabs to spaces
set shiftwidth=2
set tabstop=2
set nowrap
syntax enable
imap kj <Esc>

" Rulers
execute "set colorcolumn=" . join(range(80,255), ',')
highlight ColorColumn guibg=Gray14 ctermbg=Blue

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

" Enter new lines easily
"nmap oo o<Esc>k
"nmap OO O<Esc>j

" Set cursor properly when entering insert mode when using tmux.
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

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

" ---- Load windows local settings
if !empty(glob("~/_vimrc.local"))
   source $HOME\_vimrc.local
endif

" ---- Load local settings
if !empty(glob("~/.vimrc.local"))
   source $HOME/.vimrc.local
endif
