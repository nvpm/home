"-- plug/line.vim --

if !NVPMTEST&&exists('__LINEPLUG__')|finish|endif

let __LINEPLUG__ = 1

call line#init()

"-- user commands --
command! Line call line#line()

"-- auto commands --
augroup LINE
  au!
  au BufWritePost,BufEnter,FocusGained,ModeChanged,BufDelete * 
        \call line#draw()
augroup END

