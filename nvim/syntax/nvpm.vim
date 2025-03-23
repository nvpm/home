" Vim syntax file
" Language: nvpm
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
endif

runtime! syntax/flux.vim

let b:current_syntax = "nvpm"

if !exists('g:nvpm.conf')|finish|endif
finish

let s:synx = g:nvpm.synx
let s:tree = s:synx[:len(s:synx)-2]
let s:leaf = s:synx[ len(s:synx)-1]

" cut2 functionality
let s:indx = 0
for type in s:tree
  for parent in type.e
    let init = 'syn region '
    let name = 'nvpmcut2type'..string(s:indx)..parent
    let start= ' start=/^\c\s*--\s*\n*\s*\('..type.s..'\)/'
    let end  = ' end=/^\c\s*'..parent..'/me=s-'..string(len(parent))
    let syn  = init..name..start..end
    let hi   = 'hi def link '..name..' Comment'
    call execute(syn)
    call execute(hi)
  endfor
  let s:indx+=1
endfor




