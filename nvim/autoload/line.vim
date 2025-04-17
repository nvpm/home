"-- auto/line.vim  --

if exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

fu! line#pack(...) "{

  let type = match(['p','w','t','b'],a:1)
  let revs = a:2
  let line = ''

  if g:line.nvpm
    let node = flux#seek(g:nvpm.tree.root,type)
    if has_key(node,'meta')
      let list = line#list(node.list,node.meta.indx,node.meta.leng,revs)
      let line = join(list,'')
    endif
  else
  endif
  if s:edgekind==0
    let line = '%#linefill#'..line
  endif

  return line

endfu "}
fu! line#list(...) "{

  let curr = a:2
  let leng = a:3
  let revs = a:4
  let list = []

  for indx in range(leng) "loop over given list {
    let item = a:1[indx]
    let info = g:line.nvpm?eval('item.data.name'):fnamemodify(item,':t')
    let iscurr = indx==curr
    let elem = ''
    if s:edgekind==0 " brackets  config{
      if indx==curr
        let elem.= '['..info..']'
      else
        let elem.= ' '..info..' '
      endif
    endif "}
    if s:edgekind==1 " highlight config{
      if indx==curr
        let elem.= line#mode('curr',' '..info..' ')
      else
        let elem.= line#mode('inac',' '..info..' ')
      endif
    endif "}
    call add(list,elem)
  endfor "}

  return revs?reverse(list):list

endfu "}
fu! line#curr(...) "{

  return 'curr'

endfu "}
fu! line#bone(...) "{

  let list = []
  for bone in a:1
    if type(bone)==type([])
      let item = ''
      if bone[0]=~'\(git\|branch\)'
        let item = g:line.git
      elseif bone[0]=='file'
        let item = line#file()
      elseif bone[0]=='mode'
        let item = line#mode('mode')
      elseif bone[0]=~'\(pack\|curr\)'
        let item = line#{bone[0]}(get(bone,1),a:2)
      endif
      if !empty(item)|call add(list,item)|endif
    endif
  endfor
  return join(list,s:innerspace)

endfu "}
fu! line#skel(...) "{

  let s:skel = #{head:{},foot:{}}
  let s:skel.head.l=[['pack','t']]
  let s:skel.head.r=[['pack','w'],['curr','p']]
  let s:skel.foot.l=[['pack','b'],['git'],['file']]
  let s:skel.foot.r=[]

endfu "}
fu! line#mode(...) "{

  let name = a:1
  let mode = mode()
  let line = ''
  if     mode=='i'
    let line.= '%#line'..name..'i#'..(a:0==1?'insert':a:2)
  elseif mode=~'\(v\|V\|\|s\|S\|\)'
    let line.= '%#line'..name..'v#'..(a:0==1?'visual':a:2)
  elseif mode=='R'
    let line.= '%#line'..name..'r#'..(a:0==1?'replace':a:2)
  elseif mode=~'\(c\|r\|!\)'
    let line.= '%#line'..name..'c#'..(a:0==1?'cmdline':a:2)
  elseif mode=='t'
    let line.= '%#line'..name..'t#'..(a:0==1?'terminal':a:2)
  else
    let line.= '%#line'..name..'#' ..(a:0==1?'normal':a:2)
  endif

  return line

endfu "}

"-- main functions --
fu! line#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')

  let s:activate = get(g:,'line_activate',1)
  let s:verbose  = get(g:,'line_verbose' ,2)
  let s:projname = get(g:,'line_projname',0)
  let s:gitinfo  = get(g:,'line_gitinfo',1)
  let s:delay    = get(g:,'line_gitdelay',20000)
  let s:edgekind = get(g:,'line_edgekind',1)
  let s:floating = get(g:,'line_floating',0)

  let g:line = {}
  let g:line.nvpm = 0
  let g:line.zoom = 0
  let g:line.mode = 0
  let g:line.timer= -1
  let g:line.git  = ''

  let s:innerspace = s:edgekind<2?'%#linefill# ':''

  call line#save()
  call line#skel()
  call line#seth()

  if s:activate
    hi clear TabLine
    hi clear StatusLine
    call line#show()
  endif

endfu "}
fu! line#head(...) "{

  let line = ''

  let line.= line#bone(s:skel.head.l,0)
  let line.= '%#linefill#%='
  let line.= line#bone(s:skel.head.r,1)

  return line

endfu "}
fu! line#foot(...) "{

  let line = ''

  let line.= line#bone(s:skel.foot.l,0)
  let line.= '%#linefill#%='
  let line.= line#bone(s:skel.foot.r,1)

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
    "set tabline=%{%line#head()%}
    "set statusline=%{%line#foot()%}
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

"-- auxy functions --
fu! line#seth(...) "{

  if    hlexists('linemode')
    if !hlexists('linemodei')|hi def link linemodei linemode|endif
    if !hlexists('linemodev')|hi def link linemodev linemode|endif
    if !hlexists('linemodec')|hi def link linemodec linemode|endif
    if !hlexists('linemodet')|hi def link linemodet linemode|endif
    if !hlexists('linemoder')|hi def link linemoder linemode|endif
  endif
  if    hlexists('linecurr')
    if !hlexists('linecurri')|hi def link linecurri linecurr|endif
    if !hlexists('linecurrv')|hi def link linecurrv linecurr|endif
    if !hlexists('linecurrc')|hi def link linecurrc linecurr|endif
    if !hlexists('linecurrt')|hi def link linecurrt linecurr|endif
    if !hlexists('linecurrr')|hi def link linecurrr linecurr|endif
  endif
  if    hlexists('lineinac')
    if !hlexists('lineinaci')|hi def link lineinaci lineinac|endif
    if !hlexists('lineinacv')|hi def link lineinacv lineinac|endif
    if !hlexists('lineinacc')|hi def link lineinacc lineinac|endif
    if !hlexists('lineinact')|hi def link lineinact lineinac|endif
    if !hlexists('lineinacr')|hi def link lineinacr lineinac|endif
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
      let info = cr .' ' . branch . char
    endif
  endif
  let g:line.git = info
endfu "}
fu! line#file(...) "{

  if !empty(matchstr(bufname(),'term://.*'))
    let name = 'terminal'
  elseif &filetype == 'help' && !filereadable('./'.bufname())
    let name = 'help: '..resolve(expand("%:t"))
  else
    let name = resolve(expand("%"))
  endif
  return '%#linefill#'..name

endfu "}

" vim: nowrap
