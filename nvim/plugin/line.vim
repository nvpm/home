" plug/line.vim
" once {

if !NVPMTEST&&exists('__LINEPLUG__')|finish|endif
let __LINEPLUG__ = 1

" end-once}
" init {

call line#line()

" end-init}
" cmds {

" '_ LINEShow {

       command!
\      LINEShow
\      call line#show()

" }
" '_ LINEHide {

       command!
\      LINEHide
\      call line#hide()

" }
" '_ LINESwap {

       command!
\      LINESwap
\      call line#swap()

" }

" end-cmds}
