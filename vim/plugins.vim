" Plugin manager
call plug#begin('~/.vim/plugged')

" System plugins
Plug 'xolox/vim-misc'
Plug 'flazz/vim-colorschemes'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'

" Editing plugins
Plug 'kana/vim-textobj-user'
Plug 'bps/vim-textobj-python'
Plug 'tpope/vim-ragtag'
Plug 'kana/vim-textobj-line'

" File plugins
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-surround'  " Surround things.
Plug 'godlygeek/tabular'
Plug 'Raimondi/delimitMate' " Automatically close parens etc.
Plug 'michaeljsmith/vim-indent-object'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'preservim/nerdcommenter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Project plugins
Plug 'mileszs/ack.vim'
Plug 'ctrlpvim/ctrlp.vim'

" Python
Plug 'hdima/python-syntax'

" Javascript/Node
Plug 'jelera/vim-javascript-syntax'
Plug 'digitaltoad/vim-jade'
Plug 'niftylettuce/vim-jinja'
Plug 'pangloss/vim-javascript'

" Postgres
Plug 'lifepillar/pgsql.vim'
call plug#end()            " required
