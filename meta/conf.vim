" devl {

  hi NVPMPassed  guifg=#009900 gui=bold
  hi NVPMFailed  guifg=#ffffff guibg=#990000 gui=bold

  let NVPMTEST = 1

  nmap <silent><F1> <esc>:wall<cr>:NVPMInit<cr>
  imap <silent><F1> <esc>:wall<cr>:NVPMInit<cr>
  cmap <silent><F1> <esc>:wall<cr>:NVPMInit<cr>
  command! NVPMInit so meta/init.vim

  nmap <silent><F2> <esc>:wall<cr>:NVPMMenuSync<cr>
  imap <silent><F3> <esc>:wall<cr>:NVPMMenuSync<cr>
  cmap <silent><F2> <esc>:wall<cr>:NVPMMenuSync<cr>
  command! NVPMMenuSync so meta/conf.vim|
                       \so meta/menu.vim|
                       \call menu#sync()

  nmap <silent><F3> <esc>:wall<cr>:NVPMMenuMake<cr>
  imap <silent><F3> <esc>:wall<cr>:NVPMMenuMake<cr>
  cmap <silent><F3> <esc>:wall<cr>:NVPMMenuMake<cr>
  command! NVPMMenuMake so meta/conf.vim|
                       \so meta/menu.vim|
                       \call menu#make()

  nmap <silent>mgc  <esc>:wall<cr>:NVPMMenuSave<cr>
  nmap <silent>mgp  <esc>:wall<cr>:NVPMMenuPush<cr>

  command! NVPMMenuSave so meta/menu.vim|call menu#save()
  command! NVPMMenuPush so meta/menu.vim|call menu#push()

" end-devl}
" main {

  set termguicolors     " enable true colors support
  let ayucolor="light"  " for light version of theme
  let ayucolor="mirage" " for mirage version of theme
  let ayucolor="dark"   " for dark version of theme
  "colorscheme github
  colorscheme ayu
  if !has('nvim')
    syntax on
    set bg=dark
  endif

  "hi Pmenu      guibg=#1f252a guifg=#888888
  "hi PmenuSel   guibg=#aa361b guifg=#ffffff

  hi Folded      guifg=#749984
  hi DiffAdded   guifg=#00ff00 gui=bold
  hi DiffRemoved guifg=#ff5555 gui=bold
  hi Visual      ctermfg=231 ctermbg=24 guifg=#ffffff guibg=#005f87
  hi NonText     ctermfg=0 guifg=#555555

" }
" nvpm {

  if !has('nvim')
    set hidden
  endif

  " nvpm user variables tree
  let nvpm_maketree = 1
  let nvpm_initload = 1
  let nvpm_loadline = 1
  let nvpm_autocmds = 1

  let nvpm_fluxconf = {}
  let nvpm_fluxconf.lexis = ''
  let nvpm_fluxconf.lexis.= '|project proj scheme layout book'
  let nvpm_fluxconf.lexis.= '|workspace arch archive architecture section'
  let nvpm_fluxconf.lexis.= '|tab folder fold shelf package pack chapter'
  let nvpm_fluxconf.lexis.= '|file buff buffer path entry node leaf page'

  hi fluxvars guifg=#00ff00 gui=bold

  nmap <silent><space>   :NvpmLoop + 3<cr>
  nmap <silent>m<space>  :NvpmLoop - 3<cr>
  nmap <silent><tab>     :NvpmLoop + 2<cr>
  nmap <silent>m<tab>    :NvpmLoop - 2<cr>
  nmap <silent><BS>      :NvpmLoop + 1<cr>
  nmap <silent><DEL>     :NvpmLoop - 1<cr>
  nmap <silent><C-p>     :NvpmLoop - 1<cr>
  nmap <silent><C-n>     :NvpmLoop + 1<cr>
  nmap <silent><C-i>     :NvpmLoop - 0<cr>
  nmap <silent><C-o>     :NvpmLoop - 0<cr>
  nmap <silent><C-Space> :NvpmLoop + 0<cr>
  nmap <silent>=         :NvpmLoop + -1<cr>
  nmap <silent>-         :NvpmLoop - -1<cr>

  nmap <F8> <esc>:NvpmLoad<space>
  imap <F8> <esc>:NvpmLoad<space>
  cmap <F8> <esc>:NvpmLoad<space>

  nmap <F9> <esc>:NvpmLoad<space>
  imap <F9> <esc>:NvpmLoad<space>
  cmap <F9> <esc>:NvpmLoad<space>

  nmap <F10> <esc>:NvpmMake<space>
  imap <F10> <esc>:NvpmMake<space>
  cmap <F10> <esc>:NvpmMake<space>

  nmap <F11> <esc>:wall<cr>:NvpmEdit<cr>
  imap <F11> <esc>:wall<cr>:NvpmEdit<cr>
  cmap <F11> <esc>:wall<cr>:NvpmEdit<cr>
  nmap <F12> <esc>:wall<cr>:NvpmEdit<cr>
  imap <F12> <esc>:wall<cr>:NvpmEdit<cr>
  cmap <F12> <esc>:wall<cr>:NvpmEdit<cr>

  nmap mt :NvpmTerm<cr>i

