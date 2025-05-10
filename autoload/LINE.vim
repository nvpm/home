"-- auto/line.vim  --
if !exists('NVPMTEST')&&exists('_LINEAUTO_')|finish|endif
let _LINEAUTO_ = 1
let s:nvim = has('nvim')
let s:vim  = !s:nvim

fu! line#init(...) abort "{

  let s:initload = get(g: , 'line_initload' ,  0  )
  let s:showmode = get(g: , 'line_showmode' ,  2  )
  let s:bonetype = get(g: , 'line_bonetype' ,  1  )
  let s:skeleton = get(g: , 'line_skeleton' ,  0  )
  let s:gitimode = get(g: , 'line_gitimode' ,  2  )
  let s:gitdelay = get(g: , 'line_gitdelay' , &ut )
  let s:curredge = get(g: , 'line_curredge' , '[,]' )
  let s:inacedge = get(g: , 'line_inacedge' , ' , ' )
  let s:boneedge = get(g: , 'line_boneedge' , ',' )

  let s:curredge = split(s:curredge,',',1)
  let s:inacedge = split(s:inacedge,',',1)
  let s:boneedge = split(s:boneedge,',',1)

  let g:line = {}
  let g:line.mode = 1
  let g:line.arbo = get(g:,'arbo_initload')
  let g:line.arbo = g:line.arbo&&exists('g:arbo.tree.mode')&&g:arbo.tree.mode
  let g:line.zoom = 0

  call line#save()
  call line#skel()

  let s:gitimode = (executable('git')&&line#find('git'))*s:gitimode

  call line#zero()


  let s:modeinfo          = {}
  let s:modeinfo.normal   = 'normal'
  let s:modeinfo.insert   = 'insert'
  let s:modeinfo.visual   = 'visual'
  let s:modeinfo.replace  = 'replace'
  let s:modeinfo.cmdline  = 'cmdline'
  let s:modeinfo.terminal = 'terminal'

  if s:initload
    call line#show()
  endif
  if !get(g:,'line_keepuser')
    unlet! g:line_initload
    unlet! g:line_showmode
    unlet! g:line_bonetype
    unlet! g:line_skeleton
    unlet! g:line_gitimode
    unlet! g:line_gitdelay
    unlet! g:line_curredge
    unlet! g:line_inacedge
    unlet! g:line_boneedge
    unlet! g:line_keepuser
  endif

endfu "}
fu! line#mode(...) abort "{

  let mode = mode()
  if mode=='i'
    let default = a:0==1
    let colr = a:1
    let colr.= hlexists(a:1) ? '' : 'Insert'
    let info = '%#'..colr..'#'..(default? s:modeinfo.insert : a:2)
    if s:bonetype==2&&default
      let edge = '%#'..colr..'Edge#'
      let left = edge..s:boneedge[0]
      let right= edge..s:boneedge[1]
      let info = left..info..right
      ec info
    endif
    return info
  elseif mode=~'\(v\|V\|\|s\|S\|\)'
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Visual'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : s:modeinfo.visual)
  elseif mode=='R'
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Replace'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : s:modeinfo.replace)
  elseif mode=~'\(c\|r\|!\)'
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Cmdline'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : s:modeinfo.cmdline)
  elseif mode=='t'
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Terminal'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : s:modeinfo.terminal)
  else
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Normal'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : s:modeinfo.normal)
  endif

  "return
  "
  "if hlexists(a:1)
  "  return '%#'..a:1..'#'..a:2
  "endif
  "let mode = mode()
  "
  "if mode=='i'
  "  return '%#'..a:1..'Insert#'     .. a:2
  "endif
  "if mode=~'\(v\|V\|\|s\|S\|\)'
  "  return '%#'..a:1..'Visual#'     .. a:2
  "endif
  "if mode=='R'
  "  return '%#'..a:1..'Replace#'    .. a:2
  "endif
  "if mode=~'\(c\|r\|!\)'
  "  return '%#'..a:1..'Cmdline#'    .. a:2
  "endif
  "if mode=='t'
  "  return '%#'..a:1..'Terminal#'   .. a:2
  "endif
  "
  "return '%#'..a:1..'Normal#'     .. a:2

endfu "}
fu! line#pack(...) abort "{

  let list = a:1
  let curr = a:2
  let leng = a:3
  let revs = a:4
  let colr = a:5
  let pack = []

  for indx in range(leng)
    let item = list[indx]
    let info = g:line.arbo?eval('item.data.name'):fnamemodify(item,':t:r')
    let iscurr = indx==curr
    if indx==curr
      let info = s:curredge[0]..info..s:curredge[1]
      let elem = line#mode(colr,info)
    else
      let info = s:inacedge[0]..info..s:inacedge[1]
      let elem = line#mode('LineInac',info)
    endif
    call add(pack,elem)
  endfor

  return revs?reverse(pack):pack

endfu "}
fu! line#atom(...) abort "{

  if a:0!=3|return ''|endif

  let func = a:1
  let args = a:2
  let revs = a:3

  if     func=='curr' "{
    let type = get(args,0,-1)
    let colr = get(args,1,'LineCurr')
    let name = ''

    if g:line.arbo   "{
      let node = flux#seek(g:arbo.tree.root,type)
      if has_key(node,'meta')
        let name = node.list[node.meta.indx].data.name
        if (empty(name)||name=='<unnamed>')&&type==0
          let name = fnamemodify(g:arbo.tree.file,':t')
        endif
      endif
    "}
    elseif type=='b' "{
      let name = expand('%:t')
    endif "}

    if empty(name)|return ''|endif
    let name = line#mode(colr,name)
    if s:bonetype==2
      let edge = colr.'Edge'
      let left = line#mode(edge,s:boneedge[0])
      let right= line#mode(edge,s:boneedge[1])
      let name = left..name..right
    endif
    return name
  "}
  elseif func=='list' "{

    let type = get(args,0,-1)
    let colr = get(args,1,'LineCurr')
    let line = ''
    let list = []
    let leng = 0
    let indx = 0

    if g:line.arbo   "{
      let node = flux#seek(g:arbo.tree.root,type)
      if has_key(node,'meta')
        let indx = node.meta.indx
        let leng = node.meta.leng
        let list = node.list
      endif
    "}
    elseif type==3 "{
      if s:showmode==1
        let list = [bufname()]
        let indx = 0
        let leng = 1
      elseif s:showmode>1
        let list = map(range(1,bufnr('$')),'bufname(v:val)')
        let list = filter(list,'!empty(v:val)&&buflisted(v:val)')
        let indx = match(list,bufname())
        let leng = len(list)
      endif
    "}
    elseif type==2 "{
    endif "}

    let list = line#pack(list,indx,leng,revs,colr)
    if !empty(list)
      let line = join(list,'')
      if s:bonetype==2
        if     leng==1      "{
          let left = line#mode('LineCurrEdge',s:boneedge[0])
          let right= line#mode('LineCurrEdge',s:boneedge[1])
        "}
        elseif indx==leng-1 "{
          if revs
            let left = line#mode('LineCurrEdge',s:boneedge[0])
            let right= line#mode('LineInacEdge',s:boneedge[1])
          else
            let left = line#mode('LineInacEdge',s:boneedge[0])
            let right= line#mode('LineCurrEdge',s:boneedge[1])
          endif
        "}
        elseif indx==0      "{
          if revs
            let left = line#mode('LineInacEdge',s:boneedge[0])
            let right= line#mode('LineCurrEdge',s:boneedge[1])
          else
            let left = line#mode('LineCurrEdge',s:boneedge[0])
            let right= line#mode('LineInacEdge',s:boneedge[1])
          endif
        "}
        else                "{
          let left = line#mode('LineInacEdge',s:boneedge[0])
          let right= line#mode('LineInacEdge',s:boneedge[1])
        endif "}
        let line = left..line..right
      endif
    endif

    return line

  "}
  elseif func=='file' "{
    let name = bufname()
    let hi   = get(args,0,'LineFile')
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
    if s:bonetype==2
      let edge = '%#LineFileEdge#'
      let name = edge..s:boneedge[0]..name..edge..s:boneedge[1]
    endif
    return name
  "}
  elseif func=='mode' "{
    let mode = line#mode('LineMode')
    return mode
  "}
  elseif func=='user' "{
    if empty(args)|return ''|endif
    let info = '%#LineUser#'..get(args,0,'')
    if s:bonetype==2
      let edge = '%#LineUserEdge#'
      let info = edge..s:boneedge[0]..info..edge..s:boneedge[1]
    endif
    return info
  "}
  endif

endfu "}
fu! line#bone(...) abort "{

  let skel = ''
  for bone in a:1
    if     type(bone)==1 " string type
      let skel.= bone
    elseif type(bone)==3 " list type
      let func = bone[0]
      if func=='git'&&s:gitimode
        let skel.= g:line.git.bone
      else
        let skel.= line#atom(func,bone[1:],a:2)
      endif
    endif
    let skel.= '%#LineFill#'
  endfor
  return skel

endfu "}
fu! line#skel(...) abort "{

  if a:0
    if !exists('g:line_skeleton')
      let g:line_skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}
    endif
  elseif type(s:skeleton)!=4 " dict type
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

