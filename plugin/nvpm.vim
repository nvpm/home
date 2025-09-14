"-- plug/nvpm.vim --
if !exists('NVPMTEST')&&exists('_NVPMPLUG_')|finish|endif
let _NVPMPLUG_ = 1

call nvpm#init()

"-- user commands --
if !exists(':NvpmMake') "{
  com! -complete=customlist,nvpm#user -nargs=* 
  \NvpmMake call nvpm#user('make','<args>')
endif "}
if !exists(':NvpmGrow') "{
  com! -complete=customlist,nvpm#user -nargs=* 
  \NvpmGrow call nvpm#user('grow','<args>')
endif "}
if !exists(':NvpmFell') "{
  com! -complete=customlist,nvpm#user -nargs=* 
  \NvpmFell call nvpm#user('fell','<args>')
endif "}
if !exists(':NvpmJump') "{
  com! -complete=customlist,nvpm#user -count -nargs=* 
  \NvpmJump call nvpm#user('jump','<args>')
endif "}
if !exists(':NvpmTerm') "{
  com! NvpmTerm call nvpm#user('term')
endif "}

"-- auto commands  --
if g:nvpm.autocmds
  augroup NVPM
    au!
    au! BufEnter *.arbo set ft=arbo
    if g:nvpm.initload
      au! VimLeavePre * call nvpm#save()
    endif
  augroup END
endif

