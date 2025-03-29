" plug/text.vim
" once {

if !NVPMTEST&&exists('__TEXTPLUG__')|finish|endif
let __TEXTPLUG__ = 1

" end-once}
" cmds {

" '_ TEXTJust {

       command!
\      -nargs=?
\      -range
\      TEXTJust
\     <line1>,<line2>call text#just(<args>)

" }
" '_ TEXTFixs {

       command!
\      -range
\      TEXTFixs
\     <line1>,<line2>call text#fixs()

" }

" end-cmds}
