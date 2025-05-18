"-- auto/arbo.vim  --
if !exists('NVPMTEST')&&exists('_ARBOAUTO_')|finish|endif
let _ARBOAUTO_ = 1
let s:nvim = has('nvim')
let s:vim  = !s:nvim

"-- main functions --
fu! arbo#init(...) abort "{

  let g:arbo = get(g:,'arbo',{})

  let g:arbo.initload = get(g:arbo,'initload',0)
  let g:arbo.autocmds = get(g:arbo,'autocmds',0)
  let g:arbo.filetree = get(g:arbo,'filetree',0)
  let g:arbo.savebufs = get(g:arbo,'savebufs',0)&&g:arbo.initload

  let g:arbo.flux = {}
  if has_key(g:arbo,'lexicon')
    let g:arbo.flux.lexicon = g:arbo.lexicon
  else
    let g:arbo.flux.lexicon  = ''
    let g:arbo.flux.lexicon .= '|project proj scheme layout book'
    let g:arbo.flux.lexicon .= '|workspace arch archive architecture section'
    let g:arbo.flux.lexicon .= '|tab folder fold shelf package pack chapter'
    let g:arbo.flux.lexicon .= '|file buff buffer path entry node leaf page'
  endif
  let g:arbo.flux.fixt  = 1
  let g:arbo.flux.home  = 1
  let g:arbo.flux.file  = ''
  call flux#conf(g:arbo.flux)

  let g:arbo.mode = 0
  let g:arbo.term = ''

  let g:arbo.root = {}
  call arbo#zero()

  let g:arbo.file = {}
  let g:arbo.file.root = '.nvpm/arbo/'
  let g:arbo.file.flux = g:arbo.file.root..'flux/'
  let g:arbo.file.edit = g:arbo.file.root..'edit'
  let g:arbo.file.save = g:arbo.file.root..'save'

  if !argc()&&g:arbo.initload
    let g:arbo.initload = abs(g:arbo.initload)
    if filereadable(g:arbo.file.save)
      let flux = get(readfile(g:arbo.file.save),0,'')
      let root = eval(flux)
      if type(root)!=4
        call delete(g:arbo.file.save)
        return
      endif
      let g:arbo.root = root
      if g:arbo.savebufs
        call arbo#rend()
        for file in g:arbo.root.bufs
          exec 'badd '..file
        endfor
      endif
      if 1+arbo#find(g:arbo.file.edit) 
        call arbo#fell(g:arbo.file.edit)
      endif
      let g:arbo.mode = !!g:arbo.root.meta.leng
      call timer_start(g:arbo.initload,{->arbo#load()})
    endif
  endif

endfu "}
fu! arbo#load(...) abort "{

  if !g:arbo.mode|return|endif
  if exists('g:line.mode')&&g:line.mode
    let g:line.arbo = g:arbo.mode
    if exists('*line#show')
      call line#show()
    endif
  endif

  call arbo#curr()
  call arbo#rend()
  call arbo#save()

endfu "}
fu! arbo#grow(...) abort "{

  let file = a:1

  if empty(file)||!filereadable(file)|return 1|else
    let g:arbo.flux.file = file
    let root = flux#flux(g:arbo.flux)
    if empty(root)||empty(get(root,'list'))|return 2|endif
    let indx = arbo#find(file)
    if 1+indx
      let g:arbo.root.list[indx] = root
    else
      call add(g:arbo.root.list,root)
      let indx = g:arbo.root.meta.leng
      let g:arbo.root.meta.leng+=1
    endif
    let g:arbo.root.meta.indx = indx
  endif
  let g:arbo.mode = !!g:arbo.root.meta.leng

endfu "}
fu! arbo#fell(...) abort "{

  if !a:0||empty(a:1)
    call arbo#zero()
  else
    let file = a:1
    let indx = arbo#find(file)
    if 1+indx
      unlet g:arbo.root.list[indx]
      let g:arbo.root.meta.leng-= 1
      " just to keep indx inside bounds, because of new leng
      call arbo#indx(g:arbo.root.meta)
    else
      return 1
    endif
  endif
  let g:arbo.mode = !!g:arbo.root.meta.leng
  call arbo#load()

endfu "}
fu! arbo#jump(...) abort "{

  " TODO: make it as such that it jumps to an absolute location too
  let step = a:1
  let type = a:2

  if g:arbo.mode
    " leaves trim mode on non-leaf jumps
    if g:arbo.mode==2&&type<g:arbo.flux.leaftype
      wall
      call arbo#trim()
      return
    endif
    if g:arbo.root.curr==bufname()
      let meta = flux#seek(g:arbo.root,type).meta
      call arbo#indx(meta,meta.indx+step)
    endif
    " performs the JumpBack WorkFlow
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
fu! arbo#trim(...) abort "{

  if !isdirectory('.nvpm')||!isdirectory(g:arbo.file.flux)
    return 1
  endif

  if g:arbo.mode == 2
    let pick = bufname()
    if arbo#grow(pick)
      echohl WarningMsg
      echo  'ArboJump: the flux file "'.pick.'" is invalid. Aborting...'
      echohl None
      return 1
    else
      call arbo#fell(g:arbo.file.edit)
      let indx = arbo#find(pick)
      if 1+indx
        call arbo#indx(g:arbo.root.meta,indx)
      endif
    endif
    call arbo#load()
    return
  endif

  let fluxes = readdir(g:arbo.file.flux)
  let body   = []
  for file in fluxes
    let file = g:arbo.file.flux..file
    let line = 'file '..fnamemodify(file,':t:r')..':'..file
    call add(body,line)
  endfor

  let flux = ''
  if !empty(g:arbo.root.list)
    let flux = g:arbo.root.list[g:arbo.root.meta.indx].file
  endif

  call writefile(body,g:arbo.file.edit)
  call arbo#grow(g:arbo.file.edit)
  let g:arbo.mode = 2

  if !empty(flux)
    let node = flux#seek(g:arbo.root,g:arbo.flux.leaftype)
    for indx in range(node.meta.leng)
      let leaf = node.list[indx]
      if leaf.data.info == flux
        let node.meta.indx = indx
        break
      endif
    endfor
  endif

  call arbo#load()

endfu "}
fu! arbo#make(...) abort "{

  let name = get(a:000,0,'')

  let lines = ''
  let lines.= '# arbo new flux file,'
  let lines.= '# ------------------,'
  let lines.= '#,'
  let lines.= '# --> '..name..','
  let lines.= '#,'

  let lines = split(lines,',')
  call writefile(lines,name)
  call arbo#trim()

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

  let root = g:arbo.root
  let list = get(root,'list',[])

  if empty(root)||empty(list)|return 1|endif

  let node = flux#seek(root,g:arbo.flux.leaftype)
  if empty(node)|return 1|endif
  let curr = node.list[node.meta.indx].data.info
  if empty(curr)|return 1|endif

  let g:arbo.root.last = g:arbo.root.curr
  let g:arbo.root.curr = curr

endfu "}
fu! arbo#rend(...) abort "{

  let curr = g:arbo.root.curr
  let head = fnamemodify(curr,':h')..'/'

  exe 'edit '.curr

  if (curr=~'^.*\.flux$'||head==g:arbo.file.flux)&&&l:ft!='flux'
    setl filetype=flux
    setl commentstring=-%s
  endif
  if g:arbo.filetree&&!empty(head)&&!filereadable(head)&&&bt!='terminal'
    call mkdir(head,'p')
  endif

endfu "} 
fu! arbo#indx(...) abort "{

  let meta = a:1

  let meta.indx = get(a:,2,meta.indx)
  let meta.indx%= meta.leng               " limits range inside length
  let meta.indx+= (meta.indx<0)*meta.leng " keeps indx positive

endfu "}
fu! arbo#show(...) abort "{

  for key in keys(g:arbo)
    if key=='root'
      echo 'root :' g:arbo.root.meta
      for flux in g:arbo.root.list
        echo '  '..flux.file
      endfor
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
  if g:arbo.savebufs
    let g:arbo.root.bufs = []
  endif
  let g:arbo.root.meta = #{leng:0,indx:0,type:0}

endfu "}
fu! arbo#save(...) abort "{

  if g:arbo.initload
    if g:arbo.savebufs
      let bool = '!empty(v:val)'
      let bool.= '&&buflisted(v:val)'
      let bool.= '&&v:val!~"^.nvpm.*"'
      let bool.= '&&v:val!~"^.git.*"'
      let bool.= '&&v:val!~"^term:.*"'
      let list = map(range(1,bufnr('$')),'bufname(v:val)')
      let list = filter(list,bool)
      let g:arbo.root.bufs = list
    endif
    call writefile([string(g:arbo.root)],g:arbo.file.save)
  endif

endfu "}

"-- user function --
fu! arbo#user(...) abort "{

  if a:0==3 " user completions {

    let cmdline = trim(a:000[1])
    if cmdline=~'\CArboFell'
      let list = []
      for flux in g:arbo.root.list
        if flux.file==g:arbo.file.edit|continue|endif
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
    if cmdline=~'\v\CArboGrow'
      let files = readdir(g:arbo.file.flux)
      return files
    endif
    return []

  endif "}

  let func = a:1
  let args = get(a:,2,'')

  if func=='jump' "{
    if empty(args)
      call arbo#trim()
      return
    endif
    let user = matchlist(args,'\([+-]\)\(\d\+\)')
    if empty(user)
      echohl WarningMsg
      echo  'ArboJump: the entry "'.args.'" is invalid'
      echohl None
      return 1
    endif
    let step = v:count1 * [+1,-1][user[1]=='-']
    let type = user[2]
    let type+= 0 "type cast into an integer
    if type<0||type>g:arbo.flux.leaftype
      echohl WarningMsg
      echo  'ArboJump: the entry "'.args.'" is out of bounds'
      echohl None
      return 1
    endif
    call arbo#jump(step,type)
    return
  endif "}
  if func=='grow' "{
    if g:arbo.mode==2
      echohl WarningMsg
      echo  'ArboGrow: leave trim mode first'
      echohl None
      return 1
    endif
    let file = g:arbo.file.flux..args
    if isdirectory(file)
      let fluxes = readdir(file)
      for flux in fluxes
        call arbo#grow(simplify(file.'/'.flux))
      endfor
    else
      call arbo#grow(file)
    endif
    call arbo#load()
    return
  endif "}
  if func=='fell' "{
    if g:arbo.mode==2
      echohl WarningMsg
      echo  'ArboFell: leave trim mode first'
      echohl None
      return 1
    endif
  endif "}
  if func=='make' "{

    if empty(args)
      return 1
    endif
    call mkdir(g:arbo.file.flux,'p')
    let flux = g:arbo.file.flux..args
    if filereadable(flux)
      echohl WarningMsg
      echo 'ArboMake: flux file ['.args.'] exists. Choose another name!'
      echohl None
      return 1
    endif
    let args = flux
  endif "}

  call arbo#{func}(args)

endfu "}
