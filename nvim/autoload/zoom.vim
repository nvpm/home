" auto/zoom.vim
" once {

if !NVPMTEST&&exists('__ZOOMAUTO__')|finish|endif
let __ZOOMAUTO__ = 1

" end-once}
" func {

fu! zoom#init(...) "{
  if exists('s:init')|return|else|let s:init=1|endif

  let s:zoom = 0

  let s:h = get(g:,'zoom_height','80%')
  let s:w = get(g:,'zoom_width' , 80  )

  if get(g:,'zoom_initzoom',0)
    call zoom#show()
  endif

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

" end-func }
