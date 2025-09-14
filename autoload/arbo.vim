"-- auto/arbo.vim  --
if !exists('NVPMTEST')&&exists('_ARBOAUTO_')|finish|endif
let _ARBOAUTO_=1
let s:nvim = has('nvim')
let s:vim  = !s:nvim

"-- main functions --
fu! arbo#arbo(...) abort "{

  if !a:0|return {}|else|let s:conf=arbo#argv(a:000)|endif

  call arbo#conf()
  call arbo#read()
  call arbo#trim()
  call arbo#endl()
  call arbo#list()
  call arbo#cuts()
  call arbo#loop()
  call arbo#home()
  retu arbo#data()

endfu "}
fu! arbo#data(...) abort "{

  let list = get(s:conf,'list',[])
  let leng = get(s:conf,'leng',len(list))
  let home = get(s:conf,'HOME','')

  let tree = arbo#tree(list,leng,home)

  let tree.file = s:conf.file

  "if get(s:conf,'fixt',0)|call arbo#fixt(tree,s:conf)|endif

  " leave conf the way it was
  if has_key(s:conf,'leng')|unlet s:conf.leng|endif
  if has_key(s:conf,'list')|unlet s:conf.list|endif
  if has_key(s:conf,'body')|unlet s:conf.body|endif
  if has_key(s:conf,'HOME')|unlet s:conf.HOME|endif
  if has_key(s:conf,'file')|unlet s:conf.file|endif

  unlet s:conf

  return tree

endfu "}
fu! arbo#fixt(...) abort "{

  let root = get(a:000,0,{})
  let conf = get(a:000,1,{})

  if empty(root)|return|endif
  if empty(conf)|return|endif

  if has_key(root,'list')&&root.meta.leng
    let leng = root.meta.leng
    let mintype = conf.leaftype
    let minkeyw = conf.lexicon[mintype][0]
    for node in root.list
      let type = arbo#find(conf.lexicon,node.info.keyw)
      if type<mintype
        let mintype = type
        let minkeyw = node.info.keyw
      endif
    endfor
    let indx = 0
    let list = []
    let node = root.list[indx]
    while indx<root.meta.leng&&arbo#find(conf.lexicon,node.info.keyw)>mintype
      call add(list,node)
      let indx+=1
      let node = root.list[indx]
    endwhile
    if indx
      let next = root.list[indx]
      let node = #{data:{},meta:{}}
      let node.info.keyw = minkeyw
      let node.info.name = '<unnamed>'
      let node.info.info = ''
      let node.meta.leng = len(list)
      let node.meta.indx = 0
      let node.meta.type = arbo#find(conf.lexicon,list[0].info.keyw)
      let node.list = list
      let root.list = [node]+root.list[indx:]
      let root.meta.leng = len(root.list)
    endif
    for node in root.list
      if has_key(node,'list')
        call arbo#fixt(node,conf)
      endif
    endfor
  endif

endfu "}
fu! arbo#tree(...) abort "{

  let list = get(a:000,0,[])
  let leng = get(a:000,1,len(list))
  let home = get(a:000,2,'')
  let home = [home .. '/',home][empty(home)]
  let indx = 0

  let tree = #{list:[],meta:#{leng:0,indx:0,type:-2}}

  " loop over conf.list
  while indx<leng

    " catches node from given nodelist
    let node = list[indx]|let indx+=1
    let path = [home,''][node.absl] .. node.info.info

    let node.type = arbo#find(s:conf.lexicon     ,node.info.keyw)
    let node.tree = arbo#find(s:conf.lexicon[:-2],node.info.keyw)

    " recursively handles non-leaf nodes (sub-tree)
    if 1+node.tree
      let init = indx
      while indx<leng
        let item = list[indx]
        let item.tree = arbo#find(s:conf.lexicon[:-2],item.info.keyw)
        " breaks at next same (or higher) type node
        if 1+item.tree && item.tree<=node.tree
          break
        endif
        let indx+=1
      endwhile

      " extend node fields with.list, indx and leng recursively
      let sublist = list[init:indx-1]
      let subtree = arbo#tree(sublist,indx-init,path)
      call extend(node,subtree)

    endif

    " skips non-matching nodes
    if node.type<0|continue|endif

    " handles cut-tree functionality
    if node.cuts==1|continue|endif
    if node.cuts==2| break  |endif

    " a leafless tree perishes
    if empty(get(node,'list','leafless'))|continue|endif

    " transfers node type to parent node
    let tree.meta.type = node.type

    " handles home for leaf nodes
    if -1==node.tree && get(s:conf,'home')
      let info = empty(node.info.info)?node.info.name:node.info.info
      let node.info.info = [home .. info,info][node.absl]
      let node.info.info = simplify(node.info.info)
     "let node.info.info = substitute(node.info.info,'//','/','g')
     "let node.info.info = substitute(node.info.info,'/$','','')
    endif

    " remove unnecessary node-fields
    unlet node.cuts
    unlet node.tree
    unlet node.absl
    unlet node.type

    " adds node to tree & increment length
    call add(tree.list,node)|let tree.meta.leng+=1

  endwhile

  return tree

