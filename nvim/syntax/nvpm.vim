" Vim syntax file
" Language: nvpm
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
endif

runtime! syntax/flux.vim

let b:current_syntax = "nvpm"

if !exists('g:nvpm.conf.lexis')|finish|endif

fu! s:synx(...) " {

let lexis = g:nvpm.conf.lexis
let synx  = [{},{},{},{}]

let synx[0].s = lexis[0]
let synx[1].s = lexis[1]
let synx[2].s = lexis[2]
let synx[3].s = lexis[3]

let synx[0].c1 = synx[0].s +    []
let synx[1].c1 = synx[1].s + synx[0].c1
let synx[2].c1 = synx[2].s + synx[1].c1
let synx[3].c1 = synx[3].s + synx[2].c1

let synx[0].c2 =    []
let synx[1].c2 = synx[0].c1
let synx[2].c2 = synx[1].c1
let synx[3].c2 = synx[2].c1

let synx[0].s = join(synx[0].s,'\|')
let synx[1].s = join(synx[1].s,'\|')
let synx[2].s = join(synx[2].s,'\|')
let synx[3].s = join(synx[3].s,'\|')

let synx[0].c1 = join(synx[0].c1,'\|')
let synx[1].c1 = join(synx[1].c1,'\|')
let synx[2].c1 = join(synx[2].c1,'\|')
let synx[3].c1 = join(synx[3].c1,'\|')

let synx[0].c2 = join(synx[0].c2,'\|')
let synx[1].c2 = join(synx[1].c2,'\|')
let synx[2].c2 = join(synx[2].c2,'\|')
let synx[3].c2 = join(synx[3].c2,'\|')

return synx

endfu "}

let s:synx = s:synx()

for i in range(4)
  let s = s:synx[i].s
  let c1= s:synx[i].c1
  let c2= s:synx[i].c2
  let  p= 'nvpm'..i
  let syn = 'syntax match '..p
  let hi  = 'hi def  link '..p

  let cuts ='/^\c\s*-\{-1,2}\s*\n*\s*-*\('..s..'\)\_.*/'
  let cut1 = '/^\c\s*-\s*\n*\s*-*\('..s..'\)\_.\{-}-*\('..c1..'\)/me=e-50'
  let cut2 ='/^\c\s*--\s*\n*\s*-*\('..s..'\)\_.\{-}-*\('..c2..'\)/me=e-50'

  exec syn..'cuts '..cuts
  exec syn..'cut1 '..cut1
  exec syn..'cut2 '..cut1

  exec hi ..'cuts  fluxcomm'
  exec hi ..'cut1  fluxcomm'
  exec hi ..'cut2  fluxcomm'

endfor








