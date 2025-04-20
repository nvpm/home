"-- auto/nvpm.vim  --

if !NVPMTEST&&exists('__NVPMAUTO__')|finish|endif
let __NVPMAUTO__ = 1

"-- main functions --
fu! nvpm#init(...) abort "{ 

  " s:init {

    if exists('s:init')|return|else|let s:init=1|endif

  " }
  " s:loop {

    let s:loop = {'+':1,'-':-1,'next':+1,'prev':-1}

  "}
  " s:dirs {
  
    let s:dirs = {}
    let s:dirs.root  = '.nvpm/flux/'
    let s:dirs.edit = '.nvpm/edit'
    let s:dirs.save = '.nvpm/save'
    let s:dirs.curr = '.nvpm/curr'

  " }
  " s:conf {
  
    let s:conf = get(g:,'nvpm_fluxconf',{})
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
  " g:nvpm {

    let g:nvpm = {}

    let g:nvpm.tree = {}
    let g:nvpm.tree.root = {}
    let g:nvpm.tree.file = ''
    let g:nvpm.tree.mode = 0

    let g:nvpm.edit = {}
    let g:nvpm.edit.line = 0
    let g:nvpm.edit.mode = 0
    let g:nvpm.edit.curr = ''

    let g:nvpm.term = {}
    let g:nvpm.term.buff = ''

    let g:nvpm.flux = {}
    let g:nvpm.flux.list = []
    let g:nvpm.flux.leng = 0
    let g:nvpm.flux.indx = 0

  " }

  let init = abs(get(g:,'nvpm_initload',0))
  if init && !argc() 
    if filereadable(s:dirs.save)
      let flux = get(readfile(s:dirs.save),0,'')
      if !empty(flux) && filereadable(s:dirs.root..flux)
        let u = init>0 && init<200
        call timer_start(u*200+(!u)*init,{->nvpm#load(flux)})
      endif
    endif
  endif

endfu "}
fu! nvpm#load(...) abort "{

  let file = flux#argv(a:000)

  if !g:nvpm.edit.mode
    let file = s:dirs.root..file
  endif

  if !filereadable(file)|return 1|endif

  let s:conf.file = file
  let root = flux#flux(s:conf)
  let list = get(root,'list',[])

  if empty(root)    |let s:conf.file=''|return 2|endif
  if empty(list)    |let s:conf.file=''|return 3|endif
  if nvpm#curr(root)|let s:conf.file=''|return 4|endif

  let g:nvpm.tree.root = root
  let g:nvpm.tree.file = file
  let g:nvpm.tree.mode = 1

  if get(g:,'nvpm_loadline',1)
    if exists('*line#show')
      hi clear TabLine
      hi clear StatusLine
      let g:line.nvpm = 1
      call line#show()
    endif
  endif
  call nvpm#save()
  call nvpm#rend()
  if exists('g:zoom.mode')&&g:zoom.mode
    only
    call zoom#show()
  endif

endfu "}
fu! nvpm#loop(...) abort "{

  if !a:0|return 1|endif

  let user = split(a:1,' ')
  let step = get(user,0, 0)
  let type = get(user,1,-1)
  let step = get(s:loop,step,0)

  if type=='flux'||type=='-1' " flux files iteration {
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
  endif "}

  if type(step)!=type(0)|ec 'wrong arg-commands'|return 1|endif
  let step = v:count1 * step
  let tree = g:nvpm.tree.root

  if type!='0'&&type!='1'&&type!='2'&&type!='3'
    let type = flux#find(s:conf.lexis,type)
  else
    let type = str2nr(type)
  endif

  if type<0||type>3|return 1|endif

  if g:nvpm.tree.mode
    if type == 2 && g:nvpm.edit.mode|call nvpm#edit()|endif
    if type == 1 && g:nvpm.edit.mode|call nvpm#edit()|endif
    if type == 0 && g:nvpm.edit.mode|call nvpm#edit()|endif
    let bufname = bufname()
    if bufname==g:nvpm.tree.curr 
      let node = flux#seek(tree,type)
      if empty(node)|return 1|endif
      call nvpm#indx(node.meta,step)
    endif
    call nvpm#curr()
    call nvpm#rend()
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
fu! nvpm#edit(...) abort "{

  " loads bufname if in edit mode 
  " only leaves edit mode upon correct load
  if g:nvpm.edit.mode
    let g:nvpm.edit.mode = nvpm#load(bufname())
    return
  endif

  " makes the edit file otherwise
  let fluxes = []
  if isdirectory(s:dirs.root)
    let fluxes = readdir(s:dirs.root)
  endif
  let body   = []
  for file in fluxes
    let file = s:dirs.root..file
    let line = 'file '..fnamemodify(file,':t:r')..':'..file
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
fu! nvpm#save(...) abort "{

  if g:nvpm.tree.file != s:dirs.edit
    call writefile([fnamemodify(g:nvpm.tree.file,':t')],s:dirs.save)
  endif

endfu "}
fu! nvpm#term(...) abort "{

  if !bufexists(g:nvpm.term.buff)
    exec 'buffer|terminal'
    let g:nvpm.term.buff = bufname()
  endif

  if !empty(matchstr(g:nvpm.term.buff,'term://.*'))
    call execute('edit! '..g:nvpm.term.buff)
  endif

endfu "}
fu! nvpm#make(...) abort "{


  let name = get(a:000,0,'')

  if empty(name)|return|endif
  if !isdirectory(s:dirs.root)&&filereadable(s:dirs.root)
    ec 'Location '..s:dirs.root..' is a file. Remove it first.'
    return
  endif

  call mkdir(s:dirs.root,'p')
  call nvpm#flux()

  let name = fnamemodify(name,':e')=='flux'?name:fnamemodify(name,':t:r')..'.flux'

  for flux in g:nvpm.flux.list
    if flux==a:1
      echo 'NVPM: flux file ['.name.'] already exists.'
      echo '      Choose another name!'
      return
    endif
  endfor

  let path = s:dirs.root..name

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

"-- auxy functions --
fu! nvpm#curr(...) abort "{

  let root = get(a:,1,g:nvpm.tree.root)
  let list = get(root,'list',[])

  if empty(root)|return 1|endif
  if empty(list)|return 2|endif
                                     
  let node = flux#seek(root,3)
  if empty(node)|return 3|endif
  let curr = node.list[node.meta.indx].data.info
  if empty(curr)|return 4|endif

  let g:nvpm.tree.curr = curr

endfu "}
fu! nvpm#rend(...) abort "{

  let curr = simplify(g:nvpm.tree.curr)
  let head = fnamemodify(curr,':h')..'/'
  let HEAD = fnamemodify(head,':p')..'/'


  if !empty(curr)

    call execute('edit '.curr)

    if 1+match(curr,'^.*\.flux$')||
      \head == s:dirs.root      &&
      \&ft  != 'flux'
      set filetype=flux
      set commentstring=-%s
    endif

    if get(g:,'nvpm_maketree',0) &&
      \!empty(head) &&
      \!filereadable(head) &&
      \-1==match(curr,'term\:\/\/')
      call mkdir(head,'p')
    endif

  endif

endfu "}
fu! nvpm#indx(...) abort "{

  let meta = a:1
  let step = a:2
  let meta.indx+= step                    " steps forwards or backwards
  let meta.indx%= meta.leng               " limits range inside length
  let meta.indx+= (meta.indx<0)*meta.leng " keeps indx positive

endfu "}
fu! nvpm#show(...) abort "{

  call flux#show(get(a:,1,g:nvpm.tree.root))

endfu "}
fu! nvpm#flux(...) abort "{

  if isdirectory(s:dirs.root)&&empty(g:nvpm.flux.list)
    let g:nvpm.flux.list = readdir(s:dirs.root)
    let g:nvpm.flux.leng = len(g:nvpm.flux.list)
    let g:nvpm.flux.indx = 0
  endif

endfu "}

"-- user functions --
fu! nvpm#DIRS(...) abort "{
  let files = readdir(s:dirs.root)
  return files
endfu "}
fu! nvpm#LOOP(...) abort "{
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
