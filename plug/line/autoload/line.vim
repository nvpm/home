"-- auto/line.vim  --

if !NVPMTEST&&exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

fu! line#bone(...) abort "{

  let bones= a:1
  let revs = a:2
  let list = []

  for bone in bones
    if type(bone)==type([])&&!empty(bone)
      let func = bone[0]
      let item = ''
      if func =~ '\(file\|user\|pack\|curr\)'
        let item = line#{func}(bone[1:],revs)
      elseif func == 'git'
        let item = g:line.git
      endif
      if !empty(item)|call add(list,item)|endif
    endif
  endfor
  return join(list,'')

endfu "}
fu! line#pack(...) abort "{

  let type = get(a:1,0)
  let colr = get(a:1,1)
  let colr = type(colr)==type('')&&!empty(colr) ? colr : 'linecurr'
  let revs = a:2
  let list = []

  if g:line.nvpm "{
    let node = flux#seek(g:nvpm.tree.root,match(['p','w','t','b'],type))
    if has_key(node,'meta')
      let list = line#list(node.list,node.meta.indx,node.meta.leng,revs,colr)
    endif
  "}
  elseif type=='b' "{
    if s:verbose==1
      let list = [bufname()]
      let curr = 0
      let leng = 1
    elseif s:verbose>1
      let list = map(range(1,bufnr('$')),'bufname(v:val)')
      let list = filter(list,'!empty(v:val)&&buflisted(v:val)')
      let curr = match(list,bufname())
      let leng = len(list)
    endif
    let list = line#list(list,curr,leng,revs,colr)
  endif "}
  let line = join(list,'')
  if s:edgekind==0&&!empty(line)
    let line = '%#linefill#'..line
  endif

  return line

endfu "}
fu! line#curr(...) abort "{

  let type = get(a:1,0)
  let colr = get(a:1,1)
  let colr = type(colr)==type('')&&!empty(colr) ? colr : 'linefill'
  let revs = a:2
  let name = ''

  if g:line.nvpm   "{
    let node = flux#seek(g:nvpm.tree.root,match(['p','w','t','b'],type))
    if has_key(node,'meta')
      let name = node.list[node.meta.indx].data.name
      if (empty(name)||name=='<unnamed>')&&type==0
        let name = fnamemodify(g:nvpm.tree.file,':t')
      endif
    endif
  "}
  elseif type=='b' "{
    let name = expand('%:t')
  endif "}
  if empty(name)|return ''|endif
  let name = '%#'.colr.'#'..name
  return name

endfu "}
fu! line#list(...) abort "{

  let curr = a:2
  let leng = a:3
  let revs = a:4
  let colr = a:5
  let list = []

  for indx in range(leng)
    let item = a:1[indx]
    let info = g:line.nvpm?eval('item.data.name'):fnamemodify(item,':t:r')
    let iscurr = indx==curr
    let elem = ''
    if s:edgekind==0 " brackets  config{
      if indx==curr&&leng>1
        let elem.= '['..info..']'
      else
        let elem.= ' '..info..' '
      endif
    endif "}
    if s:edgekind==1 " highlight config{
      let info = ' '..info..' '
      if indx==curr
        if colr=='linecurr' " include check for hi linecurr exists
          let elem.= line#mode(colr,info)
        else
          let elem.= '%#'.colr.'#'.info
        endif
      else
        let elem.= line#mode('lineinac',info)
      endif
    endif "}
    call add(list,elem)
  endfor

  return revs?reverse(list):list

endfu "}
fu! line#mode(...) abort "{

  let name = a:1
  let mode = mode()
  let line = ''
  if     mode=='i'
    let line.= '%#'..name..'i#'..(a:0==1?' insert ':a:2)
  elseif mode=~'\(v\|V\|\|s\|S\|\)'
    let line.= '%#'..name..'v#'..(a:0==1?' visual ':a:2)
  elseif mode=='R'
    let line.= '%#'..name..'r#'..(a:0==1?' replace ':a:2)
  elseif mode=~'\(c\|r\|!\)'
    let line.= '%#'..name..'c#'..(a:0==1?' cmdline ':a:2)
  elseif mode=='t'
    let line.= '%#'..name..'t#'..(a:0==1?' terminal ':a:2)
  else
    let line.= '%#'..name..'#' ..(a:0==1?' normal ':a:2)
  endif

  return line

endfu "}

