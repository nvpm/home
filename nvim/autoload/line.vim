"-- auto/line.vim  --

if exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

"-- auxy functions --
fu! line#bone(...) "{

  let line = ''
  for bone in a:1
    if     bone[0]=='info'  "{
      let line.= 'info'
    "}
    elseif bone[0]=='curr'  "{
      let line.= 'curr'
    "}
    elseif bone[0]=='list'  "{
      let line.= 'list'
    endif "}
  endfor
  return line

endfu "}
fu! line#skel(...) "{

  let s:skel = #{head:{},foot:{}}
  let s:skel.head.l=[['list','t']]
  let s:skel.head.r=[['list','w'],['curr','p']]
  let s:skel.foot.l=[['info','mode'],['list','b'],['info','git'],['info','fn']]
  let s:skel.foot.r=[['info','ft'],['info','lc']]

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

  call line#save()
  call line#skel()

  if s:activate
    hi clear TabLine
    hi clear StatusLine
    call line#show()
  endif

endfu "}
fu! line#head(...) "{

  let line = ''

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
    "call line#time()
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

  "call line#time(1)

  let g:line.mode = 0

endfu "}
fu! line#line(...) "{

  if g:line.mode
    call line#hide()
  else
    call line#show()
  endif

endfu "}
fu! line#save(...) "{

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

endfu "}

" vim: nowrap
