"-- plug/zoom.vim --
if !exists('NVPMTEST')&&exists('_ZOOMPLUG_')|finish|endif
let _ZOOMPLUG_ = 1

call zoom#init()

"-- user commands --
if !exists(':Zoom') "{
  com! Zoom call zoom#zoom()
endif "}

"-- auto commands --
if g:zoom.autocmds
  augroup ZOOM
    au!
    au WinEnter    .nvpm/zoom/* if g:zoom.mode|wincmd p|endif
    au VimLeavePre * if g:zoom.mode|only|quit|endif
    au FileType help call zoom#auto('help')
    au FileType man  call zoom#auto('manp')
    au ColorScheme * call zoom#show(1)
  augroup END
endif

