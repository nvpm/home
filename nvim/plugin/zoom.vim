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

" end-acmd}
