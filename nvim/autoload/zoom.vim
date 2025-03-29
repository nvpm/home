" auto/zoom.vim
" once {

if !NVPMTEST&&exists('__ZOOMAUTO__')|finish|endif
let __ZOOMAUTO__ = 1

" end-once}
" func {

" --- main functions ---
fu! zoom#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif

  let s:user = {}
  let s:user.height = get(g:,'zoom_height','80%')
  let s:user.width  = get(g:,'zoom_width' , 80  )
  let s:user.layout = get(g:,'zoom_layout', 'center')

  if get(g:,'zoom_initload',0)
    call zoom#show()
  endif

  let s:zoom = 0

  let s:tbuf = '.nvpm/zoom/tbuf'
  let s:bbuf = '.nvpm/zoom/bbuf'
  let s:rbuf = '.nvpm/zoom/rbuf'
  let s:lbuf = '.nvpm/zoom/lbuf'
  let s:bufflist = [s:lbuf,s:bbuf,s:tbuf,s:rbuf]

endfu "}
fu! zoom#swap(...) "{
  if s:zoom
    call zoom#hide()
  else
    call zoom#show()
  endif
endfu "}
fu! zoom#show(...) "{

  call line#hide()

  let s:zoom = 1

endfu "}
fu! zoom#hide(...) "{

  call line#show()

  let s:zoom = 0

endfu "}
fu! zoom#open(...) "{

endfu "}
fu! zoom#bdel(...) "{

endfu "}

" --- au   functions ---
fu! zoom#help(...) "{
  let bufname=bufname()
  if &filetype == 'man'
    close
    if s:zoom
      call zoom#hide()
      exec 'edit '. bufname
      call zoom#show()
    else
      exec 'edit '. bufname
    endif
  endif
  if &filetype == 'help' && !s:zoom|only|endif
  if &filetype == 'help' && s:zoom &&!filereadable('./'.bufname)
    bdel
    exec 'edit '. bufname
  endif
endfu "}
fu! zoom#quit(...) "{
  call zoom#hide()
  quit
endfu "}
fu! zoom#back(...) "{

  if (1+match(s:bufflist,bufname())) && !s:spliting
    let s:zoom = 0
    call zoom#bdel()
    call zoom#swap()
  endif
  if exists('g:nvpm.tree.mode') && !s:spliting
    if g:nvpm.tree.mode
      exe 'edit '..g:nvpm.tree.curr
    endif
  endif
endfu "}

" end-func }
