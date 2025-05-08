"-- auto/arbo.vim  --
if !exists('NVPMTEST')&&exists('_ARBOAUTO_')|finish|endif
let _ARBOAUTO_ = 1
let s:nvim = has('nvim')
let s:vim  = !s:nvim

"-- main functions --
fu! arbo#init(...) abort "{ 

  " s:loop   {

    let s:loop = {'+':1,'-':-1,'next':+1,'prev':-1}

  "}
  " s:file   {
  
    let s:file = {}
    let s:file.root = '.nvpm/arbo/'
    let s:file.flux = s:file.root..'flux/'
    let s:file.edit = s:file.root..'edit'
    let s:file.save = s:file.root..'save'

  " }
  " s:conf   {
  
    let s:conf = get(g:,'arbo_fluxconf',{})
    if empty(s:conf)
      let s:conf.lexis = ''
      let s:conf.lexis.= '|project proj scheme layout book'
      let s:conf.lexis.= '|workspace arch archive architecture section'
      let s:conf.lexis.= '|tab folder fold shelf package pack chapter'
      let s:conf.lexis.= '|file buff buffer path entry node leaf page'
    endif
    let s:conf.fixt = 1
    let s:conf.home = 1
    call flux#conf(s:conf)

  " }
  " g:arbo   {

    let g:arbo = {}

    let g:arbo.tree = {}
    let g:arbo.tree.root = {}
    let g:arbo.tree.file = ''
    let g:arbo.tree.mode = 0

    let g:arbo.edit = {}
    let g:arbo.edit.line = 0
    let g:arbo.edit.mode = 0
    let g:arbo.edit.curr = ''

    let g:arbo.term = {}
    let g:arbo.term.buff = ''

    let g:arbo.flux = {}
    let g:arbo.flux.list = []
    let g:arbo.flux.leng = 0
    let g:arbo.flux.indx = 0

  " }

  if !argc()&&get(g:,'arbo_initload')
    if filereadable(s:file.save)
      let flux = get(readfile(s:file.save),0,'')
      if !empty(flux) && filereadable(s:file.flux..flux)
        call arbo#load(flux)
      endif
    endif
  endif

endfu "}
fu! arbo#load(...) abort "{

  let file = flux#argv(a:000)

  if !g:arbo.edit.mode
    let file = s:file.flux..file
  endif

  if !filereadable(file)|return 1|endif

  let s:conf.file = file
  let root = flux#flux(s:conf)
  let list = get(root,'list',[])

  if empty(root)    |let s:conf.file=''|return 2|endif
  if empty(list)    |let s:conf.file=''|return 3|endif
  if arbo#curr(root)|let s:conf.file=''|return 4|endif

  let g:arbo.tree.root = root
  let g:arbo.tree.file = file
  let g:arbo.tree.mode = 1

  if exists('*line#show')&&exists('g:line.mode')&&g:line.mode
    let g:line.arbo = 1
    call line#show()
  endif
  call arbo#save()
  call arbo#rend()
  if exists('g:zoom.mode')&&g:zoom.mode
    only
    call zoom#show()
  endif

endfu "}
fu! arbo#loop(...) abort "{

  if !a:0|return 1|endif

  let user = split(a:1,' ')
  let step = get(user,0, 0)
  let type = get(user,1,-1)
  let step = get(s:loop,step,0)

  if type=='flux'||type=='-1' " flux files iteration {
    if g:arbo.edit.mode|return|endif
    call arbo#flux()
    if g:arbo.flux.leng
      let flux = g:arbo.flux.list[0]
      if g:arbo.tree.mode
        call arbo#indx(g:arbo.flux,step)
        let flux = g:arbo.flux.list[g:arbo.flux.indx]
      endif
      return arbo#load(flux)
    endif
    return
  endif "}

  if type(step)!=type(0)|ec 'wrong arg-commands'|return 1|endif
  let step = v:count1 * step
  let tree = g:arbo.tree.root

  if type!='0'&&type!='1'&&type!='2'&&type!='3'
    let type = flux#find(s:conf.lexis,type)
  else
    let type = str2nr(type)
  endif

  if type<0||type>3|return 1|endif

  if g:arbo.tree.mode
    if type == 2 && g:arbo.edit.mode|call arbo#edit()|endif
    if type == 1 && g:arbo.edit.mode|call arbo#edit()|endif
    if type == 0 && g:arbo.edit.mode|call arbo#edit()|endif
    let bufname = bufname()
    if bufname==g:arbo.tree.curr 
      let node = flux#seek(tree,type)
      if empty(node)|return 1|endif
      call arbo#indx(node.meta,step)
    endif
    call arbo#curr()
    call arbo#rend()
  else
    if type == s:conf.leaftype
      if step < 0
        :bprev
      else
        :bnext
      endif
    elseif type == s:conf.leaftype-1
      if step < 0
        :tabprev
      else
        :tabnext
      endif
    endif
  endif

