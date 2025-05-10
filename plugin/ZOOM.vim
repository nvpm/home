"-- plug/zoom.vim --
if !exists('NVPMTEST')&&exists('_ZOOMPLUG_')|finish|endif
let _ZOOMPLUG_ = 1

call zoom#init()|delfunc zoom#init

"-- user commands --
command! Zoom call zoom#zoom()

"-- auto commands --
if get(g:,'zoom_autocmds',1)
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

