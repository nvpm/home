"-- auto/nvpm.vim  --
if !exists('NVPMTEST')&&exists('_NVPMAUTO_')|finish|endif
let _NVPMAUTO_ = 1
let s:nvim = has('nvim')

if !has_key(g:,'nvpmhome')
  let g:nvpmhome = resolve(expand('~/.nvpm'))
endif

"-- main functions --
fu! nvpm#init(...) abort "{ user variables & startup routines

  " either gets or sets g:nvpm
  let g:nvpm          = get(g:     , 'nvpm'     , {})
  let g:nvpm.initload = get(g:nvpm , 'initload' ,  0)
  let g:nvpm.autocmds = get(g:nvpm , 'autocmds' ,  1)
  let g:nvpm.filetree = get(g:nvpm , 'filetree' ,  0)
  let g:nvpm.invasive = get(g:nvpm , 'invasive' ,  1)

  " NvpmTerm options
  let g:nvpm.termexit = get(g:nvpm , 'termexit' ,  1)
  let g:nvpm.termlist = get(g:nvpm , 'termlist' ,  0)
  let g:nvpm.termkeep = get(g:nvpm , 'termkeep' ,  0)

  " builds the arbo conf dictionary
  let g:nvpm.arbo = {}
  if has_key(g:nvpm,'lexicon')
    let g:nvpm.arbo.lexicon = g:nvpm.lexicon
  else
    let g:nvpm.arbo.lexicon  = ''
    let g:nvpm.arbo.lexicon .= ',project scheme layout root'
    let g:nvpm.arbo.lexicon .= ',workspace archive trunk'
    let g:nvpm.arbo.lexicon .= ',tab folder shelf package branch'
    let g:nvpm.arbo.lexicon .= ',file buffer path entry leaf'
  endif
  let g:nvpm.arbo.syntax = 'nvpm'
  let g:nvpm.arbo.file   = ''
  call arbo#conf(g:nvpm.arbo) " listfies the lexicon

  " 0: unloaded tree, 1: loaded tree, 2: edit mode
  let g:nvpm.mode = 0
  let g:nvpm.home = getcwd()
  call nvpm#null('tree')
  call nvpm#null('term')

  " default file locations
  let g:nvpm.file = {}
  if g:nvpm.invasive
    let g:nvpm.file.root = '.nvpm/nvpm/'
  else
    let g:nvpm.file.root = g:nvpmhome..'/nvpm/locals'..getcwd()..'/'
  endif
  let g:nvpm.file.arbo = g:nvpm.file.root..'arbo/'
  let g:nvpm.file.edit = g:nvpm.file.root..'edit.arbo'
  let g:nvpm.file.tree = g:nvpm.file.root..'tree.json'

  if !argc()&&g:nvpm.initload
    let g:nvpm.initload = abs(g:nvpm.initload)
    if filereadable(g:nvpm.file.tree)
      let arbo = get(readfile(g:nvpm.file.tree),0,'')
      let root = json_decode(arbo)
      if type(root)!=4
        call delete(g:nvpm.file.tree)
        return
      endif
      let g:nvpm.tree = root
      if 1+nvpm#find(g:nvpm.file.edit)
        call nvpm#trim(g:nvpm.file.edit)
      endif
      let g:nvpm.mode = !!g:nvpm.tree.meta.leng
      call timer_start(g:nvpm.initload,{->nvpm#load()})
    endif
  endif

endfu "}
fu! nvpm#load(...) abort "{ loading mechanisms (line,zoom,rend,curr,save)

  if !g:nvpm.mode|return|endif

  call nvpm#line()
  call nvpm#zoom()
  call nvpm#curr()
  call nvpm#rend()
  call nvpm#save()

endfu "}
fu! nvpm#grow(...) abort "{ grows nvpm tree given an arbo file

  let file = a:1

  if empty(file)||!filereadable(file)|return 1|else
    let g:nvpm.arbo.file = file
    let root = arbo#arbo(g:nvpm.arbo)
    if empty(root)||empty(get(root,'list'))|return 2|endif
    let indx = nvpm#find(file)
    if 1+indx
      let g:nvpm.tree.list[indx] = root
    else
      call add(g:nvpm.tree.list,root)
      let indx = g:nvpm.tree.meta.leng
      let g:nvpm.tree.meta.leng+=1
    endif
    let g:nvpm.tree.meta.indx = indx
  endif
  let g:nvpm.mode = !!g:nvpm.tree.meta.leng

endfu "}
fu! nvpm#trim(...) abort "{ trims an arbo file from the nvpm tree

  if !a:0||empty(a:1)
    call nvpm#null('tree')
  else
    let file = a:1
    let indx = nvpm#find(file)
    if 1+indx
      unlet g:nvpm.tree.list[indx]
      let g:nvpm.tree.meta.leng-= 1
      " just to keep indx inside bounds, because of new leng
      call arbo#indx(g:nvpm.tree)
    else
      return 1
    endif
  endif

  let g:nvpm.mode = !!g:nvpm.tree.meta.leng
  if g:nvpm.mode
    return nvpm#load()
  endif
  echohl WarningMsg
  echo  'NvpmTrim: You killed the tree. Use NvpmGrow to grow it back!'
  echohl None
  call nvpm#line()

endfu "}
fu! nvpm#edit(...) abort "{ enters/leaves Nvpm Edit Mode

  if !isdirectory(g:nvpm.file.arbo)|return 1|endif

  if g:nvpm.mode == 2 "{
    let currarbo = bufname()

    " only leaves Edit Mode upon valid arbo file
    if nvpm#grow(currarbo)
      echohl WarningMsg
      echo  'NvpmEdit: the arbo file "'.currarbo.'" is invalid. Aborting...'
      echohl None
      return 1
    else
      " removes edit file generated subtree from the nvpm tree
      call nvpm#trim(g:nvpm.file.edit)

      " jumps to the subtree respective to the selected arbo file before
      " exiting Edit Mode
      let indx = nvpm#find(currarbo)
      if 1+indx
        call arbo#indx(g:nvpm.tree,indx)
      endif
    endif
    call nvpm#load()
    return
  endif "}

  " Edit Mode workspace creation
  let forest = readdir(g:nvpm.file.arbo)
  let body   = []
  if empty(g:nvpm.arbo.lexicon)|return 1|else
    let leafkeyw = get(g:nvpm.arbo.lexicon[-1],0,'')
  endif

  if empty(leafkeyw)|return 1|else
    for file in forest
      let file = g:nvpm.file.arbo..file
      let line = 'file '..fnamemodify(file,':t:r')..':'..file
      call add(body,line)
    endfor
  endif

  let arbo = ''
  if !empty(g:nvpm.tree.list)
    let arbo = g:nvpm.tree.list[g:nvpm.tree.meta.indx].file
  endif

  call writefile(body,g:nvpm.file.edit)
  call nvpm#grow(g:nvpm.file.edit)
  let g:nvpm.mode = 2

  if !empty(arbo)
    let node = arbo#seek(g:nvpm.tree,g:nvpm.arbo.leaftype)
    for indx in range(node.meta.leng)
      let leaf = node.list[indx]
      if leaf.info.info == arbo
        let node.meta.indx = indx
        break
      endif
    endfor
  endif

  call nvpm#load()

endfu "}
fu! nvpm#jump(...) abort "{ jumps between nodes

  " TODO: make it as such that it jumps to an absolute location too
  let step = a:1
  let type = a:2

  " jumps for loaded nvpm tree
  if g:nvpm.mode

    " leaves edit mode on non-leaf jumps
    if g:nvpm.mode==2&&type<g:nvpm.arbo.leaftype
      wall
      call nvpm#edit()
      return
    endif

    " updates indx based on given step
    if g:nvpm.tree.curr==bufname()
      let node = arbo#seek(g:nvpm.tree,type)
      if !has_key(node,'meta')|return 1|endif
      call arbo#indx(node,node.meta.indx+step)
    endif

    " renders the newly calculated current leaf node
    call nvpm#curr()
    call nvpm#rend()

  " jumps for unloaded nvpm tree
  else
    if type == g:nvpm.arbo.leaftype
      if step < 0
        exe '::.,.+'.(v:count1-1).'bprev'
      else
        exe '::.,.+'.(v:count1-1).'bnext'
      endif
    elseif type == g:nvpm.arbo.leaftype-1
      if step < 0
        exe '::.,.+'.(v:count1-1).'tabprev'
      else
        exe '::.,.+'.(v:count1-1).'tabnext'
      endif
    endif
  endif

endfu "}
fu! nvpm#make(...) abort "{ makes new arbo file and enters Edit Mode on it

  let name = get(a:000,0,'')

  let lines = ''
  let lines.= '# nvpm new arbo file,'
  let lines.= '# ------------------,'
  let lines.= '#,'
  let lines.= '# --> '..name..','
  let lines.= '#,'

  let lines = split(lines,',')
  call writefile(lines,name)
  call nvpm#edit()

endfu "}
fu! nvpm#term(...) abort "{ creates the nvpm wild terminal

  let name = get(a:,1,'main')
  let name = empty(name)?'main':name
  let cmd  = get(a:,2,$SHELL)

  if has_key(g:nvpm.term,name)&&bufexists(g:nvpm.term[name])
    exe 'buffer '..g:nvpm.term[name]
    if !s:nvim|exe 'normal i'|endif
  else
    let conf = {}
    if s:nvim
      let conf.term    = v:true
      let conf.on_exit = function('nvpm#auto',['termexit'])
      if name=='main'
        if g:nvpm.mode==2|let conf.cwd = g:nvpm.file.root|endif
        call jobstart(cmd,conf)
      elseif !g:nvpm.termkeep
        let hold = "&&echo&&read -p 'PRESS [Enter] TO EXIT: '"
        call jobstart(cmd..hold,conf)
      else
        call chansend(jobstart($SHELL,conf),cmd.."\n")
      endif
      setl ft=
    else
      let conf.curwin = 1
      let conf.exit_cb = function('nvpm#auto',['termexit'])
      if name=='main'
        if g:nvpm.mode==2|let conf.cwd = g:nvpm.file.root|endif
        let cmd=''
      else
        let cmd.="\n"
      endif
      call term_sendkeys(term_start($SHELL,conf),cmd)
    endif
    let g:nvpm.term[name] = bufnr()
    if !g:nvpm.termlist|setl nobuflisted|endif
  endif
  startinsert

endfu "}

"-- auxy functions --
fu! nvpm#find(...) abort "{ looks for a given arbo file in the nvpm tree

  let file = a:1
  let root = get(a:,2,g:nvpm.tree)

  let indx = 0
  for arbo in root.list
    if file==arbo.file|return indx|endif
    let indx+=1
  endfor
  return -1

endfu "}
fu! nvpm#curr(...) abort "{ calculates the current leaf node in the nvpm tree

  let root = g:nvpm.tree
  let list = get(root,'list',[])

  if empty(root)||empty(list)|return 1|endif

  let node = arbo#seek(root,g:nvpm.arbo.leaftype)
  if empty(node)|return 1|endif
  let curr = node.list[node.meta.indx].info.info
  if empty(curr)|return 1|endif

  let g:nvpm.tree.last = g:nvpm.tree.curr
  let g:nvpm.tree.curr = curr

endfu "}
fu! nvpm#rend(...) abort "{ renders the current leaf node

  let curr = g:nvpm.tree.curr
  let head = fnamemodify(curr,':h')..'/'

  exe 'edit '.curr

  if curr=~'^.*\.arbo$'||head==g:nvpm.file.arbo
    setl nobuflisted
    if &l:ft!='arbo'
      setl filetype=arbo
    endif
  endif
  if g:nvpm.filetree&&!empty(head)&&!filereadable(head)&&&bt!='terminal'
    call mkdir(head,'p')
  endif

endfu "}
fu! nvpm#show(...) abort "{ pretty-prints the nvpm tree

  for key in keys(g:nvpm)
    if key=='root'
      echo 'root :' g:nvpm.tree.meta
      for arbo in g:nvpm.tree.list
        echo '  '..arbo.file
      endfor
      continue
    endif
    let item = g:nvpm[key]
    echo key..' : '..string(item)
  endfor

endfu "}
fu! nvpm#null(...) abort "{ resets the nvpm tree

  if !a:0|return|endif

  if a:1=='tree'
    let g:nvpm.tree      = {}
    let g:nvpm.tree.curr = ''
    let g:nvpm.tree.last = ''
    let g:nvpm.tree.list = []
    let g:nvpm.tree.meta = #{leng:0,indx:0,type:0}
  elseif a:1=='term'
    let g:nvpm.term = {}
  endif

endfu "}
fu! nvpm#save(...) abort "{ saves the state of the nvpm tree for startup use

  if g:nvpm.initload&&g:nvpm.mode==1
    call writefile([json_encode(g:nvpm.tree)],g:nvpm.file.tree)
  endif

endfu "}
"TODO: re-investigate why these are necessary
fu! nvpm#line(...) abort "{ initializes nvpm/line

  if exists('g:line.mode')&&g:line.mode
    let g:line.nvpm = g:nvpm.mode
    if exists('*line#show')
      call line#show()
    endif
  endif

endfu "}
fu! nvpm#zoom(...) abort "{ initializes nvpm/zoom

  if exists('*zoom#show')&&exists('g:zoom.mode')&&g:zoom.mode
    only
    call zoom#show()
  endif

endfu "}

"-- user function --
fu! nvpm#user(...) abort "{ handles all user input (user -> nvpm)

  if a:0==3 " <tab> completions {
    let cmdline = trim(a:000[1])
    if  cmdline=~'\CNvpmTrim' "{
      let list = []
      for arbo in g:nvpm.tree.list
        if arbo.file==g:nvpm.file.edit|continue|endif
        call add(list,fnamemodify(arbo.file,':t'))
      endfor
      return list
    endif "}
    if  cmdline=~'\CNvpmJump' "{
      let list = []
      for i in range(g:nvpm.arbo.leaftype+1)
        call add(list,'+'..i)
        call add(list,'-'..i)
      endfor
      return list
    endif "}
    if  cmdline=~'\CNvpmGrow' "{
      let files = readdir(g:nvpm.file.arbo)
      return files
    endif "}
    if  cmdline=~'\CNvpmTerm' "{
      return keys(g:nvpm.term)
    endif "}
    return []
  endif "}

  let func = a:1
  let args = trim(get(a:,2,''))

  if func=='jump' "{
    if empty(args)|return|endif
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
    if type<0||type>g:nvpm.arbo.leaftype
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
      echo  'NvpmGrow: leave Edit Mode first'
      echohl None
      return 1
    endif
    let file = g:nvpm.file.arbo..args
    if isdirectory(file)
      let forest = readdir(file)
      for arbo in forest
        call nvpm#grow(simplify(file.'/'.arbo))
      endfor
    else
      call nvpm#grow(file)
    endif
    call nvpm#load()
    return
  endif "}
  if func=='trim' "{
    if g:nvpm.mode==2
      echohl WarningMsg
      echo  'NvpmTrim: leave Edit Mode first'
      echohl None
      return 1
    endif
    if empty(trim(args))&&g:nvpm.mode|return nvpm#trim()|endif
    let args = g:nvpm.file.arbo..args
    call nvpm#trim(args)
    return
  endif "}
  if func=='make' "{

    if empty(args)|return|endif

    call mkdir(g:nvpm.file.arbo,'p')
    let arbo = g:nvpm.file.arbo..args..'.arbo'
    if filereadable(arbo)
      echohl WarningMsg
      echo 'NvpmMake: arbo file ['.args.'.arbo] exists. Choose another name!'
      echohl None
      return 1
    endif
    call nvpm#make(arbo)
    return
  endif "}
  if func=='term' "{
    if !empty(args)
      let args = split(args)
      let name = args[0]..' '..get(args,1,'')
      call nvpm#term(name,join(args))
      return
    endif
  endif "}

  call nvpm#{func}(args)

endfu "}
fu! nvpm#auto(...) abort "{ handles autocmds & callbacks

  let func = get(a:,1,'')

  if func=='termexit'
    "TODO: save line number and jump to it when exiting
    if !g:nvpm.termexit|return|endif
    let bufnr = bufnr()
    call nvpm#rend()
    exec 'bdelete '..bufnr
    for key in keys(g:nvpm.term)
      if bufnr==g:nvpm.term[key]
        call remove(g:nvpm.term,key)
        break
      endif
    endfor
  endif

endfu "}
