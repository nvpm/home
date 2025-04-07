"-- plug/nvpm.vim --

if !NVPMTEST&&exists('__NVPMPLUG__')|finish|endif
let __NVPMPLUG__ = 1

call nvpm#init()

"-- user commands --
com! -complete=customlist,nvpm#DIRS        -nargs=* NvpmMake call nvpm#make("<args>")
com! -complete=customlist,nvpm#DIRS        -nargs=1 NvpmLoad call nvpm#load("<args>")
com! -complete=customlist,nvpm#LOOP -count -nargs=1 NvpmLoop call nvpm#loop("<args>")
com!                                                NvpmEdit call nvpm#edit()
com!                                                NvpmTerm call nvpm#term()

"-- auto commands  --
if get(g:,'nvpm_autocmds',1)
  augroup NVPM
    au!
    au! BufEnter *.flux set ft=flux
  augroup END
endif

" vim: nowrap