"-- main functions --
fu! line#init(...) abort "{
  if exists('s:init')|return|else|let s:init=1|endif

  let s:activate = get(g:,'line_activate',1)
  let s:verbose  = get(g:,'line_verbose' ,2)
  let s:gitinfo  = get(g:,'line_gitinfo',1)
  let s:delay    = get(g:,'line_gitdelay',20000)
  let s:edgekind = get(g:,'line_edgekind',1)
  let s:floating = get(g:,'line_floating',0)
  let s:skeleton = get(g:,'line_skeleton',{})

  let g:line = {}
  let g:line.nvpm = 0
  let g:line.zoom = #{mode:0,left:0,right:0}
  let g:line.mode = 0
  let g:line.timer= -1
  let g:line.git  = ''

  call line#save()
  call line#seth()
  call line#skel()

  if s:activate
    hi clear TabLine
    hi clear StatusLine
    call line#show()
  endif

endfu "}
fu! line#head(...) abort "{

  let line = ''
  if g:line.zoom.mode
    let line.= '%#Normal#'..repeat(' ',g:line.zoom.left)
  endif
  let line.= line#bone(s:skeleton.head.l,0)
  let line.= '%#linefill#%='
  let line.= line#bone(s:skeleton.head.r,1)
  if g:line.zoom.mode
    let line.= '%#Normal#'..repeat(' ',g:line.zoom.right)
  endif

  let &tabline = line

endfu "}
fu! line#foot(...) abort "{

  let line = ''
  let line.= line#bone(s:skeleton.foot.l,0)
  let line.= '%#linefill#%='
  let line.= line#bone(s:skeleton.foot.r,1)

  let &statusline = line

endfu "}
fu! line#draw(...) abort "{
  if &showtabline|call line#head()|endif
  if &laststatus |call line#foot()|endif
endfu "}
fu! line#show(...) abort "{

  if !s:activate|return|endif
  if s:verbose>0&&s:gitinfo
    call line#time()
  endif
  if g:line.nvpm
    set showtabline=2
    let &laststatus=2
  else
    if s:verbose==0
      let &laststatus  = s:laststatus
      let &showtabline = s:showtabline
    endif
    if s:verbose>0
      let &laststatus=2
    endif
    if s:verbose>2
      set showtabline=2
    endif
  endif

  let g:line.mode = 1

endfu "}
fu! line#hide(...) abort "{

  if !s:activate|return|endif

  call line#save()

  set showtabline=0
  set laststatus=0

  call line#time(1)

  let g:line.mode = 0

endfu "}
fu! line#line(...) abort "{

  if g:line.mode
    call line#hide()
  else
    call line#show()
    call line#draw()
  endif

endfu "}

"-- auxy functions --
fu! line#seth(...) abort "{

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
fu! line#save(...) abort "{

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

endfu "}
fu! line#time(...) abort "{

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
fu! line#user(...) abort "{

  let body = get(a:1,0,'')
  let colr = get(a:1,1)
  let colr = type(colr)!=type('') || empty(colr) ? 'linefill' : colr 
  let colr = '%#'.colr.'#'
  return colr..body

endfu "}
fu! line#file(...) abort "{

  let name = bufname()
  if name=~ '^term://.*'
    let hi   = '%#Title#'
    let char = ''
    let name = 'terminal'
  elseif name =~ $VIMRUNTIME..'/doc/'
    let hi   = '%#Title#'
    let char = ''
    let name = fnamemodify(name,':t')
  elseif &filetype == 'help'
    let hi   = '%#Title#'
    let char = ''
    let name = fnamemodify(name,':~')
  else
    let hi   = get(a:1,0,'linefill')
    let hi   = type(hi)!=type('') || empty(hi) ? 'linefill' : hi 
    let hi   = '%#'.hi.'#'
    let char = ''
    let name = fnamemodify(name,':~')
  endif
  let name = hi..char..' '..name
  return name

endfu "}
fu! line#giti(...) abort "{
  let info  = ''
  if s:gitinfo && executable('git')
    let branch   = trim(system('git rev-parse --abbrev-ref HEAD'))
    if empty(branch)|let g:line.git = ''|return ''|endif
    let modified = !empty(trim(system('git diff HEAD --shortstat')))
    let staged   = !empty(trim(system('git diff --no-ext-diff --cached --shortstat')))
    let cr = ''
    let char = ''
    if empty(matchstr(branch,'fatal: not a git repository'))
      let cr   = '%#linegitc#'
      if modified
        let cr    = '%#linegitm#'
        let char  = '[M]'
      endif
      if staged
        let cr   = '%#linegits#'
        let char = '[S]'
      endif
      let info = cr .' '.branch . char
    endif
  endif
  let g:line.git = info
endfu "}
fu! line#skel(...) abort "{

  if empty(s:skeleton)
    let s:skeleton = #{head:{},foot:{}}
    let s:skeleton.head.l=[['pack','t']]
    let s:skeleton.head.r=[['pack','w'],['curr','p']]
    let s:skeleton.foot.l=[['pack','b'],['git'],['file']]
    let s:skeleton.foot.r=[['user','%Y%m ⬤ %l,%c/%P']]
  endif

endfu "}

