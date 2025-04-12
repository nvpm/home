"-- auto/line.vim  --

if exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

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

  let s:modetype  = get(g:,'line_modetype',1)
  let s:colors    = get(g:,'line_colors' ,{})

  let g:line = {}
  let g:line.nvpm = 0
  let g:line.mode = 0
  let g:line.timer= -1
  let g:line.git  = ''

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

  call line#seth()|delfunc line#seth|delfunc line#geth

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

  "if g:line.nvpm||s:verbose>0
    let line .= line#draw(3)
  "endif

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
fu! line#seth(...) "{

  if s:modetype>0&&empty(s:colors)||!has_key(s:colors,'curr')
    let s:modetype = 0
    return
  else
    let groups = {}
    for name in keys(s:colors) " loop over colors {
      if type(s:colors[name])!=type({})||hlexists('nvpmline'..name)|continue|endif
      let fields = ''
      for field in keys(s:colors[name])
        if s:colors[name][field] =~ '^\w\+\.\w\+$'
          let [group,arg] = split(s:colors[name][field],'\.')
          if !has_key(groups,group)
            let groups[group] = line#geth(group)
          endif
          let group = groups[group]
          if has_key(group,arg)
            let fields.= arg..'='..group[arg]..' '
          endif
        else
          let fields.= field..'='..s:colors[name][field]..' '
        endif
      endfor
      exe 'hi nvpmline'..name..' '..fields
    endfor "}
  endif

endfu "}
fu! line#geth(...) "{

  let group = a:1
  let field = get(a:,2,'no field')
  let args = {}
  if hlexists(group)
    let info = execute('hi '.group)
    let info = split(info,'\s\+')[2:]
    let info = map(info,'split(v:val,"=")')
    for arg in info
      if arg[0]==field|return arg[1]|endif
      let args[arg[0]] = arg[1]
    endfor
  endif
  return args

endfu "}
fu! line#draw(...) "{

  let list = []
  let revs = get(a:,2)

  if g:line.nvpm
    let type = get(a:,1,-1)
    let node = flux#seek(g:nvpm.tree.root,type)
    if has_key(node,'meta')
      let curr = node.meta.indx
      let leng = node.meta.leng
      let list = line#list(node.list,curr,leng,revs)
    endif
  else
    if s:verbose>1
      let bufs = map(range(1,bufnr('$')),'bufname(v:val)')
      let bufs = filter(bufs,'!empty(v:val)&&buflisted(v:val)')
      let curr = match(bufs,bufname())
      let leng = len(bufs)
      let list = line#list(bufs,curr,leng,revs)
    elseif s:verbose==1
      let list = line#list([bufname()],0,1,revs)
    endif
  endif

  let list = revs?reverse(list):list
  let list = join(list,'')
  if s:modetype==0
    let list ='%#Normal#'..list
  endif
  return list

endfu "}
fu! line#list(...) "{

  let list = a:1
  let curr = a:2
  let leng = a:3
  let revs = a:4
  let names= []

  for i in range(leng)
    let item = list[i]
    let info = g:line.nvpm?eval('item.data.name'):fnamemodify(item,':t')
    let iscurr = i==curr
    if i==curr
      let name = line#curr(info,leng)
    else
      let name = line#inac(info,leng)
    endif
    call add(names,name)
  endfor
  return names

endfu "}
fu! line#curr(...) "{

  let info = a:1
  let leng = a:2
  let elem = ''
  if s:modetype==0 " brackets config
    let elem = '['.info.']'
  endif
  if s:modetype==1 " highlight config
    let elem = ' '.info
  endif
  return elem

endfu "}
fu! line#inac(...) "{

  let info = a:1
  let leng = a:2
  let elem = ''
  if s:modetype==0 " brackets config
    let elem = ' '.info.' '
  endif
  if s:modetype==1 " highlight config
    let elem = ' '.info
  endif
  return elem

endfu "}
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
