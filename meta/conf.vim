" devl {

let NVPMTEST = 1
if exists('g:nvpmdev')&&getcwd()==g:nvpmdev
  let NVPMCRYP = '/iasj/cryp/git.gpg'
  so meta/meta.vim
  nmap <silent><F1> <esc>:wall<cr>:MetaInit<cr>
  imap <silent><F1> <esc>:wall<cr>:MetaInit<cr>
  cmap <silent><F1> <esc>:wall<cr>:MetaInit<cr>

  nmap <silent><F2> <esc>:wall<cr>:MetaSync<cr>
  nmap <silent><F3> <esc>:wall<cr>:MetaMake<cr>
  nmap <silent>mgc  <esc>:wall<cr>:MetaSave<cr>
  nmap <silent>mgp  <esc>:wall<cr>:MetaPush<cr>
  nmap <silent>mgn  <esc>:wall<cr>:MetaPush nvpm<cr>
  com! MetaInit so meta/init.vim
  com! MetaSync call meta#sync()
  com! MetaMake call meta#make()
  com! -nargs=? -complete=customlist,meta#plug MetaSave call meta#save("<args>")
  com! -nargs=? -complete=customlist,meta#plug MetaPush call meta#push("<args>")
endif

"}
" main {

if !has('nvim')
  set termguicolors
  syntax on
  set bg=dark
endif
colorscheme ayu

hi clear Pmenu       |hi Pmenu       guibg=#1f252a guifg=#888888
hi clear PmenuSel    |hi PmenuSel    guibg=#aa361b guifg=#ffffff
hi clear Folded      |hi Folded      guibg=#0f0f0f guifg=#749984
hi clear DiffAdded   |hi DiffAdded   guifg=#00ff00 gui=bold
hi clear DiffRemoved |hi DiffRemoved guifg=#ff5555 gui=bold
hi clear Visual      |hi Visual      ctermfg=231 ctermbg=24 guifg=#ffffff guibg=#005f87
hi clear NonText     |hi NonText     ctermfg=0 guifg=#555555

"}
" arbo {

if !has('nvim')
  set hidden
endif

let arbo = {}
let arbo.autocmds = 1
let arbo.filetree = 1
let arbo.savetree = 1
let arbo.bufflist = 1
let arbo.initload = 1
let arbo.lexicon  = 'project|workspace|tab|file'

hi fluxvars guifg=#00ff00 gui=bold

nmap <silent><space>   :ArboJump +4<cr>
nmap <silent>m<space>  :ArboJump -4<cr>
nmap <silent><tab>     :ArboJump +3<cr>
nmap <silent>m<tab>    :ArboJump -3<cr>
nmap <silent><BS>      :ArboJump +2<cr>
nmap <silent><DEL>     :ArboJump -2<cr>
nmap <silent><C-p>     :ArboJump -2<cr>
nmap <silent><C-n>     :ArboJump +2<cr>
nmap <silent><C-i>     :ArboJump -1<cr>
nmap <silent><C-o>     :ArboJump -1<cr>
nmap <silent><C-Space> :ArboJump +1<cr>
nmap <silent>=         :ArboJump +0<cr>
nmap <silent>-         :ArboJump -0<cr>

nmap <F8>  <esc>:ArboGrow<space>
imap <F8>  <esc>:ArboGrow<space>
cmap <F8>  <esc>:ArboGrow<space>
nmap <F9>  <esc>:ArboFell<space>
imap <F9>  <esc>:ArboFell<space>
cmap <F9>  <esc>:ArboFell<space>
nmap <F10> <esc>:ArboMake<space>
imap <F10> <esc>:ArboMake<space>
cmap <F10> <esc>:ArboMake<space>
nmap <silent><F12> <esc>:wall<cr>:ArboJump<cr>
imap <silent><F12> <esc>:wall<cr>:ArboJump<cr>
cmap <silent><F12> <esc>:wall<cr>:ArboJump<cr>
if !has('nvim')
  nmap <silent>mt <esc>:wall<cr>:ArboTerm<cr>
else
  nmap <silent>mt <esc>:wall<cr>:ArboTerm<cr>:startinsert<cr>
endif

"}
" line {

"let _LINEAUTO_ = 1
"let _LINEPLUG_ = 1

let line_keepuser = 0
let line_initload = 0
let line_showmode = 3
let line_gitimode = 2
let line_gitdelay = 0
let line_bonetype = 0 "0:none,1:normal,2:buttons,3:powerline
let line_inacedge = ' , '
let line_curredge = ' , ' " () []   
if g:line_bonetype==0
  let line_curredge = '(,)'
  let line_inacedge = ' , '
endif
let line_boneedge = ',' "                     

nmap <silent>ml :Line<cr><c-l>

