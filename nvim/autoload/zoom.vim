"-- auto/zoom.vim --

if !NVPMTEST&&exists('__ZOOMAUTO__')|finish|endif
let __ZOOMAUTO__ = 1

"-- main functions --
fu! zoom#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')

  let g:zoom = {}
  let g:zoom.mode = 0
  let g:zoom.buff = '.nvpm/zoom'
  let g:zoom.carg = ''

endfu "}
fu! zoom#calc(...) "{

  let totalheight = &lines
  let totalwidth  = &columns

  let s:height = get(g:,'zoom_height',totalheight)
  let s:width  = get(g:,'zoom_width' ,80)

  if get(g:,'zoom_usefloat',1)
    if type(s:height)==type(3.14)
      let s:height = s:height*totalheight
    endif
    if type(s:width)==type(3.14)
      let s:width = s:width*totalwidth
    endif
  endif

  if get(g:,'zoom_uselimit',1)
    let s:height%=totalheight
    let s:width %=totalwidth
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
    let s:height = float2nr(s:height)
    " bottom pad takes whole height difference under 3
    let s:bottom = totalheight-s:height
    if s:bottom>3
      " top pad takes smaller portion, if odd difference
      let s:top    = float2nr(s:bottom/2)
      let s:bottom = s:top+s:bottom%2
    endif
  endif

  if s:width<totalwidth
    let s:width = float2nr(s:width)
    " left pad takes whole width difference under 3
    let s:left = totalwidth-s:width
    if s:left>3
      " right pad takes smaller portion, if odd difference
      let s:right = float2nr(s:left/2)
      let s:left  = s:right+s:left%2
    endif
  endif
  let left = get(g:,'zoom_left',-1)
  if left>=0
    "let left = [left,totalwidth-width][left+width>=totalwidth]
    let s:right+= s:left-left
    let s:left  = left
  endif
  let right = get(g:,'zoom_right',-1)
  if right>=0
    let s:left+= s:right-right
    let s:right  = right
  endif

endfu " }
fu! zoom#pads(...) "{

  if s:left>1
    silent! exec string(s:left-1)..'vsplit '..g:zoom.buff
    call zoom#buff()
    silent! wincmd p
  endif
  if s:right>1
    silent! exec 'rightbelow '..string(s:right-1)..'vsplit '..g:zoom.buff
    call zoom#buff()
    silent! wincmd p
  endif
  if s:top>1
    silent! exec 'top '..string(s:top-1)..'split '..g:zoom.buff
    call zoom#buff()
    silent! wincmd p
  endif

  let &cmdheight = s:bottom

endfu " }
fu! zoom#show(...) "{

  if a:0&&!g:zoom.mode|return|endif

  silent! only

  let g:zoom.mode = 0

  call line#hide()
  call zoom#save()
  call zoom#calc()
  call zoom#pads()
  call zoom#none()

  let g:zoom.mode = 1

endfu "}
fu! zoom#hide(...) "{

  silent! only

  call line#show()
  call zoom#rest()

  exe ':silent! bdel '..g:zoom.buff

  let g:zoom.mode = 0

endfu "}
fu! zoom#swap(...) "{

  if g:zoom.mode
    call zoom#hide()
  else
    call zoom#show()
  endif

endfu "}

"-- auxy functions --
fu! zoom#save(...) "{

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

  let s:numb = &number
  let s:cmdh = &cmdheight
  let s:fill = &fillchars
  let s:sign = &signcolumn
  let s:reln = &relativenumber
  let &number         = 0
  let &cmdheight      = !s:nvim
  let &signcolumn     = 'no'
  let &relativenumber = 0

  if get(g:,'zoom_devl')|return|endif
  exe 'set fillchars=vert:\ '
  exe 'set fillchars+=eob:\ '

endfu "}
fu! zoom#rest(...) "{

  let &number         = s:numb
  let &cmdheight      = s:cmdh
  let &fillchars      = s:fill
  let &signcolumn     = s:sign
  let &relativenumber = s:reln

endfu "}
fu! zoom#buff(...) "{

  silent! setl nomodifiable
  silent! setl nonumber
  silent! setl signcolumn=no
  silent! setl nobuflisted

  if get(g:,'zoom_devl')|return|endif
  let &l:tabline    = ' '
  let &l:statusline = ' '

endfu " }
fu! zoom#none(...) "{

  if get(g:,'zoom_devl')|return|endif
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
fu! zoom#help(...) "{

  let bufname=bufname()

  if &filetype == 'help'
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
fu! zoom#term(...) "{

  if g:zoom.mode&&s:nvim
    only
    bdel
    call zoom#show()
  endif

endfu "}

" end of buffer
