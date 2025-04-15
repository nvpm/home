" meta/init.vim
" init {

let s:test = {}

"}
" plug {
fu! s:test.flux(...) "{

  so nvim/autoload/flux.vim
  so nvim/syntax/flux.vim

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

  so nvim/autoload/flux.vim
  so nvim/syntax/flux.vim
  so nvim/autoload/nvpm.vim
  so nvim/plugin/nvpm.vim

endfu "}
fu! s:test.zoom(...) "{

  so nvim/autoload/zoom.vim
  so nvim/plugin/zoom.vim

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
fu! s:test.line(...) "{

  so nvim/autoload/line.vim
  so nvim/plugin/line.vim

  fu! Showcterm()
    let term = &termguicolors
    set notermguicolors
    ec repeat("\n",3)
    for i in range(256)
      let name = 'nvpmtestcolor'.i
      exe 'hi '..name..' ctermbg='..i..' ctermfg='..(i%8==0||(i>=233&&i<=239)?255:8)
      exe 'echohl '..name
      echon ' '..i..' '
      "exe 'hi clear '..name
    endfor
    ec repeat("\n",2)
    let &termguicolors = term
  endfu
  call Showcterm()|delfunc Showcterm

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
if 1|call s:test.zoom()|endif
if 0|call s:test.line()|endif

"}
