"-- auto/line.vim  --
if !exists('NVPMTEST')&&exists('_LINEAUTO_')|finish|endif
let _LINEAUTO_ = 1
let s:nvim = has('nvim')

if !has_key(g:,'nvpmhome')
  let g:nvpmhome = resolve(expand('~/.nvpm'))
endif
let s:home = g:nvpmhome..'/line/'

"-- main functions --
fu! line#init(...) abort "{ user variables & startup routines

  let g:line = get(g:,'line',{})

  let g:line.initload = get(g:line , 'initload' ,  1  )
  let g:line.showmode = get(g:line , 'showmode' ,  2  )
  let g:line.gitimode = get(g:line , 'gitimode' ,  1  )
  let g:line.gitdelay = get(g:line , 'gitdelay' , &ut )
  let g:line.bonetype = get(g:line , 'bonetype' ,  0  )
  let g:line.curredge = get(g:line , 'curredge' , '[,]' )
  let g:line.inacedge = get(g:line , 'inacedge' , ' , ' )
  let g:line.boneedge = get(g:line , 'boneedge' , ',' )
  let g:line.skeleton = get(g:line , 'skeleton' ,  0  )

  let g:line.curredge = split(g:line.curredge,',',1)
  let g:line.inacedge = split(g:line.inacedge,',',1)
  let g:line.boneedge = split(g:line.boneedge,',',1)

  let g:line.mode = 1
  let g:line.nvpm = 0
  let g:line.zoom = 0
  "let g:line.pads = #{left:0,right:0}

  call line#save()
  call line#skel()

  let g:line.gitimode = (executable('git')&&line#find('git'))*g:line.gitimode

  call line#zero()

  let g:line.modeinfo          = {}
  let g:line.modeinfo.normal   = 'normal'
  let g:line.modeinfo.insert   = 'insert'
  let g:line.modeinfo.visual   = 'visual'
  let g:line.modeinfo.replace  = 'replace'
  let g:line.modeinfo.cmdline  = 'cmdline'
  let g:line.modeinfo.terminal = 'terminal'

  if !has_key(g:line,'leaftype')
    if exists('g:nvpm.arbo.leaftype')
      let g:line.leaftype = g:nvpm.arbo.leaftype
    else
      let g:line.leaftype = 4
    endif
  endif

  if g:line.initload
    call line#show()
  endif

endfu "}
fu! line#draw(...) abort "{ sets both tab and status lines
  if !g:line.mode|return|endif
  call line#head()
  call line#feet()
endfu "}
fu! line#show(...) abort "{ renders both lines into view

  call line#giti()

  if g:line.nvpm
    set showtabline=2
    let &laststatus=2
  else
    if g:line.showmode==0
      let &laststatus  = g:line.save.laststatus
      let &showtabline = g:line.save.showtabline
    endif
    if g:line.showmode>0
      let &laststatus=2
    endif
    if g:line.showmode>2
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
fu! line#hide(...) abort "{ hides both lines from the user's view

  call line#save()

  let &showtabline = 0
  let &laststatus  = 0
  let &statusline  = ' '
  let &tabline     = ' '

  if exists('g:zoom.mode')&&g:zoom.mode&&bufexists(g:zoom.pads.t)
    call setbufvar(g:zoom.pads.t,'&statusline','%#Normal# ')
  endif
  let g:line.mode = 0
  call line#stop()

endfu "}
fu! line#line(...) abort "{ swaps both lines on and off (toggle switch)

  if g:line.mode
    call line#hide()
  else
    call line#show()
    call line#draw()
  endif

endfu "}

"-- skel functions --
fu! line#mode(...) abort "{ colorizes an atom based on current vim mode

  let mode = mode()
  if mode=='i'
    let default = a:0==1
    let colr = a:1
    let colr.= hlexists(a:1) ? '' : 'Insert'
    let info = '%#'..colr..'#'..(default? g:line.modeinfo.insert : a:2)
    if g:line.bonetype==2&&default
      let edge = '%#'..colr..'Edge#'
      let left = edge..g:line.boneedge[0]
      let right= edge..g:line.boneedge[1]
      let info = left..info..right
      ec info
    endif
    return info
  elseif mode=~'\(v\|V\|\|s\|S\|\)'
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Visual'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : g:line.modeinfo.visual)
  elseif mode=='R'
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Replace'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : g:line.modeinfo.replace)
  elseif mode=~'\(c\|r\|!\)'
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Cmdline'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : g:line.modeinfo.cmdline)
  elseif mode=='t'
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Terminal'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : g:line.modeinfo.terminal)
  else
    let colr = '%#'..a:1
    let colr.= hlexists(a:1) ? '' : 'Normal'
    let colr.= '#'
    return colr..(a:0==2 ? a:2 : g:line.modeinfo.normal)
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
fu! line#pack(...) abort "{ packs multiple atoms together

  let list = a:1
  let curr = a:2
  let leng = a:3
  let revs = a:4
  let colr = a:5
  let pack = []

  for indx in range(leng)
    let item = list[indx]
    let info = g:line.nvpm?eval('item.name'):fnamemodify(item,':t:r')
    let iscurr = indx==curr
    if indx==curr
      let info = g:line.curredge[0]..info..g:line.curredge[1]
      let elem = line#mode(colr,info)
    else
      let info = g:line.inacedge[0]..info..g:line.inacedge[1]
      let elem = line#mode('LineInac',info)
    endif
    call add(pack,elem)
  endfor

  return revs?reverse(pack):pack

endfu "}
fu! line#atom(...) abort "{ builds an atom based on functions and arguments

  if a:0!=3|return ''|endif

  let func = a:1
  let args = a:2
  let revs = a:3

  if     func=='curr' "{
    if !len(args)|return ''|endif
    let type = args[0]
    let name = ''
    if g:line.nvpm "{
      if type==0
        let name = fnamemodify(g:nvpm.curr.arbo.file,':t')
      else
        let node = nvpm#seek(type)
        if has_key(node,'meta')&&has_key(node,'list')
          let node = node.list[node.meta.indx]
          if has_key(node,'info')
            let name = node.name
          endif
        endif
      endif
    endif "}
    if empty(name)|return ''|endif
    let colr = get(args,1,'LineCurr')
    let name = line#mode(colr,name)
    if g:line.bonetype==2
      let edge = colr.'Edge'
      let left = line#mode(edge,g:line.boneedge[0])
      let right= line#mode(edge,g:line.boneedge[1])
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

    if g:line.nvpm   "{
      let node = nvpm#seek(type)
      if has_key(node,'meta')
        let indx = node.meta.indx
        let leng = node.meta.leng
        let list = node.list
      endif
    "}
    elseif type==g:line.leaftype "{
      if g:line.showmode==1
        let list = [bufname()]
        let indx = 0
        let leng = 1
      elseif g:line.showmode>1
        let list = map(range(1,bufnr('$')),'bufname(v:val)')
        let list = filter(list,'!empty(v:val)&&buflisted(v:val)')
        let indx = match(list,bufname())
        let leng = len(list)
      endif
    "}
    elseif type==g:line.leaftype-1 "{
    endif "}

    let list = line#pack(list,indx,leng,revs,colr)
    if !empty(list)
      let line = join(list,'')
      if g:line.bonetype==2
        if     leng==1      "{
          let left = line#mode('LineCurrEdge',g:line.boneedge[0])
          let right= line#mode('LineCurrEdge',g:line.boneedge[1])
        "}
        elseif indx==leng-1 "{
          if revs
            let left = line#mode('LineCurrEdge',g:line.boneedge[0])
            let right= line#mode('LineInacEdge',g:line.boneedge[1])
          else
            let left = line#mode('LineInacEdge',g:line.boneedge[0])
            let right= line#mode('LineCurrEdge',g:line.boneedge[1])
          endif
        "}
        elseif indx==0      "{
          if revs
            let left = line#mode('LineInacEdge',g:line.boneedge[0])
            let right= line#mode('LineCurrEdge',g:line.boneedge[1])
          else
            let left = line#mode('LineCurrEdge',g:line.boneedge[0])
            let right= line#mode('LineInacEdge',g:line.boneedge[1])
          endif
        "}
        else                "{
          let left = line#mode('LineInacEdge',g:line.boneedge[0])
          let right= line#mode('LineInacEdge',g:line.boneedge[1])
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
    elseif name =~ '.*/arbo/.*\.arbo$'
      let char = ''
      let name = 'arbo/'..fnamemodify(name,':t')
    elseif &filetype == 'help'
      let char = ''
      let name = fnamemodify(name,':~')
    else
      let char = ''
      let name = fnamemodify(name,':~')
    endif
    let hi   = '%#'.hi.'#'
    let name = hi..char..' '..name
    if g:line.bonetype==2
      let edge = '%#LineFileEdge#'
      let name = edge..g:line.boneedge[0]..name..edge..g:line.boneedge[1]
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
    if g:line.bonetype==2
      let edge = '%#LineUserEdge#'
      let info = edge..g:line.boneedge[0]..info..edge..g:line.boneedge[1]
    endif
    return info
  "}
  endif

endfu "}
fu! line#bone(...) abort "{ creates a bone type

  let skel = ''
  for bone in a:1
    if     type(bone)==1 " string type
      let skel.= bone
    elseif type(bone)==3 " list type
      let func = bone[0]
      if func=='git'&&g:line.gitimode
        let skel.= g:line.git.bone
      else
        let skel.= line#atom(func,bone[1:],a:2)
      endif
    endif
    let skel.= '%#LineFill#'
  endfor
  return skel

endfu "}
fu! line#skel(...) abort "{ conforms or creates the skeleton variable

  if a:0
    if !has_key(g:,'line')|let g:line = {}|endif
    if !has_key(g:line,'skeleton')
      let g:line.skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}
    endif
  elseif type(g:line.skeleton)!=4 " dict type
    let g:line.skeleton = #{head:#{l:[],r:[]},feet:#{l:[],r:[]}}
    call add(g:line.skeleton.head.l,['list',2])
    call add(g:line.skeleton.head.r,['list',1])
    call add(g:line.skeleton.head.r,' ')
    call add(g:line.skeleton.head.r,['curr',0])
    call add(g:line.skeleton.feet.l,['list',3])
    call add(g:line.skeleton.feet.l,' ')
    call add(g:line.skeleton.feet.l,['git'])
    call add(g:line.skeleton.feet.l,' ')
    call add(g:line.skeleton.feet.l,['file'])
    call add(g:line.skeleton.feet.r,['user','%Y%m ● %l,%v/%p%%'])
    let g:line.headl = 1
    let g:line.headr = 1
    let g:line.feetl = 1
    let g:line.feetr = 1
  else
    let g:line.headl = exists('g:line.skeleton.head.l')
    let g:line.headr = exists('g:line.skeleton.head.r')
    let g:line.feetl = exists('g:line.skeleton.feet.l')
    let g:line.feetr = exists('g:line.skeleton.feet.r')
  endif

