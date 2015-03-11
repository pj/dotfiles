" CtrlP
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

" silver searcher config
if executable('ag')
  let g:ackprg = 'ag --nogroup --nocolor --column'

  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

" Commenting settings
" Align line-wise comment delimiters flush left instead of following code
" indentation
let g:NERDDefaultAlign = 'left'

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

let g:coc_disable_transparent_cursor = 1

"nmap <Leader>ff :CtrlP<CR>
nnoremap <silent><nowait> <Leader>ff  :<C-u>CocList files<cr>
nnoremap <silent><nowait> <Leader>fb  :<C-u>CocList -I buffers<cr>
"nmap <Leader>fo :CtrlPBuffer<CR>
"nmap <Leader>t :CtrlPBufTag<CR>
"nmap <Leader>T :CtrlPBufTagAll<CR>
"nmap <Leader>fm :CtrlPMRUFiles<CR>
nnoremap <silent><nowait> <Leader>fr  :<C-u>CocList mru<cr>
nnoremap <silent><nowait> <Leader>fl  :<C-u>CocList location<cr>

" Search workspace symbols.
nnoremap <silent><nowait> <Leader>st  :<C-u>CocList -I symbols<cr>
"nnoremap <silent><nowait> <Leader>ss  :<C-u>CocSearch<cr>
nmap <Leader>cc <plug>NERDCommenterToggle
vmap <Leader>cc <plug>NERDCommenterToggle

nnoremap <silent><nowait> <Leader>xp  :<C-u>CocList diagnostics<cr>
" Show commands.
nnoremap <silent><nowait> <Leader>xx  :<C-u>CocList commands<cr>
" Find symbol of current document.
"nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>


" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <D-@> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif


" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

