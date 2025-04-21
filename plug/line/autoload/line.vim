"-- auto/line.vim  --

if !NVPMTEST&&exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

fu! line#skel(...) abort "{

  if a:0
    if !exists('g:line_skeleton')
      let g:line_skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}
    endif
  elseif empty(s:skeleton)
    let s:skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}
    call add(s:skeleton.head.l,['list','t'])
    call add(s:skeleton.head.r,['list','w'])
    call add(s:skeleton.head.r,' ')
    call add(s:skeleton.head.r,['curr','p'])
    call add(s:skeleton.feet.l,['list','b'])
    call add(s:skeleton.feet.l,['user',' '])
    call add(s:skeleton.feet.l,['git'])
    call add(s:skeleton.feet.l,' ')
    call add(s:skeleton.feet.l,['file'])
    call add(s:skeleton.feet.r,'%y%m  %l,%c/%P')
    let g:line_skeleton = s:skeleton
  endif

endfu "}
fu! line#bone(...) abort "{

  let revs = a:2
  let list = []

  for bone in a:1
    let type = type(bone)
    if     type==1 " string
      call add(list,bone)
    elseif type==3 " list
      let func = bone[0]
      let args = bone[1:]
      if  func == 'git'
        let item = s:giti
      else
        let item = line#atom(func,args,revs)
      endif
      call add(list,item)
    endif
  endfor
  return join(list,'')

endfu "}
fu! line#atom(...) abort "{
  let type = a:1
  let args = get(a:,2)
  let revs = get(a:,3)

  if     type=='curr' "{
    let type = get(args,0,-1)
    let colr = get(args,1,s:edgekind==2?'linecurr':'linefill')
    let name = ''

    if g:line.nvpm   "{
      let node = flux#seek(g:nvpm.tree.root,type)
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
    if s:edgekind==2
      let name = '%#linecurredge#'..name..'%#linecurredge#'
    endif
    return name
  "}
  elseif type=='list' "{

    let type = get(args,0,-1)
    let colr = get(args,1,'linecurr')
    let line = ''
    let list = []
    let leng = 0
    let indx = 0

    if g:line.nvpm   "{
      let node = flux#seek(g:nvpm.tree.root,type)
      if has_key(node,'meta')
        let indx = node.meta.indx
        let leng = node.meta.leng
        let list = node.list
      endif
    "}
    elseif type=='b' "{
      if s:verbose==1
        let list = [bufname()]
        let indx = 0
        let leng = 1
      elseif s:verbose>1
        let list = map(range(1,bufnr('$')),'bufname(v:val)')
        let list = filter(list,'!empty(v:val)&&buflisted(v:val)')
        let indx = match(list,bufname())
        let leng = len(list)
      endif
    "}
    elseif type=='t' "{
    endif "}

    let list = line#list(list,indx,leng,revs,colr)
    if !empty(list)
      let line = join(list,'')
      if     s:edgekind==0
        let line = '%#linefill#'..line
      elseif s:edgekind==2
        if indx==leng-1
          if revs
            let line = '%#linecurredge#'..line..'%#lineinacedge#'
          else
            let line = '%#lineinacedge#'..line..'%#linecurredge#'
          endif
        elseif indx==0
          if revs
            let line = '%#lineinacedge#'..line..'%#linecurredge#'
          else
            let line = '%#linecurredge#'..line..'%#lineinacedge#'
          endif
        else
          let line = '%#lineinacedge#'..line..'%#lineinacedge#'
        endif
      endif
    endif

    return line

  "}
  elseif type=='file' "{
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
      let hi   = get(args,0,'linefill')
      "let hi   = type(hi)!=type('') || empty(hi) ? 'linefill' : hi
      let hi   = '%#'.hi.'#'
      let char = ''
      let name = fnamemodify(name,':~')
    endif
    let name = hi..char..' '..name
    return name
  "}
  elseif type=='mode' "{
    return line#mode('linemode')
  "}
  elseif type=='user' "{
    return ''
  "}
  endif

