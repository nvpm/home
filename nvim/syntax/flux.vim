" Vim syntax file
" Language: flux
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
else
  let b:current_syntax = "flux"
  syntax clear
endif

let s:r = 'syn region  FLUX'
let s:m = 'syn match   FLUX'
let s:k = 'syn keyword FLUX'
let s:h = 'hi def link FLUX'

fu! s:main() "{

  exe s:m.'comm /[#{}].*$/                '
  exe s:m.'sepr /[:=@,_\/|]/     contained'
  exe s:m.'vars /\$(\w\+)/       contained'
  exe s:m.'cut3 /^\s*-\{3,}\_.*/          '

  exe s:h.'comm Comment'
  exe s:h.'sepr Normal'
  exe s:h.'vars Title'
  exe s:h.'cut3 fluxcomm'

  "exe s:h.'name Normal'
  "exe s:h.'line Operator'
  "exe s:h.'keyw Keyword'
  "exe s:h.'kcom fluxkeyw'

endfu "}
call s:main()
fu! s:loop() "{
  let head = '/^\v *loop +.*$/ contains=@fluxloop'
  let name = '/\w*\s*[:=@]/ contains=fluxsepr'
  let cut1 = '/\s*-\s*[a-z0-9_.-\/]\+/'
  let cut2 = '/\s*-\{2,}.*$/'
  let cuts = 'start=/^\s*-\{1,2}\s*.*\n*\s*loop/ end=/^\s*\(endl\|endlo\|endloo\|endloop\).*$/'
  syn cluster fluxloop 
\ contains=fluxlkeyw,fluxlname,fluxlcut1,fluxlcut2,fluxcomm
  exe s:k.'lkeyw loop endl[oop]'
  exe s:m.'lname '.name.' contained'
  exe s:m.'lcut1 '.cut1.' contained'
  exe s:m.'lcut2 '.cut2.' contained'
  exe s:m.'lhead '.head
  exe s:r.'lcuts '.cuts

  exe s:h.'lkeyw Keyword'
  exe s:h.'lhead Operator'
  exe s:h.'lcut1 fluxcomm'
  exe s:h.'lcut2 fluxcomm'
  exe s:h.'lname fluxvars'
  exe s:h.'lcuts fluxcomm'

endfu "}
call s:loop()
fu! s:cuts()
endfu

finish
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

for i in range(4) "{

  let s = s:synx[i].s
  let c1= s:synx[i].c1
  let c2= s:synx[i].c2..'\|endl\|endlo\|endloo\|endloop'

  " for shortening of each code line's length
  let  p= 'flux'..i
  let syn = 'syntax match '..p
  let hi  = 'hi def  link '..p

  let cuts = '/^\s*-\{-1,2}\s*\n*\s*-*\('.s.'\)\_.*/'
  let cut1 = '/^\s*-\s*\n*\s*-*\('.s.'\)\_.\{-}-*\('.c1.'\)/me=e-50'
  let cut2 ='/^\s*--\s*\n*\s*-*\('.s.'\)\_.\{-}-*\('.c2.'\)/me=e-50'

  exe syn..'cuts '..cuts
  exe syn..'cut1 '..cut1
  exe syn..'cut2 '..cut2

  exe hi ..'cuts  fluxcomm'
  exe hi ..'cut1  fluxcomm'
  exe hi ..'cut2  fluxcomm'


endfor "}

"----------------------------------------------------
" main flux definitions

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

syn cluster flux contains=fluxkeyw,fluxvars,fluxsepr,fluxcomm

exe s:m.'comm             /[#{}].*$/'
exe s:m.'sepr   contained /[:=@,_\/|]/'
exe s:m.'vars   contained /\$(\w\+)/'
exe s:m.'keyw   contained /^\s*\('.s:KEYW.'\)/'
exe s:m.'kcom   contained /,\s*\('.s:KEYW.'\)/ contains=fluxsepr'
exe s:m.'name /,*\s*\('.s:KEYW.'\)\s\+[$().a-z0-9_-|\/ ]*\s*[:=@]/ contains=@flux,fluxkcom'
exe s:m.'line /^\(,*\s*\('.s:KEYW.'\)\s*[$().a-z0-9_-|\/]*\s*[:=@]\=.*\)\+$/ contains=@flux,fluxname'
"exe s:m.'line /\s*\('.s:KEYW.'\)\s\+[$().a-z0-9_-|\/]*\s*[:=@]\=.*$/ contains=@flux,fluxname'
exe s:m.'cut3 /^\s*-\{3,}\_.*/ contains=fluxlendl'

exe s:h.'name  Normal'
exe s:h.'line  Operator'
exe s:h.'comm  Comment'
exe s:h.'cut3  fluxcomm'
exe s:h.'sepr  Normal'
exe s:h.'vars  Title'
exe s:h.'keyw  Keyword'
exe s:h.'kcom  fluxkeyw'

"----------------------------------------------------
" loop definitions

exe s:m.'lkeyw contained /\('.s:LOOP.'\)/'
exe s:m.'lcut1 contained /\s*-\s*[a-z0-9_.-\/]\+/'
exe s:m.'lcut2 contained /\s*-\{2,}.*$/'
exe s:m.'lname contained /\w*\s*[:=@]/ contains=fluxsepr'
exe s:r.'lcuts start=/^\s*-\{1,2}\s*.*\n*\s*loop/ end=/^\s*\(endl\|endlo\|endloo\|endloop\).*$/ contains=fluxcut3'

exe s:m.'lendl /^\s*\('.s:LOOP.'\).*$/ contains=fluxcomm'
exe s:m.'lhead /^\s*loop\s*\w*\s*[:=@].*$/ contains=fluxlkeyw,fluxlname,fluxlcut1,fluxlcut2,fluxcomm'

exe s:h.'lkeyw fluxkeyw'
exe s:h.'lendl fluxkeyw'
exe s:h.'lcut1 fluxcomm'
exe s:h.'lcut2 fluxcomm'
exe s:h.'lname fluxvars'
exe s:h.'lcuts fluxcomm'
exe s:h.'lhead fluxline'

"----------------------------------------------------

unlet s:synx s:lexis s:keyw
