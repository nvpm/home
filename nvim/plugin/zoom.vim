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
    exe 'au WinEnter '..g:zoom.buff..' if g:zoom.mode|wincmd p|endif'
    au QuitPre     * if g:zoom.mode|only|quit|endif
    au BufWinEnter * call zoom#help()
    au ColorScheme * call zoom#show(1)
    if has('nvim')
      au TermClose   * call timer_start(20,{->zoom#term()})
    endif
  augroup END
endif
