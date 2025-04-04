"-- plug/zoom.vim --

if !NVPMTEST&&exists('__ZOOMAUTO__')|finish|endif
let __ZOOMAUTO__ = 1

"-- main functions --
fu! zoom#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')

  let g:zoom = {}
  let g:zoom.mode = 0

  let s:buff        = {}
  let s:buff.left   = '.nvpm/zoom/left'
  let s:buff.right  = '.nvpm/zoom/right'
  let s:buff.top    = '.nvpm/zoom/top'
  let s:buff.list   = [s:buff.left,s:buff.right,s:buff.top]

  let s:bgcolors = ''

  let s:splitting = 0

endfu "}
fu! zoom#calc(...) "{

  let totalheight = &lines
  let totalwidth  = &columns

  let height = get(g:,'zoom_height',totalheight)  
  let width  = get(g:,'zoom_width' ,80)  

  if get(g:,'zoom_usefloat',1)
    if type(height)==type(3.14)
      let height = height*totalheight
    endif
    if type(width)==type(3.14)
      let width = width*totalwidth
    endif
  endif

  if get(g:,'zoom_uselimit',1)
    let height%=totalheight
    let width %=totalwidth
  endif

  if get(g:,'zoom_useminus',1)
    let height+= (height<=0)*totalheight
    let width += (width <=0)*totalwidth
  endif

  let s:top    = 0
  let s:bottom = 0
  let s:left   = 0
  let s:right  = 0

  if height<totalheight
    let height = float2nr(height)
    " bottom pad takes whole height difference under 3
    let s:bottom = totalheight-height
    if s:bottom>3
      " top pad takes smaller portion, if odd difference
      let s:top    = float2nr(s:bottom/2)
      let s:bottom = s:top+s:bottom%2
    endif
  endif

  if width<totalwidth
    let width = float2nr(width)
    " left pad takes whole width difference under 3
    let s:left = totalwidth-width
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

  let s:splitting = 1

  if s:left>1
    silent! exec string(s:left-1)..'vsplit '..s:buff.left
    call zoom#buff()
    silent! wincmd p
  endif
  if s:right>1
    silent! exec 'rightbelow '..string(s:right-1)..'vsplit '..s:buff.right
    call zoom#buff()
    silent! wincmd p
  endif
  if s:top>1
    silent! exec 'top '..string(s:top-1)..'split '..s:buff.top
    call zoom#buff()
    silent! wincmd p
  endif

  let &cmdheight = s:bottom

  let s:splitting = 0

endfu " }
fu! zoom#show(...) "{

  if a:0&&!g:zoom.mode|return|endif

  silent! only

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
  call zoom#bdel()
  call zoom#rest()

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
    let s:bgcolors = ''
    for arg in normal
      if 1+match(arg,'^\(ctermbg\|guibg\)')
        let s:bgcolors.= arg..' '
        let s:bgcolors.= substitute(arg,'bg','fg','')..' '
      endif
    endfor
    let s:bgcolors = trim(s:bgcolors)
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
  silent! setl readonly
  silent! setl nonumber
  silent! setl signcolumn=no
  silent! setl nobuflisted

  if get(g:,'zoom_devl')|return|endif
  let &l:tabline    = ' '
  let &l:statusline = ' '

endfu " }
fu! zoom#bdel(...) "{

  call execute(':silent! bdel '..s:buff.left)
  call execute(':silent! bdel '..s:buff.right)
  call execute(':silent! bdel '..s:buff.top)

endfu "}
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
    if !empty(s:bgcolors)
      exe 'hi TabLineFill  '..s:bgcolors
      exe 'hi TabLineSell  '..s:bgcolors
      exe 'hi StatusLine   '..s:bgcolors
      exe 'hi StatusLineNC '..s:bgcolors
      exe 'hi LineNr       '..s:bgcolors
      exe 'hi SignColumn   '..s:bgcolors
      exe 'hi VertSplit    '..s:bgcolors
      exe 'hi NonText      '..s:bgcolors
    endif
  endif

endfu " }

"-- auto functions --
fu! zoom#help(...) "{

  let bufname=bufname()
  if &filetype == 'man'
    bdel
    exec 'edit '. bufname
  endif
  if &filetype == 'help'
    if g:zoom.mode
      if bufname!=g:nvpm.tree.curr
        bdel
        exec 'edit '. bufname
      endif
    else
      only
    endif
  endif

endfu "}
fu! zoom#quit(...) "{

  only
  quit

endfu "}
fu! zoom#back(...) "{

  if !s:splitting&&1+match(s:buff.list,bufname())
    silent! wincmd p
  endif

endfu "}
fu! zoom#term(...) "{

  if g:zoom.mode&&s:nvim
    only
    bdel
    call nvpm#rend()
    call zoom#show()
  endif

endfu "}

" end of buffer
