" meta/init.vim
" init {

let s:test = {}

"}
" plug {
fu! s:test.arbo(...) "{

  "so autoload/flux.vim
  "so syntax/flux.vim
  "so autoload/arbo.vim
  "so plugin/arbo.vim
  
  so meta/meta.vim

  MetaSave

endfu "}
fu! s:test.line(...) "{

  so autoload/line.vim
  so plugin/line.vim
  so meta/meta.vim

  call meta#sync()
  return
  ec &tabline
  ec &statusline
  return
  fu! s:data(...)
    let data = a:2
    if data!=['']
      echo join(data)
    endif
  endfu

  if exists('s:sock')
    call chanclose(s:sock)
    let s:indx=0
  endif
  let nvpmcode = 'sock/nvpm.c'
  let nvpmexec = 'sock/nvpm'
  "call system('gcc '.nvpmcode.' -o '.nvpmexec)
  "call system(nvpmexec.' 2 8080&')

  let addr   = 'localhost:8080'
  let s:sock = sockconnect('tcp',addr,{'on_data':function('s:data')})

endfu "}
fu! s:test.flux(...) "{

  so autoload/flux.vim
  so syntax/flux.vim

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
fu! s:test.zoom(...) "{

  so autoload/zoom.vim
  "so plugin/zoom.vim

  call zoom#test()

  return
  let left = repeat(' ' ,g:zoom.size.l )
  ec left..'h: '.winheight(0).'/'.&lines ' ,  w: '.winwidth(0).'/'.&columns

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
fu! s:test.eval(...) "{
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

if 0|call s:test.flux()|endif
if 1|call s:test.arbo()|endif
if 0|call s:test.zoom()|endif
if 0|call s:test.line()|endif

"}
