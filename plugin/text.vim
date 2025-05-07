"-- plug/text.vim  --
if exists('_TEXTPLUG_')|finish|endif
let _TEXTPLUG_ = 1

"-- user commands --
command! -nargs=? -range TextJust <line1>,<line2>call text#just(<args>)
command!          -range TextFixs <line1>,<line2>call text#fixs()