endfu "}

"-- main functions --
fu! line#head(...) abort "{

  let line = ''
  if s:headl
    if g:line.zoom
      let line.= '%#Normal#'..repeat(' ',g:zoom.size.l)
    endif
    let line.= line#bone(s:skeleton.head.l,0)
  endif

  let line.= '%='

  if s:headr
    let line.= line#bone(s:skeleton.head.r,1)
    if g:line.zoom
      let line.= '%#Normal#'..repeat(' ',g:zoom.size.r)
    endif
  endif

  if &showtabline
    let &tabline = line
  endif

endfu "}
fu! line#feet(...) abort "{

  let line = ''

  if s:feetl
    if g:line.zoom && &laststatus==3
      let line.= '%#Normal#'..repeat(' ',g:zoom.size.l)
    endif
    let line.= line#bone(s:skeleton.feet.l,0)
  endif

  let line.= '%='

  if s:feetr
    let line.= line#bone(s:skeleton.feet.r,1)
    if g:line.zoom && &laststatus==3
      let line.= '%#Normal#'..repeat(' ',g:zoom.size.r)
    endif
  endif

  if &laststatus
    let &statusline = line
  endif

endfu "}
fu! line#draw(...) abort "{
  if !g:line.mode|return|endif
  call line#head()
  call line#feet()