endfu "}
fu! arbo#edit(...) abort "{

  " loads bufname if in edit mode 
  " only leaves edit mode upon correct load
  if g:arbo.edit.mode
    let g:arbo.edit.mode = arbo#load(bufname())
    return
  endif

  " makes the edit file otherwise
  let fluxes = []
  if isdirectory(s:file.flux)
    let fluxes = readdir(s:file.flux)
  endif
  let body   = []
  for file in fluxes
    let file = s:file.flux..file
    let line = 'file '..fnamemodify(file,':t:r')..':'..file
    if file == g:arbo.tree.file
      let body = [line]+body
      continue
    endif
    call add(body,line)
  endfor
  let body = ['tab ARBO Edit Mode']+body

  if !isdirectory('.nvpm')
    return 1
  endif

  call writefile(body,s:file.edit)
  let g:arbo.edit.mode = 1
  call arbo#load(s:file.edit)

endfu "}
fu! arbo#save(...) abort "{

  if g:arbo.tree.file != s:file.edit
    call writefile([fnamemodify(g:arbo.tree.file,':t')],s:file.save)
  endif

endfu "}
fu! arbo#term(...) abort "{

  if !bufexists(g:arbo.term.buff)
    exec 'buffer|terminal'
    let g:arbo.term.buff = bufname()
  endif

  if !empty(matchstr(g:arbo.term.buff,'term://.*'))
    call execute('edit! '..g:arbo.term.buff)
  endif

endfu "}
fu! arbo#make(...) abort "{


  let name = get(a:000,0,'')

  if empty(name)|return|endif
  if !isdirectory(s:file.flux)&&filereadable(s:file.flux)
    ec 'Location '..s:file.flux..' is a file. Remove it first.'
    return
  endif

  call mkdir(s:file.flux,'p')
  call arbo#flux()

  let name = fnamemodify(name,':e')=='flux'?name:fnamemodify(name,':t:r')..'.flux'

  for flux in g:arbo.flux.list
    if flux==a:1
      echo 'arbo: flux file ['.name.'] already exists.'
      echo '      Choose another name!'
      return
    endif
  endfor

  let path = s:file.flux..name

  let lines = ''
  let lines.= '# arbo new flux file,'
  let lines.= '# ------------------,'
  let lines.= '#,'                     
  let lines.= '# --> '..name..','
  let lines.= '#,'                     
  let lines.= '#,'                     
  let lines.= 'project <pname>:<phome>,'                     
  let lines.= '  workspace <wname>:<whome>,'                     
  let lines.= '    tab <tname>:<thome>,'                     
  let lines.= '      file <fname>:<filename>,'                     

  let lines = split(lines,',')
  call writefile(lines,path)
  call arbo#load(name)
  call arbo#flux()
  call arbo#edit()

endfu "}

"-- auxy functions --
fu! arbo#curr(...) abort "{

  let root = get(a:,1,g:arbo.tree.root)
  let list = get(root,'list',[])

  if empty(root)|return 1|endif
  if empty(list)|return 2|endif
                                     
  let node = flux#seek(root,3)
  if empty(node)|return 3|endif
  let curr = node.list[node.meta.indx].data.info
  if empty(curr)|return 4|endif

  let g:arbo.tree.curr = curr

endfu "}
fu! arbo#rend(...) abort "{

  let curr = simplify(g:arbo.tree.curr)
  let head = fnamemodify(curr,':h')..'/'
  let HEAD = fnamemodify(head,':p')..'/'
  if !empty(curr)
    call execute('edit '.curr)
    if 1+match(curr,'^.*\.flux$')||
      \head == s:file.flux      &&
      \&ft  != 'flux'
      set filetype=flux
      set commentstring=-%s
    endif
    if get(g:,'arbo_maketree',0) &&
      \!empty(head) &&
      \!filereadable(head) &&
      \-1==match(curr,'term\:\/\/')
      call mkdir(head,'p')
    endif
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

  call flux#show(get(a:,1,g:arbo.tree.root))

endfu "}
fu! arbo#flux(...) abort "{

  if isdirectory(s:file.flux)&&empty(g:arbo.flux.list)
    let g:arbo.flux.list = readdir(s:file.flux)
    let g:arbo.flux.leng = len(g:arbo.flux.list)
    let g:arbo.flux.indx = 0
  endif

endfu "}

"-- user functions --
fu! arbo#DIRS(...) abort "{
  let files = readdir(s:file.flux)
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
