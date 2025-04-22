" meta/init.vim
" init {

let s:test = {}

"}
" plug {
fu! s:test.line(...) "{

  so plug/line/autoload/line.vim
  so plug/line/plugin/line.vim

  call line#test()
  return
  "U+2500–U+257F   # Box Drawing
  "U+2580–U+259F   # Block Elements
  "U+1FB00–U+1FBFF # Legacy Computing (includes extended box drawing)

  for i in range(0x2500,0x257f)
    echon nr2char(i) . ' '
  endfor

  for i in range(0x2580,0x259f)
    echon nr2char(i) . ' '
  endfor

  for i in range(0x1FB00,0x1FBFF)
    echon nr2char(i) . ' '
  endfor

    return
    let file = 'char/char.gen'
    let body = []
    let line = ''
    let size = float2nr(pow(2,7))
    let shift= 0
    for n in range(10000)
      let init = (n+0)*size + shift
      let end  = (n+1)*size + shift
      call add(body,'{ '..init.' - '.end)
      call add(body,'')
      for i in range(init,end)
        let char = nr2char(i).. ' '
        if i%30==0
          call add(body,line)
          let line = ''
        elseif char=~'\p'
          let line.= char
        endif
      endfor
      call add(body,'')
      call add(body,'}')
    endfor
    call writefile(body,file)
    ec 'finished'

  return
  "fu! Showcterm()
  "  let term = &termguicolors
  "  set notermguicolors
  "  ec repeat("\n",3)
  "  for i in range(256)
  "    let name = 'nvpmtestcolor'.i
  "    exe 'hi '..name..' ctermbg='..i..' ctermfg='..(i%8==0||(i>=233&&i<=239)?255:8)
  "    exe 'echohl '..name
  "    echon ' '..i..' '
  "    "exe 'hi clear '..name
  "  endfor
  "  ec repeat("\n",2)
  "  let &termguicolors = term
  "endfu
  ""call Showcterm()|delfunc Showcterm
  "ec line#foot()

endfu "}
fu! s:test.flux(...) "{

  so plug/flux/autoload/flux.vim
  so plug/flux/syntax/flux.vim

  let conf = {}

  let conf.file = 'test/flux/case.case'
  let conf.home = 1
  let conf.fixt = 1

  let conf.lexis = ''
  let conf.lexis.= '|project proj'
  let conf.lexis.= '|workspace archive arch'
  let conf.lexis.= '|tab pack folder fold'
  let conf.lexis.= '|file buff'

  let flux = flux#flux(conf)
  let expt = s:test.eval('test/flux/case.expt')

  echon "test/flux: "
  let diff = flux!=?expt
  if diff|call self.fail()|call flux#show(flux)|return 1|endif
  call self.pass()

endfu "}
fu! s:test.nvpm(...) "{

  so plug/flux/autoload/flux.vim
  so plug/flux/syntax/flux.vim
  so plug/nvpm/autoload/nvpm.vim
  so plug/nvpm/plugin/nvpm.vim

endfu "}
fu! s:test.zoom(...) "{

  so plug/zoom/autoload/zoom.vim
  so plug/zoom/plugin/zoom.vim

  ec '     h: '.winheight(0).'/'.&lines ' ,  w: '.winwidth(0).'/'.&columns

  return

  let conf = {}
  let conf.relative = 'win'
  let conf.style = 'minimal'
  let conf.border = ['+','-','+','|']
  let conf.title = 'zoom mode'
  let conf.title_pos = 'center'
  let conf.width = 40
  let conf.height= 12
  let conf.col= 10
  let conf.row= 1

  return
  call nvim_open_win(0,1,conf)
  ec nvim_win_get_config(0)

endfu "}
"}
" test {
fu! s:test.eval(...) "{"
  let file = a:1
  if !filereadable(file)
    return []
  endif
  let file = readfile(file)
  let indx = match(file,'ft=')
  if 1+indx
    call remove(file,indx)
  endif
  return eval(join(file))

endfu "}
fu! s:test.pass(...) "{"
  echohl NVPMPassed
  echon "pass"
  echohl None
endfu "}
fu! s:test.fail(...) "{"
  echohl NVPMFailed
  echon "fail"
  echohl None
endfu "}
"}
" exec {

if 0| so meta/conf.vim |endif
if 0|call s:test.flux()|endif
if 0|call s:test.nvpm()|endif
if 0|call s:test.zoom()|endif
if 1|call s:test.line()|endif

"}
