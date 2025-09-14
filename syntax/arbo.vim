" Vim syntax file
" Language: arbo
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
else
  let b:current_syntax = "arbo"
  syntax clear
endif

" Note: this function exists only to use any names
"	for local variables,instead of using s: vars
"	It's deleted immediately after its 1st call
fu! s:main()

" main {{{3

  let c  = 'syn cluster arbo'
  let k  = 'syn keyword arbo'
  let r  = 'syn  region arbo'
  let m  = 'syn   match arbo'
  let h  = 'hi def link arbo'
  let cd = ' contained '
  let ct = ' contains='

  let comm = '[#{}]'
  let sepr = '[:=,]'
  let vars = '\(\$_\|\$(\w\+)\)'
  let cut3 = '/\(^\|,\)\s*---\_.*/'
  let cuts = '/^\s*--\=\s*$/'
  exe m.'comm /'.comm.'.*$/'.cd|exe h.'comm Comment'
  exe m.'vars /'.vars.'/'   .cd|exe h.'vars Title'
  exe m.'sepr /'.sepr.'/'   .cd|exe h.'vars Normal'

  exe m.'cut3 '.cut3|exe h.'cut3 arbocomm'
  exe m.'cuts '.cuts|exe h.'cuts arbocomm'

" }}}
" arbo {{{3

  let keyw = '\(^\|,\)\s*\w\+\s*'
  exe m.'keyw /'.keyw.'/'.cd.ct.'arbosepr'|exe h.'keyw Keyword'

  let sep  = '[:=]'
  let name = '/'
  let name.= '\('.keyw.'\)*'
  let name.= '\([-_+a-zA-Z0-9$()\|/]\+\s*\)\+'
  let name.= sep
  let name.= '/'
  let name.= cd
  let name.= ct.'arbokeyw,arbosepr,arbovars'
  exe m.'name '.name|exe h.'name Normal'

  let line = '/^.*$/'
  let line.= ct.'arbokeyw,arbosepr,arboname,arbovars,arbocomm,arbocut3,arbocuts'
  exe m.'line '.line|exe h.'line Constant'

" }}}
" loop {{{3

  let sep  = '[:=]'
  let keyw = '^\s*loop'
  let loop = '/'.keyw.'\s\+/'
  let endl = '/^\s*endl\s*'.comm.'*$/'
  let endl.= ct.'arbocomm'
  let cut1 = '/\('.keyw.'\s\+\|'.sep.'\s*\)\=-\+\s*\w\+/'.cd.ct.'arbolkeyw,arbosepr'
  let cut2 = '/\('.keyw.'\s\+\|'.sep.'\s*\)\=--\+.*$/'.cd.ct.'arbolkeyw,arbosepr'
  let lcut = ' start=/^\s*--*\s*\n*\s*loop/'
  let lcut.= '   end=/^\s*endl.*$/'
  let lcut.= ct.'arbocut3'

  exe m.'lkeyw '.loop|exe h.'lkeyw Title'
  exe m.'lendl '.endl|exe h.'lendl arbolkeyw'
  exe m.'lcut1 '.cut1|exe h.'lcut1 arbocomm'
  exe m.'lcut2 '.cut2|exe h.'lcut2 arbocomm'
  exe r.'lcuts '.lcut|exe h.'lcuts arbocomm'

  let name = '/'.keyw.'\s\+\w\+\s*'.sep.'/'
  let name.= cd
  let name.= ct.'arbolkeyw,arbosepr'
  exe m.'lname '.name|exe h.'lname arbovars'

  let head = '/'.keyw.'\s\+.*$/'
  let head.= ct.'arbolkeyw,arbosepr,arbolname,arbolcut1,arbolcut2,arbocomm'
  exe m.'lhead '.head|exe h.'lhead arboline'

  exe m.'lnone /'.keyw.'\s\+-*\s*\w*s*'.sep.'\=\s*--\_.*endl.*$/'
  exe m.'lnone /^.*'.sep.'\(\s*-\s*\w\+\s*\)*\s*--\_.*endl.*$/'
  exe h.'lnone arbocomm'

  exe m.'lbadf /'.keyw.'\s*-\+\s*\w*s*'.sep.'.*$/'
  exe h.'lbadf Error'

" }}}
" cuts {{{3

" lexis {

let lexis = []
if exists('g:nvpm.arbo.lexicon')
  let lexis = g:nvpm.arbo.lexicon
endif

" }
" vars  {

let init = []
let cut1 = []
let cut2 = []

" }
" cuts  {

for i in range(len(lexis))
  let init = lexis[i]
  let cut1 = init+cut1
  let cut2 = cut1[1:]

  let s  = join(init,'\|')
  let c1 = join(cut1,'\|')
  let c2 = join(cut2,'\|')

  let syn = r..'arbo'..i
  let hi  = h..'arbo'..i

  let cpre  = '^\s*-\{-1,2}\s*\n*\s*-*'
  let c1pre =  '^\s*-\s*\n*\s*-*'
  let c2pre = '^\s*--\s*\n*\s*-*'
  let cmid  = '\_.\{-}\(-*\s*\n*\)*'
  let cmid  = '\_.\{-}-*'

  let cpatt  = '/'.cpre.'\('.s.'\)\_.*/'
  let c1patt = '/'.c1pre.'\('.s.'\)'.cmid.'\('.c1.'\)/'
  let c2patt = '/'.c2pre.'\('.s.'\)'.cmid.'\('.c2.'\)/'
  let c1patt = '/'.c1pre.'\('.s.'\)'.cmid.'\('.c1.'\)/me=e-50'
  let c2patt = '/'.c2pre.'\('.s.'\)'.cmid.'\('.c2.'\)/me=e-50'
  let c2patt = i ? c2patt : '/jeebajebanotfound/'

  let cpatt = m..i..'cuts '..cpatt
  let cpat1 = m..i..'cut1 '..c1patt
  let cpat2 = m..i..'cut2 '..c2patt

  exe cpatt..ct..'arbolendl,arbolcuts,arbolhead'
  exe cpat1..ct..'arbolendl,arbolcuts,arbolhead'
  exe cpat2..ct..'arbolendl,arbolcuts,arbolhead,arbocut3'

  "exe h..i..'cuts Error'
  "exe h..i..'cut1 arbocomm'
  "exe h..i..'cut2 SpellBad'
  exe h..i..'cuts arbocomm'
  exe h..i..'cut1 arbocomm'
  exe h..i..'cut2 arbocomm'

endfor "}

" }}}

syntax sync minlines=100
endfu|call s:main()|delfunc s:main

" vim: nowrap sw=2 sts=2 ts=8 noet fdm=marker:

