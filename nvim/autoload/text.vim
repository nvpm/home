" auto/text.vim
" once {

if !NVPMTEST&&exists('__TEXTAUTO__')|finish|endif
let __TEXTAUTO__ = 1

" end-once}
" func {

fu! text#fixs(...) range "{
  let init = get(a:000,0,a:firstline)
  let end  = get(a:000,1,a:lastline)
  let lnum = init
  while lnum <= end
    let line = getline(lnum)
    let line = substitute(line,' \+',' ','g')
    let line = substitute(line,'^ ','','g')
    call setline(lnum,line)
    "exec $"normal :s/\n$/  /g"
    let lnum+=1
  endwhile
  "exec $"normal :{a:firstline},{a:lastline}s/\n$//g"
endfu " }
fu! text#just(...) range "{
  if a:0|let tw=&tw|let &tw=a:1|endif
  exe a:firstline
  exe 'norm! V'.a:lastline.'Ggq'
  let lastline=line('.')
  let s=@/|exe 'silent '.a:firstline.','.lastline.'s/\s\+/ /ge'|let @/=s
  let i=a:firstline
  while i<=lastline "NOT a:lastline!!!
    exe i
    let i=i+1
    if getline('.') !~ '\w\s'
      continue
    endif
    while strlen(substitute(getline('.'),'.','x','g'))<&tw
      silent! norm! E
      if strpart(getline('.'),col('.'))=~'^\s*$'
        norm! ^E
      endif
      exe "norm! a \<Esc>"
    endw
  endw
  "let line = getline(a:lastline)
  "let line = substitute(line,' \+',' ','g')
  "call setline(a:lastline,line)

  if a:0
    let &tw=tw
  endif
  call text#fixs(a:lastline,a:lastline)
endfu " }

" end-func }