endfu "}
fu! arbo#skel(...) abort "{
endfu "}

"-- conf functions --
fu! arbo#conf(...) abort "{

  if !a:0|return arbo#conf(s:conf)|else|let conf=a:1|endif
  if !has_key(conf,'lexicon')|let conf.lexicon=''|endif
  if type(conf.lexicon)==type('')
    let conf.lexicon = split(conf.lexicon,',')
    let list = []
    for type in conf.lexicon
      if empty(type)|continue|endif
      call add(list,split(type,'\s'))
    endfor
    let conf.lexicon = list
  endif

  let conf.leaftype = len(conf.lexicon)

endfu "}
fu! arbo#read(...) abort "{

  if !has_key(s:conf,'file')|return|endif
  if !empty(s:conf.file)
    if type(s:conf.file)==type('')
      if filereadable(s:conf.file)
        let s:conf.body = readfile(s:conf.file)
      endif
    endif
  endif
  " makes sure it's a body of string-lines
  if !has_key(s:conf,'body')|let s:conf.body=[]|else
    call filter(s:conf.body,'type(v:val)==type("")')
  endif
  let s:conf.leng = len(s:conf.body)

endfu "}
fu! arbo#trim(...) abort "{

  if has_key(s:conf,'body')
    let comm = '\c\s*[#{}].*'
    let leng = get(s:conf,'leng',len(s:conf.body))|let s:conf.leng=0
    let indx = 0
    let body = []
    while indx<leng
      let line = s:conf.body[indx]
      let line = trim(substitute(line,comm,'',''))
      if !empty(line)|call add(body,line)|let s:conf.leng+=1|endif
      let indx+=1
    endwhile
    let s:conf.body = body
  endif

endfu "}
fu! arbo#endl(...) abort "{

  if has_key(s:conf,'body')
    let endl = '\m\s*,\s*'
    let leng = get(s:conf,'leng',len(s:conf.body))|let s:conf.leng=0
    let indx = 0
    let body = []
    while indx<leng
      let line = s:conf.body[indx]|let indx+=1
      let line = split(line,endl)
      call extend(body,line)
      let s:conf.leng+=len(line)
    endwhile
    let s:conf.body = body
  endif

endfu "}
fu! arbo#list(...) abort "{

  let objc = get(a:,1,s:conf)

  if type(objc)==type({})
    if has_key(objc,'body')
      let objc.list = arbo#list(objc.body)
      let objc.leng = len(objc.list)
    endif
  endif
  if type(objc)==type([])
    let body = objc
    let list = []
    for line in body
      let node = arbo#node(line)
      call add(list,node)
    endfor
    return list
  endif

endfu "}
fu! arbo#cuts(...) abort "{

  let objc = get(a:,1,s:conf)

  if type(objc)==type({})
    if has_key(objc,'list')
      let objc.list = arbo#cuts(objc.list)
      let objc.leng = len(objc.list)
    endif
  endif
  if type(objc)==type([])
    let leng = len(objc)
    let cuts = 0
    let indx = 0
    let newlist = []
    while indx<leng
      let node = objc[indx]|let indx+=1
      if node.cuts>=3|break|endif
      let stda = empty(node.info.keyw..node.info.name..node.info.info)
      if stda && node.cuts
        let cuts = node.cuts
        continue
      endif
      if cuts
        let node.cuts = cuts
        let cuts = 0
      endif
      call add(newlist,node)
    endwhile
    return newlist
  endif

