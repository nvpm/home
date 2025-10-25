"-- auto/zoom.vim --
if !exists('NVPMTEST')&&exists('_ZOOMAUTO_')|finish|endif
let _ZOOMAUTO_ = 1
let s:nvim = has('nvim')

if empty($NVPMHOME)
  let $NVPMHOME = resolve(expand('~/.nvpm'))
endif
let s:home = $NVPMHOME..'/zoom/'

"-- main functions --
fu! zoom#init(...) abort "{ user variables & startup routines

  let g:zoom_initload = get(g:,'zoom_initload', 0)
  let g:zoom_autocmds = get(g:,'zoom_autocmds', 1)
  let g:zoom_autosize = get(g:,'zoom_autosize', 1)
  let g:zoom_autohelp = get(g:,'zoom_autohelp', 1)
  let g:zoom_keepline = get(g:,'zoom_keepline', 1)
  let g:zoom_height   = get(g:,'zoom_height'  ,-4)
  let g:zoom_width    = get(g:,'zoom_width'   ,-4)

  let g:zoom = {}
  let g:zoom.mode = 0
  let g:zoom.save = {}

  let g:zoom.size   = #{ l : 0  , r : 0  , t : 0  , b : 0  }
  let g:zoom.pads   = #{}
  let g:zoom.pads.l = s:home..'l'
  let g:zoom.pads.r = s:home..'r'
  let g:zoom.pads.t = s:home..'t'
  let g:zoom.pads.b = s:home..'b'
  let g:zoom.pads.list = []

  let g:zoom.colr = {}
  let g:zoom.colr.VertSplit    = ''
  let g:zoom.colr.StatusLineNC = ''

  let g:zoom.none = ''

  if !argc()&&g:zoom_initload
    call timer_start(g:zoom_initload,{->zoom#show()})
  endif

endfu "}
fu! zoom#calc(...) abort "{ calculates padding buffers based on user variables

  let s:width  = g:zoom_width
  let s:height = g:zoom_height

  if type(s:width)==type(3.14)
    let s:width = float2nr(s:width*&columns)
  endif
  if type(s:height)==type(3.14)
    let s:height = float2nr(s:height*&lines)
  endif
  let s:width += (s:width <=0)*&columns
  let s:height+= (s:height<=0)*&lines

  let Dw = &columns-s:width |let dw = Dw/2
  let Dh = &lines  -s:height|let dh = Dh/2

  let g:zoom.size.r = dw-(dw==1)
  let g:zoom.size.l = dw+(dw==1)+Dw%2
  let g:zoom.size.t = dh
  let g:zoom.size.b = dh+Dh%2

endfu " }
fu! zoom#pads(...) abort "{ splits the view with padding buffers

  if g:zoom.size.l>1
    let size = g:zoom.size.l-1
    silent! exec string(size).'vsplit '.g:zoom.pads.l
    call zoom#buff()
    silent! wincmd p
  endif
  if g:zoom.size.r>1
    let size = g:zoom.size.r-1
    silent! exec 'rightbelow '.string(size).'vsplit '.g:zoom.pads.r
    call zoom#buff()
    silent! wincmd p
  endif
  if g:zoom.size.t==0
    set showtabline=0
  elseif g:zoom.size.t==1 " use the single line occupied by the tabline
    set showtabline=2
    if !g:zoom_keepline
      let &tabline = '%#Normal# '
    endif
  elseif g:zoom.size.t>1
    let size = g:zoom.size.t-1
    silent! exec string(size).'split '.g:zoom.pads.t
    call zoom#buff()
    " TODO: 
    "let tabs = &stal==2||(len(gettabinfo())>1&&&stal==1)
    "if g:zoom_keepline&&tabs
      "let &l:statusline = &tabline
      "set showtabline=0
    "endif
    silent! wincmd p
  endif
  if g:zoom.size.b>0
    let line = g:zoom_keepline&&&laststatus
    let &cmdheight = g:zoom.size.b-line
  else
    set laststatus=0
    set cmdheight=0
  endif

  exe 'vertical resize ' .. s:width
  exe 'resize '          .. s:height

endfu " }
fu! zoom#show(...) abort "{ enters zoom mode

  silent! only

  let g:zoom.mode = 0

  call zoom#save()
  call zoom#none()
  call zoom#calc()
  call zoom#pads()

  let g:zoom.mode = 1

  if exists('g:line.zoom')
    let g:line.zoom = 1 
  endif

  if !g:zoom_keepline
    if g:zoom.save.linemode
      call line#hide()
    else
      let &showtabline = 0
      let &laststatus  = 0
      let &statusline  = ' '
      let &tabline     = ' '
    endif
  endif

  exe 'set fillchars=vert:\ '
  if s:nvim
    exe 'set fillchars+=horiz:\ '
    exe 'set fillchars+=horizdown:\ '
    exe 'set fillchars+=vertleft:\ '
    exe 'set fillchars+=vertright:\ '
  endif

endfu "}
fu! zoom#hide(...) abort "{ leaves zoom mode

  let &cmdheight   = g:zoom.save.cmdheight
  let &fillchars   = g:zoom.save.fillchars

  if exists('g:line.zoom')
    let g:line.zoom = 0 
  endif

  if g:zoom.save.linemode
    call line#show()
  else
    let &showtabline = g:zoom.save.showtabline
    let &laststatus  = g:zoom.save.laststatus
    let &statusline  = g:zoom.save.statusline
    let &tabline     = g:zoom.save.tabline
  endif

  call zoom#seth()
  let g:zoom.size = #{ l : 0  , r : 0  , t : 0  , b : 0  }
  let g:zoom.mode = 0

  for buf in g:zoom.pads.list
    if bufexists(buf)
      call setbufvar(buf,'&winfixwidth' ,0)
      call setbufvar(buf,'&winfixheight',0)
      call execute('bwipeout '..buf)
    endif
  endfor
  let g:zoom.pads.list = []

endfu "}
fu! zoom#zoom(...) abort "{ swaps between modes (toggle switch)

  if g:zoom.mode
    call zoom#hide()
  else
    call zoom#show()
  endif

endfu "}

"-- auxy functions --
fu! zoom#geth(...) abort "{ get highlight arguments from hi-group

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
fu! zoom#save(...) abort "{ saves vim's related variables & hi-groups in place

  " save current colors
  for name in keys(g:zoom.colr)
    if empty(g:zoom.colr[name])
      let args = zoom#geth(name)
      if empty(args)|continue|endif
      let g:zoom.colr[name] = args
    endif
  endfor

  " save current user options
  let g:zoom.save.cmdheight   = &cmdheight
  let g:zoom.save.fillchars   = &fillchars
  let g:zoom.save.showtabline = &showtabline
  let g:zoom.save.laststatus  = &laststatus
  let g:zoom.save.statusline  = &statusline
  let g:zoom.save.tabline     = &tabline

  let g:zoom.save.linemode    = exists('g:line.mode')&&g:line.mode

endfu "}
fu! zoom#none(...) abort "{ sets all hi-groups same as the backgroups

  " builds the none hi arg to put into all hi-groups in g:zoom.colr
  if empty(g:zoom.none)
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
  endif

  for name in keys(g:zoom.colr)
    exe 'hi clear '..name
    if !empty(g:zoom.none)
      exe 'hi '..name..' '.g:zoom.none
    endif
  endfor

endfu "}
fu! zoom#seth(...) abort "{ sets hi-groups to saved hi info (zoom#save)

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
fu! zoom#buff(...) abort "{ sets appropriate vim variables to padding buffers

  call add(g:zoom.pads.list,bufnr())
  silent! setl nomodifiable
  silent! setl nonumber
  silent! setl norelativenumber
  silent! setl signcolumn=no
  silent! setl nobuflisted
  silent! setl winfixwidth
  silent! setl winfixheight
  let &l:statusline = '%#Normal# '
  exe 'setl fillchars=vert:\ '
  exe 'setl fillchars+=eob:\ '
  if s:nvim
    exe 'setl fillchars+=horiz:\ '
    exe 'setl fillchars+=horizdown:\ '
    exe 'setl fillchars+=vertleft:\ '
    exe 'setl fillchars+=vertright:\ '
  endif

endfu " }

"-- auto function --
fu! zoom#auto(...) abort "{ handles autocmds & callbacks

  if !a:0|return|endif

  if a:1=='help' "{
    "TODO: investigate the 'keywordprg' option in both Vim & Neovim for
    "      all filetypes
    if buflisted(bufnr())|return|endif
    if &ft=='man'||&ft=='help'
      call timer_start(0,{->zoom#auto('only')})
    endif
    return
  endif "}
  if a:1=='only' "{
    if g:zoom.mode
      only
      call zoom#show()
    else
      silent! wincmd p
      silent! close
    endif
    return
  endif "}
  if a:1=='quit' "{
    if g:zoom.mode|only|quit|endif
    return
  endif "}
  if a:1=='back' "{
    if g:zoom.mode&&bufname()=~s:home..'[lrtb]'
      wincmd p
    endif
    return
  endif "}
  if a:1=='size' "{
    if g:zoom.mode
      call zoom#hide()
      call zoom#show()
    endif
    return
  endif "}

endfu "}
