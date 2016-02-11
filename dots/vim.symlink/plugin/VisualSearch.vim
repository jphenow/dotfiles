" vsearch.vim
" Visual mode search
vmap g/ :call VsearchPatternSave()<cr>/<c-r>/<cr>
vmap g? :call VsearchPatternSave()<cr>?<c-r>/<cr>
function! VsearchPatternSave()
  let l:temp = @@
  normal gvy
  let @/ = substitute(escape(@@, '/'), "\n", "\\\\n", "g")
  let @@ = l:temp
  unlet l:temp
endfunction