" }
" line {

  let line_keepuser = 0
  let line_initload = 1
  let line_verbose  = 2
  let line_gitinfo  = 1
  let line_gitdelay = 1000
  let line_edgekind = 2 "0:bracks,1:hi,2:buttons,3:powerline
  let line_brackets = '[]'

  nmap <silent>ml :Line<cr><c-l>

  " Colors   {

    " LineInac {

      hi LineInac     guibg=#001100 guifg=#007700
      hi LineInacEdge guibg=bg      guifg=#001100

    " }
    " LineCurr {

      hi LineCurr     guibg=#003300 guifg=#00ff00
      hi LineCurrEdge guibg=bg      guifg=#003300

    " }
    " LineSpot {

      hi LineSpotNormal   guibg=#007700 guifg=Black
      hi LineSpotInsert   guibg=#ff0000 guifg=White
      hi LineSpotReplace  guibg=#00ffff guifg=Black
      hi LineSpotVisual   guibg=#005f87 guifg=White
      hi LineSpotCmdline  guibg=#ffff00 guifg=Black
      hi LineSpotTerminal guibg=#ffffff guifg=Black

      hi LineSpotEdgeNormal   guibg=bg guifg=#007700
      hi LineSpotEdgeInsert   guibg=bg guifg=#ff0000
      hi LineSpotEdgeReplace  guibg=bg guifg=#00ffff
      hi LineSpotEdgeVisual   guibg=bg guifg=#005f87
      hi LineSpotEdgeCmdline  guibg=bg guifg=#ffff00
      hi LineSpotEdgeTerminal guibg=bg guifg=#ffffff
      
    " }
    " LineFile {

      hi def link LineFile     LineCurr
      hi def link LineFileEdge LineCurrEdge

    " }
    " LineUser {

      hi def link LineUser     LineFile
      hi def link LineUserEdge LineFileEdge

    " }
    " LineGitx {

      hi LineGits guibg=#555500 | hi LineGitsEdge guifg=#555500
      hi LineGitm guibg=#440000 | hi LineGitmEdge guifg=#440000

      hi def link LineGitc     LineCurr 
      hi def link LineGitcEdge LineCurrEdge

    " }

  "}
  " Skeleton {

    call line#skel(1)

    call add(g:line_skeleton.head.l,['list',2])
    call add(g:line_skeleton.head.r,['list',1])
    call add(g:line_skeleton.head.r,repeat(' ',1))
    call add(g:line_skeleton.head.r,['curr',0,'linespot'])

    call add(g:line_skeleton.feet.l,['list',3])
    call add(g:line_skeleton.feet.l,' ')
    call add(g:line_skeleton.feet.l,['git'])
    call add(g:line_skeleton.feet.l,' ')
    call add(g:line_skeleton.feet.l,['file'])
    call add(g:line_skeleton.feet.r,['user','%Y%m ● %l,%v/%p%%'])

  "}

" }
" zoom {

  set cmdheight=1
  let zoom_autocmds = 1
  let zoom_initload = 1
  let zoom_keepline = 1
  let zoom_usefloat = 1
  let zoom_useminus = 1

  let zoom_height = -4
  let zoom_width  = 80

  nmap <silent>mz :Zoom<cr>

" }
" text {

  nmap maj vip:TextFixs<cr>vip:TextJust 76<cr>{vapoj<vip>
  vmap maj :'<,'>TextFixs<cr>:'<,'>TextJust 76<cr>

"}

" }