endfu "}
fu! line#head(...) abort "{ builds the tabline (the head)

  let line = ''
  if g:line.headl
    let line.= line#bone(g:line.skeleton.head.l,0)
  endif
  let line.= '%='
  if g:line.headr
    let line.= line#bone(g:line.skeleton.head.r,1)
  endif

  if g:line.zoom
    if bufwinnr(g:zoom.pads.t)
      if &showtabline|let &showtabline=0|endif
      call setbufvar(g:zoom.pads.t,'&statusline',line)
      return
    endif
    if g:zoom.size.l
      let line = '%#Normal#'..repeat(' ',g:zoom.size.l)..line
    endif
    if g:zoom.size.r
      let line = line..'%#Normal#'..repeat(' ',g:zoom.size.r)
    endif
  endif

  let &tabline = line

endfu "}
fu! line#feet(...) abort "{ builds the statusline (the feet)

  let line = ''

  if g:line.feetl
    let line.= line#bone(g:line.skeleton.feet.l,0)
  endif
  let line.= '%='
  if g:line.feetr
    let line.= line#bone(g:line.skeleton.feet.r,1)
  endif

  if g:line.zoom&&&laststatus==3
    if g:zoom.size.l
      let line = '%#Normal#'..repeat(' ',g:zoom.size.l)..line
    endif
    if g:zoom.size.r
      let line = line..'%#Normal#'..repeat(' ',g:zoom.size.r)
    endif
  endif

  let &statusline = line

