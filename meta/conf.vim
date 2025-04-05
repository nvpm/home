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
  let g:nvpm_maketree = 1
  let g:nvpm_initload = 1

  let g:nvpm_fluxconf = {}
  let g:nvpm_fluxconf.lexis = ''
  let g:nvpm_fluxconf.lexis.= '|project proj scheme layout book'
  let g:nvpm_fluxconf.lexis.= '|workspace arch archive architecture section'
  let g:nvpm_fluxconf.lexis.= '|tab folder fold shelf package pack chapter'
  let g:nvpm_fluxconf.lexis.= '|file buff buffer path entry node leaf page'

  "let g:nvpm_fluxconf.lexis = ''
  "let g:nvpm_fluxconf.lexis.= '|project'
  "let g:nvpm_fluxconf.lexis.= '|workspace'
  "let g:nvpm_fluxconf.lexis.= '|tab'
  "let g:nvpm_fluxconf.lexis.= '|file'

  hi fluxcomm guifg=#6c6776
  hi fluxkeyw guifg=#00ff00 gui=bold,italic
  hi fluxname guifg=#ffffff
  hi fluxvars guifg=#1177ff
  hi fluxline guifg=#ffee00
  hi fluxsepr guifg=#ffffff gui=bold

  nmap <silent><space>   :NVPMLoop + 3<cr>
  nmap <silent>m<space>  :NVPMLoop - 3<cr>
  nmap <silent><tab>     :NVPMLoop + 2<cr>
  nmap <silent>m<tab>    :NVPMLoop - 2<cr>
  nmap <silent><BS>      :NVPMLoop + 1<cr>
  nmap <silent><del>     :NVPMLoop - 1<cr>
  nmap <silent><c-n>     :NVPMLoop + 1<cr>
  nmap <silent><c-p>     :NVPMLoop - 1<cr>
  nmap <silent><c-space> :NVPMLoop + 0<cr>
  nmap <silent>=         :NVPMLoop + -1<cr>
  nmap <silent>-         :NVPMLoop - -1<cr>

  nmap <F8> <esc>:NVPMLoad<space>
  imap <F8> <esc>:NVPMLoad<space>
  cmap <F8> <esc>:NVPMLoad<space>

  nmap <F9> <esc>:NVPMLoad<space>
  imap <F9> <esc>:NVPMLoad<space>
  cmap <F9> <esc>:NVPMLoad<space>

  nmap <F10> <esc>:NVPMMake<space>
  imap <F10> <esc>:NVPMMake<space>
  cmap <F10> <esc>:NVPMMake<space>

  nmap <F11> <esc>:wall<cr>:NVPMEdit<cr>
  imap <F11> <esc>:wall<cr>:NVPMEdit<cr>
  cmap <F11> <esc>:wall<cr>:NVPMEdit<cr>
  nmap <F12> <esc>:wall<cr>:NVPMEdit<cr>
  imap <F12> <esc>:wall<cr>:NVPMEdit<cr>
  cmap <F12> <esc>:wall<cr>:NVPMEdit<cr>

  nmap mt :NVPMTerm<cr>i

" }
" zoom {

  set cmdheight=1
  let zoom_devl = 1
  let zoom_autocmds = 1
  let zoom_initload = 1
  let zoom_usefloat = 1
  let zoom_uselimit = 1
  let zoom_useminus = 1

  let zoom_height   = -4
  let zoom_width    = 80
  "let zoom_left     = 3

  nmap <silent>mz    :Zoom<cr>

" }
" line {

  " Line options for use with colors
  let g:line_closure       = 1
  let g:line_innerspace    = 0
  let g:line_projname      = 1
  let g:line_bottomright   = ''
  let g:line_bottomright   = '%y%m ⬤ %l,%c/%P'
  let g:line_bottomcenter  = ''
  let g:line_bottomcenter  = ' ⬤ %{line#file()}'
  let g:line_git_info      = 1
  let g:line_git_delayms   = 5000

  " Git Info Colors
  hi LINEGitModified guifg=#aa4371 gui=bold
  hi LINEGitStaged   guifg=#00ff00 gui=bold
  hi LINEGitClean    guifg=#77aaaa gui=bold

  " Line Colors
  hi LINEFill guibg=bg
  hi LINEItem guifg=#aaaaaa guibg=bg
  hi LINECurr guifg=#ffffff guibg=bg
  hi LINEProj guifg=#ffffff guibg=#5c5c5c gui=bold

  nmap <silent>ml :LINESwap<cr><c-l>

" }
" text {

  nmap maj vip:TEXTFixs<cr>vip:TEXTJust 74<cr>{vapoj<vip>
  vmap maj :'<,'>TEXTFixs<cr>:'<,'>TEXTJust 74<cr>

"}

" }
