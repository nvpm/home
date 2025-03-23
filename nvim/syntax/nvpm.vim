" Vim syntax file
" Language: nvpm
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
endif

runtime! syntax/flux.vim

let b:current_syntax = "nvpm"






















"if exists('g:nvpm.conf.node')
"  let s:node = g:nvpm.conf.node
"  fu! s:keywords(...) "{
"    let words = get(a:,0,'')
"    let strg = ''
"    let strg.= substitute(words,'|',' ','g')
"    let strg = trim(strg)
"    if get(a:,2,0)
"      let strg = substitute(strg,' ','\\|','g')
"    endif
"    return strg
"  endfu "}
"  "exec 'syn keyword fluxkeyword loop endloop home '..s:keywords(s:node)
"  let s:node = split(s:node,'|')
"  let s:conf = []
"  for type in s:node
"    if empty(type)|continue|endif
"    call add(s:conf,type)
"  endfor
"  unlet s:node
"endif

