"-- auto/line.vim  --

if !NVPMTEST&&exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

"-- main functions --
fu! line#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif

  let botr = '%y%m ⬤ %l,%c/%P'
  let botc = ' ⬤ %f'

  let s:user = {}
  let s:user.bottomcenter = get(g:,'line_bottomcenter'  , botc )
  let s:user.bottomright  = get(g:,'line_bottomright'   , botr )
  let s:user.closure      = get(g:,'line_closure'       , 1    )
  let s:user.innerspace   = get(g:,'line_innerspace'    , 0    )
  let s:user.projname     = get(g:,'line_show_projname' , 1    )
  let s:user.gitinfo      = get(g:,'line_git_info'      , 0    )
  let s:user.gitdelayms   = get(g:,'line_git_delayms'   , 2000 )

  let s:git  = ''
  let s:line = 1

endfu "}
fu! line#keep(...) "{

  if s:line|call line#show()|endif

endfu "}
fu! line#topl(...) "{
  let line  = ''

  let line .= line#list(2)

  " middle of top line
  let line .= '%#LINEFill#'
  let line .= '%='

  let line.= line#list(1,1)

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

  let line .= line#list(3)

  let line .= s:git
  let line .= '%#LINEFill#'
  let line .= s:user.bottomcenter
  let line .= '%='
  let line .= s:user.bottomright

  return line

endfu "}
fu! line#show(...) "{

  "if exists('g:zoom.mode')&&g:zoom.mode|return|endif
  if g:nvpm.tree.mode
    if s:user.gitinfo
      let time = timer_start(s:user.gitdelayms,'line#time',{'repeat':-1})
    endif
    set tabline=%!line#topl()
    set statusline=%!line#botl()
  endif

  set showtabline=2
  set laststatus=3

  let s:line = 1

endfu "}
fu! line#hide(...) "{

  set showtabline=0
  set laststatus=0

  let &tabline = ' '
  let &statusline = ' '

  let s:line = 0

endfu "}
fu! line#swap(...) "{

  if s:line
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
  let s:git = info
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

