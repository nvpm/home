"-- plug/line.vim --
if !exists('NVPMTEST')&&exists('_LINEPLUG_')|finish|endif
let _LINEPLUG_ = 1

call line#init()

"-- user commands --
if !exists(':Line') "{
  com! Line call line#line()
endif "}
