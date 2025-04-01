"-- plug/zoom.vim --

if !NVPMTEST&&exists('__ZOOMAUTO__')|finish|endif
let __ZOOMAUTO__ = 1

"-- main functions --
fu! zoom#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif

  let g:zoom = {}
  let g:zoom.mode = 0

  let pads        = {}
  let pads.left   = '.nvpm/zoom/left'
  let pads.right  = '.nvpm/zoom/right'
  let pads.top    = '.nvpm/zoom/top'
  let pads.list   = [pads.left,pads.right,pads.top]
  let g:zoom.pads = pads

  let h = get(g:,'zoom_height',-4 )
  let w = get(g:,'zoom_width' ,+80)

  "if type(user.height)==type(3.14)
  "  let user.height = float2nr(&lines*user.height)
  "  "let user.height = abs(user.height)
  "endif
  "if type(user.width)==type(3.14)
  "  let user.width = float2nr(&columns*user.width)
  "  "let user.width = abs(user.width)
  "endif

  "let s:height    = (user.h>=-&lines  )*(user.h+(user.h<=0)*&lines)
  "let s:width     = (user.w>=-&columns)*(user.w+(user.w<=0)*&columns)

  let s:height = h
  let s:width  = w

  let s:splitting = 0

endfu "}
fu! zoom#calc(...) "{

  let totalheight = &lines
  let totalwidth  = &columns

  let s:height+=(s:height<=0)*totalheight
  let s:width +=(s:width <=0)*totalwidth

  let s:top    = 0
  let s:bottom = 0
  let s:left   = 0
  let s:right  = 0

  if s:height<totalheight
    " bottom pad takes whole height difference under 3
    let s:bottom = totalheight-s:height
    if s:bottom>3
      " top pad takes smaller portion, if odd difference
      let s:top    = float2nr(s:bottom/2)
      let s:bottom = s:top+s:bottom%2
    endif
  endif

  if s:width<totalwidth
    " left pad takes whole width difference under 3
    let s:left = totalwidth-s:width
    if s:left>3
      " right pad takes smaller portion, if odd difference
      let s:right = float2nr(s:left/2)
      let s:left  = s:right+s:left%2
    endif
  endif

endfu " }
fu! zoom#pads(...) "{

  let s:splitting = 1

  if s:left>1
    exec string(s:left-1)..'vsplit '..g:zoom.pads.left
    call zoom#buff()
    silent! wincmd p
  endif
  if s:right>1
    exec 'rightbelow '..string(s:right-1)..'vsplit '..g:zoom.pads.right
    call zoom#buff()
    silent! wincmd p
  endif
  if s:top>1
    exec 'top '..string(s:top-1)..'split '..g:zoom.pads.top
    call zoom#buff()
    silent! wincmd p
  endif
  let &cmdheight = s:bottom

  let s:splitting = 0

endfu " }
fu! zoom#buff(...) "{

  setl nomodifiable
  setl readonly
  setl nonumber
  setl signcolumn=no
  setl nobuflisted

  let &l:tabline    = ' '
  let &l:statusline = ' '

endfu " }
fu! zoom#none(...) "{

  return
  hi StatusLine   guifg=none guibg=none
  hi StatusLineNC guifg=none guibg=none
  hi SignColumn   guifg=none guibg=none

endfu " }
fu! zoom#show(...) "{

  silent! only

  let s:wrap = &wrap
  let s:numb = &number
  let s:cmdh = &cmdheight
  let s:fill = &fillchars
  let s:sign = &signcolumn
  let &wrap       = 0
  let &number     = 0
  let &cmdheight  = 0
  let &signcolumn = 'no'
  "call execute('set fillchars+=vert:\ ')
  "call execute('set fillchars+=vertleft:\ ')
  "call execute('set fillchars+=vertright:\ ')
  "call execute('set fillchars+=horiz:\ ')
  "call execute('set fillchars+=horizup:\ ')
  "call execute('set fillchars+=horizdown:\ ')
  "call execute('set fillchars+=eob:\ ')

  call line#hide()
  call zoom#calc()
  call zoom#pads()
  call zoom#none()

  let g:zoom.mode = 1

endfu "}
fu! zoom#hide(...) "{

  silent! only
  call zoom#bdel()

  let &wrap       = s:wrap
  let &number     = s:numb
  let &cmdheight  = s:cmdh
  let &fillchars  = s:fill
  let &signcolumn = s:sign

  call line#show()

  let g:zoom.mode = 0

endfu "}
fu! zoom#swap(...) "{

  if g:zoom.mode
    call zoom#hide()
  else
    call zoom#show()
  endif

endfu "}
fu! zoom#bdel(...) "{

  call execute(':silent! bdel '..g:zoom.pads.left)
  call execute(':silent! bdel '..g:zoom.pads.right)
  call execute(':silent! bdel '..g:zoom.pads.top)

endfu "}

"-- auto functions --
fu! zoom#help(...) "{

  let bufname=bufname()
  if &filetype == 'man'
    bdel
    "if g:zoom.mode
    "  call zoom#hide()
    "  call zoom#show()
    "endif
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

  if !s:splitting&&1+match(g:zoom.pads.list,bufname())
    silent! wincmd p
  endif

endfu "}
fu! zoom#term(...) "{

  if g:zoom.mode
    call feedkeys('j','i')
    only
    bdel
    call nvpm#rend()
    call zoom#show()
  endif

endfu "}
" end of buffer
