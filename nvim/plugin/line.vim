"-- plug/line.vim --

if exists('__LINEPLUG__')|finish|endif
let __LINEPLUG__ = 1

call line#init()

"-- user commands --
command! Line call line#line()
