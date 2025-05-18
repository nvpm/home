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
    au BufWinEnter * call zoom#help()
    au ColorScheme * call zoom#show(1)
    if has('nvim')
      au TermClose   * call timer_start(20,{->zoom#term()})
    endif
  augroup END
endif

