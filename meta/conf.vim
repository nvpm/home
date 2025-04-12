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
  colorscheme ayu
  if !has('nvim')
    syntax on
    set bg=dark
  endif

  "hi Pmenu      guibg=#1f252a guifg=#888888
  "hi PmenuSel   guibg=#aa361b guifg=#ffffff

  hi Comment     gui=italic
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

  let nvpm_fluxconf = {}
  let nvpm_fluxconf.lexis = ''
  let nvpm_fluxconf.lexis.= '|project proj scheme layout book'
  let nvpm_fluxconf.lexis.= '|workspace arch archive architecture section'
  let nvpm_fluxconf.lexis.= '|tab folder fold shelf package pack chapter'
  let nvpm_fluxconf.lexis.= '|file buff buffer path entry node leaf page'

  hi fluxcomm guifg=#6c6776
  hi fluxkeyw guifg=#00ff00 gui=bold
  hi fluxname guifg=#ffffff
  hi fluxvars guifg=#1177ff
  hi fluxline guifg=#ffee00 gui=italic
  hi fluxsepr guifg=#ffffff gui=bold

  nmap <silent><space>   :NvpmLoop + 3<cr>
  nmap <silent>m<space>  :NvpmLoop - 3<cr>
  nmap <silent><tab>     :NvpmLoop + 2<cr>
  nmap <silent>m<tab>    :NvpmLoop - 2<cr>
  nmap <silent><BS>      :NvpmLoop + 1<cr>
  nmap <silent><DEL>     :NvpmLoop - 1<cr>
  nmap <silent><C-n>     :NvpmLoop + 1<cr>
  nmap <silent><C-p>     :NvpmLoop - 1<cr>
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

  nmap <silent><F11> <esc>:wall<cr>:NvpmEdit<cr>
  imap <silent><F11> <esc>:wall<cr>:NvpmEdit<cr>
  cmap <silent><F11> <esc>:wall<cr>:NvpmEdit<cr>
  nmap <silent><F12> <esc>:wall<cr>:NvpmEdit<cr>
  imap <silent><F12> <esc>:wall<cr>:NvpmEdit<cr>
  cmap <silent><F12> <esc>:wall<cr>:NvpmEdit<cr>

  nmap mt :NvpmTerm<cr>i

" }
" line {

  "let __LINEAUTO__ = 1
  "let __LINEPLUG__ = 1

  let line_activate  = 1
  let line_verbose   = 1
  let line_projname  = 1
  let line_gitinfo   = 1
  let line_gitdelay  = 10000
  let line_modetype  = 0 " 0,1,2, and 3
  let line_colors    = #{}
  let line_colors.curr = #{guifg:'#000000',guibg:'Visual.guibg',gui:'bold'}
  let line_colors.inac = #{guifg:'#337777'}

  "let line_colors    = #{n:{},i:{},v:{},c:{},t:{},e:{}}
  "let line_colors.n.curr = #{gfg:'#000000' , gbg:'#337777'   , g:'bold'}
  "let line_colors.i.curr = #{gfg:'#000000' , gbg:'#ff0000'   , g:'bold'}
  "let line_colors.v.curr = #{gfg:'#000000' , gbg:'Visual.bg' , g:'bold'}
  "let line_colors.c.curr = #{gfg:'#000000' , gbg:'#00ff00'   , g:'bold'}
  "let line_colors.t.curr = g:line_colors.n.curr
  "
  "let line_colors.n.inac = #{gfg:'#337777',gbg:'bg'}
  "let line_colors.i.inac = g:line_colors.n.inac
  "let line_colors.v.inac = g:line_colors.n.inac
  "let line_colors.c.inac = g:line_colors.n.inac
  "let line_colors.t.inac = g:line_colors.n.inac
  "
  "let line_colors.n.mode = #{gfg:'#00ff00' , gbg:'#2c2c2c'}
  "let line_colors.i.mode = #{gfg:'#00ffff' , gbg:'#2c2c2c'}
  "let line_colors.v.mode = #{gfg:'#ffff00' , gbg:'#2c2c2c'}

  "let line_powerline = 0xe0b0 " until 0xe0b3
  "let line_powerline = 0xe0b4 " until 0xe0b7
  "let line_powerline = 0xe0b8 " until 0xe0bb
  "let line_powerline = 0xe0bc " until 0xe0bf
  "let line_powerline = 0xe0c0 " until 0xe0c3

  hi clear TabLine
  hi clear StatusLine

  " Line Colors
  hi LINEFILL guibg=bg
  hi LINEITEM guifg=#337777 guibg=bg
  hi LINECURR guifg=#000000 guibg=#337777 gui=bold
  hi LINEPROJ guifg=#ffffff guibg=#5c5c5c gui=bold
  "
  "hi LINECHAREND  guifg=#337777 guibg=bg
  "hi LINECHARINIT guifg=bg      guibg=#337777
  "hi LINECHARINAC guifg=#002222 guibg=bg

  " Git Info Colors
  hi LINEGITM guifg=#aa4371
  hi LINEGITS guifg=#00ff00
  hi LINEGITC guifg=#77aaaa

  nmap <silent>ml :Line<cr><c-l>

" }
" zoom {

  set cmdheight=1
  let zoom_autocmds = 1
  let zoom_initload = 1
  let zoom_usefloat = 1
  let zoom_useminus = 1

  let zoom_height = -5
  let zoom_width  = 80
  "let zoom_right  = 0

  nmap <silent>mz :Zoom<cr>

" }
" text {

  nmap maj vip:TextFixs<cr>vip:TextJust 74<cr>{vapoj<vip>
  vmap maj :'<,'>TextFixs<cr>:'<,'>TextJust 74<cr>

"}

" }
