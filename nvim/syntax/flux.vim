" Vim syntax file
" Language: flux
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
else
  let b:current_syntax = "flux"
  syntax clear
endif

if !exists('g:nvpm.conf.lexis')
  if !exists('g:nvpm_fluxconf')
    finish
  else
    let s:lexis = g:nvpm_fluxconf.lexis
    if len(s:lexis)<4|finish|endif
  endif
else
  let s:lexis = g:nvpm.conf.lexis
endif

syn case ignore

"for i in range(4) "{
"
"  let s = s:synx[i].s
"  let c1= s:synx[i].c1
"  let c2= s:synx[i].c2..'\|endl\|endlo\|endloo\|endloop'
"
"  " for shortening of each code line's length
"  let  p= 'nvpm'..i
"  let syn = 'syntax match '..p
"  let hi  = 'hi def  link '..p
"  let cuts ='/^\c\s*-\{-1,2}\s*\n*\s*-*\('..s..'\)\_.*/'
"  let cut1 = '/^\c\s*-\s*\n*\s*-*\('..s..'\)\_.\{-}-*\('..c1..'\)/me=e-50'
"  let cut2 ='/^\c\s*--\s*\n*\s*-*\('..s..'\)\_.\{-}-*\('..c2..'\)/me=e-50'
"
"  " the instructions themselves
"  exec syn..'cuts '..cuts
"  exec syn..'cut1 '..cut1
"  exec syn..'cut2 '..cut2
"  exec hi ..'cuts  fluxcomm'
"  exec hi ..'cut1  fluxcomm'
"  exec hi ..'cut2  fluxcomm'
"
"endfor "}
"----------------------------------------------------

fu! s:synx(...) " {

let synx  = [{},{},{},{}]

let synx[0].s = s:lexis[0]
let synx[1].s = s:lexis[1]
let synx[2].s = s:lexis[2]
let synx[3].s = s:lexis[3]

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
let s:keyw = ''
let s:loop = 'loop endl endlo endloo endloop'

for type in s:lexis
  for keyw in type
    let s:keyw.= keyw..' '
  endfor
endfor

let s:keyw = trim(s:keyw)
let s:KEYW = substitute(s:keyw,'\s','\\|','g')
let s:LOOP = substitute(s:loop,'\s','\\|','g')

let s:r = 'syn region  flux'
let s:m = 'syn match   flux'
let s:k = 'syn keyword flux'
let s:h = 'hi def link flux'

exe s:m.'comm           /[#{}].*$/'
exe s:m.'sepr contained /[:=@,\/|]/'
exe s:m.'vars contained /\$(\w\+)/'
exe s:m.'keyw contained /\('.s:KEYW.'\)/'
exe s:m.'loop contained /\('.s:LOOP.'\)/'

syn cluster flux contains=fluxkeyw,fluxvars,fluxsepr,fluxcomm
exe s:m.'name /\s*\('.s:KEYW.'\)\s\+[$().a-z0-9_-|\/ ]\+\s*[:=@]/ contains=@flux'
exe s:m.'line /\s*\('.s:KEYW.'\)\s\+[$().a-z0-9_-|\/]\+\s*[:=@]\=.*$/ contains=@flux,fluxname'

exe s:h.'name  Normal'
exe s:h.'line  Operator'

exe s:h.'comm  Comment'
exe s:h.'sepr  Normal'
exe s:h.'vars  CursorLineNr'
exe s:h.'keyw  Keyword'


"exe s:h.'line  NonText'
"exe s:h.'cut3 fluxcomm'


finish

"----------------------------------------------------


exe 'syn   match fluxname /\c\s*\('..s:keyw..'\)\s\+[$().a-z0-9_-|\/]\+\s*[:=@]/ contains=fluxsepr,fluxkeyw,fluxvars'
exe 'syn  match  fluxinfo /\c\s*\('..s:keyw..'\)\s\+[$().a-z0-9_-|\/]\+\s*[:=@]\=.*$/ contains=fluxkeyw,fluxname,fluxcomm,fluxvars,fluxsepr'

"----------------------------------------------------
"syn   match fluxcomm /[#{}].*$/
"syn   match fluxvars /\$([a-z0-9_~-]\+)/ contained
"syn  region fluxinfo start=/[:=@]/ms=e+1 end=/\n/ contains=fluxcomm,fluxvars
"exe 'syn   match fluxname /^\c\s*\('..s:keyw..'\)\s\+[$().a-z0-9_-|\/]\+/ contains=fluxkeyw,fluxvars'
"
""exe 'syn   match fluxinfo /^\c\s*\('..s:keyw..'\)\s\+.*[:=@]\=.*$/ contains=fluxkeyw,fluxname'
"
"hi def link fluxvars WarningMsg
"hi def link fluxcomm Comment
"hi def link fluxinfo Include
"hi def link fluxname SpellBad
"hi def link fluxcut3 fluxcomm
"----------------------------------------------------
syn match fluxlcut1 contained /\s*-\s*[a-z0-9_./\\:]\+/
syn match fluxlcut2 contained /\s*-\{2,}.*$/
syn match fluxlname contained /\w*\s*[:=@]/
syn match fluxlhead           /^\c\s*loop\s*\w*\s*[:=@].*$/ contains=fluxkeyw,fluxlname,fluxlinfo,fluxlcut1,fluxlcut2,fluxcomm
syn region fluxlcuts start=/^\c\s*-\{1,2}\s*.*\n*\s*loop/ end=/\c\(endl\|endlo\|endloo\|endloop\).*$/ contains=fluxcut3

hi def link fluxlcut1 fluxcomm
hi def link fluxlcut2 fluxcomm
hi def link fluxlname fluxvars
hi def link fluxlhead fluxinfo
hi def link fluxlcuts fluxcomm
"----------------------------------------------------

unlet s:synx s:lexis s:keyw
