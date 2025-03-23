" auto/nvpm.vim
" once {

if !NVPMTEST&&exists('__NVPMAUTO__')|finish|endif
let __NVPMAUTO__ = 1

" end-once}
" func {

" main functions {

fu! nvpm#init(...) " initiate main variables {

  if has_key(s:,'once')&&g:NVPMTEST|return|endif
  let s:once = 1

  let s:user = {}
  let s:user.maketree = get(g:,'nvpm_maketree',0)

  let s:dirs = {}
  let s:dirs.local  = '.nvpm/flux/'
  let s:dirs.global = '~/nvim/flux/'
  let s:dirs.edit = '.nvpm/edit'
  let s:dirs.save = '.nvpm/save'

  let s:dirs.global = resolve    (s:dirs.global)
  let s:dirs.global = expand     (s:dirs.global)
  let s:dirs.global = fnamemodify(s:dirs.global,':p')

  let words = [
        \'next',
        \'prev',
        \'project',
        \'workspace',
        \'tab',
        \'file',
  \]

  let loop = #{words:words,forward:+1,next:+1,prev:-1,previous:-1,back:-1}

  let conf = {}
  let conf.lexis = ''
  let conf.lexis.= '|project proj scheme layout book'
  let conf.lexis.= '|workspace arch archive architecture section'
  let conf.lexis.= '|tab folder fold shelf package pack chapter'
  let conf.lexis.= '|file buff buffer path entry node leaf page'
  let conf.home  = 1

  call flux#conf(conf)

  let g:nvpm = {}

  let g:nvpm.tree = {}
  let g:nvpm.tree.root = {}
  let g:nvpm.tree.file = ''
  let g:nvpm.tree.mode = 0

  let g:nvpm.line = {}
  let g:nvpm.line.mode = 1

  let g:nvpm.edit = {}
  let g:nvpm.edit.line = 0
  let g:nvpm.edit.mode = 0
  let g:nvpm.edit.curr = ''

  let g:nvpm.term = {}
  let g:nvpm.term.buff = ''

  let g:nvpm.conf = conf
  let g:nvpm.loop = loop

  let g:nvpm.flux = {}
  let g:nvpm.flux.list = []
  let g:nvpm.flux.leng = 0
  let g:nvpm.flux.indx = 0

  call nvpm#synx()

  if get(g:,'nvpm_initload',0) && !argc() 
    if !filereadable(s:dirs.save)
      call nvpm#edit()
      return
    endif
    let flux = get(readfile(s:dirs.save),0,'')
    if empty(flux) || !filereadable(s:dirs.local..flux)
      call nvpm#edit()
    else
      call nvpm#load(flux)
    endif
  endif

endfu "}
fu! nvpm#loop(...) " loop over nodes {

  if !a:0|return 1|endif

  let user = split(a:1,' ')
  let step = get(user,0, 0)
  let type = get(user,1,-1)
  let step = get(g:nvpm.loop,step,0)
  if type=='flux'
    if g:nvpm.edit.mode|return|endif
    call nvpm#flux()
    if g:nvpm.flux.leng
      let flux = g:nvpm.flux.list[0]
      if g:nvpm.tree.mode
        call nvpm#indx(g:nvpm.flux,step)
        let flux = g:nvpm.flux.list[g:nvpm.flux.indx]
      endif
      return nvpm#load(flux)
    endif
    return
  endif
  if type(step)!=type(0)|ec 'wrong arg-commands'|return 1|endif
  let step = v:count1 * step
  let type = flux#find(g:nvpm.conf.lexis,type)
  let tree = g:nvpm.tree.root

  if type<0 || type>3|return 1|endif

  if g:nvpm.tree.mode
    if type == 2 && g:nvpm.edit.mode|call nvpm#edit()|endif
    if type == 1 && g:nvpm.edit.mode|call nvpm#edit()|endif
    if type == 0 && g:nvpm.edit.mode|call nvpm#edit()|endif
    if bufname()==g:nvpm.tree.curr 
      let node = nvpm#seek(type,'node',tree)
      if empty(node)|return 1|endif
      call nvpm#indx(node.meta,step)
    endif
    call nvpm#curr()
  else
    if type == g:nvpm.conf.leaftype
      if step < 0
        :bprev
      else
        :bnext
      endif
    elseif type == g:nvpm.conf.leaftype-1
      if step < 0
        :tabprev
      else
        :tabnext
      endif
    endif
  endif

endfu "}
fu! nvpm#load(...) " loads a flux file {

  let file = flux#argv(a:000)

  if !g:nvpm.edit.mode
    let file = s:dirs.local..file
  endif

  if !filereadable(file)|return 1|endif

  let g:nvpm.conf.file = file
  let root = flux#flux(g:nvpm.conf)
  let list = get(root,'list',[])

  if empty(root)    |let g:nvpm.conf.file=''|return 2|endif
  if empty(list)    |let g:nvpm.conf.file=''|return 3|endif
  if nvpm#curr(root)|let g:nvpm.conf.file=''|return 4|endif

  let g:nvpm.tree.root = root
  let g:nvpm.tree.file = file

  call line#line()
  call nvpm#save()
  let g:nvpm.tree.mode = 1

