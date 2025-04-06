"-- auto/line.vim  --

if !NVPMTEST&&exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

"-- main functions --
fu! line#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')

  let botr = '%y%m ⬤ %l,%c/%P'
  let botc = ' ⬤ %{line#file()}'

  let s:user = {}
  let s:user.bottomcenter = get(g:,'line_bottomcenter'  , botc )
  let s:user.bottomright  = get(g:,'line_bottomright'   , botr )
  let s:user.closure      = get(g:,'line_closure'       , 1    )
  let s:user.innerspace   = get(g:,'line_innerspace'    , 0    )
  let s:user.projname     = get(g:,'line_projname'      , 1    )
  let s:user.gitinfo      = get(g:,'line_gitinfo'       , 1    )
  let s:user.gitdelay     = get(g:,'line_gitdelay'    , 5000 )
  let s:user.initload     = get(g:,'line_initload'    , 1 )

  let g:line = {}
  let g:line.mode = 1
  let g:line.timer= -1
  let g:line.git  = ''

  let s:opts = {}
  let s:opts.tabline     = &tabline
  let s:opts.statusline  = &statusline
  let s:opts.showtabline = &showtabline
  let s:opts.laststatus  = &laststatus

  if s:user.initload
    call line#show(1)
    let &showtabline = s:opts.showtabline
  endif

endfu "}
fu! line#keep(...) "{

  if g:line.mode|call line#show()|endif

endfu "}
fu! line#topl(...) "{
  let line  = ''

  let line .= line#list(2)

  " middle of top line
  let line .= '%#LINEFill#'
  let line .= '%='

  let line.= line#list(1,1)

  if !s:user.projname|return line|endif
  let proj = flux#seek(g:nvpm.tree.root,0)

  if empty(proj)||proj.list[proj.meta.indx].data.name=='<unnamed>'||proj.list[proj.meta.indx].data.name==''
    let proj = g:nvpm.tree.file
    let proj = fnamemodify(proj,':t')
  else
    let proj = proj.list[proj.meta.indx].data.name
  endif

  let line .= '%#LINEProj#'..' '..proj..' '

  return line

endfu "}
fu! line#botl(...) "{
  let space = repeat(' ',s:user.innerspace)
  let line  = ''
  let indx  = 0

  if exists('g:nvpm.tree.mode')&&g:nvpm.tree.mode
    let line .= line#list(3)
  else
    let list = execute('ls')
    let list = split(list,'\n')
    for item in list
      let item = split(item,'\s')
      call filter(item,"v:val!=''")
      let curr = item[1]
      let file = item[2][1:-2]
      if curr=~'%'|break|endif
    endfor
    let file = fnamemodify(file,':t')
    let file = ' '..file..' '
  endif

  let line .= g:line.git
  let line .= '%#LINEFill#'
  let line .= s:user.bottomcenter
  let line .= '%='
  let line .= s:user.bottomright

  return line

endfu "}
fu! line#show(...) "{

  if s:user.gitinfo && g:line.timer==-1
    let g:line.timer = timer_start(s:user.gitdelay,'line#time',{'repeat':-1})
  endif

  if !a:0&&exists('g:nvpm.tree.mode')&&g:nvpm.tree.mode
    set tabline=%!line#topl()
    let &showtabline=2
  endif
  set statusline=%!line#botl()
  let &laststatus=2+s:nvim

  let g:line.mode = 1

endfu "}
fu! line#hide(...) "{

  set showtabline=0
  set laststatus=0

  if 1+g:line.timer
    call timer_stop(g:line.timer)
    let g:line.timer = -1
  endif

  "let &tabline = ' '
  "let &statusline = ' '

  let g:line.mode = 0

endfu "}
fu! line#swap(...) "{

  if g:line.mode
    call line#hide()
  else
    call line#show()
  endif

endfu "}

"-- auxy functions --
fu! line#list(...) "{

  let type = get(a:000,0,-1)
  let revs = get(a:000,1)
  let node = flux#seek(g:nvpm.tree.root,type)

  if empty(node)|return ''|endif

  if !has_key(node,'list')|return ''|endif
  if !has_key(node,'meta')|return ''|endif

  let curr = node.list[node.meta.indx%node.meta.leng]
  let space = repeat(' ',s:user.innerspace)

  let names = []

  for item in node.list
    let iscurr = item is curr
    let name   = ''
    let name  .= iscurr ? '%#LINECurr#' : '%#LINEItem#'
    let name  .= s:user.closure&&iscurr ? '['..space : ' '..space
    let name  .= item.data.name
    let name  .= s:user.closure && iscurr ? space..']' : ' '..space
    call add(names,name)
  endfor

  let names = revs?reverse(names):names

  return join(names,'')

endfu "}
fu! line#time(...) "{
  let info  = ''
  if s:user.gitinfo && executable('git')
    let branch   = trim(system('git rev-parse --abbrev-ref HEAD'))
    if empty(branch)|return ''|endif
    let modified = !empty(trim(system('git diff HEAD --shortstat')))
    let staged   = !empty(trim(system('git diff --no-ext-diff --cached --shortstat')))
    let cr = ''
    let char = ''
    let s = ' '
    if empty(matchstr(branch,'fatal: not a git repository'))
      let cr   = '%#LINEGitClean#'
      if modified
        let cr    = '%#LINEGitModified#'
        let char  = ' [M]'
      endif
      if staged
        let cr   = '%#LINEGitStaged#'
        let char = ' [S]'
      endif
      let info = cr .' ' . branch . char
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

