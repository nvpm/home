"-- auto/line.vim  --

if exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

"-- main functions --
fu! line#curr(...) "{

  let info = a:1
  let leng = a:2
  let revs = a:3
  let indx = a:4

  let elem = ''
  if s:modetype==0 " brackets config
    let elem = '['..info..']'
  endif
  if s:modetype==1 " highlight config
    let elem = '%#nvpmlinecurr# '..info..' '
  endif
  if 1+s:powerline " powerline config
    if revs
      let end  = '%#nvpmlinecharend#' ..s:left
      let init = '%#nvpmlinecharinit#'..s:left
      let elem = end..'%#nvpmlinecurr# '..info..' '..init
    else
      let end  = '%#nvpmlinecharend#' ..s:right
      let init = '%#nvpmlinecharinit#'..s:right
      let space= '%#nvpmlinecurr# '
      let elem = init..space..info..' '..end
    endif
  endif
  return elem

endfu "}
fu! line#inac(...) "{

  let info = a:1
  let leng = a:2
  let revs = a:3
  let indx = a:4
  let elem = ''
  if s:modetype==0 " brackets config
    let elem = ' '..info..' '
  endif
  if s:modetype==1 " highlight config
    let elem = '%#nvpmlineinac# '..info..' '
  endif
  if 1+s:powerline " powerline config
    let inac = '%#nvpmlineinac#'
    let iend = '%#nvpmlinechariend#'
    if revs
      let end  = indx==leng-1?iend.s:left.inac.' ':inac.'  '
      let elem = end..info..'  '
    else
      let end = ' '..iend..s:right
      let elem = '%#nvpmlineinac#  '..info..(indx==leng-1?end:'  ')
    endif
  endif
  return elem

endfu "}
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
  let s:powerline = get(g:,'line_powerline',-1)

  let g:line = {}
  let g:line.nvpm = 0
  let g:line.zoom = 0
  let g:line.mode = 0
  let g:line.timer= -1
  let g:line.git  = ''

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

  if 1+s:powerline
    let s:right    = nr2char(s:powerline + 0)
    let s:iright   = nr2char(s:powerline + 1)
    let s:left     = nr2char(s:powerline + 2)
    let s:ileft    = nr2char(s:powerline + 3)
    let s:brackets = 0
    if has_key(s:colors,'curr')&&has_key(s:colors,'inac')
      if &termguicolors
        let s:colors.charend = {} "{
        if has_key(s:colors.curr,'guibg')
          let s:colors.charend.guifg = s:colors.curr.guibg
        endif
        if has_key(s:colors.inac,'guibg')
          let s:colors.charend.guibg = s:colors.inac.guibg
        endif
        if has_key(s:colors.curr,'gui')
          let s:colors.charend.gui = s:colors.curr.gui
        endif "}
        let s:colors.charinit= {} "{ 
        if has_key(s:colors.inac,'guibg') 
          let s:colors.charinit.guifg = s:colors.inac.guibg 
        endif 
        if has_key(s:colors.curr,'guibg')
          let s:colors.charinit.guibg = s:colors.curr.guibg
        endif
        if has_key(s:colors.inac,'gui')
          let s:colors.charinit.gui = s:colors.inac.gui
        endif "}
        let s:colors.chariend= {} "{
        if has_key(s:colors.inac,'guibg')
          let s:colors.chariend.guifg = s:colors.inac.guibg
        endif
        if has_key(s:colors.curr,'guibg')
          let s:colors.chariend.guibg = s:colors.fill.guibg
        endif
        if has_key(s:colors.inac,'gui')
          let s:colors.chariend.gui = s:colors.inac.gui
        endif "}
      else
        let s:colors.charend = {} "{
        if has_key(s:colors.curr,'ctermbg')
          let s:colors.charend.ctermfg = s:colors.curr.ctermbg
        endif
        if has_key(s:colors.inac,'ctermbg')
          let s:colors.charend.ctermbg = s:colors.inac.ctermbg
        endif
        if has_key(s:colors.curr,'cterm')
          let s:colors.charend.cterm = s:colors.curr.cterm
        endif "}
        let s:colors.charinit= {} "{
        if has_key(s:colors.inac,'ctermbg')
          let s:colors.charinit.ctermfg = s:colors.inac.ctermbg
        endif
        if has_key(s:colors.curr,'ctermbg')
          let s:colors.charinit.ctermbg = s:colors.curr.ctermbg
        endif
        if has_key(s:colors.inac,'cterm')
          let s:colors.charinit.cterm = s:colors.inac.cterm
        endif "}
        let s:colors.chariend= {} "{
        if has_key(s:colors.inac,'ctermbg')
          let s:colors.chariend.ctermfg = s:colors.inac.ctermbg
        endif
        if has_key(s:colors.curr,'ctermbg')
          let s:colors.chariend.ctermbg = s:colors.fill.ctermbg
        endif
        if has_key(s:colors.inac,'cterm')
          let s:colors.chariend.cterm = s:colors.inac.cterm
        endif "}
      endif
    else
      let s:modetype = 1
    endif
  endif

  call line#seth()
  delfunc line#seth
  delfunc line#geth

  if s:activate
    hi clear TabLine
    hi clear StatusLine
    call line#show()
  endif

endfu "}
fu! line#topl(...) "{

  let line  = ''

  let line .= line#draw(2)
  let line .= '%#nvpmlinefill#'
  let line .= '%='
  let line.= line#draw(1,1)
  let line.= line#proj()

  return line

endfu "}
fu! line#botl(...) "{

  let line  = ''

  let line .= line#draw(3)

  let line .= g:line.git
  let line .= '%#nvpmlinefill#'
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
    let &laststatus=2+s:nvim*(1-g:line.zoom)
  else
    if s:verbose==0
      let &laststatus  = s:laststatus
      let &showtabline = s:showtabline
    endif
    if s:verbose>0
      set statusline=%!line#botl()
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

  let groups = {}
  for name in keys(s:colors) " loop over colors {
    if s:modetype==0&&(name=='curr'||name=='inac')|continue|endif
    if hlexists('nvpmline'..name)|continue|endif
    let fields = ''
    for field in keys(s:colors[name])
      if s:colors[name][field] =~ '^\w\+\.\w\+$'
        let [group,arg] = split(s:colors[name][field],'\.')
        if !has_key(groups,group)
          let groups[group] = line#geth(group)
        endif
        let group = groups[group]
        if has_key(group,arg)
          let fields.= field..'='..group[arg]..' '
        endif
      else
        let fields.= field..'='..s:colors[name][field]..' '
      endif
    endfor
    exe 'hi nvpmline'..name..' '..fields
  endfor "}

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
      let name = line#curr(info,leng,revs,i)
    else
      let name = line#inac(info,leng,revs,i)
    endif
    call add(names,name)
  endfor
  return names

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
  let line .= '%#nvpmlineproj#'..' '..proj..' '
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
      let cr   = '%#nvpmlinegitc#'
      if modified
        let cr    = '%#nvpmlinegitm#'
        let char  = ' [M]'
      endif
      if staged
        let cr   = '%#nvpmlinegits#'
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
