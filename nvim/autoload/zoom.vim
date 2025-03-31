"-- plug/zoom.vim --

if !NVPMTEST&&exists('__ZOOMAUTO__')|finish|endif
let __ZOOMAUTO__ = 1

"-- main functions --
fu! zoom#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif

  let g:zoom = {}

  let size = {}
  let size.l = 0
  let size.r = 0
  let size.t = 0
  let size.b = 0
  let size.h = 0
  let size.w = 0

  let pads = {}
  let pads.l = '.nvpm/zoom/left'
  let pads.r = '.nvpm/zoom/right'
  let pads.t = '.nvpm/zoom/top'
  let pads.b = '.nvpm/zoom/bottom'
  let pads.list = [pads.l,pads.r,pads.t,pads.b]

  let user = {}
  let user.h = get(g:,'zoom_height',-90)
  let user.w = get(g:,'zoom_width',80)

  let g:zoom.size  = size
  let g:zoom.pads  = pads
  let g:zoom.user  = user
  let g:zoom.mode  = 0
  let g:zoom.split = 0
  let g:zoom.tgit  = 0

  call execute('set fillchars+=vert:\ ')
  call execute('set fillchars+=vertleft:\ ')
  call execute('set fillchars+=vertright:\ ')
  call execute('set fillchars+=horiz:\ ')
  call execute('set fillchars+=horizup:\ ')
  call execute('set fillchars+=horizdown:\ ')
  call execute('set fillchars+=eob:\ ')

endfu "}
fu! zoom#prep(...) "{

  silent! only
  call line#hide()
  let s:cmdh = &cmdheight
  "set cmdheight=0

endfu " }
fu! zoom#post(...) "{

  let &cmdheight = s:cmdh

endfu " }
fu! zoom#calc(...) "{

  let g:zoom.size.h = winheight(0)
  let g:zoom.size.w = winwidth(0)

  let g:zoom.size.t = float2nr((g:zoom.size.h-g:zoom.user.h)/2)
  let g:zoom.size.l = float2nr((g:zoom.size.w-g:zoom.user.w)/2)

  let g:zoom.size.b = g:zoom.size.t
  let g:zoom.size.r = g:zoom.size.l
  "let g:zoom.size.l+= g:zoom.size.l%2

endfu " }
fu! zoom#buff(...) "{

  setl nomodifiable
  setl readonly
  setl nobuflisted
  setl nonumber

  let &l:tabline    = ' '
  let &l:statusline = ' '

endfu " }
fu! zoom#pads(...) "{

  let g:zoom.split = 1

  "let g:zoom.split = 0
  "return
  if g:zoom.size.l
    exec 'vsplit'..g:zoom.pads.l
    call zoom#buff()
    silent! wincmd p
  endif

  if g:zoom.size.r
    exec 'silent! rightbelow vsplit '. g:zoom.pads.r
    call zoom#buff()
    silent! wincmd p
  endif

  if g:zoom.size.t
    exec 'silent! top split '. g:zoom.pads.t
    call zoom#buff()
    silent! wincmd p
  endif

  if g:zoom.size.b
    exec 'silent! bot split '. g:zoom.pads.b
    call zoom#buff()
    silent! wincmd p
  endif

  if g:zoom.size.l
    silent! wincmd h
    exec 'vertical resize ' . g:zoom.size.l
    silent! wincmd p
  endif

  if g:zoom.size.r
    silent! wincmd l
    exec 'vertical resize ' . g:zoom.size.r
    silent! wincmd p
  endif

  if g:zoom.size.t
    silent! wincmd k
    exec 'resize ' . g:zoom.size.t
    silent! wincmd p
  endif

  if g:zoom.size.b
    silent! wincmd j
    exec 'resize ' . g:zoom.size.b
    silent! wincmd p
  endif

  let g:zoom.split = 0

endfu " }
fu! zoom#show(...) "{

  call zoom#prep()
  call zoom#calc()
  call zoom#pads()

  call zoom#none()
  call zoom#post()

  let g:zoom.mode = 1

endfu "}
fu! zoom#hide(...) "{

  silent! only
  call zoom#bdel()
  let g:zoom.mode = 0

  call line#show()

endfu "}
fu! zoom#swap(...) "{

  if g:zoom.mode
    call zoom#hide()
  else
    call zoom#show()
  endif

endfu "}
fu! zoom#bdel(...) "{

  call execute(':silent! bdel '..g:zoom.pads.l)
  call execute(':silent! bdel '..g:zoom.pads.r)
  call execute(':silent! bdel '..g:zoom.pads.b)
  call execute(':silent! bdel '..g:zoom.pads.t)

endfu "}
fu! zoom#none(...) "{

  hi TabLineFill  ctermfg=bg ctermbg=bg guifg=bg guibg=bg
  hi TabLineSell  ctermfg=bg ctermbg=bg guifg=bg guibg=bg
  hi StatusLine   ctermfg=bg ctermbg=bg guifg=bg guibg=bg
  hi StatusLineNC ctermfg=bg ctermbg=bg guifg=bg guibg=bg
  hi LineNr       ctermfg=bg ctermbg=bg guibg=bg
  hi SignColumn   ctermfg=bg ctermbg=bg guibg=bg
  hi VertSplit    ctermfg=bg ctermbg=bg guifg=bg guibg=bg
  hi NonText      ctermfg=bg ctermbg=bg guifg=bg

endfu " }

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

  if !g:zoom.mode|return|endif
  if !g:zoom.split && 1+match(g:zoom.pads.list,bufname())
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
