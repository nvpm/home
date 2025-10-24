"-- plug/line.vim --
if !exists('NVPMTEST')&&exists('_LINEPLUG_')|finish|endif
let _LINEPLUG_ = 1

call line#init()

"-- user commands --
if !exists(':Line') "{
  com! Line call line#line()
endif "}

augroup LINE
  au!
  au BufEnter,ModeChanged,BufDelete * call line#draw()
  au VimLeavePre * call line#stop()
augroup END
