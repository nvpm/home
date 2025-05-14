"-- auto/arbo.vim  --
if !exists('NVPMTEST')&&exists('_ARBOAUTO_')|finish|endif
let _ARBOAUTO_ = 1
let s:nvim = has('nvim')
let s:vim  = !s:nvim

fu! arbo#grow(...) abort "{

  if !a:0|return 1|endif

  let file = a:1
  let skip = a:0==2

  if g:arbo.mode!=2
    let file = g:arbo.file.flux..file
  endif

  if isdirectory(file)
    for flux in readdir(file)
      call arbo#grow(file.'/'.flux,1)
    endfor
    call arbo#load()
    return
  endif

  if !filereadable(file)|return 2|endif

  let g:arbo.flux.file = file
  let fluxtree = flux#flux(g:arbo.flux)
  if empty(fluxtree)|return 3|endif

  let indx = arbo#find(file)
  if 1+indx
    let g:arbo.root.meta.indx = indx
    return
  else
    call add(g:arbo.root.list,fluxtree)
    let g:arbo.root.meta.leng+=1
    let g:arbo.root.meta.indx = g:arbo.root.meta.leng-1
  endif

  if !skip|call arbo#load()|endif

endfu "}
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

  let g:arbo.root.curr = ''
  let g:arbo.root.last = ''
  let g:arbo.root.list = []
  let g:arbo.root.meta = #{leng:0,indx:0,type:0}

  let g:arbo.file.root = '.nvpm/arbo/'
  let g:arbo.file.flux = g:arbo.file.root..'flux/'
  let g:arbo.file.edit = g:arbo.file.root..'edit'
  let g:arbo.file.save = g:arbo.file.root..'save'

  call flux#conf(g:arbo.flux)

  "if !argc()&&g:arbo.user.initload
  "  if filereadable(g:arbo.file.save)
  "    let flux = get(readfile(g:arbo.file.save),0,'')
  "    if !empty(flux) && filereadable(g:arbo.file.flux..flux)
  "      call arbo#grow(flux)
  "    endif
  "  endif
  "endif

endfu "}
"-- main functions --
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
      call garbagecollect()
      let g:arbo.root.meta.leng-= 1
      " just to keep indx inside bounds
      call arbo#indx(g:arbo.root.meta,0)
    endif
  else
    let g:arbo.mode = 0
    let g:arbo.root = #{curr:'',last:'',list:[],meta:#{leng:0,indx:0,type:0}}
  endif

endfu "}
fu! arbo#jump(...) abort "{

  let user = matchlist(a:1,'\([+-]\)\(\w\+\)')

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
      :write
      call arbo#edit()
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
    elseif type == s:flux.leaftype-1
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
fu! arbo#load(...) abort "{

  let g:arbo.mode = 1

  call arbo#curr()

  if exists('*line#show')&&exists('g:line.mode')&&g:line.mode
    let g:line.arbo = 1
    call line#show()
  endif

  call arbo#rend()

endfu "}
fu! arbo#find(...) abort "{

  let file = a:1
  let indx = 0
  for flux in g:arbo.root.list
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

"-- user functions --
fu! arbo#DIRS(...) abort "{
  let files = readdir(g:arbo.file.flux)
  return files
endfu "}
fu! arbo#LOOP(...) abort "{
  let words = [
        \'next',
        \'prev',
        \'project',
        \'workspace',
        \'tab',
        \'file',
  \]

  return words
endfu "}
