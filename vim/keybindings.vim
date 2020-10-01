"nmap <Leader>ff :CtrlP<CR>
nnoremap <silent><nowait> <Leader>ff  :<C-u>CocList files<cr>
nmap <Leader>fo :CtrlPBuffer<CR>
"nmap <Leader>t :CtrlPBufTag<CR>
"nmap <Leader>T :CtrlPBufTagAll<CR>
nmap <Leader>fm :CtrlPMRUFiles<CR>

" Search workspace symbols.
nnoremap <silent><nowait> <Leader>st  :<C-u>CocList -I symbols<cr>
"nnoremap <silent><nowait> <Leader>ss  :<C-u>CocSearch<cr>
nmap <Leader>ss <ESC>:Ack<SPACE>

nmap <Leader>cc <plug>NERDCommenterToggle
vmap <Leader>cc <plug>NERDCommenterToggle

nmap <Leader>ww <C-w>v

nmap <Leader>gb <C-O>
nmap <Leader>gf <C-I>

nnoremap <silent><nowait> <Leader>xp  :<C-u>CocList diagnostics<cr>
" Show commands.
nnoremap <silent><nowait> <Leader>xx  :<C-u>CocList commands<cr>
" Find symbol of current document.
"nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

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

