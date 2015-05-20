" Plugin manager
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" System plugins
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
Plugin 'flazz/vim-colorschemes'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'bling/vim-airline'

" File plugins
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/syntastic'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'xolox/vim-easytags'
Plugin 'majutsushi/tagbar'
Bundle 'ntpeters/vim-better-whitespace'
Plugin 'tpope/vim-surround'  " Surround things.
Plugin 'aperezdc/vim-template'
Plugin 'honza/vim-snippets'
Plugin 'autoclose'
Plugin 'godlygeek/tabular'

" Project plugins
Plugin 'mileszs/ack.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'

" Python
Plugin 'ivanov/vim-ipython'
Plugin 'jmcantrell/vim-virtualenv'
Plugin 'klen/python-mode'
Plugin 'amoffat/snake'

" Javascript/Node
Plugin 'kchmck/vim-coffee-script'
Plugin 'marijnh/tern_for_vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" ---- System Settings
set undofile " tell it to use an undo file
set history=700 " Sets how many lines of history VIM has to remember
set autoread " Set to auto read when a file is changed from the outside
colorscheme molokai " Theme

" airline config
set laststatus=2

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" sessions settings
let g:session_autoload = 'yes'
let g:session_autosave = 'yes'

" ---- Editor Settings
" Use relative numbers when not inserting
set relativenumber
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber
nnoremap <silent><leader>n :set rnu! rnu? <cr>

set undofile " Use undo file

" Whitespace chars
" :set list
" :set listchars=tab:ÎõÎé

set expandtab " Tabs to spaces

" Rulers
set textwidth=80
execute "set colorcolumn=+" . join(range(1,255), ',+')
highlight ColorColumn guibg=Gray14

syntax enable

" Make backspace delete line endings.
set backspace=eol,start,indent

" Utilisnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<tab>"
" let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"

" Tags stuff
" toggle Tagbar display
map <F4> :TagbarToggle<CR>
" autofocus on Tagbar open
let g:tagbar_autofocus = 1

set incsearch

" This unsets the "last search pattern" register by hitting return
nnoremap <CR> :noh<CR><CR>

" Easily rerun vim source file
nmap <C-s> :w<CR>:source %<CR>

imap ii <Esc>
imap kj <Esc>

" ---- Interfile Settings
" CtrlP
nmap ,f :CtrlP<CR>
nmap ,b :CtrlPBuffer<CR>
nmap ,t :CtrlPBufTag<CR>
nmap ,T :CtrlPBufTagAll<CR>
nmap ,l :CtrlPLine<CR>
nmap ,m :CtrlPMRUFiles<CR>
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = {
\ 'dir':  '\v[\/](\.git|\.hg|\.svn|\.meteor)$',
\ 'file': '\.pyc$\|\.pyo$|\.class$|\.min\..*\.js',
\}

nmap ,n :NERDTreeToggle<CR>

nmap ,s :Ack

" silver searcher config
if executable('ag')
  let g:ackprg = 'ag'
endif

" ---- Load windows local settings
:if !empty(glob("~/_vimrc.local"))
:   source $HOME\_vimrc.local
:endif

:if !empty(glob("~/.vimrc.local"))
:   source $HOME/.vimrc.local
:endif
