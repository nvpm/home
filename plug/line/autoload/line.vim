"-- auto/line.vim  --

if !NVPMTEST&&exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

fu! line#skel(...) abort "{

  if a:0==1
    if !exists('g:line_skeleton')
      let g:line_skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}
    endif
    return
  endif
  if a:0==0
    if type(s:skeleton)!=4 " dict type
      let s:skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}
      call add(s:skeleton.head.l,['list',2])
      call add(s:skeleton.head.r,['list',1])
      call add(s:skeleton.head.r,' ')
      call add(s:skeleton.head.r,['curr',0])
      call add(s:skeleton.feet.l,['list',3])
      call add(s:skeleton.feet.l,' ')
      call add(s:skeleton.feet.l,['git'])
      call add(s:skeleton.feet.l,' ')
      call add(s:skeleton.feet.l,['file'])
      call add(s:skeleton.feet.r,['user','%Y%m ● %l,%v/%p%%'])
      let s:headl = 1
      let s:headr = 1
      let s:feetl = 1
      let s:feetr = 1
    else
      let s:headl = exists('s:skeleton.head.l')
      let s:headr = exists('s:skeleton.head.r')
      let s:feetl = exists('s:skeleton.feet.l')
      let s:feetr = exists('s:skeleton.feet.r')
    endif
    return
  endif

endfu "}
fu! line#mode(...) abort "{

  if hlexists(a:1)
    return '%#'..a:1..'#'..a:2
  endif
  let mode = mode()

  if mode=='i'
    return '%#'..a:1..'Insert#'     .. a:2
  endif
  if mode=~'\(v\|V\|\|s\|S\|\)'
    return '%#'..a:1..'Visual#'     .. a:2
  endif
  if mode=='R'
    return '%#'..a:1..'Replace#'    .. a:2
  endif
  if mode=~'\(c\|r\|!\)'
    return '%#'..a:1..'Cmdline#'    .. a:2
  endif
  if mode=='t'
    return '%#'..a:1..'Terminal#'   .. a:2
  endif

  return '%#'..a:1..'Normal#'     .. a:2

endfu "}
fu! line#atom(...) abort "{

  let type = a:1
  let args = get(a:,2,'none')
  let revs = get(a:,3)

  if     type=='curr' "{
    let type = get(args,0,-1)
    let colr = get(args,1,'linecurr')
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
    if s:edgekind==2
      let edge = colr.'Edge'
      let left = line#mode(edge,'')
      let right= line#mode(edge,'')
      let name = line#mode(colr,name)
      let name = left..name..right
    else
      let name = '%#'.colr.'#'..name
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
    elseif type==3 "{
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
    elseif type==2 "{
    endif "}

    let list = line#list(list,indx,leng,revs,colr)
    if !empty(list)
      let line = join(list,'')
      if     s:edgekind==0
        let line = '%#linefill#'..line
      elseif s:edgekind==2
        if     leng==1      "{
          let left = line#mode('linecurredge','')
          let right= line#mode('linecurredge','')
        "}
        elseif indx==leng-1 "{
          if revs
            let left = line#mode('linecurredge','')
            let right= line#mode('lineinacedge','')
          else
            let left = line#mode('lineinacedge','')
            let right= line#mode('linecurredge','')
          endif
        "}
        elseif indx==0      "{
          if revs
            let left = line#mode('lineinacedge','')
            let right= line#mode('linecurredge','')
          else
            let left = line#mode('linecurredge','')
            let right= line#mode('lineinacedge','')
          endif
        "}
        else                "{
          let left = line#mode('lineinacedge','')
          let right= line#mode('lineinacedge','')
        endif "}
        let line = left..line..right
      endif
    endif

    return line

  "}
  elseif type=='file' "{
    let name = bufname()
    let hi   = get(args,0,'linefile')
    if name=~ '^term://.*'
      let char = ''
      let name = 'terminal'
    elseif name =~ $VIMRUNTIME..'/doc/'
      let char = ''
      let name = fnamemodify(name,':t')
    elseif &filetype == 'help'
      let char = ''
      let name = fnamemodify(name,':~')
    else
      let char = ''
      let name = fnamemodify(name,':~')
    endif
    let hi   = '%#'.hi.'#'
    let name = hi..char..' '..name
    if s:edgekind==2
      let name = '%#linefileedge#'..name..'%#linefileedge#'
    endif
    return name
  "}
  elseif type=='mode' "{
    return line#mode('linemode')
  "}
  elseif type=='user' "{
    let info = args
    if type(info)==3 " list type
      let info = get(info,0,'')
    endif
    if type(info)==1 " string type
      if s:edgekind==2
        let info = '%#LineUser#'..info
        let info = '%#LineUserEdge#'..info..'%#LineUserEdge#'
      endif
    else
      return ''
    endif
    return info
  "}
  endif

endfu "}
fu! line#bone(...) abort "{

  let revs = a:2
  let list = []

  for bone in a:1
    let type = type(bone)
    if     type==1 " string type
      let item = bone
    elseif type==3 " list type
      let func = bone[0]
      let args = bone[1:]
      if  func == 'git'
        let item = g:line.git
      else
        let item = line#atom(func,args,revs)
      endif
    endif
    call add(list,item)
  endfor
  return join(list,'')

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

