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
"colorscheme ayu
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
"colorscheme shine
colorscheme ayu
"colorscheme evening

"" Transparent background
"highlight Normal guibg=NONE ctermbg=NONE
"highlight NormalNC guibg=NONE ctermbg=NONE
"highlight NonText guibg=NONE ctermbg=NONE
"highlight EndOfBuffer guibg=NONE ctermbg=NONE

hi clear Pmenu      |hi Pmenu       guibg=#1f252a guifg=#888888
hi clear PmenuSel   |hi PmenuSel    guibg=#aa361b guifg=#ffffff
hi clear Folded     |hi Folded      guibg=#0f0f0f guifg=#749984
hi clear DiffAdded  |hi DiffAdded   guifg=#00ff00 gui=bold
hi clear DiffRemoved|hi DiffRemoved guifg=#ff5555 gui=bold
hi clear Visual     |hi Visual      ctermfg=231 ctermbg=24 guifg=#ffffff guibg=#005f87
hi clear NonText    |hi NonText     ctermfg=0 guifg=#555555

"}
" gbox {

let g:gbox_safefile = '/iasj/cryp/git.gpg'
let g:gbox_pushcmd  = 'push --force origin --mirror'

"}
" nvpm {

if !s:nvim
  set hidden
endif

"let _NVPMAUTO_ = 1
"let _NVPMPLUG_ = 1

let nvpm_initload = 1
let nvpm_autocmds = 1

let nvpm_termlist = 0
let nvpm_termkeep = 0
let nvpm_termexit = 1
let nvpm_termmode = 0

let nvpm_filetree = 1
let nvpm_invasive = 0

let nvpm_lexicon  = 'project group,workspace plugin,tab,file'

hi arbovars guifg=#00ff00 gui=bold
hi arbokeyw guifg=#aa7700 gui=bold

" NvpmTerm maps {

  nnoremap mgl :wa<cr>:NvpmTerm git --no-pager log --all --graph --oneline<cr>
  nnoremap mgd :wa<cr>:NvpmTerm git --no-pager diff<cr>
  nnoremap mgs :wa<cr>:NvpmTerm git status<cr>
  nnoremap mgg :wa<cr>:NvpmTerm tig<cr>
  nnoremap mf  :wa<cr>:NvpmTerm ranger<cr>
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

  nnoremap <silent><c-e> :NvpmEdit<cr>

" }

"}
" line {

"let _LINEAUTO_ = 1
"let _LINEPLUG_ = 1

let line_initload = 1
let line_showmode = 2
let line_gitimode = 2
let line_gitdelay = 0
let line_bonetype = 2 "0:none,1:normal,2:buttons,3:powerline
let line_curredge = '[,]' " () []   
let line_curredge = ' , ' " () []   
let line_inacedge = ' , '
let line_boneedge = ',' "                     
let line_boneedge = ',' "                     

nmap <silent>ml :Line<cr><c-l>

let line_skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}

call add(line_skeleton.head.l,['list',3])
call add(line_skeleton.head.r,['list',2])
call add(line_skeleton.head.r,' ')
call add(line_skeleton.head.r,['curr',1])
"call add(line_skeleton.head.r,['curr',0,'LineSpot'])

call add(line_skeleton.feet.l,['git'])
call add(line_skeleton.feet.l,['list',4])
call add(line_skeleton.feet.l,' ')
call add(line_skeleton.feet.l,['file'])
call add(line_skeleton.feet.r,['user','%m %l,%v/%p%%'])

" Colors   {

  hi clear tabline
  hi clear statusline
  " LineFill {

    if line_bonetype==2
      hi def link LineFill Normal
    else
      hi def link LineFill DiffChange
    endif

  " }
  " LineMode {

    if line_bonetype
      hi LineModeNormal   guibg=#008877 guifg=White gui=bold
      hi LineModeInsert   guibg=#ff0000 guifg=White gui=bold
      hi LineModeReplace  guibg=#00ffff guifg=Black gui=bold
      hi LineModeVisual   guibg=#005f87 guifg=White gui=bold
      hi LineModeCmdline  guibg=#ffff00 guifg=Black gui=bold
      hi LineModeTerminal guibg=#ffffff guifg=Black gui=bold

      if line_bonetype==2
        hi LineModeEdgeNormal   guibg=bg guifg=#008877
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

    if line_bonetype
      hi def link LineSpotNormal   LineModeNormal
      hi def link LineSpotInsert   LineModeInsert
      hi def link LineSpotReplace  LineModeReplace
      hi def link LineSpotVisual   LineModeVisual
      hi def link LineSpotCmdline  LineModeCmdline
      hi def link LineSpotTerminal LineModeTerminal

      if line_bonetype==2
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

    if line_bonetype
      hi LineCurr     guibg=#005533 guifg=White gui=bold
      if line_bonetype==2
        hi LineCurrEdge guibg=bg    guifg=#005533
      endif
    else
      hi def link LineCurr LineFill
    endif

  " }
  " LineInac {

    if line_bonetype
      hi LineInac     guibg=#002211 guifg=#00aa77
      if line_bonetype==2
        hi LineInacEdge guibg=bg    guifg=#002211
      endif
    else
      hi def link LineInac LineCurr
    endif

  " }
  " LineFile {

    if line_bonetype
      hi def link LineFile LineCurr
      if line_bonetype==2
        hi def link LineFileEdge LineCurrEdge
      endif
    else
      hi def link LineFile LineFill
    endif

  " }
  " LineUser {

    if line_bonetype
      hi def link LineUser LineFile
      if line_bonetype==2
        hi def link LineUserEdge LineFileEdge
      endif
    else
      hi def link LineUser LineFill
    endif

  " }
  " LineGitx {

    if line_bonetype
      hi LineGits guibg=#555500 guifg=#000000
      hi LineGitm guibg=#440000 guifg=#ffffff
      hi def link LineGitc LineCurr
      if line_bonetype==2
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

let zoom_initload = 1
let zoom_autocmds = 1
let zoom_autohelp = 1
let zoom_keepline = 1
let zoom_pushline = 1
let zoom_height   = -4
let zoom_width    = 80

nmap <silent>mz :Zoom<cr>

"}
" text {

nmap maj vip:TextFixs<cr>vip:TextJust 76<cr>{vapoj<vip>
vmap maj :'<,'>TextFixs<cr>:'<,'>TextJust 76<cr>

"}

"}
