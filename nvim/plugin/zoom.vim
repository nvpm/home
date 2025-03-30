"-- plug/zoom.vim --

if !NVPMTEST&&exists('__ZOOMPLUG__')|finish|endif
let __ZOOMPLUG__ = 1

call zoom#init()

"-- user commands --
command! Zoom call zoom#swap()
"command! Zoom call zoom#show()

"-- auto commands --
if get(g:,'zoom_autocmds',1)
  augroup ZOOM
    au!
    au WinEnter    * call zoom#back()
    au BufWinEnter * call zoom#help()
    au QuitPre     * call zoom#quit()
    au TermClose   * call timer_start(20,{->zoom#term()})
  augroup END
endif
