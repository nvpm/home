" Vim syntax file
" Language: nvpm
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
endif

runtime! syntax/flux.vim

let b:current_syntax = "nvpm"

if !exists('g:nvpm.conf.lexis')|finish|endif

syn match   nvpm2cut1  /^\c\s*-\s*\n*\s*tab\_.\{-}\(tab\|workspace\|project\)/me=e-50
hi def link nvpm2cut1 Comment                            

"syn region nvpm2cut1alone start=/^\c\s*-\s*\n*/ end=/^\s*tab\_.\{-}\(tab\)/
"hi def link nvpm2cut1alone Comment
"
"
"
"finish
"syn region nvpmc1wksp start=/^\s*\*\s*workspace/ end=/^\s*workspace/me=s-9 

"syn match   nvpmc1file /^\c\s*-\s*\n*\s*file\s*\(.*\)$/
"hi def link nvpmc1file Comment

"syn match nvpm2cut1a /^\c\s*-\s*\n*\s*tab\_.*\(tab\|workspace\|project\)*/
"syn match nvpm2cut1  /^\c\s*-\s*\n*\s*tab\_.*tab/me=e-10


"hi def link nvpm2cut1  Comment
"hi def link nvpm2cut1a Comment






















finish
fu! s:synx(...) " {

  let lexis = g:nvpm.conf.lexis
  let synx = [0,1,2,3]

  let synx[0] = #{s:join(lexis[0],'\|'),e:lexis[0]}
  let synx[1] = #{s:join(lexis[1],'\|'),e:lexis[1]}
  let synx[2] = #{s:join(lexis[2],'\|'),e:lexis[2]}
  let synx[3] = #{s:join(lexis[3],'\|'),e:lexis[3]}

  let synx[0].e = synx[0].e +     []   
  let synx[1].e = synx[1].e + synx[0].e
  let synx[2].e = synx[2].e + synx[1].e
  let synx[3].e = synx[3].e + synx[2].e

  let synx[0].e = #{cut1:synx[0].e,cut2:['']}
  let synx[1].e = #{cut1:synx[1].e,cut2:synx[0].e.cut1}
  let synx[2].e = #{cut1:synx[2].e,cut2:synx[1].e.cut1}
  let synx[3].e = #{cut1:synx[3].e,cut2:synx[2].e.cut1}

  return synx

endfu "}

let s:synx = s:synx()
let s:indx = 0

for type in s:synx
  "for parent in type.e.cut1
  "  let init = 'syn region '
  "  let name = 'nvpmcut1type'..string(s:indx)..parent
  "  let start= ' start=/^\c\s*-\s*\n*\s*\('..type.s..'\)/'
  "  let end  = ' end=/^\c\s*'..parent..'/me=s-'..string(len(parent))
  "  let cont = ' contains=fluxcut3'..'nvpmcut1type'..string(s:indx)..parent
  "  let cont = ' contains=fluxcut3'
  "  let synx = init..name..start..end..cont
  "  let high = 'hi def link '..name..' Comment'
  "  call execute(synx)
  "  call execute(high)
  "endfor
  "for parent in type.e.cut2
  "  let init = 'syn region '
  "  let name = 'nvpmcut2type'..string(s:indx)..parent
  "  let start= ' start=/^\c\s*--\s*\n*\s*\('..type.s..'\)/'
  "  let end  = empty(parent)?'':'^\c\s*'..parent
  "  let end  = ' end=/'..end..'/me=s-'..string(len(parent))
  "  let cont = ' contains=fluxcut3'..'nvpmcut1type'..string(s:indx)..parent
  "  "let synx = init..name..start..end..cont
  "  let synx = init..name..start..end
  "  let high = 'hi def link '..name..' Comment'
  "  call execute(synx)
  "  call execute(high)
  "endfor
  let s:indx+=1
endfor

"unlet s:synx s:indx
