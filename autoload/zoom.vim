"-- auto/zoom.vim --
if !exists('NVPMTEST')&&exists('_ZOOMAUTO_')|finish|endif
let _ZOOMAUTO_ = 1
let s:nvim = has('nvim')

if !has_key(g:,'nvpmhome')
  let g:nvpmhome = resolve(expand('~/.nvpm'))
endif
let s:home = g:nvpmhome..'/zoom/'

"-- main functions --
fu! zoom#init(...) abort "{ user variables & startup routines

  let g:zoom = get(g:,'zoom',{})
  let g:zoom.initload = get(g:zoom , 'initload' , 0)
  let g:zoom.autocmds = get(g:zoom , 'autocmds' , 1)
  let g:zoom.autosize = get(g:zoom , 'autosize' , 1)
  let g:zoom.autohelp = get(g:zoom , 'autohelp' , 1)
  let g:zoom.keepline = get(g:zoom , 'keepline' , 1)
  let g:zoom.height   = get(g:zoom , 'height'   , &lines)
  let g:zoom.width    = get(g:zoom , 'width'    , &columns)
  let g:zoom.left     = get(g:zoom , 'left'     , -1)
  let g:zoom.right    = get(g:zoom , 'right'    , -1)
  let g:zoom.top      = get(g:zoom , 'top'      , -1)

  let g:zoom.mode   = 0

  let g:zoom.save = {}

  let g:zoom.size   = #{ l : 0  , r : 0  , t : 0  , b : 0  }

  let g:zoom.pads   = #{}
  let g:zoom.pads.l = s:home..'l'
  let g:zoom.pads.r = s:home..'r'
  let g:zoom.pads.t = s:home..'t'
  let g:zoom.pads.b = s:home..'b'
  let g:zoom.pads.list = []

  let g:zoom.colr = {}
  let g:zoom.colr.VertSplit = ''
  let g:zoom.colr.TabLine      = ''
  let g:zoom.colr.TabLineSel   = ''
  let g:zoom.colr.TabLineFill  = ''
  let g:zoom.colr.StatusLine   = ''
  let g:zoom.colr.StatusLineNC = ''

  let g:zoom.none = ''

  if !argc()&&g:zoom.initload
    call timer_start(g:zoom.initload,{->zoom#show()})
  endif

endfu "}
fu! zoom#calc(...) abort "{ calculates padding buffers based on user variables

  if type(g:zoom.width)==type(3.14)
    let g:zoom.width = float2nr(g:zoom.width*&columns)
  endif
  if type(g:zoom.height)==type(3.14)
    let g:zoom.height = float2nr(g:zoom.height*&lines)
  endif
  let g:zoom.width += (g:zoom.width <=0)*&columns
  let g:zoom.height+= (g:zoom.height<=0)*&lines

  let Dw = &columns-g:zoom.width |let dw = Dw/2
  let Dh = &lines  -g:zoom.height|let dh = Dh/2

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
    if !g:zoom.keepline
      let &tabline = '%#Normal# '
    endif
  elseif g:zoom.size.t>=2
    let tabs = &stal==2||(len(gettabinfo())>1&&&stal==1)
    if g:zoom.size.t==2&&g:zoom.keepline&&tabs&&g:zoom.size.b==2
      let g:zoom.size.t = 1
      let g:zoom.size.b = 3
    else
      let size = g:zoom.size.t-1
      silent! exec string(size).'split '.g:zoom.pads.t
      call zoom#buff()
      silent! wincmd p
    endif
  endif
  if g:zoom.size.b<=0
    set laststatus=0
    set cmdheight=0
  else
    let statusline = (g:zoom.keepline>0)*(&laststatus>0)
    if g:zoom.size.b==1
      let &cmdheight = !statusline
    elseif g:zoom.size.b>1
      let &cmdheight = g:zoom.size.b-statusline
    endif
  endif

  exe 'vertical resize ' .. g:zoom.width
  exe 'resize '          .. g:zoom.height

endfu " }
fu! zoom#show(...) abort "{ enters zoom mode

  silent! only

  let g:zoom.mode = 0

  call zoom#save()
  call zoom#none()
  call zoom#calc()
  call zoom#pads()

  let g:zoom.mode = 1

  if exists('g:line.pads')
    let g:line.pads.left  = g:zoom.size.l
    let g:line.pads.right = g:zoom.size.r
  endif

  if !g:zoom.keepline&&!a:0
    if exists('*line#hide')
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

  call zoom#seth()
  let g:zoom.size = #{ l : 0  , r : 0  , t : 0  , b : 0  }
  silent! only
  let g:zoom.mode = 0

  let &cmdheight   = g:zoom.save.cmdheight
  let &fillchars   = g:zoom.save.fillchars

  if !g:zoom.keepline
    let &showtabline = g:zoom.save.showtabline
    let &laststatus  = g:zoom.save.laststatus
    let &statusline  = g:zoom.save.statusline
    let &tabline     = g:zoom.save.tabline
  endif

  if exists('g:line.mode')&&g:line.mode||!g:zoom.keepline
    call line#show()
  endif

  if exists('g:line.pads')
    let g:line.pads.left  = 0
    let g:line.pads.right = 0
  endif

  for buf in g:zoom.pads.list
    call zoom#buff(buf)
  endfor

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

  if a:0&&bufexists(a:1)
    call setbufvar(a:1,'&winfixwidth' ,0)
    call setbufvar(a:1,'&winfixheight',0)
  else
    silent! setl winfixwidth
    silent! setl winfixheight
    let bufnr = bufnr()
    if 1+index(g:zoom.pads.list,bufnr)&&bufexists(bufnr)|return|endif
    call add(g:zoom.pads.list,bufnr)
    silent! setl nomodifiable
    silent! setl nonumber
    silent! setl norelativenumber
    silent! setl signcolumn=no
    silent! setl nobuflisted
    let &l:statusline = '%#Normal#'
    exe 'setl fillchars=vert:\ '
    exe 'setl fillchars+=eob:\ '
    if s:nvim
      exe 'setl fillchars+=horiz:\ '
      exe 'setl fillchars+=horizdown:\ '
      exe 'setl fillchars+=vertleft:\ '
      exe 'setl fillchars+=vertright:\ '
    endif
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
      call zoom#show(1)
    endif
    return
  endif "}

endfu "}
