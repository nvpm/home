"-- auto/zoom.vim --
if exists('_ZOOMAUTO_')|finish|endif
let _ZOOMAUTO_ = 1
let s:nvim = has('nvim')
"let s:vim  = !s:nvim

"-- main functions --
fu! zoom#init(...) abort "{

  let s:keepline = get(g:,'zoom_keepline')

  let g:zoom        = {}
  let g:zoom.mode   = 0
  let g:zoom.line   = exists('g:_LINEAUTO_')
  let g:zoom.arbo   = exists('g:_ARBOAUTO_')
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

  if !argc()&&get(g:,'zoom_initload')
    call timer_start(50,{->zoom#show()})
  endif

endfu "}
fu! zoom#calc(...) abort "{

  let totalheight = &lines
  let totalwidth  = &columns

  let s:height = get(g:,'zoom_height',totalheight)
  let s:width  = get(g:,'zoom_width' ,80)

  if get(g:,'zoom_usefloat',1)
    if type(s:height)==type(3.14)
      let s:height = s:height*totalheight
      let s:height = float2nr(s:height)
    endif
    if type(s:width)==type(3.14)
      let s:width = s:width*totalwidth
      let s:width = float2nr(s:width)
    endif
  endif

  if get(g:,'zoom_useminus',1)
    let s:height+= (s:height<=0)*totalheight
    let s:width += (s:width <=0)*totalwidth
  endif

  if s:height<totalheight
    let g:zoom.size.b = totalheight-s:height
    if g:zoom.size.b>3
      let g:zoom.size.t = float2nr(g:zoom.size.b/2)
      let g:zoom.size.b = g:zoom.size.t+g:zoom.size.b%2
    endif
  endif

  if s:width<totalwidth
    let g:zoom.size.l = totalwidth-s:width
    if g:zoom.size.l>3
      let g:zoom.size.r = float2nr(g:zoom.size.l/2)
      let g:zoom.size.l = g:zoom.size.r+g:zoom.size.l%2
    endif
  endif

  " layout definitions {

    let left = get(g:,'zoom_left',-1)
    if left>=0
      let diff = g:zoom.size.l-left
      if diff>0
        let g:zoom.size.r+= diff
        let g:zoom.size.l = left
      endif
    endif
    let right = get(g:,'zoom_right',-1)
    if right>=0
      let diff = g:zoom.size.r-right
      if diff>0
        let g:zoom.size.l+= diff
        let g:zoom.size.r = right
      endif
    endif
    let top = get(g:,'zoom_top',-1)
    if top>=0
      let diff = g:zoom.size.t-top-2*(&ls&&&stal&&s:keepline)
      if diff>=0
        let g:zoom.size.b+= diff
        let g:zoom.size.t = top
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
    let t = g:zoom.size.t-1-(&showtabline==2&&s:keepline)
    silent! exec string(t).'split '.g:zoom.pads.t
    call zoom#buff()
    silent! wincmd p
  endif
  if get(g:,'zoom_pushcmdl')
    let &cmdheight = g:zoom.size.b
  else
    if g:zoom.size.b>1
      let b = g:zoom.size.b-&cmdheight-&laststatus>0
      silent! exec 'rightbelow split '.g:zoom.pads.b
      call zoom#buff()
      silent! wincmd p
    endif
  endif

  exe 'vertical resize '..s:width
  exe 'resize '..s:height

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

  if !s:keepline||(g:zoom.arbo&&!g:arbo.tree.mode)
    set statusline=
    set tabline=
    set showtabline=0
    set laststatus=0
  endif

  exe 'set fillchars=vert:\ '
  if s:nvim
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

  let &cmdheight = s:cmdh
  let &fillchars = s:fill
  if !s:keepline||(g:zoom.arbo&&!g:arbo.tree.mode)
    let &showtabline = s:topl
    let &laststatus  = s:botl
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

  let s:cmdh = &cmdheight
  let s:fill = &fillchars
  let s:topl = &showtabline
  let s:botl = &laststatus

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
  if s:nvim
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
