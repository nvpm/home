"-- auto/nvpm.vim  --
if !exists('NVPMTEST')&&exists('_NVPMAUTO_')|finish|endif
let _NVPMAUTO_ = 1
let s:nvim = has('nvim')
let s:vim  = !s:nvim

"-- main functions --
fu! nvpm#init(...) abort "{

  let g:nvpm = get(g:,'nvpm',{})

  let g:nvpm.initload = get(g:nvpm,'initload',0)
  let g:nvpm.autocmds = get(g:nvpm,'autocmds',0)
  let g:nvpm.filetree = get(g:nvpm,'filetree',0)
  let g:nvpm.savebufs = get(g:nvpm,'savebufs',0)&&g:nvpm.initload

  let g:nvpm.flux = {}
  if has_key(g:nvpm,'lexicon')
    let g:nvpm.flux.lexicon = g:nvpm.lexicon
  else
    let g:nvpm.flux.lexicon  = ''
    let g:nvpm.flux.lexicon .= ',project proj scheme layout book'
    let g:nvpm.flux.lexicon .= ',workspace arch archive architecture section'
    let g:nvpm.flux.lexicon .= ',tab folder fold shelf package pack chapter'
    let g:nvpm.flux.lexicon .= ',file buff buffer path entry node leaf page'
  endif
  " these will be gone once the flux synx var is implemented
  let g:nvpm.flux.fixt  = 1
  let g:nvpm.flux.home  = 1
  let g:nvpm.flux.file  = ''
  call flux#conf(g:nvpm.flux)

  let g:nvpm.mode = 0
  let g:nvpm.term = ''

  let g:nvpm.root = {}
  call nvpm#zero()

  let g:nvpm.file = {}
  let g:nvpm.file.root = '.nvpm/nvpm/'
  let g:nvpm.file.flux = g:nvpm.file.root..'flux/'
  let g:nvpm.file.edit = g:nvpm.file.root..'edit'
  let g:nvpm.file.save = g:nvpm.file.root..'save'

  if !argc()&&g:nvpm.initload
    let g:nvpm.initload = abs(g:nvpm.initload)
    if filereadable(g:nvpm.file.save)
      let flux = get(readfile(g:nvpm.file.save),0,'')
      let root = eval(flux)
      if type(root)!=4
        call delete(g:nvpm.file.save)
        return
      endif
      let g:nvpm.root = root
      if g:nvpm.savebufs
        call nvpm#rend()
        for file in g:nvpm.root.bufs
          exec 'badd '..file
        endfor
      endif
      if 1+nvpm#find(g:nvpm.file.edit) 
        call nvpm#fell(g:nvpm.file.edit)
      endif
      let g:nvpm.mode = !!g:nvpm.root.meta.leng
      call timer_start(g:nvpm.initload,{->nvpm#load()})
    endif
  endif

endfu "}
fu! nvpm#load(...) abort "{

  if !g:nvpm.mode|return|endif
  if exists('g:line.mode')&&g:line.mode
    let g:line.nvpm = g:nvpm.mode
    if exists('*line#show')
      call line#show()
    endif
  endif
  if exists('*zoom#show')&&exists('g:zoom.mode')&&g:zoom.mode
    only
    call zoom#show()
  endif

  call nvpm#curr()
  call nvpm#rend()
  call nvpm#save()

endfu "}
fu! nvpm#grow(...) abort "{

  let file = a:1

  if empty(file)||!filereadable(file)|return 1|else
    let g:nvpm.flux.file = file
    let root = flux#flux(g:nvpm.flux)
    if empty(root)||empty(get(root,'list'))|return 2|endif
    let indx = nvpm#find(file)
    if 1+indx
      let g:nvpm.root.list[indx] = root
    else
      call add(g:nvpm.root.list,root)
      let indx = g:nvpm.root.meta.leng
      let g:nvpm.root.meta.leng+=1
    endif
    let g:nvpm.root.meta.indx = indx
  endif
  let g:nvpm.mode = !!g:nvpm.root.meta.leng

endfu "}
fu! nvpm#fell(...) abort "{

  if !a:0||empty(a:1)
    call nvpm#zero()
  else
    let file = a:1
    let indx = nvpm#find(file)
    if 1+indx
      unlet g:nvpm.root.list[indx]
      let g:nvpm.root.meta.leng-= 1
      " just to keep indx inside bounds, because of new leng
      call nvpm#indx(g:nvpm.root.meta)
    else
      return 1
    endif
  endif
  let g:nvpm.mode = !!g:nvpm.root.meta.leng
  call nvpm#load()

endfu "}
fu! nvpm#jump(...) abort "{

  " TODO: make it as such that it jumps to an absolute location too
  let step = a:1
  let type = a:2

  if g:nvpm.mode
    " leaves trim mode on non-leaf jumps
    if g:nvpm.mode==2&&type<g:nvpm.flux.leaftype
      wall
      call nvpm#trim()
      return
    endif
    if g:nvpm.root.curr==bufname()
      let meta = flux#seek(g:nvpm.root,type).meta
      call nvpm#indx(meta,meta.indx+step)
    endif
    " performs the JumpBack WorkFlow
    call nvpm#curr()
    call nvpm#rend()
  else
    if type == g:nvpm.flux.leaftype
      if step < 0
        exe '::.,.+'.(v:count1-1).'bprev'
      else
        exe '::.,.+'.(v:count1-1).'bnext'
      endif
    elseif type == g:nvpm.flux.leaftype-1
      if step < 0
        exe '::.,.+'.(v:count1-1).'tabprev'
      else
        exe '::.,.+'.(v:count1-1).'tabnext'
      endif
    endif
  endif

endfu "}
fu! nvpm#trim(...) abort "{

  if !isdirectory('.nvpm')||!isdirectory(g:nvpm.file.flux)
    return 1
  endif

  if g:nvpm.mode == 2
    let pick = bufname()
    if nvpm#grow(pick)
      echohl WarningMsg
      echo  'NvpmJump: the flux file "'.pick.'" is invalid. Aborting...'
      echohl None
      return 1
    else
      call nvpm#fell(g:nvpm.file.edit)
      let indx = nvpm#find(pick)
      if 1+indx
        call nvpm#indx(g:nvpm.root.meta,indx)
      endif
    endif
    call nvpm#load()
    return
  endif

  let fluxes = readdir(g:nvpm.file.flux)
  let body   = []
  for file in fluxes
    let file = g:nvpm.file.flux..file
    let line = 'file '..fnamemodify(file,':t:r')..':'..file
    call add(body,line)
  endfor

  let flux = ''
  if !empty(g:nvpm.root.list)
    let flux = g:nvpm.root.list[g:nvpm.root.meta.indx].file
  endif

  call writefile(body,g:nvpm.file.edit)
  call nvpm#grow(g:nvpm.file.edit)
  let g:nvpm.mode = 2

  if !empty(flux)
    let node = flux#seek(g:nvpm.root,g:nvpm.flux.leaftype)
    for indx in range(node.meta.leng)
      let leaf = node.list[indx]
      if leaf.info.info == flux
        let node.meta.indx = indx
        break
      endif
    endfor
  endif

  call nvpm#load()

endfu "}
fu! nvpm#make(...) abort "{

  let name = get(a:000,0,'')

  let lines = ''
  let lines.= '# nvpm new flux file,'
  let lines.= '# ------------------,'
  let lines.= '#,'
  let lines.= '# --> '..name..','
  let lines.= '#,'

  let lines = split(lines,',')
  call writefile(lines,name)
  call nvpm#trim()

endfu "}
fu! nvpm#term(...) abort "{

  if !bufexists(g:nvpm.term)
    terminal
    let g:nvpm.term = bufname()
  endif

  if !empty(matchstr(g:nvpm.term,'term://.*'))
    call execute('edit! '..g:nvpm.term)
  endif

endfu "}

"-- auxy functions --
fu! nvpm#find(...) abort "{

  let file = a:1
  let root = get(a:,2,g:nvpm.root)

  let indx = 0
  for flux in root.list
    if file==flux.file|return indx|endif
    let indx+=1
  endfor
  return -1

endfu "}
fu! nvpm#curr(...) abort "{

  let root = g:nvpm.root
  let list = get(root,'list',[])

  if empty(root)||empty(list)|return 1|endif

  let node = flux#seek(root,g:nvpm.flux.leaftype)
  if empty(node)|return 1|endif
  let curr = node.list[node.meta.indx].info.info
  if empty(curr)|return 1|endif

  let g:nvpm.root.last = g:nvpm.root.curr
  let g:nvpm.root.curr = curr

endfu "}
fu! nvpm#rend(...) abort "{

  let curr = g:nvpm.root.curr
  let head = fnamemodify(curr,':h')..'/'

  exe 'edit '.curr

  if (curr=~'^.*\.flux$'||head==g:nvpm.file.flux)&&&l:ft!='flux'
    setl filetype=flux
    setl commentstring=-%s
  endif
  if g:nvpm.filetree&&!empty(head)&&!filereadable(head)&&&bt!='terminal'
    call mkdir(head,'p')
  endif

endfu "} 
fu! nvpm#indx(...) abort "{

  let meta = a:1

  let meta.indx = get(a:,2,meta.indx)
  let meta.indx%= meta.leng               " limits range inside length
  let meta.indx+= (meta.indx<0)*meta.leng " keeps indx positive

endfu "}
fu! nvpm#show(...) abort "{

  for key in keys(g:nvpm)
    if key=='root'
      echo 'root :' g:nvpm.root.meta
      for flux in g:nvpm.root.list
        echo '  '..flux.file
      endfor
      continue
    endif
    let item = g:nvpm[key]
    echo key..' : '..string(item)
  endfor

endfu "}
fu! nvpm#zero(...) abort "{

  let g:nvpm.root.curr = ''
  let g:nvpm.root.last = ''
  let g:nvpm.root.list = []
  if g:nvpm.savebufs
    let g:nvpm.root.bufs = []
  endif
  let g:nvpm.root.meta = #{leng:0,indx:0,type:0}

endfu "}
fu! nvpm#save(...) abort "{

  if g:nvpm.initload
    if g:nvpm.savebufs
      let bool = '!empty(v:val)'
      let bool.= '&&buflisted(v:val)'
      let bool.= '&&v:val!~"^.nvpm.*"'
      let bool.= '&&v:val!~"^.git.*"'
      let bool.= '&&v:val!~"^term:.*"'
      let list = map(range(1,bufnr('$')),'bufname(v:val)')
      let list = filter(list,bool)
      let g:nvpm.root.bufs = list
    endif
    call writefile([string(g:nvpm.root)],g:nvpm.file.save)
  endif

endfu "}

"-- user function --
fu! nvpm#user(...) abort "{

  if a:0==3 " user completions {

    let cmdline = trim(a:000[1])
    if cmdline=~'\CNvpmFell'
      let list = []
      for flux in g:nvpm.root.list
        if flux.file==g:nvpm.file.edit|continue|endif
        call add(list,flux.file)
      endfor
      return list
    endif
    if cmdline=~'\CNvpmJump'
      let list = []
      for i in range(g:nvpm.flux.leaftype+1)
        call add(list,'+'..i)
        call add(list,'-'..i)
      endfor
      return list
    endif
    if cmdline=~'\CNvpmGrow'
      let files = readdir(g:nvpm.file.flux)
      return files
    endif
    return []

  endif "}

  let func = a:1
  let args = get(a:,2,'')

  if func=='jump' "{
    if empty(args)
      call nvpm#trim()
      return
    endif
    let user = matchlist(args,'\([+-]\)\(\d\+\)')
    if empty(user)
      echohl WarningMsg
      echo  'NvpmJump: the entry "'.args.'" is invalid'
      echohl None
      return 1
    endif
    let step = v:count1 * [+1,-1][user[1]=='-']
    let type = user[2]
    let type+= 0 "type cast into an integer
    if type<0||type>g:nvpm.flux.leaftype
      echohl WarningMsg
      echo  'NvpmJump: the entry "'.args.'" is out of bounds'
      echohl None
      return 1
    endif
    call nvpm#jump(step,type)
    return
  endif "}
  if func=='grow' "{
    if g:nvpm.mode==2
      echohl WarningMsg
      echo  'NvpmGrow: leave trim mode first'
      echohl None
      return 1
    endif
    let file = g:nvpm.file.flux..args
    if isdirectory(file)
      let fluxes = readdir(file)
      for flux in fluxes
        call nvpm#grow(simplify(file.'/'.flux))
      endfor
    else
      call nvpm#grow(file)
    endif
    call nvpm#load()
    return
  endif "}
  if func=='fell' "{
    if g:nvpm.mode==2
      echohl WarningMsg
      echo  'NvpmFell: leave trim mode first'
      echohl None
      return 1
    endif
  endif "}
  if func=='make' "{

    if empty(args)
      return 1
    endif
    call mkdir(g:nvpm.file.flux,'p')
    let flux = g:nvpm.file.flux..args
    if filereadable(flux)
      echohl WarningMsg
      echo 'NvpmMake: flux file ['.args.'] exists. Choose another name!'
      echohl None
      return 1
    endif
    let args = flux
  endif "}

  call nvpm#{func}(args)

endfu "}
