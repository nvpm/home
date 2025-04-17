"-- plug/line.vim --

if exists('__LINEPLUG__')|finish|endif
let __LINEPLUG__ = 1

call line#init()

"-- user commands --
command! Line call line#line()

"-- auto commands --
if get(g:,'line_autocmds',0)
  augroup LINE
    au!
    au ModeChanged * if g:line.mode|redrawtabline|endif
  augroup END
endif