" Colors   {

  hi clear tabline
  hi clear statusline
  " LineFill {

    if g:line_bonetype==2
      hi def link LineFill Normal
    else
      hi def link LineFill DiffChange
    endif

  " }
  " LineMode {

    if g:line_bonetype
      hi LineModeNormal   guibg=#000077 guifg=White
      hi LineModeInsert   guibg=#ff0000 guifg=White
      hi LineModeReplace  guibg=#00ffff guifg=Black
      hi LineModeVisual   guibg=#005f87 guifg=White
      hi LineModeCmdline  guibg=#ffff00 guifg=Black
      hi LineModeTerminal guibg=#ffffff guifg=Black

      if g:line_bonetype==2
        hi LineModeEdgeNormal   guibg=bg guifg=#000077
        hi LineModeEdgeInsert   guibg=bg guifg=#ff0000
        hi LineModeEdgeReplace  guibg=bg guifg=#00ffff
        hi LineModeEdgeVisual   guibg=bg guifg=#005f87
        hi LineModeEdgeCmdline  guibg=bg guifg=#ffff00
        hi LineModeEdgeTerminal guibg=bg guifg=#ffffff
      endif
    else
      hi def link ModeSpot LineFill
    endif

  " }
  " LineSpot {

    if g:line_bonetype
      hi def link LineSpotNormal   LineModeNormal
      hi def link LineSpotInsert   LineModeInsert
      hi def link LineSpotReplace  LineModeReplace
      hi def link LineSpotVisual   LineModeVisual
      hi def link LineSpotCmdline  LineModeCmdline
      hi def link LineSpotTerminal LineModeTerminal

      if g:line_bonetype==2
        hi def link LineSpotEdgeNormal   LineModeEdgeNormal
        hi def link LineSpotEdgeInsert   LineModeEdgeInsert
        hi def link LineSpotEdgeReplace  LineModeEdgeReplace
        hi def link LineSpotEdgeVisual   LineModeEdgeVisual
        hi def link LineSpotEdgeCmdline  LineModeEdgeCmdline
        hi def link LineSpotEdgeTerminal LineModeEdgeTerminal
      endif
    else
      hi def link LineSpot LineFill
    endif

  " }
  " LineCurr {

    if g:line_bonetype
      hi LineCurr     guibg=#000033 guifg=White
      if g:line_bonetype==2
        hi LineCurrEdge guibg=bg    guifg=#000033
      endif
    else
      hi def link LineCurr LineFill
    endif

  " }
  " LineInac {

    if g:line_bonetype
      hi LineInac     guibg=#000011 guifg=#007777
      if g:line_bonetype==2
        hi LineInacEdge guibg=bg    guifg=#000011
      endif
    else
      hi def link LineInac LineCurr
    endif

  " }
  " LineFile {

    if g:line_bonetype
      hi def link LineFile LineCurr
      if g:line_bonetype==2
        hi def link LineFileEdge LineCurrEdge
      endif
    else
      hi def link LineFile LineFill
    endif

  " }
  " LineUser {

    if g:line_bonetype
      hi def link LineUser LineFile
      if g:line_bonetype==2
        hi def link LineUserEdge LineFileEdge
      endif
    else
      hi def link LineUser LineFill
    endif

  " }
  " LineGitx {

    if g:line_bonetype
      hi LineGits guibg=#555500 guifg=#000000
      hi LineGitm guibg=#440000 guifg=#ffffff
      hi def link LineGitc LineCurr
      if g:line_bonetype==2
        hi LineGitsEdge guifg=#555500
        hi LineGitmEdge guifg=#440000
        hi def link LineGitcEdge LineCurrEdge
      endif
    else
      hi def link LineGits LineFill
      hi def link LineGitm LineFill
      hi def link LineGitc LineFill
    endif

  " }

"}
" Skeleton {

  if !exists('g:line_skeleton')

    call line#skel(1)

    call add(g:line_skeleton.head.l,['list',3])
    call add(g:line_skeleton.head.r,['list',2])
    "call add(g:line_skeleton.head.r,'%#TypeDef#|')
    call add(g:line_skeleton.head.r,['curr',1,'LineSpot'])

    call add(g:line_skeleton.feet.l,['git'])
    call add(g:line_skeleton.feet.l,' | ')
    call add(g:line_skeleton.feet.l,['list',4])
    call add(g:line_skeleton.feet.l,' | ')
    call add(g:line_skeleton.feet.l,['file'])
    call add(g:line_skeleton.feet.r,['user','%m %l,%v/%p%%'])
  endif

"}

"}
" zoom {

set noruler
"set noshowcmd
"set noshowmode
let zoom_autocmds = 1
let zoom_initload = 1
let zoom_keepline = 1
let zoom_pushcmdl = 1
let zoom_usefloat = 1
let zoom_useminus = 1

let zoom_height = -4
let zoom_width  = 80
let zoom_top    = 0

nmap <silent>mz :Zoom<cr>

"}
" text {

nmap maj vip:TextFixs<cr>vip:TextJust 76<cr>{vapoj<vip>
vmap maj :'<,'>TextFixs<cr>:'<,'>TextJust 76<cr>

"}

"}
" vim: nowrap
