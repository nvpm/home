"-- auto/arbo.vim  --
if !exists('NVPMTEST')&&exists('_ARBOAUTO_')|finish|endif
let _ARBOAUTO_=1

"-- main functions --
fu! arbo#arbo(...) abort "{ main arbo routine

  if !a:0|return {}|else|let s:conf=a:1|endif

  " Note: do not to change this sequence!
  call arbo#conf()
  call arbo#read()
  call arbo#comm()
  call arbo#endl()
  call arbo#list()
  call arbo#trim()
  call arbo#loop()
  call arbo#home()
  retu arbo#data()

endfu "}
fu! arbo#data(...) abort "{ builds the arbo Data Structure (DS)

  let list = get(s:conf,'list',[])
  let leng = get(s:conf,'leng',len(list))

  if s:conf.homing
    let home = get(s:conf,'home','')
    let tree = arbo#tree(list,leng,home)
  else
    let tree = arbo#tree(list,leng)
  endif

  let tree.file = s:conf.file
  let tree.synx = s:conf.syntax

  if get(s:conf,'fixtree',0)|call arbo#fixt(tree,s:conf)|endif

  " leave conf the way it was
  if has_key(s:conf,'leng')|unlet s:conf.leng|endif
  if has_key(s:conf,'list')|unlet s:conf.list|endif
  if has_key(s:conf,'body')|unlet s:conf.body|endif
  if has_key(s:conf,'home')|unlet s:conf.home|endif
  if has_key(s:conf,'file')|unlet s:conf.file|endif

  unlet s:conf

  return tree

endfu "}
fu! arbo#fixt(...) abort "{ fixes some user mistakes in the DS

  let root = get(a:000,0,{})
  let conf = get(a:000,1,{})

  if empty(root)|return|endif
  if empty(conf)|return|endif

  if has_key(root,'list')&&root.meta.leng
    let leng = root.meta.leng
    let mintype = conf.leaftype
    let minkeyw = conf.lexicon[mintype-1][0]
    for node in root.list
      let type = arbo#find(conf.lexicon,node.keyw)
      if type<mintype
        let mintype = type
        let minkeyw = node.keyw
      endif
    endfor

    let indx = 0
    let list = []
    let node = root.list[indx]
    " while bounded & curr node type is inside a non-leaf node
    while indx<root.meta.leng&&arbo#find(conf.lexicon,node.keyw)>mintype
      call add(list,node)
      let indx+=1
      let node = root.list[indx]
    endwhile
    if indx
      let next = root.list[indx]
      let node = #{info:{},meta:{}}
      let node.keyw = minkeyw
      let node.name = '<fixed>'
      let node.info = ''
      let node.meta.leng = len(list)
      let node.meta.indx = 0
      "let node.meta.type = arbo#find(conf.lexicon,list[0].info.keyw)
      let node.meta.type = mintype+1
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
fu! arbo#tree(...) abort "{ recursively builds the tree from the list of nodes

  let list = get(a:,1,[])
  let leng = get(a:,2,len(list))

  if s:conf.homing
    let home = get(a:,3,'')
    let home = [home .. '/',home][empty(home)]
  endif

  let tree = #{list:[],meta:#{leng:0,indx:0,type:-2}}

  let indx = 0
  " loop over conf.list
  while indx<leng

    " catches node from given nodelist
    let node = list[indx]|let indx+=1

    let node.type = arbo#find(s:conf.lexicon     ,node.keyw)
    let node.tree = arbo#find(s:conf.lexicon[:-2],node.keyw)

    " recursively handles non-leaf nodes (sub-tree)
    if 1+node.tree
      let init = indx
      while indx<leng
        let item = list[indx]
        let item.tree = arbo#find(s:conf.lexicon[:-2],item.keyw)
        " breaks at next same (or higher) type node
        if 1+item.tree && item.tree<=node.tree
          break
        endif
        let indx+=1
      endwhile

      " extend node fields with.list, indx and leng recursively
      let sublist = list[init:indx-1]
      if s:conf.homing
        let path = [home,''][node.absl] .. node.info
        let subtree = arbo#tree(sublist,indx-init,path)
      else
        let subtree = arbo#tree(sublist,indx-init)
      endif
      call extend(node,subtree)

    endif

    " skips non-matching nodes
    if node.type<0|continue|endif

    " handles trim functionality
    if node.trim==1|continue|endif
    if node.trim==2| break  |endif

    " a leafless tree perishes
    if empty(get(node,'list','leafless'))|continue|endif

    " transfers node type to parent node
    let tree.meta.type = node.type

    " handles home for leaf nodes
    if s:conf.homing && -1==node.tree
      let info = empty(node.info)?node.name:node.info
      let node.info = [home .. info,info][node.absl]
      let node.info = simplify(node.info)
    endif

    " remove unnecessary node-fields
    if has_key(node,'trim')|unlet node.trim|endif
    if has_key(node,'tree')|unlet node.tree|endif
    if has_key(node,'absl')|unlet node.absl|endif
    if has_key(node,'type')|unlet node.type|endif

    " adds node to tree & increment length
    call add(tree.list,node)|let tree.meta.leng+=1

  endwhile

  return tree

