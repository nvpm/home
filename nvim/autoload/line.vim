"-- auto/line.vim  --

if !NVPMTEST&&exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

fu! line#draw(...) "{

  let revs = get(a:,2)
  let list = []

  if g:line.nvpm
    let type = get(a:,1,-1)
    let node = flux#seek(g:nvpm.tree.root,type)
    let curr = node.meta.indx
    let leng = node.meta.leng
    let list = line#list(node.list,curr,leng,revs)
  else
    let bufs = map(range(1,bufnr('$')),'bufname(v:val)')
    let bufs = filter(bufs,'!empty(v:val)&&buflisted(v:val)')
    let curr = match(bufs,bufname())
    let leng = len(bufs)
    let list = line#list(bufs,curr,leng,revs)
  endif

  let list = revs?reverse(list):list
  return join(list,'')

endfu "}
fu! line#list(...) "{

  let list = a:1
  let curr = a:2
  let leng = a:3
  let revs = a:4
  let names= []

  for i in range(leng)
    exe 'let info = list[i]'..(g:line.nvpm?'.data.name':'')
    let iscurr = i==curr
    let name = ''
    if s:brackets
      "let name = '%#Normal#'
      let space= leng>1?' ':''
      let name.= i==curr && leng>1 ? '[' : space
      let name.= info
      let name.= i==curr && leng>1 ? ']' : space
    endif
    call add(names,name)
  endfor
  return names

endfu "}
"-- main functions --
fu! line#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')

  let s:powerline = get(g:,'line_powerline',-1)
  let s:activate  = get(g:,'line_activate',1)
  let s:verbose   = get(g:,'line_verbose' ,2)
  let s:brackets  = get(g:,'line_brackets',1)
  let s:projname  = get(g:,'line_projname',0)
  let s:gitinfo   = get(g:,'line_gitinfo',1)
  let s:delay     = get(g:,'line_gitdelay',20000)
  let limit       = s:delay>=2000
  let s:delay     = limit*s:delay+!limit*2000

  if 1+s:powerline
    let s:right = nr2char(s:powerline + 0)
    let s:iright= nr2char(s:powerline + 1)
    let s:left  = nr2char(s:powerline + 2)
    let s:ileft = nr2char(s:powerline + 3)
  endif

  let g:line = {}
  let g:line.nvpm = 0
  let g:line.mode = 0
  let g:line.timer= -1
  let g:line.git  = ''

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

  if s:activate
    call line#show()
  endif

endfu "}
fu! line#topl(...) "{

  let line  = ''

  let line .= line#draw(2)
  let line .= '%#LINEFill#'
  let line .= '%='
  let line.= line#draw(1,1)
  let line.= line#proj()

  return line

endfu "}
fu! line#botl(...) "{

  let line  = ''

  if g:line.nvpm||s:verbose>1
  "if g:line.nvpm
    let line .= line#draw(3)
  elseif s:verbose==1
  "elseif s:verbose>=1
    let line .= '%t'
  endif

  let line .= g:line.git
  let line .= '%#LINEFill#'
  let line .= s:verbose>0||g:line.nvpm?' ⬤ ':''
  let line .= '%{line#file()}'
  let line .= '%='
  let line .= '%y%m ⬤ %l,%c/%P'

  return line

endfu "}
fu! line#show(...) "{

  if !s:activate|return|endif
  if s:verbose>0
    call line#time()
  endif
  if g:line.nvpm
    set tabline=%!line#topl()
    set statusline=%!line#botl()
    set showtabline=2
    let &laststatus=2+s:nvim
  else
    if s:verbose==0
      let &laststatus  = s:laststatus
      let &showtabline = s:showtabline
    endif
    if s:verbose>0
      set statusline=%!line#botl()
      let &laststatus=2+s:nvim
    endif
    if s:verbose>2
      set showtabline=2
    endif
  endif

  let g:line.mode = 1

endfu "}
fu! line#hide(...) "{

  if !s:activate|return|endif
  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

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
fu! line#proj(...) "{

  if !s:projname|return ''|endif

  let line = ''

  let proj = flux#seek(g:nvpm.tree.root,0)
  if empty(proj)||
    \proj.list[proj.meta.indx].data.name=='<unnamed>'||
    \proj.list[proj.meta.indx].data.name==''
    let proj = g:nvpm.tree.file
    let proj = fnamemodify(proj,':t')
  else
    let proj = proj.list[proj.meta.indx].data.name
  endif
  let line .= '%#LINEProj#'..' '..proj..' '
  return line

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
      let cr   = '%#LINEGITC#'
      if modified
        let cr    = '%#LINEGITM#'
        let char  = ' [M]'
      endif
      if staged
        let cr   = '%#LINEGITS#'
        let char = ' [S]'
      endif
      let info = cr .'  ' . branch . char
    endif
  endif
  let g:line.git = info
endfu "}
fu! line#file(...) "{
  let termpatt = 'term://.*'
  if !empty(matchstr(bufname(),termpatt))
    return 'terminal'
  endif
  if &filetype == 'help' && !filereadable('./'.bufname())
    return resolve(expand("%:t"))
  else
    let file = resolve(expand("%"))
    if len(file)>25
      let file = fnamemodify(file,':t')
    endif
    return file
  endif
endfu "}

"-- auto functions --

" vim: nowrap
