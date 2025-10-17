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
    au WinEnter    * call zoom#auto('back')
    au VimLeavePre * call zoom#auto('quit')
    if g:zoom.autohelp
      au FileType  help,man setl nobuflisted
      au BufWinEnter * call zoom#auto('help')
    endif
    if g:zoom.autosize
      au VimResized * call zoom#auto('size')
    endif
  augroup END
endif
