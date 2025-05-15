"-- plug/arbo.vim --
if !exists('NVPMTEST')&&exists('_ARBOPLUG_')|finish|endif
let _ARBOPLUG_ = 1

call arbo#init()

"-- user commands --
if !exists(':ArboMake') "{
  com! -complete=customlist,arbo#user -nargs=* 
  \ArboMake call arbo#user('make','<args>')
endif "}
if !exists(':ArboGrow') "{
  com! -complete=customlist,arbo#user -nargs=* 
  \ArboGrow call arbo#user('grow','<args>')
endif "}
if !exists(':ArboFell') "{
  com! -complete=customlist,arbo#user -nargs=* 
  \ArboFell call arbo#user('fell','<args>')
endif "}
if !exists(':ArboJump') "{
  com! -complete=customlist,arbo#user -count -nargs=* 
  \ArboJump call arbo#user('jump','<args>')
endif "}
if !exists(':ArboEdit') "{
  com! ArboEdit call arbo#user('edit')
endif "}
if !exists(':ArboTerm') "{
  com! ArboTerm call arbo#user('term')
endif "}

"-- auto commands  --
if g:arbo.user.autocmds
  augroup ARBO
    au!
    au! BufEnter *.flux set ft=flux
    au! VimLeavePre * call arbo#save()
  augroup END
endif