endfu "}

"-- conf functions --
fu! arbo#conf(...) abort "{ rectifies configuration dictionary

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
  if !has_key(conf,'syntax')||conf.syntax ==? 'normal'
    let conf.syntax = 'normal'
    let conf.homing = 0
  elseif conf.syntax ==? 'nvpm'
    let conf.homing  = 1
    let conf.fixtree = 1
  endif

  let conf.leaftype = len(conf.lexicon)

endfu "}
fu! arbo#read(...) abort "{ reads the arbo file

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
fu! arbo#comm(...) abort "{ ignores comments and empty lines

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
fu! arbo#endl(...) abort "{ splits end-of-line characters

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
fu! arbo#list(...) abort "{ transforms conf.body into list of nodes

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
fu! arbo#trim(...) abort "{ standalone and triple trims features

  let objc = get(a:,1,s:conf)

  if type(objc)==type({})
    if has_key(objc,'list')
      let objc.list = arbo#trim(objc.list)
      let objc.leng = len(objc.list)
    endif
  endif
  if type(objc)==type([])
    let leng = len(objc)
    let trim = 0
    let indx = 0
    let newlist = []
    while indx<leng
      let node = objc[indx]|let indx+=1
      if node.trim>=3|break|endif
      if node.stda && node.trim
        let trim = node.trim
        continue
      endif
      if trim
        let node.trim = trim
        let trim = 0
      endif
        call remove(node,'stda')
      call add(newlist,node)
    endwhile
    return newlist
  endif

endfu "}
fu! arbo#loop(...) abort "{ looping mechanism

  if has_key(s:conf,'list')
    let indx = 0
    let list = []
    let leng = get(s:conf,'leng',len(s:conf.list))
    let s:conf.leng = 0
    while indx<leng
      let node = s:conf.list[indx]|let indx+=1
      if node.keyw !=? 'loop'
        call add(list,node)
        let s:conf.leng+=1
      else " found loop keyword
        let loop = []
        while indx<leng
          let item = s:conf.list[indx]|let indx+=1
          if item.keyw==?'endl'|break|endif
          if node.trim|continue|endif
          call add(loop,item)
        endwhile
        if node.trim==1|continue|endif
        if node.trim==2
          let s:conf.list[indx].trim = 2
          continue
        endif
        let info = empty(node.info)?node.name:node.info
        let name = empty(node.info)?'':node.name
        let vars = split(info,' ')
        let vars = arbo#list(vars)
        let vars = arbo#trim(vars)
        for node in vars
          if node.trim==1|continue|endif
          if node.trim>=2|  break |endif
          let var = node.keyw
          for item in loop
            let info = deepcopy(item)
            if empty(name)
              let info.name = substitute(info.name,'$_',var,'g')
              let info.info = substitute(info.info,'$_',var,'g')
            else
              let info.name = substitute(info.name,'$('..name..')',var,'g')
              let info.info = substitute(info.info,'$('..name..')',var,'g')
            endif
            if node.trim
              let info.trim = node.trim
            endif
            call add(list,info)|let s:conf.leng+=1
          endfor
        endfor
      endif
    endwhile
    let s:conf.list = list
  endif

