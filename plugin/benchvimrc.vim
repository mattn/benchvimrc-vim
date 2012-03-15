function! s:add_point(s, l)
  if a:s =~ '^\s*\w' && a:s !~ '^\s*\(en\|if\|el\)'
    let r = join([
    \ printf('let [g:bvimrc_t[g:bvimrc_c], g:bvimrc_s, g:bvimrc_c] = [reltimestr(reltime(g:bvimrc_s)),reltime(), %d]', a:l),
    \], '|') . "\n" . a:s
  else
    let r = a:s
  endif
  return r
endfunction

function! s:benchvimrc()
  let vimrc = fnamemodify(expand(has('win32') || has('win64') ? '~/_vimrc' : '~/.vimrc'), ':p')
  let g:bvimrc_l = readfile(vimrc, 1)
  call add(g:bvimrc_l, "echo ''")
  let tmp = tempname()
  try
    let l = map(range(len(g:bvimrc_l)), 's:add_point(g:bvimrc_l[v:val], v:val+1)')
    call writefile(split(join(l, "\n"), "\n", 1), tmp, 1)
    let g:bvimrc_t = {}
    let g:bvimrc_s = reltime()
    let g:bvimrc_c = 0
    exe 'so' tmp
    let l = map(range(1, len(g:bvimrc_l)-1),
    \ 'printf("%s %05d: %s", has_key(g:bvimrc_t, v:val) ? g:bvimrc_t[v:val] : "          ", v:val, g:bvimrc_l[v:val-1])'
    \)
    call writefile(l, tmp, 1)
    unlet g:bvimrc_c
    unlet g:bvimrc_l
    unlet g:bvimrc_t
    unlet g:bvimrc_s
    silent exe "split" tmp
    silent file __BENCHVIMRC__
    setlocal buftype=nofile filetype=vim
    silent! %foldopen
  finally
    call delete(tmp)
  endtry
endfunction

command! -nargs=0 BenchVimrc call s:benchvimrc()
