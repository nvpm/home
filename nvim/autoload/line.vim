"-- auto/line.vim  --

if exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

fu! line#atom(...) "{

  let type = a:1
  let info = a:2
  let revs = a:3
  let indx = a:4
  let leng = a:5
  let elem = ''
  if type==0 " curr{
    if s:atomtype==0 " brackets  config{
      let info = '['..info..']'
    endif "}
    if s:atomtype==1 " highlight config{
      let elem = '%#linecurr# '..info..' '
    endif "}
    if s:atomtype==3 " powerline config{
      if revs
        let end  = '%#linecharend#' ..s:left
        let init = '%#linecharinit#'..s:left
        let elem = end..'%#linecurr# '..info..' '..init
      else
        let end  = '%#linecharend#' ..s:right
        let init = '%#linecharinit#'..s:right
        let space= '%#linecurr# '
        let elem = init..space..info..' '..end
      endif
    endif "}
  endif "}
  if type==1 " inac{
    if s:atomtype==0 " brackets  config{
      let elem = ' '..info..' '
    endif "}
    if s:atomtype==1 " highlight config{
      let elem = '%#lineinac# '..info..' '
    endif "}
    if s:atomtype==3 " powerline config{
      let inac = '%#lineinac#'
      let iend = '%#linechariend#'
      if revs
        let end  = indx==leng-1?iend.s:left.inac.' ':inac.'  '
        let elem = end..info..'  '
      else
        let end = ' '..iend..s:right
        let elem = '%#lineinac#  '..info..(indx==leng-1?end:'  ')
      endif
    endif "}
  endif "}
  return elem

endfu "}
fu! line#list(...) "{

  let curr = a:2
  let leng = a:3
  let revs = a:4
  let list = []

  for indx in range(leng)
    let item = a:1[indx]
    let info = g:line.nvpm?eval('item.data.name'):fnamemodify(item,':t')
    let iscurr = indx==curr
    if indx==curr
      let elem = line#atom(0,info,revs,indx,leng)
    else
      let elem = line#atom(1,info,revs,indx,leng)
    endif
    call add(list,elem)
  endfor
  if s:atomtype==2
  endif
  return list

endfu "}
fu! line#draw(...) "{

  let list = []
  let type = get(a:,0) " 0: blist ,1:mode, 2:spot, 3:mode, 4:
  let revs = get(a:,2)

  if g:line.nvpm
    let node = flux#seek(g:nvpm.tree.root,get(a:,1,-1))
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
  if s:atomtype==0
    let list ='%#Normal#'..list
  endif
  return list

endfu "}
fu! line#seth(...) "{

  let data = get(a:,1,s:colors)

  for atom in keys(data)
    let name = 'line'.atom
    let atom = data[atom]
    if type(atom)==type([])&&!hlexists(name)
      let gbg = get(atom,0,'')|let gbg=['guibg='..  gbg,''][empty(gbg)]
      let gfg = get(atom,1,'')|let gfg=['guifg='..  gfg,''][empty(gfg)]
      let gui = get(atom,2,'')|let gui=['gui='  ..  gui,''][empty(gui)]
      let cbg = get(atom,3,'')|let cbg=['ctermbg='..cbg,''][empty(cbg)]
      let cfg = get(atom,4,'')|let cfg=['ctermfg='..cfg,''][empty(cfg)]
      let ctm = get(atom,5,'')|let ctm=['cterm='  ..ctm,''][empty(ctm)]
      let arg = gbg.' '.gfg.' '.gui.' '
      let arg.= cbg.' '.cfg.' '.ctm
      if !empty(arg)
        exe 'hi '..name..' '..arg
      endif
    elseif type(atom)==type({})
    endif
  endfor

endfu "}
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

  let s:atomtype  = get(g:,'line_atomtype',1)
  let s:powerline = get(g:,'line_powerline',-1)
  let s:colors    = get(g:,'line_colors',{})

  let g:line = {}
  let g:line.nvpm = 0
  let g:line.zoom = 0
  let g:line.mode = 0
  let g:line.timer= -1
  let g:line.git  = ''

  let s:laststatus  = &laststatus
  let s:showtabline = &showtabline

  if !empty(s:colors)
    call line#seth()
  endif

  if s:activate
    hi clear TabLine
    hi clear StatusLine
    call line#show()
  endif

endfu "}
fu! line#topl(...) "{

  let line  = ''

  let line .= line#draw(2)
  let line .= '%#linefill#'
  let line .= '%='
  let line.= line#draw(1,1)
  let line.= line#proj()

  return line

endfu "}
fu! line#botl(...) "{

  let line  = ''

  let line .= line#draw(3)

  let line .= g:line.git
  let line .= '%#linefill#'
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
  let line .= '%#linespot#'..' '..proj..' '
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
      let cr   = '%#linegitc#'
      if modified
        let cr    = '%#linegitm#'
        let char  = ' [M]'
      endif
      if staged
        let cr   = '%#linegits#'
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
