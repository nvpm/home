"-- plug/line.vim --

if exists('__LINEPLUG__')|finish|endif
let __LINEPLUG__ = 1

call line#init()

"-- user commands --
command! Line call line#line()

"-- auto commands --
augroup LINE
  au!
  au ModeChanged,BufEnter * if g:line.mode|call line#draw()|endif
  au BufWrite * call line#giti()|call line#draw()
augroup END

