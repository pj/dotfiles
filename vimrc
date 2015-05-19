:imap ii <Esc>

" tell it to use an undo file
set undofile

syntax enable

" Plugin manager
set nocompatible              " be iMproved, required
filetype off                  " required

" Sets how many lines of history VIM has to remember
set history=700

" Set to auto read when a file is changed from the outside
set autoread

set backspace=eol,start,indent

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'xolox/vim-misc'

Plugin 'tpope/vim-fugitive'

Plugin 'airblade/vim-gitgutter'

" Plugin 'Lokaltog/powerline'
Plugin 'bling/vim-airline'

" Plugin 'AfterColors' " Allows color scheme modifications.

Bundle 'ntpeters/vim-better-whitespace'

Plugin 'flazz/vim-colorschemes'

Plugin 'kien/ctrlp.vim'

Plugin 'tpope/vim-surround'  " Surround things.

Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'aperezdc/vim-template'

Plugin 'xolox/vim-session'

" Track the engine.
" Plugin 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'

Plugin 'autoclose'

  " exuberant ctags fu
Plugin 'xolox/vim-easytags'
Plugin 'majutsushi/tagbar'

" Plugin 'Shougo/neocomplete.vim'
" Plugin 'Shougo/neosnippets.vim'
Plugin 'godlygeek/tabular'

Plugin 'Lokaltog/vim-easymotion'

" Python
Plugin 'ivanov/vim-ipython'
Plugin 'jmcantrell/vim-virtualenv'
Plugin 'klen/python-mode'

" Javascript/Node
Plugin 'kchmck/vim-coffee-script'

Plugin 'Valloric/YouCompleteMe'

Plugin 'mileszs/ack.vim'

Plugin 'scrooloose/syntastic'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Theme
colorscheme molokai

" Line numbers
:set number
:set relativenumber

" Whitespace chars
:set list
" :set listchars=tab:ÎõÎé

:set expandtab

" Char rulers
:set textwidth=80
:set colorcolumn=+2

highlight ColorColumn guibg=Gray14

" airline config
set laststatus=2

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" sessions settings
let g:session_autoload = 'yes'
let g:session_autosave = 'yes'

" Utilisnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<tab>"
" let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"

" Whitespace
":ToggleStripWhitespaceOnSave

" CtrlP setup
" From matt's vimrc
" let g:ctrlp_map = ',f'
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

" Tags stuff
" toggle Tagbar display
map <F4> :TagbarToggle<CR>
" autofocus on Tagbar open
let g:tagbar_autofocus = 1

" set guifont=Monaco:h12
" set guifont=Source\ Code\ Pro:h12

:set incsearch

nmap <C-s> :source %

" silver searcher config
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

:if !empty(glob("~/_vimrc.local"))
:   source $HOME\_vimrc.local
:endif

:if !empty(glob("~/.vimrc.local"))
:   source $HOME/.vimrc.local
:endif
