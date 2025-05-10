"-- plug/arbo.vim --
if !exists('NVPMTEST')&&exists('_ARBOPLUG_')|finish|endif
let _ARBOPLUG_ = 1

call arbo#init()

"-- user commands --
com! -complete=customlist,arbo#DIRS        -nargs=* ArboMake call arbo#make("<args>")
com! -complete=customlist,arbo#DIRS        -nargs=1 ArboLoad call arbo#load("<args>")
com! -complete=customlist,arbo#LOOP -count -nargs=1 ArboLoop call arbo#loop("<args>")
com!                                                ArboEdit call arbo#edit()
com!                                                ArboTerm call arbo#term()

"-- auto commands  --
if g:ARBO.user.autocmds
  augroup ARBO
    au!
    au! BufEnter *.flux set ft=flux
  augroup END
endif

" vim: nowrap
