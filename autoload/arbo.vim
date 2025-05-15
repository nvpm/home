"-- auto/arbo.vim  --
if !exists('NVPMTEST')&&exists('_ARBOAUTO_')|finish|endif
let _ARBOAUTO_ = 1
let s:nvim = has('nvim')
let s:vim  = !s:nvim

"-- main functions --
fu! arbo#init(...) abort "{

  let user = get(g:,'arbo',{})

  let lexicon  = ''
  let lexicon .= '|project proj scheme layout book'
  let lexicon .= '|workspace arch archive architecture section'
  let lexicon .= '|tab folder fold shelf package pack chapter'
  let lexicon .= '|file buff buffer path entry node leaf page'

  let g:arbo = #{mode:0,user:{},flux:{},root:{},file:{},term:''}

  let g:arbo.user.filetree = get(user,'filetree')
  let g:arbo.user.initload = get(user,'initload')
  let g:arbo.user.autocmds = get(user,'autocmds')

  let g:arbo.flux.lexicon  = get(user,'lexicon',lexicon)
  let g:arbo.flux.fixt  = 1
  let g:arbo.flux.home  = 1
  let g:arbo.flux.file  = ''

  call arbo#zero()

  let g:arbo.file.root = '.nvpm/arbo/'
  let g:arbo.file.flux = g:arbo.file.root..'flux/'
  let g:arbo.file.edit = g:arbo.file.root..'edit'
  let g:arbo.file.save = g:arbo.file.root..'save'

  call flux#conf(g:arbo.flux)

  if !argc()&&g:arbo.user.initload
    if filereadable(g:arbo.file.save)
      let flux = get(readfile(g:arbo.file.save),0,'')
      let g:arbo = eval(flux)
      call timer_start(100,{->arbo#line()})
      "if !empty(flux) && filereadable(g:arbo.file.flux..flux)
      "  call arbo#load(flux)
      "endif
    endif
  endif

endfu "}
fu! arbo#edit(...) abort "{

  if !isdirectory('.nvpm')||!isdirectory(g:arbo.file.flux)
    return 1
  endif

  if g:arbo.mode == 2
    let file = bufname()
    for flux in g:arbo.root.list
      if flux.file==g:arbo.file.edit|continue|endif
      call arbo#grow(flux.file)
    endfor
    call arbo#fell(g:arbo.file.edit)
    call arbo#load(fnamemodify(file,':t'))
    return
  endif

  " makes the edit file otherwise
  let fluxes = readdir(g:arbo.file.flux)
  let body   = []
  for file in fluxes
    let file = g:arbo.file.flux..file
    let line = 'file '..fnamemodify(file,':t:r')..':'..file
    let curr = g:arbo.root.list[g:arbo.root.meta.indx].file
    if file == curr
      let body = [line]+body
      continue
    endif
    call add(body,line)
  endfor

  call writefile(body,g:arbo.file.edit)
  let g:arbo.mode = 2
  call arbo#load(g:arbo.file.edit)

endfu "}
fu! arbo#load(...) abort "{

  let file = a:1

  if g:arbo.mode!=2
    let file = g:arbo.file.flux..file
    let g:arbo.mode = 1
  endif

  call arbo#grow(file)

  call arbo#line()
  call arbo#curr()
  call arbo#rend()
  call arbo#save()

endfu "}
fu! arbo#grow(...) abort "{

  let file = a:1

  if empty(file)|return 1|endif

  if isdirectory(file)
    let fluxes = readdir(file)
    for flux in fluxes
      call arbo#grow(file.'/'.flux)
    endfor
  else
    let g:arbo.flux.file = file
    let fluxtree = flux#flux(g:arbo.flux)
    if empty(fluxtree)|return 2|endif
    let indx = arbo#find(file)
    if 1+indx
      let g:arbo.root.list[indx] = fluxtree
    else
      call add(g:arbo.root.list,fluxtree)
      let indx = g:arbo.root.meta.leng
      let g:arbo.root.meta.leng+=1
    endif
    let g:arbo.root.meta.indx = indx
  endif

endfu "}
fu! arbo#fell(...) abort "{

  if a:0
    let file = a:1
    let indx = -1
    if empty(file)
      let indx = g:arbo.root.meta.indx
    else
      let indx = arbo#find(file)
    endif
    if 1+indx
      unlet g:arbo.root.list[indx]
      let g:arbo.root.meta.leng-= 1
      " just to keep indx inside bounds
      call arbo#indx(g:arbo.root.meta,0)
    endif
  else
    call arbo#zero()
  endif
  let g:arbo.mode = !!g:arbo.root.meta.leng

endfu "}
fu! arbo#jump(...) abort "{

  let user = matchlist(a:1,'\([+-]\)\(\d\+\)')

  if empty(user)
    echohl WarningMsg
    echo  'ArboJump: the entry "'.a:1.'" is invalid'
    echohl None
    return 1
  endif

  let step = v:count1 * [+1,-1][user[1]=='-']
  let type = user[2]
  let type+= 0 "type cast into an integer

  if type<0||type>g:arbo.flux.leaftype
    echohl WarningMsg
    echo  'ArboJump: the entry "'.a:1.'" is out of bounds'
    echohl None
    return 2
  endif

  if g:arbo.mode
    " leaves edit mode
    if g:arbo.mode==2&&type<g:arbo.flux.leaftype
      for flux in readdir(g:arbo.file.flux)
        let flux = g:arbo.file.flux..flux
        exe 'write '..flux
      endfor
      call arbo#edit()
      return
    endif
    if g:arbo.root.curr==bufname()
      call arbo#indx(flux#seek(g:arbo.root,type).meta,step)
    endif
    " these two perform the JumpBack WorkFlow
    call arbo#curr()
    call arbo#rend()
  else
    if type == g:arbo.flux.leaftype
      if step < 0
        exe '::.,.+'.(v:count1-1).'bprev'
      else
        exe '::.,.+'.(v:count1-1).'bnext'
      endif
    elseif type == g:arbo.flux.leaftype-1
      if step < 0
        exe '::.,.+'.(v:count1-1).'tabprev'
      else
        exe '::.,.+'.(v:count1-1).'tabnext'
      endif
    endif
  endif

endfu "}
fu! arbo#make(...) abort "{

endfu "}
fu! arbo#term(...) abort "{

  if !bufexists(g:arbo.term)
    terminal
    let g:arbo.term = bufname()
  endif

  if !empty(matchstr(g:arbo.term,'term://.*'))
    call execute('edit! '..g:arbo.term)
  endif

endfu "}

"-- auxy functions --
fu! arbo#find(...) abort "{

  let file = a:1
  let root = get(a:,2,g:arbo.root)

  let indx = 0
  for flux in root.list
    if file==flux.file|return indx|endif
    let indx+=1
  endfor
  return -1

endfu "}
fu! arbo#curr(...) abort "{

  if !g:arbo.root.meta.leng|return 1|endif

  let list = g:arbo.root.list
  let flux = get(list,g:arbo.root.meta.indx,[])

  let node = flux#seek(flux,g:arbo.flux.leaftype)
  let curr = node.list[node.meta.indx].data.info
  if empty(curr)|return 2|endif

  let g:arbo.root.last = g:arbo.root.curr
  let g:arbo.root.curr = curr

endfu "}
fu! arbo#rend(...) abort "{

  let curr = simplify(g:arbo.root.curr)
  let curr = g:arbo.root.curr
  let head = fnamemodify(curr,':h')..'/'

  exe 'edit '.curr

  if (curr=~'^.*\.flux$'||head==g:arbo.file.flux)&&&l:ft!='flux'
    setl filetype=flux
    setl commentstring=-%s
  endif
  if g:arbo.user.filetree&&!empty(head)&&!filereadable(head)&&&bt!='terminal'
    call mkdir(head,'p')
  endif

endfu "}
fu! arbo#indx(...) abort "{

  let meta = a:1
  let step = a:2
  let meta.indx+= step                    " steps forwards or backwards
  let meta.indx%= meta.leng               " limits range inside length
  let meta.indx+= (meta.indx<0)*meta.leng " keeps indx positive

endfu "}
fu! arbo#show(...) abort "{

  for key in keys(g:arbo)
    if key=='root'
      echo 'root :' g:arbo.root.meta
      continue
    endif
    let item = g:arbo[key]
    echo key..' : '..string(item)
  endfor

endfu "}
fu! arbo#zero(...) abort "{

  let g:arbo.root.curr = ''
  let g:arbo.root.last = ''
  let g:arbo.root.list = []
  let g:arbo.root.meta = #{leng:0,indx:0,type:0}

endfu "}
fu! arbo#save(...) abort "{

  call writefile([string(g:arbo)],g:arbo.file.save)

endfu "}
fu! arbo#line(...) abort "{

  if exists('*line#show')&&exists('g:line.mode')&&g:line.mode
    let g:line.arbo = 1
    call line#show()
  endif

endfu "}

"-- user function --
fu! arbo#user(...) abort "{

  if a:0==3 " user completions {

    let cmdline = trim(a:000[1])
    if cmdline=~'\CArboFell'
      let list = []
      for flux in g:arbo.root.list
        call add(list,flux.file)
      endfor
      return list
    endif
    if cmdline=~'\CArboJump'
      let list = []
      for i in range(g:arbo.flux.leaftype+1)
        call add(list,'+'..i)
        call add(list,'-'..i)
      endfor
      return list
    endif
    if cmdline=~'\v\CArbo(Load|Make)'
      let files = readdir(g:arbo.file.flux)
      return files
    endif
    return ['unknown']

  endif "}

  let func = a:1
  let args = get(a:,2,'')
  call arbo#{func}(args)

endfu "}
