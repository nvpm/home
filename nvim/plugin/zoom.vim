" plug/zoom.vim
" once {

if !NVPMTEST&&exists('__ZOOMPLUG__')|finish|endif
let __ZOOMPLUG__ = 1

" end-once}
" init {

call zoom#init()

" end-init}
" cmds {

command! Zoom call zoom#swap()

" end-cmds}
" acmd {

if get(g:,'zoom_autocmds',1)
  augroup ZOOM
    au!
    au WinEnter    * call zoom#back()
    au BufWinEnter * call zoom#help()
    au QuitPre     * call zoom#quit()
  augroup END
endif

" end-acmd}
