" plug/nvpm.vim
" once {

if !NVPMTEST&&exists('__NVPMPLUG__')|finish|endif
let __NVPMPLUG__ = 1

" }
" init {

call nvpm#init()

" end-init}
" cmds {
" '_ NVPMLoad {

       command!
\      -complete=customlist,nvpm#DIRS
\      -nargs=1
\      NVPMLoad
\      call nvpm#load("<args>")

" }
" '_ NVPMLoop {

       command!
\      -count
\      -complete=customlist,nvpm#LOOP
\      -nargs=1
\      NVPMLoop
\      call nvpm#loop("<args>")

" }
" '_ NVPMEdit {

       command!
\      NVPMEdit
\      call nvpm#edit()

" }
" '_ NVPMMake {

       command!
\      -nargs=*
\      NVPMMake
\      call nvpm#make("<args>")

" }
" '_ NVPMTerm {

       command!
\      NVPMTerm
\      call nvpm#term()

" }
" '_ NVPMInfo {

       command!
\      NVPMInfo
\      call nvpm#info()

" }
" '_ NVPMMenu {

       command!
\      NVPMMenu
\      call nvpm#menu()
       command! NVPM NVPMMenu

" }
" end-cmds }
" acmd {

" }