endfu "}
fu! line#show(...) abort "{

  call line#giti()

  if g:line.arbo
    set showtabline=2
    let &laststatus=2+s:nvim
  else
    if s:showmode==0
      let &laststatus  = s:laststatus
      let &showtabline = s:showtabline
    endif
    if s:showmode>0
      let &laststatus=2+s:nvim
    endif
    if s:showmode>2
      set showtabline=2
    endif
  endif

  let g:line.mode = 1

  augroup LINE
    au!
    au BufEnter,ModeChanged,BufDelete * call line#draw()
    au VimLeavePre * call line#stop()
  augroup END

endfu "}
fu! line#hide(...) abort "{

  call line#save()

  set showtabline=0
  set laststatus=0
  set statusline=
  set tabline=

  let g:line.mode = 0
  call line#stop()

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
fu! line#save(...) abort "{

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

endfu "}
fu! line#find(...) abort "{

  let name = a:1
  if s:feetl&&1+match(s:skeleton.feet.l,name)|return 1|endif
  if s:feetr&&1+match(s:skeleton.feet.r,name)|return 1|endif
  if s:headl&&1+match(s:skeleton.head.l,name)|return 1|endif
  if s:headr&&1+match(s:skeleton.head.r,name)|return 1|endif

endfu "}
fu! line#zero(...) abort "{

  let g:line.git = #{}
  let g:line.git.bone = ''
  if s:gitimode==1
    let g:line.git.timer = 0
  elseif s:gitimode > 1
    let g:line.git.job = 0
  endif