endfu "}
fu! line#mode(...) abort "{

  let name = a:1
  let mode = mode()
  let line = ''
  if     mode=='i'
    let line.= '%#'..name..'i#'..(a:0==1?'insert':a:2)
  elseif mode=~'\(v\|V\|\|s\|S\|\)'
    let line.= '%#'..name..'v#'..(a:0==1?'visual':a:2)
  elseif mode=='R'
    let line.= '%#'..name..'r#'..(a:0==1?'replace':a:2)
  elseif mode=~'\(c\|r\|!\)'
    let line.= '%#'..name..'c#'..(a:0==1?'cmdline':a:2)
  elseif mode=='t'
    let line.= '%#'..name..'t#'..(a:0==1?'terminal':a:2)
  else
    let line.= '%#'..name..'#' ..(a:0==1?'normal':a:2)
  endif

  return line

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
    if     s:edgekind==0 "{
      if indx==curr&&leng>1
        let elem.= '['..info..']'
      elseif leng==1
        let elem.= info
      else
        let elem.= ' '..info..' '
      endif
    "}
    elseif s:edgekind==1 "{
      let info = ' '..info..' '
      if indx==curr
        if colr=='linecurr'
          let elem.= line#mode(colr,info)
        else
          let elem.= '%#'.colr.'#'.info
        endif
      else
        let elem.= line#mode('lineinac',info)
      endif
    "}
    elseif s:edgekind==2 "{
      let info = ' '..info..' '
      if indx==curr
        if colr=='linecurr'
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
fu! line#giti(...) abort "{

  let info  = ''
  if s:gitinfo && executable('git')
    let branch = trim(system(s:gitb))
    if 1+match(branch,'^fatal:.*') "{
      let info = '%#LineGitl#gitless'
      if s:edgekind==2
        let info = '%#LineGitlEdge#'..info..'%#LineGitlEdge#'
      endif
    else
      let char = ''
      let colr = '%#linegitc#'
      let edgel= ''
      let edger= ''
      if !empty(trim(system(s:gitm)))
        if s:edgekind==2
          let edgel = '%#linegitmedge#'
          let edger = '%#linegitmedge#'
        endif
        let colr = '%#linegitm#'
        let char = '[M]'
      elseif !empty(trim(system(s:gits)))
        if s:edgekind==2
          let edgel = '%#linegitsedge#'
          let edger = '%#linegitsedge#'
        endif
        let colr = '%#linegits#'
        let char = '[S]'
      endif
      let info = edgel..colr ..' '..branch .. char .. edger
    endif "}
  endif
  let s:giti = info

endfu "}

"-- main functions --
fu! line#init(...) abort "{
  if exists('s:init')|return|else|let s:init=1|endif

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

  let s:giti = ''
  let s:gits = 'git diff --no-ext-diff --cached --shortstat'
  let s:gitm = 'git diff HEAD --shortstat'
  let s:gitb = 'git rev-parse --abbrev-ref HEAD'

  call line#save()
  call line#seth()
  call line#skel()

  if get(g:,'line_initload')
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
fu! line#feet(...) abort "{

  let line = ''
  let line.= line#bone(s:skeleton.feet.l,0)
  let line.= '%#linefill#%='
  let line.= line#bone(s:skeleton.feet.r,1)

  let &statusline = line

endfu "}
fu! line#draw(...) abort "{
  if &showtabline|call line#head()|endif
  if &laststatus |call line#feet()|endif
endfu "}
fu! line#show(...) abort "{

  if s:verbose>0&&s:gitinfo&&line#find('git')
    call line#giti()
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
fu! line#find(...) abort "{

  let name = a:1
  if 1+match(s:skeleton.feet.l,name)|return 1|endif
  if 1+match(s:skeleton.feet.r,name)|return 1|endif
  if 1+match(s:skeleton.head.l,name)|return 1|endif
  if 1+match(s:skeleton.head.r,name)|return 1|endif

endfu "}

"-- auxy functions --
fu! line#seth(...) abort "{

  if s:edgekind==0|return|endif

  if !hlexists('lineinac')|hi def link lineinac normal|endif
  if !hlexists('linecurr')
    hi def link linecurr  error
    hi def link linecurri error
    hi def link linecurrv error
    hi def link linecurrr error
    hi def link linecurrc error
    hi def link linecurrt error
  endif
  if !hlexists('linegits')|hi def link linegits visual    |endif
  if !hlexists('linegitm')|hi def link linegitm warningmsg|endif
  if !hlexists('linegitc')|hi def link linegitc normal    |endif

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
      let s:giti   = ''
    endif
  else
    if s:gitinfo && g:line.timer==-1
      let g:line.timer = timer_start(s:delay,'line#giti',{'repeat':-1})
    endif
  endif

endfu "}

