"-- plug/zoom.vim --

if !NVPMTEST&&exists('__ZOOMAUTO__')|finish|endif
let __ZOOMAUTO__ = 1

"-- main functions --
fu! zoom#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif

  let s:user = {}
  let s:user.height = get(g:,'zoom_height','90%')
  let s:user.width  = get(g:,'zoom_width' , 80  )
  let s:user.layout = get(g:,'zoom_layout' ,'center')

  if get(g:,'zoom_initload',0)
    call zoom#show()
  endif

  let s:buff      = {}
  let s:buff.l    = '.nvpm/zoom/left'
  let s:buff.r    = '.nvpm/zoom/right'
  let s:buff.b    = '.nvpm/zoom/bottom'
  let s:buff.t    = '.nvpm/zoom/top'
  let s:buff.list = [s:buff.l,s:buff.r,s:buff.b,s:buff.t]

  let s:size   = {}
  let s:size.l = 0
  let s:size.r = 0
  let s:size.b = 0
  let s:size.t = 0

  let s:zoom = 0

  let s:spliting = 0

endfu "}
fu! zoom#calc(...) "{

  let currheight = winheight(0)
  let currwidth  = winwidth(0)




  let s:size.t = float2nr((currheight-s:user.height)/2)
  let s:size.l = float2nr((currwidth -s:user.width )/2)
  let s:size.b = s:size.t
  let s:size.r = s:size.l

  "if self.layout == 'left'
  "  let self.right = currwidth - self.width - self.left
  "elseif self.layout == 'right'
  "  let self.left   = currwidth - self.width - self.right
  "else
  "  let self.left  = float2nr((currwidth-self.width)/2)
  "  let self.right = float2nr((currwidth-self.width)/2)
  "endif

endf " }
fu! zoom#swap(...) "{
  if s:zoom
    call zoom#hide()
  else
    call zoom#show()
  endif
endfu "}
fu! zoom#show(...) "{

  call zoom#calc()
  let s:spliting = 1
  call zoom#chop()
  call zoom#size()
  let s:spliting = 0

  call line#hide()

  let s:zoom = 1

endfu "}
fu! zoom#hide(...) "{

  "call zoom#bdel()
  only
  set cmdheight=1
  call line#show()

  let s:zoom = 0

endfu "}
fu! zoom#bdel(...) "{

  call execute(':silent! bdel '..s:buff.l)
  call execute(':silent! bdel '..s:buff.r)
  call execute(':silent! bdel '..s:buff.b)
  call execute(':silent! bdel '..s:buff.t)

endfu "}
fu! zoom#chop(...) "{

  if s:size.l > 0
    exec 'silent! vsplit'. s:buff.l
    let &l:statusline=' '
    call zoom#buff()
    silent! wincmd p
  endif

  if s:size.r > 0
    exec 'silent! rightbelow vsplit '. s:buff.r
    let &l:statusline=' '
    call zoom#buff()
    silent! wincmd p
  endif

  if s:size.t > 0
    exec 'silent! top split '. s:buff.t
    let &l:statusline=' '
    call zoom#buff()
    silent! wincmd p
  endif

  "if s:size.b > 0
  "  exec 'silent! bot split '. s:buff.b
  "  let &l:statusline=' '
  "  call zoom#buff()
  "  silent! wincmd p
  "endif

endf " }
fu! zoom#size(...) "{

  if s:size.l > 0
    silent! wincmd h
    exec 'vertical resize ' . s:size.l
    silent! wincmd p
  endif

  exec 'resize          ' . s:user.height
  exec 'vertical resize ' . s:user.width

  if s:size.t > 0
    silent! wincmd k
    exec 'resize ' . s:size.t
    silent! wincmd p
  endif

  if s:size.b > 0
    exec 'set cmdheight='.s:size.bot
  endif

endfu "}
fu! zoom#buff(...) "{

  set nomodifiable
  set readonly
  setlocal nobuflisted

endfu "}

"-- auto functions --
fu! zoom#help(...) "{

  if &filetype == 'man'  && !s:zoom|only|endif
  if &filetype == 'help' && !s:zoom|only|endif

endfu "}
fu! zoom#quit(...) "{

  call zoom#hide()
  quit

endfu "}
fu! zoom#back(...) "{

  if (1+match(s:buff.list,bufname())) && !s:spliting && s:zoom
    call zoom#hide()
    call zoom#show()
    call nvpm#rend()
  endif

endfu "}

