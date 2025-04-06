" auto/flux.vim
" once {

if !NVPMTEST&&exists('__FLUXAUTO__')|finish|endif
let __FLUXAUTO__=1

" end-once }
" func {

"-- main functions --
fu! flux#flux(...) "{

  if !a:0|return {}|else|let s:conf=flux#argv(a:000)|endif

  call flux#conf()
  call flux#read()
  call flux#trim()
  call flux#endl()
  call flux#list()
  call flux#cuts()
  call flux#loop()
  call flux#home()
  retu flux#data()

endfu "}
fu! flux#data(...) "{

  let list = get(s:conf,'list',[])
  let leng = get(s:conf,'leng',len(list))
  let home = get(s:conf,'HOME','')

  let tree = flux#tree(list,leng,home)

  if get(s:conf,'fixt',0)|call flux#fixt(tree,s:conf)|endif

  " leave conf the way it was
  if has_key(s:conf,'leng')|unlet s:conf.leng|endif
  if has_key(s:conf,'list')|unlet s:conf.list|endif
  if has_key(s:conf,'body')|unlet s:conf.body|endif
  if has_key(s:conf,'HOME')|unlet s:conf.HOME|endif
  if has_key(s:conf,'file')|unlet s:conf.file|endif

  unlet s:conf

  return tree

endfu "}
fu! flux#fixt(...) "{

  let root = get(a:000,0,{})
  let conf = get(a:000,1,{})

  if empty(root)|return|endif
  if empty(conf)|return|endif

  if has_key(root,'list')&&root.meta.leng
    let leng = root.meta.leng
    let mintype = conf.leaftype
    let minkeyw = conf.lexis[mintype][0]
    for node in root.list
      let type = flux#find(conf.lexis,node.data.keyw)
      if type<mintype
        let mintype = type
        let minkeyw = node.data.keyw
      endif
    endfor
    let indx = 0
    let list = []
    let node = root.list[indx]
    while indx<root.meta.leng&&flux#find(conf.lexis,node.data.keyw)>mintype
      call add(list,node)
      let indx+=1
      let node = root.list[indx]
    endwhile
    if indx
      let next = root.list[indx]
      let node = #{data:{},meta:{}}
      let node.data.keyw = minkeyw
      let node.data.name = '<unnamed>'
      let node.data.info = ''
      let node.meta.leng = len(list)
      let node.meta.indx = root.meta.indx
      let node.meta.type = flux#find(conf.lexis,list[0].data.keyw)
      let node.list = list
      let root.list = [node]+root.list[indx:]
      let root.meta.leng = len(root.list)
    endif
    for node in root.list
      if has_key(node,'list')
        call flux#fixt(node,conf)
      endif
    endfor
  endif

endfu "}
fu! flux#tree(...) "{

  let list = get(a:000,0,[])
  let leng = get(a:000,1,len(list))
  let home = get(a:000,2,'')
  let home = [home .. '/',home][empty(home)]
  let indx = 0

  let tree = #{list:[],meta:#{leng:0,indx:0}}

  " loop over conf.list
  while indx<leng

    " catches node from given nodelist
    let node = list[indx]|let indx+=1
    let path = [home,''][node.absl] .. node.data.info

    let node.type = flux#find(s:conf.lexis     ,node.data.keyw)
    let node.tree = flux#find(s:conf.lexis[:-2],node.data.keyw)

    " recursively handles non-leaf nodes (sub-tree)
    if 1+node.tree
      let init = indx
      while indx<leng
        let item = list[indx]
        let item.tree = flux#find(s:conf.lexis[:-2],item.data.keyw)
        " breaks at next same (or higher) type node
        if 1+item.tree && item.tree<=node.tree
          break
        endif
        let indx+=1
      endwhile

      " extend node fields with.list, indx and leng recursively
      let sublist = list[init:indx-1]
      let subtree = flux#tree(sublist,indx-init,path)
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
      let info = empty(node.data.info)?node.data.name:node.data.info
      let node.data.info = [home .. info,info][node.absl]
      let node.data.info = simplify(node.data.info)
     "let node.data.info = substitute(node.data.info,'//','/','g')
     "let node.data.info = substitute(node.data.info,'/$','','')
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
fu! flux#skel(...) "{
endfu "}

"-- conf functions --
fu! flux#conf(...) "{

  if !a:0|return flux#conf(s:conf)|else|let conf=a:1|endif
  if !has_key(conf,'lexis')|let conf.lexis=''|endif
  if type(conf.lexis)==type('')
    let conf.lexis = split(conf.lexis,'|')
    let list = []
    for type in conf.lexis
      call add(list,split(type,'\s'))
    endfor
    let conf.lexis = list
  endif

  let conf.leaftype = len(conf.lexis)-1

endfu "}
fu! flux#read(...) "{

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
fu! flux#trim(...) "{

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
fu! flux#endl(...) "{

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
fu! flux#list(...) "{

  let objc = get(a:,1,s:conf)

  if type(objc)==type({})
    if has_key(objc,'body')
      let objc.list = flux#list(objc.body)
      let objc.leng = len(objc.list)
    endif
  endif
  if type(objc)==type([])
    let body = objc
    let list = []
    for line in body
      let node = flux#node(line)
      call add(list,node)
    endfor
    return list
  endif

