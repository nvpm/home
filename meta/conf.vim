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
  hi NonText     ctermfg=0 guifg=#000000

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

  "set nowrap

  let line_autocmds = 1
  let line_initload = 0
  let line_verbose  = 2
  let line_gitinfo  = 1
  let line_gitdelay = 5000
  let line_edgekind = 2 "0:bracks,1:hi,2:stikers,3:powerline
  let line_brackets = '[]'
  let line_floating = 1

  nmap <silent>ml :Line<cr><c-l>

  " Colors   {

    if g:line_edgekind == 1 "{

      let s:yellow = '#777733'
      let s:blue   = '#002a57' " 005f87
      exe $'hi linecurr guibg={s:yellow} guifg=Black gui=bold'
      exe $'hi linefill guibg=bg         guifg={s:yellow}'
      hi lineinac guibg=bg      guifg=Grey
      hi def link linecurri error
      exe $'hi linecurrv guibg={s:blue} guifg=White'
      hi def link linecurrc title
      hi def link linecurrt title
      hi def link linecurrr wildmenu

      hi def link linegits Title
      hi def link linegitc DiffAdded
      hi def link linegitm WarningMsg


    endif "}
    if g:line_edgekind == 2 "{

      hi lineinac  guibg=#333300 guifg=Black gui=bold 
      hi lineinaci guibg=#333300 guifg=Black gui=bold 
      hi lineinacc guibg=#333300 guifg=Black gui=bold 
      hi lineinacv guibg=#333300 guifg=Black gui=bold 
      hi lineinact guibg=#333300 guifg=Black gui=bold 
      hi lineinacr guibg=#333300 guifg=Black gui=bold 

      hi linecurr  guibg=#777733 guifg=Black gui=bold
      hi linecurri guibg=#777733 guifg=Black gui=bold
      hi linecurrc guibg=#777733 guifg=Black gui=bold
      hi linecurrv guibg=#777733 guifg=Black gui=bold
      hi linecurrt guibg=#777733 guifg=Black gui=bold
      hi linecurrr guibg=#777733 guifg=Black gui=bold
      
      hi linecurredge guibg=bg guifg=#777733
      hi lineinacedge guibg=bg guifg=#333300

      hi linefill  guibg=bg guifg=#999933

      hi LineFile     guibg=#444400 guifg=#000000 gui=bold
      hi LineFileEdge guibg=bg      guifg=#444400

      hi LineUser     guibg=#444400 guifg=#000000 gui=bold
      hi LineUserEdge guibg=bg      guifg=#444400

      hi linegits guibg=#005500 | hi LineGitsEdge guifg=#005500
      hi linegitc guibg=#000055 | hi LineGitcEdge guifg=#000055
      hi linegitm guibg=#440000 | hi LineGitmEdge guifg=#440000
      hi linegitl guibg=#440000 | hi LineGitlEdge guifg=#440000

    endif "}

  "}
  " Skeleton {

    call line#skel(1)

    call add(g:line_skeleton.head.l,['list',2])

    call add(g:line_skeleton.head.r,['list',1])
    call add(g:line_skeleton.head.r,' ')
    call add(g:line_skeleton.head.r,['curr',0])

    call add(g:line_skeleton.feet.l,['list',3])
    call add(g:line_skeleton.feet.l,' ')
    call add(g:line_skeleton.feet.l,['git'])
    call add(g:line_skeleton.feet.l,' ')
    call add(g:line_skeleton.feet.l,['file'])

    call add(g:line_skeleton.feet.r,['user','%Y%m %l,%c/%P'])

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
  "let zoom_right  = -5

  nmap <silent>mz :Zoom<cr>

" }
" text {

  nmap maj vip:TextFixs<cr>vip:TextJust 76<cr>{vapoj<vip>
  vmap maj :'<,'>TextFixs<cr>:'<,'>TextJust 76<cr>

"}

" }