"-- main functions --
fu! line#init(...) abort "{
  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')

  let s:verbose  = get(g:,'line_verbose' ,2)
  let s:gitinfo  = get(g:,'line_gitinfo',1)
  let s:delay    = get(g:,'line_gitdelay',20000)
  let s:edgekind = get(g:,'line_edgekind',1)
  let s:skeleton = get(g:,'line_skeleton')

  let g:line = {}
  let g:line.nvpm = 0
  let g:line.zoom = #{mode:0,left:0,right:0}
  let g:line.mode = 0
  let g:line.timer= -1
  let g:line.git = ''

  call line#save()
  call line#skel()

  if get(g:,'line_initload')
    hi clear TabLine
    hi clear StatusLine
    call line#show()
  endif
  if !get(g:,'line_keepuser')
    unlet! g:line_verbose
    unlet! g:line_gitinfo
    unlet! g:line_gitdelay
    unlet! g:line_edgekind
    unlet! g:line_skeleton
    unlet! g:line_initload
    unlet! g:line_keepuser
  endif

endfu "}
fu! line#head(...) abort "{

  let line = ''
  if s:headl
    if g:line.zoom.mode
      let line.= '%#Normal#'..repeat(' ',g:line.zoom.left)
    endif
    let line.= line#bone(s:skeleton.head.l,0)
  endif

  let line.= '%#linefill#%='

  if s:headr
    let line.= line#bone(s:skeleton.head.r,1)
    if g:line.zoom.mode
      let line.= '%#Normal#'..repeat(' ',g:line.zoom.right)
    endif
  endif

  let &tabline = line

endfu "}
fu! line#feet(...) abort "{

  let line = ''

  if s:feetl
    if g:line.zoom.mode && &laststatus==3
      let line.= '%#Normal#'..repeat(' ',g:line.zoom.left)
    endif
    let line.= line#bone(s:skeleton.feet.l,0)
  endif

  let line.= '%#linefill#%='

  if s:feetr
    let line.= line#bone(s:skeleton.feet.r,1)
    if g:line.zoom.mode && &laststatus==3
      let line.= '%#Normal#'..repeat(' ',g:line.zoom.right)
    endif
  endif

  let &statusline = line

endfu "}
fu! line#draw(...) abort "{
  if &showtabline|call line#head()|endif
  if &laststatus |call line#feet()|endif
endfu "}
fu! line#show(...) abort "{

  if s:verbose>0&&s:gitinfo&&line#find('git')
    "call line#giti()
    "call line#time()
  endif
  if g:line.nvpm
    set showtabline=2
    let &laststatus=2+s:nvim
  else
    if s:verbose==0
      let &laststatus  = s:laststatus
      let &showtabline = s:showtabline
    endif
    if s:verbose>0
      let &laststatus=2+s:nvim
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

"-- auxy functions --
fu! line#find(...) abort "{

  let name = a:1
  if s:feetl&&1+match(s:skeleton.feet.l,name)|return 1|endif
  if s:feetr&&1+match(s:skeleton.feet.r,name)|return 1|endif
  if s:headl&&1+match(s:skeleton.head.l,name)|return 1|endif
  if s:headr&&1+match(s:skeleton.head.r,name)|return 1|endif

endfu "}
fu! line#save(...) abort "{

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

endfu "}
fu! line#giti(...) abort "{

  let info  = ''
  "if s:gitinfo && executable('git')
  if executable('git')
    let gits = 'git diff --no-ext-diff --cached --shortstat'
    let gitm = 'git diff HEAD --shortstat'
    let gitb = 'git rev-parse --abbrev-ref HEAD'
    let branch = trim(system(gitb))
    if 1+match(branch,'^fatal:.*') "{
      let info = '%#LineGitm#gitless'
      if s:edgekind==2
        let info = '%#LineGitmEdge#'..info..'%#LineGitmEdge#'
      endif
    else
      let gits = !empty(trim(system(gits)))
      let gitm = !empty(trim(system(gitm)))
      let char = ''
      let colr = '%#LineGitc#'
      let edgel= ''
      let edger= ''
      if s:edgekind==2
        let edgel = '%#LineGitcEdge#'
        let edger = '%#LineGitcEdge#'
      endif
      if gits
          if s:edgekind==2
            let edgel = '%#LineGitsEdge#'
            let edger = '%#LineGitsEdge#'
          endif
          let colr = '%#LineGits#'
          "let char = '[S]'
      elseif gitm
          if s:edgekind==2
            let edgel = '%#LineGitmEdge#'
            let edger = '%#LineGitmEdge#'
          endif
          let colr = '%#LineGitm#'
          "let char = '[M]'
      endif
      let info = edgel..colr ..' '..branch .. char .. edger
    endif "}
  endif
  let g:line.git = info

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

if NVPMTEST
  fu! line#test(...) abort "{

    fu! s:OnEvent(job_id, data, event) dict
      if a:event == 'stdout'
        let str = ' stdout: '.join(a:data)
      else
        let str = 'hello'
      endif
      ec a:data
    endfu

    let gits = 'git diff --no-ext-diff --cached --shortstat'
    let gitm = 'git diff HEAD'
    let gitb = 'git rev-parse --abbrev-ref HEAD'
    let cmd  = '$(git diff)'
    call jobstart(cmd,{'on_exit':function('s:OnEvent')})

  endfu "}
endif
