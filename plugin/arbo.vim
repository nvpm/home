"-- plug/arbo.vim --
if !exists('NVPMTEST')&&exists('_ARBOPLUG_')|finish|endif
let _ARBOPLUG_ = 1

call arbo#init()

"-- user commands --
com! -complete=customlist,arbo#user        -nargs=* ArboMake call arbo#user('make','<args>')
com! -complete=customlist,arbo#user        -nargs=* ArboLoad call arbo#user('load','<args>')
com! -complete=customlist,arbo#user        -nargs=* ArboFell call arbo#user('fell','<args>')
com! -complete=customlist,arbo#user -count -nargs=* ArboJump call arbo#user('jump','<args>')
com!                                                ArboEdit call arbo#user('edit')
com!                                                ArboTerm call arbo#user('term')

"-- auto commands  --
if g:arbo.user.autocmds
  augroup ARBO
    au!
    au! BufEnter *.flux set ft=flux
  augroup END
endif

" vim: nowrap
