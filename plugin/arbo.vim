"-- plug/arbo.vim --
if !exists('NVPMTEST')&&exists('_ARBOPLUG_')|finish|endif
let _ARBOPLUG_ = 1

call arbo#init()

"-- user commands --
com! -complete=customlist,arbo#DIRS        -nargs=* ArboMake call arbo#make("<args>")
com! -complete=customlist,arbo#DIRS        -nargs=1 ArboGrow call arbo#grow("<args>")
com! -complete=customlist,arbo#DIRS        -nargs=* ArboFell call arbo#fell("<args>")
com! -complete=customlist,arbo#LOOP -count -nargs=1 ArboJump call arbo#jump("<args>")
com!                                                ArboEdit call arbo#edit()
com!                                                ArboTerm call arbo#term()

"-- auto commands  --
if g:arbo.user.autocmds
  augroup ARBO
    au!
    au! BufEnter *.flux set ft=flux
  augroup END
endif

" vim: nowrap
