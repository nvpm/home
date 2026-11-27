if !exists('NVPMTEST')&&exists('_GBOXPLUG_')|finish|endif
let _GBOXPLUG_ = 1

call gbox#init()

"-- user commands --
"if !exists(':NvpmMake') "{
"  com! -complete=customlist,nvpm#user -nargs=* 
"  \ NvpmMake call nvpm#user('make','<args>')
"endif "}

