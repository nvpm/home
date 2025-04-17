"-- plug/line.vim --

if exists('__LINEPLUG__')|finish|endif
let __LINEPLUG__ = 1

call line#init()

"-- user commands --
command! Line call line#line()

"-- auto commands --
augroup LINE
  au!
  au ModeChanged * if g:line.mode|redrawtabline|endif
augroup END


