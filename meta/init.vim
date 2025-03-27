" meta/init.vim
" init {

let s:test = {}
so meta/conf.vim

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
  call flux#show(flux)
  return
  let expt = s:test.eval('test/flux/case.expt')

  echon "test/flux: "
  let diff = flux!=?expt
  if diff|call self.fail()|call flux#show(flux)|return 1|endif
  call self.pass()

endfu "}
fu! s:test.nvpm(...) "{

  so nvim/autoload/flux.vim                        
  so nvim/syntax/flux.vim
  so nvim/autoload/line.vim
  so nvim/plugin/line.vim
  so nvim/autoload/nvpm.vim
  so nvim/plugin/nvpm.vim

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

if 1|call s:test.flux()|endif
if 1|call s:test.nvpm()|endif

"}