endfu "}
fu! flux#cuts(...) "{

  let objc = get(a:,1,s:conf)

  if type(objc)==type({})
    if has_key(objc,'list')
      let objc.list = flux#cuts(objc.list)
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
      let stda = empty(node.data.keyw..node.data.name..node.data.info)
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
fu! flux#loop(...) "{

  if has_key(s:conf,'list')
    let indx = 0
    let list = []
    let leng = get(s:conf,'leng',len(s:conf.list))
    let s:conf.leng = 0
    while indx<leng
      let node = s:conf.list[indx]|let indx+=1
      if node.data.keyw !=? 'loop'
        call add(list,node)
        let s:conf.leng+=1
      else
        let loop = []
        while indx<leng
          let item = s:conf.list[indx]|let indx+=1
          if item.data.keyw==?'endl'|break|endif
          call add(loop,item)
        endwhile
        let name = node.data.name
        let vars = split(node.data.info,' ')
        let cuts = 0
        for var in vars
          " cut-tree for loop-vars
          let item = flux#node(var)
          if empty(item.data.keyw..item.data.name..item.data.info) && item.cuts
            let cuts = item.cuts
            continue
          endif
          if cuts
            let item.cuts = cuts
            let cuts = 0
          endif
          if  item.cuts==1|continue|endif
          if  item.cuts>=2|  break |endif
          if empty(var)|continue|endif
          for item in loop
            let info = deepcopy(item)
            let info.data.name = substitute(info.data.name,'$('..name..')',var,'g')
            let info.data.info = substitute(info.data.info,'$('..name..')',var,'g')
            let info.cuts      = node.cuts
            call add(list,info)|let s:conf.leng+=1
          endfor
        endfor
      endif
    endwhile
    let s:conf.list = list
  endif

endfu "}
fu! flux#home(...) "{

  if has_key(s:conf,'list')&&get(s:conf,'home')
    let indx = 0
    let leng = get(s:conf,'leng',len(s:conf.list))
    let list = []
    let s:conf.leng = 0
    while indx<leng
      let node = s:conf.list[indx]|let indx+=1
      if node.data.keyw==?'home'
        if node.cuts==1|continue|endif
        if node.cuts==2|  break |endif
        let s:conf.HOME = empty(node.data.info)?node.data.name:node.data.info
        continue
      endif
      call add(list,node)|let s:conf.leng+=1
    endwhile
    let s:conf.list = list
  endif

endfu "}
fu! flux#vars(...) "{

endfu "}

"-- auxy functions --
fu! flux#node(...) "{

  let line = get(a:000,0,'')
  let line = ['',line][type(line)==type('')]

  let rgex = '^\v *(-*) *(\w*) *(.*)$'
  let info = matchlist(line,rgex)

  let cuts = info[1]
  let keyw = info[2]
  let info = info[3]

  let node = {}
  let rgex = '\v *[=:@] *'

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
  let node.absl = absl=='@'

  let node.data = {}
  let node.data.keyw = keyw
  let node.data.name = name
  let node.data.info = info

  return node

endfu "}
fu! flux#find(...) "{

  if !exists('a:1')|return -1|endif
  if !exists('a:2')|return -1|endif

  if type(a:1)==type([])

    let lexis = a:1
    let keyword    = a:2
    let index      = -1
    for item in lexis
      let index+=1
      if type(item)==type([])
        for word in item
          if word==?keyword|return index|endif
        endfor
      else
        if keyword==?item|return index|endif
      endif
    endfor
    return -1

  endif
  if type(a:1)==type('')

    " old style find method
    " string  : 'K00 K01 ... K0x | K10 K11 ... K1y | ... | Km0 Km1 ... Kmn'
    " indexes :           0                 1        ...            m
    " failure : if seek does not find keyw, -1 is returned
    if !exists('a:1')||type(a:1)!=type('')|return -1|endif
    if !exists('a:2')||type(a:2)!=type('')|return -1|endif
    let strg = a:1
    let word = a:2
    let keyw = ''
    let indx = 0
    for char in strg
      if char =~ '\w'|let keyw.=char|continue|endif
      if char =~ '\s'
        if keyw==?word|return indx|endif
        let keyw=''
        continue
      endif
      if char == '|'
        if keyw==?word|return indx|endif
        if !empty(keyw)|let indx+=1|let keyw=''|else|continue|endif
      endif
    endfor
    return [-1,indx][keyw==?word]

  endif

  return -1

endfu "}
fu! flux#show(...) "{

  let root = get(a:000,0,{})
  let step = get(a:000,1, 0)
  let tabs = repeat(' ',step)
  let list = get(root,'list',[])

  " 1st run
  if a:0==1
    ec repeat('-',54)
    if has_key(root,'data')
      ec 'data:' get(root,'data','')
    endif
    ec 'meta:' get(root,'meta','')
    ec repeat('-',54)
    ec ''
  endif
  " recursive run loop over nodes
  for node in list
    let name = get(node.data,'name','')
    let info = get(node.data,'info','')
    let keyw = get(node.data,'keyw','')
    let name = [name,"''"][empty(name)]
    let info = [info,"''"][empty(info)]
    echon tabs keyw..' '..name..' : '..info..' ' get(node,'meta','')
    echon "\n"
    if has_key(node,'list')
      call flux#show(node,step+2)
    endif
  endfor

endfu "}
fu! flux#argv(...) "{
  let argv = get(a:000,0,{})
  if type(argv)==type([])
    if len(argv)>1
      return argv
    endif
    return flux#argv(get(argv,0,{}))
  endif
  return argv
endfu "}
fu! flux#seek(...) "{

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
    return flux#seek(root.list[indx%leng],type,code)
  endif
  return {}

endfu "}

" end-func }
