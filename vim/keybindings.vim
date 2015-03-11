nmap <Leader>ss <ESC>:Ack<SPACE>

nmap <Leader>ww <C-w>v

nmap <Leader>gb <C-O>
nmap <Leader>gf <C-I>

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif
