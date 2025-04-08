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

  if has('nvim')|colorscheme ayu|else|syntax on|endif

  hi Pmenu      guibg=#1f252a guifg=#888888
  hi PmenuSel   guibg=#2f361b guifg=#ffffff gui=bold

  hi Folded      guifg=#749984
  hi DiffAdded   guifg=#00ff00              gui=bold
  hi DiffRemoved guifg=#ff0000              gui=italic
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
  let nvpm_projname = 1
  
  let nvpm_fluxconf = {}
  let nvpm_fluxconf.lexis = ''
  let nvpm_fluxconf.lexis.= '|project proj scheme layout book'
  let nvpm_fluxconf.lexis.= '|workspace arch archive architecture section'
  let nvpm_fluxconf.lexis.= '|tab folder fold shelf package pack chapter'
  let nvpm_fluxconf.lexis.= '|file buff buffer path entry node leaf page'

  hi fluxcomm guifg=#6c6776
  hi fluxkeyw guifg=#00ff00 gui=bold,italic
  hi fluxname guifg=#ffffff
  hi fluxvars guifg=#1177ff
  hi fluxline guifg=#ffee00
  hi fluxsepr guifg=#ffffff gui=bold

  nmap <silent><space>   :NvpmLoop + 3<cr>
  nmap <silent>m<space>  :NvpmLoop - 3<cr>
  nmap <silent><tab>     :NvpmLoop + 2<cr>
  nmap <silent>m<tab>    :NvpmLoop - 2<cr>
  nmap <silent><BS>      :NvpmLoop + 1<cr>
  nmap <silent><del>     :NvpmLoop - 1<cr>
  nmap <silent><c-n>     :NvpmLoop + 1<cr>
  nmap <silent><c-p>     :NvpmLoop - 1<cr>
  nmap <silent><c-space> :NvpmLoop + 0<cr>
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

  " Line options for use with colors
  let line_closure      = 1
  let line_innerspace   = 0
  let line_bottomright  = ''
  let line_bottomright  = '%y%m ⬤ %l,%c/%P'
  let line_bottomcenter = ''
  let line_bottomcenter = ' ⬤ %{line#file()}'
  let line_gitinfo      = 1
  let line_gitdelayms   = 5000
  let line_activate     = 1

  hi clear TabLine
  hi clear StatusLine

  " Git Info Colors
  hi LINEGitModified guifg=#aa4371 gui=bold
  hi LINEGitStaged   guifg=#00ff00 gui=bold
  hi LINEGitClean    guifg=#77aaaa gui=bold

  " Line Colors
  hi LINEFill guibg=bg
  hi LINEItem guifg=#aaaaaa guibg=bg
  hi LINECurr guifg=#ffffff guibg=bg
  hi LINEProj guifg=#ffffff guibg=#5c5c5c gui=bold

  nmap <silent>ml :Line<cr><c-l>

" }
" zoom {

  set cmdheight=1
  let nvpmdevl = 0
  let zoom_autocmds = 1
  let zoom_initload = 1
  let zoom_usefloat = 1
  let zoom_useminus = 1

  let zoom_height = -3
  let zoom_width  = 80
  let zoom_right  = 0

  nmap <silent>mz :Zoom<cr>

" }
" text {

  nmap maj vip:TextFixs<cr>vip:TextJust 74<cr>{vapoj<vip>
  vmap maj :'<,'>TextFixs<cr>:'<,'>TextJust 74<cr>

"}

" }
