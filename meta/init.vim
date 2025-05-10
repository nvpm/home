" meta/init.vim
" init {

let s:test = {}

"}
" plug {
fu! s:test.flux(...) "{

  so autoload/FLUX.vim
  "so syntax/FLUX.vim

  let conf = {}

  let conf.file = 'test/flux/case.flux'
  let conf.home = 1
  let conf.fixt = 1

  let conf.lexis = '|||project|workspace|tab|file|||'

  let flux = FLUX#flux(conf)
  let expt = s:test.eval('test/flux/case.expt')

  echon "test/flux: "
  let diff = flux!=?expt
  if diff|call self.fail()|call FLUX#show(flux)|return 1|endif
  call self.pass()

endfu "}
fu! s:test.arbo(...) "{

  so meta/conf.vim
  so autoload/FLUX.vim
  so syntax/FLUX.vim
  so autoload/ARBO.vim

  call ARBO#init()
  call ARBO#grow('.nvpm/arbo/flux/test.flux')
  call ARBO#grow('.nvpm/arbo/flux/test.flux')
  call ARBO#grow('test/flux/case.flux')
  call ARBO#grow('test/flux/case.flux')
  call ARBO#grow('.nvpm/arbo/flux/test.flux')
  call ARBO#grow('.nvpm/arbo/flux/test.flux')
  call ARBO#grow('.nvpm/arbo/flux/test.flux')
  call ARBO#grow('test/flux/case.flux')
  call ARBO#grow('.nvpm/arbo/flux/main.flux')
  echo g:ARBO.data.meta 
  for flux in g:ARBO.data.list
    call FLUX#show(flux)
  endfor

endfu "}
fu! s:test.line(...) "{

  so autoload/LINE.vim
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
fu! s:test.zoom(...) "{

  so autoload/ZOOM.vim

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