endfu "}
fu! arbo#loop(...) abort "{

  if has_key(s:conf,'list')
    let indx = 0
    let list = []
    let leng = get(s:conf,'leng',len(s:conf.list))
    let s:conf.leng = 0
    while indx<leng
      let node = s:conf.list[indx]|let indx+=1
      if node.info.keyw !=? 'loop'
        call add(list,node)
        let s:conf.leng+=1
      else " found loop keyword {
        let loop = []
        while indx<leng
          let item = s:conf.list[indx]|let indx+=1
          if item.info.keyw==?'endl'|break|endif
          if node.cuts|continue|endif
          call add(loop,item)
        endwhile
        if node.cuts==1|continue|endif
        if node.cuts==2
          let s:conf.list[indx].cuts = 2
          continue
        endif
        let info = empty(node.info.info)?node.info.name:node.info.info
        let name = empty(node.info.info)?'':node.info.name
        let vars = split(info,' ')
        let vars = arbo#list(vars)
        let vars = arbo#cuts(vars)
        for node in vars "{
          if node.cuts==1|continue|endif
          if node.cuts>=2|  break |endif
          let var = node.info.keyw
          for item in loop
            let info = deepcopy(item)
            if empty(name)
              let info.info.name = substitute(info.info.name,'$_',var,'g')
              let info.info.info = substitute(info.info.info,'$_',var,'g')
            else
              let info.info.name = substitute(info.info.name,'$('..name..')',var,'g')
              let info.info.info = substitute(info.info.info,'$('..name..')',var,'g')
            endif
            if node.cuts
              let info.cuts = node.cuts
            endif
            call add(list,info)|let s:conf.leng+=1
          endfor
        endfor "}
      endif "}
    endwhile
    let s:conf.list = list
  endif

endfu "}
fu! arbo#home(...) abort "{

  if has_key(s:conf,'list')&&get(s:conf,'home')
    let indx = 0
    let leng = get(s:conf,'leng',len(s:conf.list))
    let list = []
    let s:conf.leng = 0
    while indx<leng
      let node = s:conf.list[indx]|let indx+=1
      if node.info.keyw==?'home'
        if node.cuts==1|continue|endif
        if node.cuts==2|  break |endif
        let s:conf.HOME = empty(node.info.info)?node.info.name:node.info.info
        continue
      endif
      call add(list,node)|let s:conf.leng+=1
    endwhile
    let s:conf.list = list
  endif

endfu "}
fu! arbo#vars(...) abort "{

endfu "}

"-- auxy functions --
fu! arbo#node(...) abort "{

  let line = get(a:000,0,'')
  let line = ['',line][type(line)==type('')]

  let rgex = '^\v *(-*) *(\w*) *(.*)$'
  let info = matchlist(line,rgex)

  let cuts = info[1]
  let keyw = info[2]
  let info = info[3]

  let node = {}
  let rgex = '\v *[=:] *'

  " stores absolute key for home absolute path functionality
  let absl = trim(matchstr(info,rgex))

  " split info into name and info again
  let info = split(info,rgex,1)
  if len(info)==1
    let name = trim(info[0])
    let info = ''
  elseif len(info)>=2
    let name = trim(info[0])
    let info = trim(info[1])
  endif

  let node.cuts = len(cuts)
  let node.absl = absl=='='

  let node.info = {}
  let node.info.keyw = keyw
  let node.info.name = name
  let node.info.info = info

  return node

endfu "}
fu! arbo#find(...) abort "{

  if !exists('a:1')|return -1|endif
  if !exists('a:2')|return -1|endif

  let lexi = a:1
  let keyw = a:2
  let indx = 1
  for item in lexi
    if type(item)==type([])
      for word in item
        if word==?keyw|return indx|endif
      endfor
    else
      if keyw==?item|return indx|endif
    endif
    let indx+=1
  endfor
  return -1

endfu "}
fu! arbo#show(...) abort "{

  let root = get(a:000,0,{})
  let step = get(a:000,1, 0)
  let tabs = repeat(' ',step)
  let list = get(root,'list',[])

  " 1st run
  if a:0==1
    ec repeat('-',54)
    ec 'file:' get(root,'file','')
    ec 'meta:' get(root,'meta','')
    ec repeat('-',54)
    ec ''
  endif
  " recursive run loop over nodes
  for node in list
    let name = get(node.info,'name','')
    let info = get(node.info,'info','')
    let keyw = get(node.info,'keyw','')
    let name = [name,"''"][empty(name)]
    let info = [info,"''"][empty(info)]
    echon tabs keyw..' '..name..' : '..info..' ' get(node,'meta','')
    echon "\n"
    if has_key(node,'list')
      call arbo#show(node,step+2)
    endif
  endfor

endfu "}
fu! arbo#argv(...) abort "{
  let argv = get(a:000,0,{})
  if type(argv)==type([])
    if len(argv)>1
      return argv
    endif
    return arbo#argv(get(argv,0,{}))
  endif
  return argv
endfu "}
fu! arbo#seek(...) abort "{

  let root = get(a:000,0,{})
  let type = get(a:000,1,-1)
  let code = get(a:000,2,'node')
  if !has_key(root,'meta')|return {}|endif
  if !has_key(root,'list')|return {}|endif
  if type==root.meta.type
    if code=='node'|return root     |endif
    if code=='list'|return root.list|endif
  endif
  if has_key(root,'list')&&root.meta.leng
    let indx = root.meta.indx
    let leng = root.meta.leng
    return arbo#seek(root.list[indx%leng],type,code)
  endif
  return {}

endfu "}