endfu "}
fu! nvpm#edit(...) " enters edit flux files area {

  " loads bufname if in edit mode 
  " only leaves edit mode upon correct load
  if g:nvpm.edit.mode
    let g:nvpm.edit.mode = nvpm#load(bufname())
    return
  endif

  " makes the edit file otherwise
  let fluxes = readdir(s:dirs.local)
  let body   = []
  for file in fluxes
    let file = s:dirs.local..file
    let line = 'file '..fnamemodify(file,':t')..':'..file
    if file == g:nvpm.tree.file
      let body = [line]+body
      continue
    endif
    call add(body,line)
  endfor
  let body = ['tab NVPM Edit Mode']+body

  let nvpm = '.nvpm'
  if !isdirectory(nvpm)
    if filereadable(nvpm)
      ec 'File '..nvpm..' is reserved by the nvpm. Please remove it.'
      return 1
    endif
    call mkdir(nvpm,'p')
  endif

  call writefile(body,s:dirs.edit)
  let g:nvpm.edit.mode = 1
  call nvpm#load(s:dirs.edit)

endfu "}
fu! nvpm#save(...) " saves DS info including default {

  if g:nvpm.tree.file != s:dirs.edit
    call writefile([fnamemodify(g:nvpm.tree.file,':t')],s:dirs.save)
  endif

endfu "}
fu! nvpm#term(...) " wild terminals {

  if !bufexists(g:nvpm.term.buff)
   exec 'buffer|terminal'
   let g:nvpm.term.buff = bufname()
  endif

  if !empty(matchstr(g:nvpm.term.buff,'term://.*'))
    call execute('edit! '..g:nvpm.term.buff)
  endif

endfu "}
fu! nvpm#make(...) " make a new flux file {

  let name = get(a:000,0,'')

  if empty(name)|return|endif
  if !isdirectory(s:dirs.local)&&filereadable(s:dirs.local)
    ec 'Location '..s:dirs.local..' is a file. Remove it first.'
    return
  endif

  call mkdir(s:dirs.local,'p')
  call nvpm#flux()

  for flux in g:nvpm.flux.list
    if flux==a:1
      echo 'NVPM: flux file ['.name.'] already exists.'
      echo '      Choose another name!'
      return
    endif
  endfor

  let path = s:dirs.local..name

  let lines = ''
  let lines.= '# NVPM new flux file,'
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
  call nvpm#load(name)
  call nvpm#flux()
  call nvpm#edit()

endfu "}
" unfinished
fu! nvpm#info(...) " info overview {
endfu "}
fu! nvpm#menu(...) " nvpm menu {
endfu "}

" }
" help functions {

fu! nvpm#curr(...) " gets the current file path {

  let root = get(a:,1,g:nvpm.tree.root)
  let list = get(root,'list',[])

  if empty(root)|return 1|endif
  if empty(list)|return 2|endif
                                     
  let curr = nvpm#seek(3,'node',root)
  if empty(curr)|return 3|endif
  let curr = curr.list[curr.meta.indx%curr.meta.leng].data.info
  let g:nvpm.tree.curr = curr
  let file = g:nvpm.tree.curr
  if empty(file)|return 4|endif
  let file = simplify(file)
  let head = fnamemodify(file,':h')..'/'
  let HEAD = fnamemodify(head,':p')..'/'

  call execute($'edit {file}')

  " fixes syntax for nvpm fluxfiles
  if head == s:dirs.local  || 
    \HEAD == s:dirs.global && 
    \&ft  != 'nvpm'
    let &ft = 'nvpm'
  endif

  " maketree functionality
  " TODO:
  "   - add help files identification & handling (I mean ignoring)
  if s:user.maketree &&
    \!empty(head) &&
    \!filereadable(head) &&
    \-1==match(file,'term\:\/\/')
    call mkdir(head,'p')
  endif

endfu "}
fu! nvpm#seek(...) " seeks either list or node of given type{

  let type = get(a:000,0,-1)
  let code = get(a:000,1,'node')
  let tree = get(a:000,2,g:nvpm.tree.root)

  if code=='node'
    if !has_key(tree,'list')|return {}|endif
    if type==tree.meta.type|return tree|endif

    return nvpm#seek(type,'node',tree.list[tree.meta.indx%tree.meta.leng])
  endif

  return get(nvpm#seek(type,'node',tree),'list',code=='list'?[]:{})

endfu "}
fu! nvpm#show(...) " {
  let tree = get(a:,1,g:nvpm.tree.root)
  call flux#show(tree)
endfu "}
fu! nvpm#indx(...) " {
  let dict = a:1
  let step = a:2
  let dict.indx+= step
  let dict.indx%= dict.leng
endfu "}
fu! nvpm#flux(...) " {
  if isdirectory(s:dirs.local)&&empty(g:nvpm.flux.list)
    let g:nvpm.flux.list = readdir(s:dirs.local)
    let g:nvpm.flux.leng = len(g:nvpm.flux.list)
    let g:nvpm.flux.indx = 0
  endif
endfu "}
fu! nvpm#synx(...) " {

  let lexis = get(a:000,0,g:nvpm.conf.lexis)
  let synx = {}

  let synx[0] = #{s:join(lexis[0],'\|'),e:lexis[0]}
  let synx[1] = #{s:join(lexis[1],'\|'),e:lexis[1]}
  let synx[2] = #{s:join(lexis[2],'\|'),e:lexis[2]}
  let synx[3] = #{s:join(lexis[3],'\|'),e:lexis[3]}

  let synx[0].e = synx[0].e +     []   
  let synx[1].e = synx[1].e + synx[0].e
  let synx[2].e = synx[2].e + synx[1].e
  let synx[3].e = synx[3].e + synx[2].e

  let g:nvpm.synx = synx

endfu "}

" }
" user functions {

fu! nvpm#DIRS(...) " {
  let files = readdir(s:dirs.local)
  "for i in range(len(files))
  "  let files[i] = s:dirs.local ..files[i]
  "endfor
  return files
endfu "}
fu! nvpm#MAKE(...) " {
endfu "}
fu! nvpm#LOOP(...) " {
  return g:nvpm.loop.words
endfu "}

" }

" end-func}
