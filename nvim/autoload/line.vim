"-- auto/line.vim  --

if exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

"-- auxy functions --
fu! line#bone(...) "{

  let s:currmode = mode()
  let line = ''
  for bone in a:1
    if type(bone)==type([])
      if bone[0]=~'\(git\|branch\)'
        let line.= g:line.git
      elseif bone[0]=~'\(file\|mode\)'
        let line.= line#{bone[0]}()
      elseif bone[0]=~'\(list\|curr\)'
        let line.= line#{bone[0]}(get(bone,1))
      endif
    endif
  endfor
  return line

endfu "}
fu! line#skel(...) "{

  let s:skel = #{head:{},foot:{}}
  let s:skel.head.l=[['list','t']]
  let s:skel.head.r=[['list','w'],['curr','p']]
  let s:skel.foot.l=[['mode'],['list','b'],['git'],['file']]
  let s:skel.foot.r=[]

endfu "}
fu! line#mode(...) "{

  if s:edgekind==0|return ''|endif
  let line = ''
  if     s:currmode=='i'
    let line.= '%#linemodei# insert '
  elseif s:currmode=~'\(v\|V\|\|s\|S\|\)'
    let line.= '%#linemodev# visual '
  elseif s:currmode=='R'
    let line.= '%#linemoder# replace'
  elseif s:currmode=~'\(c\|r\|!\)'
    let line.= '%#linemodec# cmdline'
  elseif s:currmode=='t'
    let line.= '%#linemodet#terminal'
  else
    let line.= '%#linemode# normal '
  endif

  return line

endfu "}
fu! line#curr(...) "{

  return 'curr'

endfu "}
fu! line#list(...) "{

  return 'list'

endfu "}
fu! line#seth(...) "{

  if hlexists('linemode')
    if !hlexists('linemodei')|hi def link linemodei linemode|endif
    if !hlexists('linemodev')|hi def link linemodev linemode|endif
    if !hlexists('linemodec')|hi def link linemodec linemode|endif
    if !hlexists('linemodet')|hi def link linemodet linemode|endif
    if !hlexists('linemoder')|hi def link linemoder linemode|endif
  endif
  
endfu "}
fu! line#save(...) "{

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

endfu "}
fu! line#time(...) "{

  if a:0
    if 1+g:line.timer
      call timer_stop(g:line.timer)
      let g:line.timer = -1
      let g:line.git   = ''
    endif
  else
    if s:gitinfo && g:line.timer==-1
      let g:line.timer = timer_start(s:delay,'line#giti',{'repeat':-1})
    endif
  endif

endfu "}
fu! line#giti(...) "{
  let info  = ''
  if s:gitinfo && executable('git')
    let branch   = trim(system('git rev-parse --abbrev-ref HEAD'))
    if empty(branch)|return ''|endif
    let modified = !empty(trim(system('git diff HEAD --shortstat')))
    let staged   = !empty(trim(system('git diff --no-ext-diff --cached --shortstat')))
    let cr = ''
    let char = ''
    let s = ' '
    if empty(matchstr(branch,'fatal: not a git repository'))
      let cr   = '%#linegitc#'
      if modified
        let cr    = '%#linegitm#'
        let char  = ' [M]'
      endif
      if staged
        let cr   = '%#linegits#'
        let char = ' [S]'
      endif
      let info = cr .'  ' . branch . char
    endif
  endif
  let g:line.git = info
endfu "}
fu! line#file(...) "{

  let name = '%#linefill#'
  if !empty(matchstr(bufname(),'term://.*'))
    let name.= 'terminal'
  endif
  if &filetype == 'help' && !filereadable('./'.bufname())
    let name.= resolve(expand("%:t"))
  else
    let file = resolve(expand("%"))
    if len(file)>25
      let file = fnamemodify(file,':t')
    endif
    let name.= file
  endif
  return name

endfu "}

"-- main functions --
fu! line#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')

  let s:activate  = get(g:,'line_activate',1)
  let s:verbose   = get(g:,'line_verbose' ,2)
  let s:projname  = get(g:,'line_projname',0)
  let s:gitinfo   = get(g:,'line_gitinfo',1)
  let s:delay     = get(g:,'line_gitdelay',20000)
  let limit       = s:delay>=2000
  let s:delay     = limit*s:delay+!limit*2000

  let s:edgekind  = get(g:,'line_edgekind',1)

  let g:line = {}
  let g:line.nvpm = 0
  let g:line.zoom = 0
  let g:line.mode = 0
  let g:line.timer= -1
  let g:line.git  = ''

  call line#save()
  call line#skel()
  call line#seth()

  let s:currmode = ''
  if s:activate
    hi clear TabLine
    hi clear StatusLine
    call line#show()
  endif

endfu "}
fu! line#head(...) "{

  let line = ''

  let s:currmode = mode()
  let line.= line#bone(s:skel.head.l)
  let line.= '%#linefill#%='
  let line.= line#bone(s:skel.head.r)

  return line

endfu "}
fu! line#foot(...) "{

  let line = ''

  let line.= line#bone(s:skel.foot.l)
  let line.= '%#linefill#%='
  let line.= line#bone(s:skel.foot.r)

  return line

endfu "}
fu! line#show(...) "{

  if !s:activate|return|endif
  if s:verbose>0
    call line#time()
  endif
  if g:line.nvpm
    set tabline=%!line#head()
    set statusline=%!line#foot()
    set showtabline=2
    let &laststatus=2+s:nvim*(1-g:line.zoom)
  else
    if s:verbose==0
      let &laststatus  = s:laststatus
      let &showtabline = s:showtabline
    endif
    if s:verbose>0
      set statusline=%!line#foot()
      let &laststatus=2+s:nvim*(1-g:line.zoom)
    endif
    if s:verbose>2
      set showtabline=2
    endif
  endif

  let g:line.mode = 1

endfu "}
fu! line#hide(...) "{

  if !s:activate|return|endif

  call line#save()

  set showtabline=0
  set laststatus=0

  call line#time(1)

  let g:line.mode = 0

endfu "}
fu! line#line(...) "{

  if g:line.mode
    call line#hide()
  else
    call line#show()
  endif

endfu "}

" vim: nowrap
