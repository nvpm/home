"-- plug/line.vim --
if exists('_LINEPLUG_')|finish|endif
let _LINEPLUG_ = 1

call line#init()|delfunc line#init

"-- user commands --
command! Line call line#line()
