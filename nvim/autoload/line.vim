"-- auto/line.vim  --

if !NVPMTEST&&exists('__LINEAUTO__')|finish|endif
let __LINEAUTO__ = 1

"-- main functions --
fu! line#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif
  let s:nvim = has('nvim')

  let s:brackets = get(g:,'nvpm_brackets',1)

  let g:line = {}
  let g:line.mode = -1
  let g:line.tabnr= &showtabline
  let g:line.timer= -1
  let g:line.git  = ''

  if get(g:,'line_activate',1)
    call line#show()
  endif

endfu "}
fu! line#topl(...) "{

  let line  = ''

  let line .= '%#LINEFill#'
  let line .= '%t'

  return line

endfu "}
fu! line#botl(...) "{

  let line  = ''
  let indx  = 0

  let line .= line#list(3)

  let line .= g:nvpm.git.info
  let line .= '%#LINEFill#'
  let line .= ' ⬤ %{line#file()}'
  let line .= '%='
  let line .= '%y%m ⬤ %l,%c/%P'

  return line

endfu "}
fu! line#show(...) "{

  if exists('g:nvpm.mode')&&g:nvpm.mode|call nvpm#line()|else
    if exists('*nvpm#line')
      call nvpm#line('timer')
    endif
    set tabline=%!line#topl()
    set statusline=%!line#botl()
    let &showtabline = g:line.tabnr
    let &laststatus = 2+s:nvim*(1-(exists('g:zoom.mode')&&g:zoom.mode))
  endif

  let g:line.mode = 1

endfu "}
fu! line#hide(...) "{

  if exists('g:nvpm.git.timer')&&1+g:nvpm.git.timer
    call timer_stop(g:nvpm.git.timer)
    let g:nvpm.git.timer = -1
    let g:nvpm.git.info  = ''
  endif

  let g:line.tabnr = &showtabline
  set showtabline=0
  set laststatus=0

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
fu! line#list(...) "{

  let names = []
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
    let name   = ''
    if s:brackets
      let name = '%#Normal#'
      let space= leng>1?' ':''
      let name.= curr=~'%' && leng>1?'[':space
      let name.= file
      let name.= curr=~'%' && leng>1?']':space
    else
      let name.= curr=~'%'?'%#NVPMLINECURR#':'%#NVPMLINEITEM#' 
      let name.= ' '..file..' '
    endif
    call add(names,name)
  endfor

  return join(names,'')

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

