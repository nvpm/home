"-- auto/line.vim  --

if !NVPMTEST&&exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

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

  let line .= line#list(2)
  let line .= '%#LINEFill#'
  let line .= '%='
  let line.= line#list(1,1)
  let line.= line#proj()

  return line

endfu "}
fu! line#botl(...) "{

  let line  = ''

  if g:line.nvpm||s:verbose>1
    let line .= line#list(3)
  elseif s:verbose==1
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
fu! line#list(...) "{

  let names = []
  let type  = get(a:,1,-1)
  let revs  = get(a:,2)

  if g:line.nvpm

    let node = flux#seek(g:nvpm.tree.root,type)

    if empty(node)|return ''|endif

    if !has_key(node,'list')|return ''|endif
    if !has_key(node,'meta')|return ''|endif

    let curr = node.list[node.meta.indx%node.meta.leng]
    let last = node.meta.leng-1

    for i in range(node.meta.leng)
      let item   = node.list[i]
      let iscurr = item is curr
      let name   = ''
      let info   = item.data.name
      if s:brackets
        let name = '%#Normal#'
        let space= node.meta.leng>1?' ':''
        let name.= iscurr && node.meta.leng>1?'[':space
        let name.= info
        let name.= iscurr && node.meta.leng>1?']':space
      else
        if 1+s:powerline
          if iscurr "{
            let info = '%#LINECURR#'..info
            if revs
              let char = '%#LINECHAREND#'..s:left
              let init = '%#LINECHARINIT#'..s:left
              let end  = '%#LINECHAREND#' ..s:left
              let name.= end..info..(i==0?' ':init)
            else
              let init = '%#LINECHARINIT#'..s:right
              let end  = '%#LINECHAREND#' ..s:right
              let name.= (i==0?'%#LINECHARINIT# ':init)..info..end
            endif
          "}
          else      "{
            let info = '%#LINEITEM#'..info
            if revs
              "let char = i==last||i==node.meta.indx-1?'':'%#LINECHARINAC#'..s:ileft
              "let name.= char..' '..info..' '
              let name.= ' '..info..' '
            else
              "let char = i==last||i==node.meta.indx-1?'':'%#LINECHARINAC#'..s:iright
              "let name.= ' '..info..' '..char
              let name.= ' '..info..' '
            endif
          endif "}
        else
          let name.= iscurr?'%#LINECURR#':'%#LINEITEM#' 
          let name.= ' '..item.data.name..' '
        endif
      endif
      call add(names,name)
    endfor

    let names = revs?reverse(names):names

  else

    let list = execute('ls')
    let list = split(list,'\n')
    let leng = len(list)
    for item in list
      let file = matchstr(item,'".*"')
      let file = substitute(file,'"','','g')
      let file = fnamemodify(file,':t')
      let file = substitute(file,'[','','g')
      let file = substitute(file,']','','g')
      let item = split(item,'\s')
      call filter(item,"v:val!=''")
      let curr = item[1]
      let iscurr = curr=~'%'
      let closure= s:brackets&&iscurr&&leng>1
      let name   = ''
      if s:brackets
        let name = '%#Normal#'
        let space= leng>1?' ':''
        let name.= curr=~'%' && leng>1?'[':space
        let name.= file
        let name.= curr=~'%' && leng>1?']':space
      else
        let name.= curr=~'%'?'%#LINECURR#':'%#LINEITEM#' 
        let name.= ' '..file..' '
      endif
      call add(names,name)
    endfor

  endif

  return join(names,'')

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
