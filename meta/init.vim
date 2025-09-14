" meta/init.vim
" init {



"}
" plug {
fu! s:test.arbo(...) "{

  so autoload/arbo.vim
  "so syntax/arbo.vim

  let conf = {}

  let conf.file = 'test/arbo/case.arbo'
  let conf.home = 1
  let conf.fixt = 1

  let conf.lexicon = ',workspace,tab,file buffer'

  let arbo = arbo#arbo(conf)
  echo string(arbo)
  return
  let expt = s:test.eval('test/arbo/case.expt')

  echon "test/arbo: "
  let diff = arbo!=?expt
  if diff|call self.fail()|call arbo#show(arbo)|return 1|endif
  call self.pass()

endfu "}
fu! s:test.nvpm(...) "{

  "so meta/conf.vim
  "so autoload/nvpm.vim
  "so plugin/nvpm.vim


endfu "}
fu! s:test.line(...) "{

  so autoload/line.vim

  call line#init()

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

  so autoload/zoom.vim

  "call zoom#test()

  "return
  let left = repeat(' ' ,g:zoom.size.l )
  ec left..'h: '.winheight(0).'/'.&lines ' ,  w: '.winwidth(0).'/'.&columns
  ec left..string(g:zoom.size)


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

if 0|call s:test.arbo()|endif
if 0|call s:test.nvpm()|endif
if 1|call s:test.zoom()|endif
if 0|call s:test.line()|endif

"}