endfu "}

"-- auxy functions --
fu! line#save(...) abort "{ saves vim's related variables

  if !has_key(g:line,'save')
    let g:line.save = {}
  endif

  let g:line.save.laststatus  = &laststatus
  let g:line.save.showtabline = &showtabline

endfu "}
fu! line#find(...) abort "{ checks if bone is in the skeleton

  let name = a:1
  if g:line.feetl&&1+match(g:line.skeleton.feet.l,name)|return 1|endif
  if g:line.feetr&&1+match(g:line.skeleton.feet.r,name)|return 1|endif
  if g:line.headl&&1+match(g:line.skeleton.head.l,name)|return 1|endif
  if g:line.headr&&1+match(g:line.skeleton.head.r,name)|return 1|endif

endfu "}
fu! line#zero(...) abort "{ resets the git variable

  let g:line.git = #{}
  let g:line.git.bone = ''
  if g:line.gitimode==1
    let g:line.git.timer = 0
  elseif g:line.gitimode > 1
    let g:line.git.job = 0
  endif

endfu "}
fu! line#data(...) abort "{ sets the git data from stream

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
fu! line#giti(...) abort "{ sets the timer, job, or tcp connection for git info

  if !g:line.gitimode|return|endif

  if g:line.gitimode==1 " timer  {
    if !g:line.git.timer
      let g:line.gitdelay = g:line.gitdelay<500?500:g:line.gitdelay
      let g:line.git.timer=timer_start(g:line.gitdelay,'line#gitb',{'repeat':-1})
    endif
    return
  endif "end-timer}
  if g:line.gitimode==2 " job    {
    if !exists('g:line.bash' ) "{
      let g:line.gitdelay = g:line.gitdelay/1000.0
      let step    = 0.25*g:line.gitdelay
      let g:line.gitdelay-= 2*step
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
      let loop.= 'sleep '.g:line.gitdelay
      let loop.= ';done'
      let g:line.bash = ['bash','-c',loop]
      unlet g:line.gitdelay
    endif "}
    let opt = {}
    if s:nvim
      if g:line.git.job|return|endif
      let opt.on_stdout = function('line#data')
      let g:line.git.job = jobstart(g:line.bash,opt)
    else
      if g:line.git.job=~'.*run'|return|endif
      let opt.out_cb = function('line#data')
      let g:line.git.job = job_start(g:line.bash,opt)
    endif
    return
  endif "end-job}
  if g:line.gitimode==3 " tcp    {
    echo 'tcp gitinfo not yet implemented. Defaulting back as job calls'
    let g:line.gitimode = 2
    call line#giti()
    return
  endif "end-tcp}

endfu "}
fu! line#gitb(...) abort "{ builds the git bone

  if !g:line.gitimode|return|endif

  if g:line.gitimode==1
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
  if g:line.bonetype==2
    let colr = '%#LineGit'.sfix
    let edgeL= colr.'Edge#'..g:line.boneedge[0]
    let edgeR= colr.'Edge#'..g:line.boneedge[1]
    let colr.= '#'
    let g:line.git.bone = edgeL.colr.' '.g:line.git.branch .char.edgeR
  else
    let colr = '%#LineGit'.sfix.'#'
    let g:line.git.bone = colr.' '.g:line.git.branch .char
  endif

endfu "}
fu! line#stop(...) abort "{ stops the timer, job, or tcp connection

  if !g:line.gitimode|return|endif

  if g:line.gitimode==1
    call timer_stop(g:line.git.timer)
  elseif g:line.gitimode==2
    call {s:nvim?'jobstop':'job_stop'}(g:line.git.job)
  endif
  call line#zero()

endfu "}
