"-- plug/zoom.vim --

if !NVPMTEST&&exists('__ZOOMPLUG__')|finish|endif
let __ZOOMPLUG__ = 1

call zoom#init()

"-- user commands --
command! Zoom call zoom#swap()

"-- auto commands --
if get(g:,'zoom_autocmds',1)
  augroup ZOOM
    au!
    au WinEnter    * call zoom#back(1)
    au BufWinEnter * call zoom#help(1)
    au QuitPre     * call zoom#quit(1)
    au ColorScheme * call zoom#show(1)
    if has('nvim')
      au TermClose   * call timer_start(20,{->zoom#term()})
    endif
  augroup END
endif
