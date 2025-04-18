"-- auto/zoom.vim --

if !NVPMTEST&&exists('__ZOOMAUTO__')|finish|endif
let __ZOOMAUTO__ = 1

"-- main functions --
fu! zoom#init(...) abort "{

  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')
  let s:devl = get(g:,'nvpmdevl')

  let g:zoom = {}
  let g:zoom.mode = 0
  let g:zoom.buff = '.nvpm/zoom'
  let g:zoom.carg = ''
  let g:zoom.lastft= ''

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

  let s:top    = 0
  let s:bottom = 0
  let s:left   = 0
  let s:right  = 0

  if s:height<totalheight
    let s:bottom = totalheight-s:height
    if s:bottom>3
      let s:top    = float2nr(s:bottom/2)
      let s:bottom = s:top+s:bottom%2
    endif
  endif

  if s:width<totalwidth
    let s:left = totalwidth-s:width
    if s:left>3
      let s:right = float2nr(s:left/2)
      let s:left  = s:right+s:left%2
    endif
  endif

  let left = get(g:,'zoom_left',-1)
  if left>=0
    let s:right+= s:left-left
    let s:left  = left
  endif
  let right = get(g:,'zoom_right',-1)
  if right>=0
    let s:left+= s:right-right
    let s:right= right
  endif

endfu " }
fu! zoom#pads(...) abort "{

  if s:left>1
    silent! exec string(s:left-1)..'vsplit '..g:zoom.buff
    call zoom#buff()
    silent! wincmd p
  endif
  if s:top>1
    silent! exec 'top '..string(s:top-1)..'split '..g:zoom.buff
    call zoom#buff()
    silent! wincmd p
  endif
  if s:right>1
    silent! exec 'rightbelow '..string(s:right-1)..'vsplit '..g:zoom.buff
    call zoom#buff()
    silent! wincmd p
  endif

  let &cmdheight = s:bottom

  exe 'vert resize '..s:width

endfu " }
fu! zoom#show(...) abort "{

  if a:0&&!g:zoom.mode|return|endif

  silent! only

  let g:zoom.mode = 0

  call zoom#save()
  call zoom#calc()
  call zoom#pads()
  call zoom#none()

  let g:zoom.mode = 1

  if exists('*line#hide')&&g:line.mode
    let g:line.zoom = #{mode:1,left:s:left,right:s:right}
    if !get(g:,'zoom_keepline')
      call line#hide()
    else
      call line#draw()
    endif
  else
    set showtabline=0
    set laststatus=0
  endif

  if s:devl|return|endif
  exe 'set fillchars=vert:\ '
  exe 'set fillchars+=eob:\ '
  if s:nvim
    exe 'set fillchars+=horiz:\ '
    exe 'set fillchars+=horizdown:\ '
  endif

endfu "}
fu! zoom#hide(...) abort "{

  silent! only
  exe ':silent! bdel '..g:zoom.buff
  let g:zoom.mode = 0

  if exists('*line#show')
    let g:line.zoom = #{mode:0,left:0,right:0}
    call line#show()
    call line#draw()
  else
    let &showtabline = s:topl
    let &laststatus  = s:botl
  endif
  let &cmdheight   = s:cmdh
  let &fillchars   = s:fill

endfu "}
fu! zoom#zoom(...) abort "{

  if g:zoom.mode
    call zoom#hide()
  else
    call zoom#show()
  endif

endfu "}

"-- auxy functions --
fu! zoom#save(...) abort "{

  if !s:nvim
    let normal = execute('hi Normal')
    let normal = split(split(normal,'\n')[0])[2:]
    let g:zoom.carg = ''
    for arg in normal
      if 1+match(arg,'^\(ctermbg\|guibg\)')
        let g:zoom.carg.= arg..' '
        let g:zoom.carg.= substitute(arg,'bg','fg','')..' '
      endif
    endfor
    let g:zoom.carg = trim(g:zoom.carg)
  endif

  let s:cmdh = &cmdheight
  let s:fill = &fillchars
  let s:topl = &showtabline
  let s:botl = &laststatus

endfu "}
fu! zoom#buff(...) abort "{

  silent! setl nomodifiable
  silent! setl nonumber
  silent! setl signcolumn=no
  silent! setl nobuflisted
  silent! setl winfixwidth
  silent! setl winfixheight

  let &l:statusline = ' '

endfu " }
fu! zoom#none(...) abort "{

  if s:devl|return|endif
  if s:nvim
    hi TabLineFill  ctermbg=none guibg=none
    hi TabLineSell  ctermbg=none guibg=none
    hi StatusLine   ctermbg=none guibg=none
    hi StatusLineNC ctermbg=none guibg=none
    hi LineNr       ctermbg=none guibg=none
    hi SignColumn   ctermbg=none guibg=none
    hi VertSplit    ctermbg=none guibg=none
    hi NonText      ctermbg=none guibg=none
  else
    if !empty(g:zoom.carg)
      exe 'hi TabLineFill  '..g:zoom.carg
      exe 'hi TabLineSell  '..g:zoom.carg
      exe 'hi StatusLine   '..g:zoom.carg
      exe 'hi StatusLineNC '..g:zoom.carg
      exe 'hi LineNr       '..g:zoom.carg
      exe 'hi SignColumn   '..g:zoom.carg
      exe 'hi VertSplit    '..g:zoom.carg
      exe 'hi NonText      '..g:zoom.carg
    endif
  endif

endfu " }

"-- auto functions --
fu! zoom#help(...) abort "{

  let bufname=bufname()

  if &filetype == 'help'&&g:zoom.lastft!='help'
    silent! helpclose
    exec 'edit '. bufname
  endif

  if &filetype == 'man'
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

  if g:zoom.mode
    let line = 0
    if exists('g:line.mode')
      let line = g:line.mode
    endif
    only
    bdel
    call zoom#show()
    if line|call line#show()|endif
  endif

endfu "}

" end of buffer
