" devl {

"let NVPMTEST = 1
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

let s:nvim = has('nvim')
if !s:nvim
  set termguicolors
  syntax on
  set bg=dark
endif
colorscheme ayu

hi clear Pmenu      |hi Pmenu       guibg=#1f252a guifg=#888888
hi clear PmenuSel   |hi PmenuSel    guibg=#aa361b guifg=#ffffff
hi clear Folded     |hi Folded      guibg=#0f0f0f guifg=#749984
hi clear DiffAdded  |hi DiffAdded   guifg=#00ff00 gui=bold
hi clear DiffRemoved|hi DiffRemoved guifg=#ff5555 gui=bold
hi clear Visual     |hi Visual      ctermfg=231 ctermbg=24 guifg=#ffffff guibg=#005f87
hi clear NonText    |hi NonText     ctermfg=0 guifg=#555555

"}
" nvpm {

if !s:nvim
  set hidden
endif

"let _NVPMAUTO_ = 1
"let _NVPMPLUG_ = 1

let nvpmhome = '/iasj/proj/nvpm/.nvpm'

let nvpm = {}
let nvpm.initload = 1
let nvpm.autocmds = 1

let nvpm.termlist = -1
let nvpm.termkeep = 0
let nvpm.termexit = 2
let nvpm.termmode = 2

let nvpm.filetree = 1
let nvpm.invasive = 0

let nvpm.lexicon  = 'project,workspace,tab,file'

hi arbovars guifg=#00ff00 gui=bold
hi arbokeyw guifg=#aa7700 gui=bold

" NvpmTerm maps {

  nnoremap mgl :wa<cr>:NvpmTerm git log --all --graph --oneline<cr>
  nnoremap mgd :wa<cr>:NvpmTerm git diff<cr>
  nnoremap mgs :wa<cr>:NvpmTerm git status<cr>
  nnoremap mgg :wa<cr>:NvpmTerm tig<cr>
  nnoremap mf  :wa<cr>:NvpmTerm yazi<cr>
  nnoremap mgR :wa<cr>:!git restore .<cr>
  nnoremap mgr :wa<cr>:!git restore --staged .<cr>

  nnoremap mt  :wa<cr>:NvpmTerm<cr>

" }
" NvpmJump maps {

  nnoremap <silent><space>   :NvpmJump +4<cr>
  nnoremap <silent>m<space>  :NvpmJump -4<cr>
  nnoremap <silent><tab>     :NvpmJump +3<cr>
  nnoremap <silent>m<tab>    :NvpmJump -3<cr>
  nnoremap <silent><BS>      :NvpmJump +2<cr>
  nnoremap <silent><DEL>     :NvpmJump -2<cr>
  nnoremap <silent><C-p>     :NvpmJump -2<cr>
  nnoremap <silent><C-n>     :NvpmJump +2<cr>
  nnoremap <silent><C-i>     :NvpmJump -1<cr>
  nnoremap <silent><C-o>     :NvpmJump -1<cr>
  nnoremap <silent><C-Space> :NvpmJump +1<cr>
  nnoremap <silent>=         :NvpmJump +0<cr>
  nnoremap <silent>-         :NvpmJump -0<cr>

" }
" Random   maps {

  nnoremap <c-e> :NvpmEdit<cr>

" }

"}
" line {

"let _LINEAUTO_ = 1
"let _LINEPLUG_ = 1

let line = {}
let line.initload = 1
let line.showmode = 3
let line.gitimode = 2
let line.gitdelay = 0
let line.bonetype = 2 "0:none,1:normal,2:buttons,3:powerline
let line.curredge = '[,]' " () []   
let line.curredge = ' , ' " () []   
let line.inacedge = ' , '
let line.boneedge = ',' "                     
let line.boneedge = ',' "                     
let line.skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}

call add(line.skeleton.head.l,['list',3])
call add(line.skeleton.head.r,['list',2])
call add(line.skeleton.head.r,'|')
call add(line.skeleton.head.r,['curr',1])
"call add(line.skeleton.head.r,'@')
call add(line.skeleton.head.r,' ')
call add(line.skeleton.head.r,['curr',0,'LineSpot'])

call add(line.skeleton.feet.l,['git'])
"call add(line.skeleton.feet.l,' | ')
call add(line.skeleton.feet.l,' ')
call add(line.skeleton.feet.l,['list',4])
call add(line.skeleton.feet.l,' ')
"call add(line.skeleton.feet.l,' | ')
call add(line.skeleton.feet.l,['file'])
call add(line.skeleton.feet.r,['user','%m %l,%v/%p%%'])

nmap <silent>ml :Line<cr><c-l>

" Colors   {

  hi clear tabline
  hi clear statusline
  " LineFill {

    if line.bonetype==2
      hi def link LineFill Normal
    else
      hi def link LineFill DiffChange
    endif

  " }
  " LineMode {

    if line.bonetype
      hi LineModeNormal   guibg=#000077 guifg=White
      hi LineModeInsert   guibg=#ff0000 guifg=White
      hi LineModeReplace  guibg=#00ffff guifg=Black
      hi LineModeVisual   guibg=#005f87 guifg=White
      hi LineModeCmdline  guibg=#ffff00 guifg=Black
      hi LineModeTerminal guibg=#ffffff guifg=Black

      if line.bonetype==2
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

    if line.bonetype
      hi def link LineSpotNormal   LineModeNormal
      hi def link LineSpotInsert   LineModeInsert
      hi def link LineSpotReplace  LineModeReplace
      hi def link LineSpotVisual   LineModeVisual
      hi def link LineSpotCmdline  LineModeCmdline
      hi def link LineSpotTerminal LineModeTerminal

      if line.bonetype==2
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

    if line.bonetype
      hi LineCurr     guibg=#000033 guifg=White
      if line.bonetype==2
        hi LineCurrEdge guibg=bg    guifg=#000033
      endif
    else
      hi def link LineCurr LineFill
    endif

  " }
  " LineInac {

    if line.bonetype
      hi LineInac     guibg=#000011 guifg=#007777
      if line.bonetype==2
        hi LineInacEdge guibg=bg    guifg=#000011
      endif
    else
      hi def link LineInac LineCurr
    endif

  " }
  " LineFile {

    if line.bonetype
      hi def link LineFile LineCurr
      if line.bonetype==2
        hi def link LineFileEdge LineCurrEdge
      endif
    else
      hi def link LineFile LineFill
    endif

  " }
  " LineUser {

    if line.bonetype
      hi def link LineUser LineFile
      if line.bonetype==2
        hi def link LineUserEdge LineFileEdge
      endif
    else
      hi def link LineUser LineFill
    endif

  " }
  " LineGitx {

    if line.bonetype
      hi LineGits guibg=#555500 guifg=#000000
      hi LineGitm guibg=#440000 guifg=#ffffff
      hi def link LineGitc LineCurr
      if line.bonetype==2
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

"}
" zoom {

"set noruler
"set noshowcmd
"set noshowmode

"let _ZOOMAUTO_ = 1
"let _ZOOMPLUG_ = 1

let zoom = {}
let zoom.autocmds = 1
let zoom.autohelp = 1
let zoom.initload = 1
let zoom.hideline = 1
let zoom.pushcmdl = 0
let zoom.height   = -4
let zoom.width    = 80

nmap <silent>mz :Zoom<cr>

"}
" text {

nmap maj vip:TextFixs<cr>vip:TextJust 76<cr>{vapoj<vip>
vmap maj :'<,'>TextFixs<cr>:'<,'>TextJust 76<cr>

"}

"}
" vim: nowrap
