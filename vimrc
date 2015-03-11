:imap ii <Esc>

" tell it to use an undo file
set undofile

" Plugin manager
set nocompatible              " be iMproved, required
filetype off                  " required

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
Plugin 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'

Plugin 'autoclose'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Theme
colorscheme molokai

" Line numbers
:set number

" Whitespace chars
" :set list
" :set listchars=tab:➪

" Char rulers
set colorcolumn=80

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
 let g:UltiSnipsExpandTrigger="<tab>"
 let g:UltiSnipsJumpForwardTrigger="<tab>"
 let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" Whitespace
:ToggleStripWhitespaceOnSave

set guifont=Monaco:h12
" set guifont=Source\ Code\ Pro:h12
