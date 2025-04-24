"-- plug/line.vim --

if !NVPMTEST&&exists('__LINEPLUG__')|finish|endif

let __LINEPLUG__ = 1

call line#init()

"-- user commands --
command! Line call line#line()

"-- auto commands --
augroup LINE
  au!
  au BufWritePost,BufEnter,FocusGained,ModeChanged,BufDelete * call line#draw()
  "if g:line_gitinfo
  "  au BufWritePost,FocusGained * 
  " \call timer_start(g:line_gitdelay,{->line#gitf()})
  "endif
augroup END