endfu "}
fu! arbo#home(...) abort "{ homing mechanism

  if has_key(s:conf,'list')&&get(s:conf,'homing')
    let indx = 0
    let leng = get(s:conf,'leng',len(s:conf.list))
    let list = []
    let s:conf.leng = 0
    while indx<leng
      let node = s:conf.list[indx]|let indx+=1
      if node.keyw==?'home'
        if node.trim==1|continue|endif
        if node.trim==2|  break |endif
        let s:conf.home = empty(node.info)?node.name:node.info
        continue
      endif
      call add(list,node)|let s:conf.leng+=1
    endwhile
    let s:conf.list = list
  endif

endfu "}

"-- auxy functions --
fu! arbo#node(...) abort "{ parses a line into a valid node

  let line = get(a:,1,'')
  let nvpm = get(a:,2,s:conf.syntax ==? 'nvpm')
  let line = ['',line][type(line)==type('')]

  let rgex = '^\v *(-*) *(\w*) *(.*)$'
  let info = matchlist(line,rgex)

  let trim = info[1]
  let keyw = info[2]
  let info = info[3]

  let node = {}
  let node.keyw = keyw
  let node.info = info
  let node.stda = ''
  let node.trim = len(trim)

  if nvpm
    let rgex = '\v *[=:] *'

    " stores absolute key for homing absolute path functionality
    let node.absl = trim(matchstr(info,rgex)) == '='

    " split info into name and info again
    let info = split(info,rgex,1)
    if len(info)==1
      let name = trim(info[0])
      let info = ''
    elseif len(info)>=2
      let name = trim(info[0])
      let info = trim(info[1])
    endif

    let node.name = name
    let node.info = info
    let node.stda.= node.name

  endif
  let node.stda.= node.keyw..node.info
  let node.stda = empty(node.stda)

  return node

endfu "}
fu! arbo#find(...) abort "{ returns the number type of a given keyword

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
fu! arbo#show(...) abort "{ pretty-prints a given node

  let root = get(a:,1,{})
  let step = get(a:,2, 0)
  let nvpm = get(a:,3, get(root,'synx','')=='nvpm')
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
    let info = get(node,'info','')

    if nvpm
      let name = get(node,'name','')
      let name = [name,"''"][empty(name)]
      let info = name..' : '..info
    endif

    let keyw = get(node,'keyw','')
    let info = [info,"''"][empty(info)]
    echon tabs keyw..' '..info..' ' get(node,'meta','')
    echon "\n"
    if has_key(node,'list')
      call arbo#show(node,step+2,nvpm)
    endif
  endfor

endfu "}
fu! arbo#seek(...) abort "{ looks for the current node of a given number type

  let root = get(a:000,0,{})
  let type = get(a:000,1,-1)

  if !has_key(root,'meta') | return {}   | endif
  if !has_key(root,'list') | return {}   | endif
  if type==root.meta.type  | return root | endif

  let leng = get(root.meta,'leng')

  if leng
    call arbo#indx(root)
    return arbo#seek(root.list[root.meta.indx],type)
  endif
  return {}

endfu "}
fu! arbo#indx(...) abort "{ sets/limits a new index to a given meta field

  if !a:0||type(a:1)!=type({})|return 1|endif

  let node = a:1

  if has_key(node,'meta')
    let meta = node.meta
    let meta.indx = get(a:,2,meta.indx)
    if has_key(meta,'leng')
      let meta.indx%= meta.leng               " limits range inside length
      let meta.indx+= (meta.indx<0)*meta.leng " keeps indx positive
    endif
  endif

endfu "}
