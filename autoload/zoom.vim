"-- auto/zoom.vim --
if !exists('NVPMTEST')&&exists('_ZOOMAUTO_')|finish|endif
let _ZOOMAUTO_ = 1
let g:zoom.nvim = has('nvim')
"let g:zoom.vim  = !g:zoom.nvim

"-- main functions --
fu! zoom#init(...) abort "{

  let g:zoom = get(g:,'zoom',{})
  let g:zoom.initload = get(g:zoom , 'initload' , 0)
  let g:zoom.autocmds = get(g:zoom , 'autocmds' , 1)
  let g:zoom.keepline = get(g:zoom , 'keepline' , 0)
  let g:zoom.pushcmdl = get(g:zoom , 'pushcmdl' , 0)
  let g:zoom.height   = get(g:zoom , 'height'   , &lines)
  let g:zoom.width    = get(g:zoom , 'width'    , &columns)
  let g:zoom.left     = get(g:zoom , 'left'     , -1)
  let g:zoom.right    = get(g:zoom , 'right'    , -1)
  let g:zoom.top      = get(g:zoom , 'top'      , -1)

  let g:zoom.mode   = 0
  let g:zoom.line   = exists('g:_LINEAUTO_')
  let g:zoom.nvpm   = exists('g:_NVPMAUTO_')
  let g:zoom.size   = #{ l : 0  , r : 0  , t : 0  , b : 0  }
  let g:zoom.pads   = #{}
  let g:zoom.pads.l = '.nvpm/zoom/l'
  let g:zoom.pads.r = '.nvpm/zoom/r'
  let g:zoom.pads.t = '.nvpm/zoom/t'
  let g:zoom.pads.b = '.nvpm/zoom/b'
  let g:zoom.colr = {}
  let g:zoom.colr.TabLine      = ''
  let g:zoom.colr.TabLineFill  = ''
  let g:zoom.colr.StatusLine   = ''
  let g:zoom.colr.StatusLineNC = ''
  let g:zoom.colr.VertSplit    = ''
  let g:zoom.none = ''

  if !argc()&&g:zoom.initload
    call timer_start(g:zoom.initload,{->zoom#show()})
  endif

endfu "}
fu! zoom#calc(...) abort "{

  let totalheight = &lines
  let totalwidth  = &columns

  if type(g:zoom.height)==type(3.14)
    let g:zoom.height = g:zoom.height*totalheight
    let g:zoom.height = float2nr(g:zoom.height)
  endif
  if type(g:zoom.width)==type(3.14)
    let g:zoom.width = g:zoom.width*totalwidth
    let g:zoom.width = float2nr(g:zoom.width)
  endif

  let g:zoom.height+= (g:zoom.height<=0)*totalheight
  let g:zoom.width += (g:zoom.width <=0)*totalwidth

  if g:zoom.height<totalheight
    let g:zoom.size.b = totalheight-g:zoom.height
    if g:zoom.size.b>3
      let g:zoom.size.t = float2nr(g:zoom.size.b/2)
      let g:zoom.size.b = g:zoom.size.t+g:zoom.size.b%2
    endif
  endif

  if g:zoom.width<totalwidth
    let g:zoom.size.l = totalwidth-g:zoom.width
    if g:zoom.size.l>3
      let g:zoom.size.r = float2nr(g:zoom.size.l/2)
      let g:zoom.size.l = g:zoom.size.r+g:zoom.size.l%2
    endif
  endif

  " layout definitions {

    if g:zoom.left>=0
      let diff = g:zoom.size.l-g:zoom.left
      if diff>0
        let g:zoom.size.r+= diff
        let g:zoom.size.l = g:zoom.left
      endif
    endif
    if g:zoom.right>=0
      let diff = g:zoom.size.r-g:zoom.right
      if diff>0
        let g:zoom.size.l+= diff
        let g:zoom.size.r = g:zoom.right
      endif
    endif
    if g:zoom.top>=0
      let diff = g:zoom.size.t-g:zoom.top-2*(&ls&&&stal&&g:zoom.keepline)
      if diff>=0
        let g:zoom.size.b+= diff
        let g:zoom.size.t = g:zoom.top
      endif
    endif

  "}

endfu " }
fu! zoom#pads(...) abort "{

  if g:zoom.size.l>1
    silent! exec string(g:zoom.size.l-1).'vsplit '.g:zoom.pads.l
    call zoom#buff()
    silent! wincmd p
  endif
  if g:zoom.size.r>1
    silent! exec 'rightb '.string(g:zoom.size.r-1).'vsplit '.g:zoom.pads.r
    call zoom#buff()
    silent! wincmd p
  endif
  if g:zoom.size.t>1
    let t = g:zoom.size.t-1-(&showtabline==2&&g:zoom.keepline)
    silent! exec string(t).'split '.g:zoom.pads.t
    call zoom#buff()
    silent! wincmd p
  endif
  if g:zoom.pushcmdl
    let &cmdheight = g:zoom.size.b
  else
    if g:zoom.size.b>1
      let b = g:zoom.size.b-&cmdheight-&laststatus>0
      silent! exec 'rightbelow split '.g:zoom.pads.b
      call zoom#buff()
      silent! wincmd p
    endif
  endif

  exe 'vertical resize '..g:zoom.width
  exe 'resize '..g:zoom.height

endfu " }
fu! zoom#show(...) abort "{

  if a:0&&!g:zoom.mode|return|endif

  silent! only

  let g:zoom.mode = 0

  call zoom#save()
  call zoom#none()
  call zoom#calc()
  call zoom#pads()

  let g:zoom.mode = 1

  if g:zoom.line
    let g:line.zoom = 1
    call line#draw()
  endif

  if !g:zoom.keepline||(g:zoom.nvpm&&!g:nvpm.mode)
    set statusline=
    set tabline=
    set showtabline=0
    set laststatus=0
  endif

  exe 'set fillchars=vert:\ '
  if g:zoom.nvim
    exe 'set fillchars+=horiz:\ '
    exe 'set fillchars+=horizdown:\ '
    exe 'set fillchars+=vertleft:\ '
    exe 'set fillchars+=vertright:\ '
  endif

endfu "}
fu! zoom#hide(...) abort "{

  call zoom#seth()
  call zoom#zero()
  silent! only
  let g:zoom.mode = 0
  echo ''

  if g:zoom.line
    let g:line.zoom = 0
  endif

  let &cmdheight = g:zoom.cmdh
  let &fillchars = g:zoom.fill
  if !g:zoom.keepline||(g:zoom.nvpm&&!g:nvpm.mode)
    let &showtabline = g:zoom.topl
    let &laststatus  = g:zoom.botl
  endif

endfu "}
fu! zoom#zoom(...) abort "{

  if g:zoom.mode
    call zoom#hide()
  else
    call zoom#show()
  endif
  if g:zoom.line&&g:line.mode|call line#draw()|endif

endfu "}

"-- auxy functions --
fu! zoom#geth(...) abort "{

  let name = a:1
  let args = ''
  if hlexists(name)
    let info = matchstr(execute('hi '.name),'xxx.*$')
    let info = split(info,'\s\+')[1:]
    if info[0]=='links'
      return 'link:'..info[-1]
    elseif info[0]=='cleared'
      return 'cleared'
    endif
    let args = join(info,' ')
  endif
  return args

endfu "}
fu! zoom#save(...) abort "{

  for name in keys(g:zoom.colr)
    if empty(g:zoom.colr[name])
      let args = zoom#geth(name)
      if empty(args)|continue|endif
      let g:zoom.colr[name] = args
    endif
  endfor

  let g:zoom.cmdh = &cmdheight
  let g:zoom.fill = &fillchars
  let g:zoom.topl = &showtabline
  let g:zoom.botl = &laststatus

endfu "}
fu! zoom#none(...) abort "{

  if empty(g:zoom.none) "{
    let args = zoom#geth('Normal')
    if empty(args)|return|endif
    let args = split(args)

    for arg in args
      let arg = split(arg,'=')
      if arg[0]=='guibg'
        let g:zoom.none.= ' guibg='..arg[1]..' guifg='..arg[1]
      elseif arg[0]=='ctermbg'
        let g:zoom.none.= ' ctermbg='..arg[1]..' ctermfg='..arg[1]
      endif
    endfor
    let g:zoom.none = trim(g:zoom.none)

  endif "}

  for name in keys(g:zoom.colr)
    exe 'hi clear '..name
    if !empty(g:zoom.none)
      exe 'hi '..name..' '.g:zoom.none
    endif
  endfor

endfu "}
fu! zoom#seth(...) abort "{

  for name in keys(g:zoom.colr)
    exe 'hi clear '..name
    if g:zoom.colr[name]=='cleared'
      continue
    elseif g:zoom.colr[name]=~'^link:'
      exe 'hi def link '..name..' '..split(g:zoom.colr[name],':')[1]
    else
      exe 'hi '..name..' '..g:zoom.colr[name]
    endif
  endfor

endfu "}
fu! zoom#buff(...) abort "{

  silent! setl nomodifiable
  silent! setl nonumber
  silent! setl norelativenumber
  silent! setl signcolumn=no
  silent! setl nobuflisted
  silent! setl winfixwidth
  silent! setl winfixheight

  let &l:statusline = '%#Normal#'
  exe 'setl fillchars=vert:\ '
  exe 'setl fillchars+=eob:\ '
  if g:zoom.nvim
    exe 'setl fillchars+=horiz:\ '
    exe 'setl fillchars+=horizdown:\ '
    exe 'setl fillchars+=vertleft:\ '
    exe 'setl fillchars+=vertright:\ '
  endif

endfu " }
fu! zoom#test(...) abort "{

  hi normal
  for name in keys(g:zoom.colr)
    exe 'hi '..name
  endfor

endfu "}
fu! zoom#zero(...) abort "{

  let g:zoom.size = #{ l : 0  , r : 0  , t : 0  , b : 0  }

endfu "}

"-- auto functions --
fu! zoom#help(...) abort "{

  let bufname=bufname()

  if &ft == 'help'
    silent! helpclose
    exec 'edit '. bufname
  endif

  if &ft == 'man'
    if g:zoom.mode
      only
      let g:zoom.mode = 0
      call zoom#show()
    " Note:
    " this will never work because of edit part!
    "else
    "  close
    "  exec 'edit '. bufname
    endif
  endif

endfu "}
fu! zoom#term(...) abort "{

  if bufname()=~'^.*git.*$'
    call input(repeat(' ',g:zoom.size.l).'Press enter/esc to close it')
  endif
  if g:zoom.mode
    let line = 0
    if g:zoom.line
      let line = g:line.mode
    endif
    only
    bdel
    call zoom#show()
    if line|call line#show()|endif
  endif

endfu "}