endfu "}
fu! line#data(...) abort "{

  if type(a:2)==1 " string in vim
    let data = a:2
  elseif type(a:2)==3 " list in neovim
    let data = join(a:2)
  else
    return
  endif
  if !empty(data)
    let data = split(data,',',1)
    let g:line.git.branch   = empty(data[0])?'gitless':data[0]
    let g:line.git.modified = data[1]+0
    let g:line.git.staged   = data[2]+0
    call line#gitb()
    call line#draw()
  endif

endfu "}
fu! line#giti(...) abort "{

  if !s:gitimode|return|endif

  if s:gitimode==1 " timer  {
    if !g:line.git.timer
      let s:gitdelay = s:gitdelay<500?500:s:gitdelay
      let g:line.git.timer=timer_start(s:gitdelay,'line#gitb',{'repeat':-1})
    endif
    return
  endif "end-timer}
  if s:gitimode==2 " job    {
    if !exists('s:bash' ) "{
      let s:gitdelay = s:gitdelay/1000.0
      let step    = 0.25*s:gitdelay
      let s:gitdelay-= 2*step
      let gits = 'git diff --no-ext-diff --cached --shortstat'
      let gitm = 'git diff --shortstat'
      let gitb = 'git rev-parse --abbrev-ref HEAD'
      let loop = ''
      let loop.= 'while true;do '
      let loop.= 'b=$('.gitb.');m=0;s=0;'
      let loop.= '!test "$b"&&b=;'
      let loop.= 'sleep '. step .';'
      let loop.= 'test "$('.gitm.')"&&m=1;'
      let loop.= 'sleep '. step .';'
      let loop.= 'test "$('.gits.')"&&s=1;'
      let loop.= 'echo $b,$m,$s;'
      let loop.= 'sleep '.s:gitdelay
      let loop.= ';done'
      let s:bash = ['bash','-c',loop]
      unlet s:gitdelay
    endif "}
    let opt = {}
    if s:vim
      if g:line.git.job=~'.*run'|return|endif
      let opt.out_cb = function('line#data')
      let g:line.git.job = job_start(s:bash,opt)
    else
      if g:line.git.job|return|endif
      let opt.on_stdout = function('line#data')
      let g:line.git.job = jobstart(s:bash,opt)
    endif
    return
  endif "end-job}
  if s:gitimode==3 " tcp    {
    echo 'tcp gitinfo not yet implemented. Defaulting back as job calls'
    let s:gitimode = 2
    call line#giti()
    return
  endif "end-tcp}

endfu "}
fu! line#gitb(...) abort "{

  if !s:gitimode|return|endif

  if s:gitimode==1
    let gits = 'git diff --no-ext-diff --cached --shortstat'
    let gitm = 'git diff --shortstat'
    let gitb = 'git rev-parse --abbrev-ref HEAD'
    let g:line.git.staged   = !empty(trim(system(gits)))
    let g:line.git.modified = !empty(trim(system(gitm)))
    let g:line.git.branch   = trim(system(gitb))
    if 1+match(g:line.git.branch,'^fatal:.*')
      let g:line.git.branch = 'gitless'
    endif
  endif
  let g:line.git.clean = !g:line.git.staged&&!g:line.git.modified
  let char = ' ['
  let sfix = ''
  if g:line.git.modified
    let sfix = 'm'
    let char.= 'M'
  endif
  if g:line.git.staged
    let char.= 'S'
    let sfix = 's'
  endif
  if g:line.git.clean
    let sfix = 'c'
    let char = ''
  else
    let char.= ']'
  endif
  if s:bonetype==2
    let colr = '%#LineGit'.sfix
    let edgeL= colr.'Edge#'..s:boneedge[0]
    let edgeR= colr.'Edge#'..s:boneedge[1]
    let colr.= '#'
    let g:line.git.bone = edgeL.colr.' '.g:line.git.branch .char.edgeR
  else
    let colr = '%#LineGit'.sfix.'#'
    let g:line.git.bone = colr.' '.g:line.git.branch .char
  endif

endfu "}
fu! line#stop(...) abort "{

  if !s:gitimode|return|endif

  if s:gitimode==1
    call timer_stop(g:line.git.timer)
  elseif s:gitimode==2
    call {s:vim?'job_stop':'jobstop'}(g:line.git.job)
  endif
  call line#zero()

endfu "}
