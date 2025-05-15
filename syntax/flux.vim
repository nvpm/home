" Vim syntax file
" Language: flux
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
else
  let b:current_syntax = "flux"
  syntax clear
endif

" Note: this function exists only to use any names
"	for local variables,instead of using s: vars
"	It's deleted immediately after its 1st call
fu! s:main()

" main {{{3

  let c  = 'syn cluster flux'
  let k  = 'syn keyword flux'
  let r  = 'syn  region flux'
  let m  = 'syn   match flux'
  let h  = 'hi def link flux'
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

  exe m.'cut3 '.cut3|exe h.'cut3 fluxcomm'
  exe m.'cuts '.cuts|exe h.'cuts fluxcomm'

" }}}
" flux {{{3

  let keyw = '\(^\|,\)\s*\w\+\s*'
  exe m.'keyw /'.keyw.'/'.cd.ct.'fluxsepr'|exe h.'keyw Keyword'

  let sep  = '[:=]'
  let name = '/'
  let name.= '\('.keyw.'\)*'
  let name.= '\([-_+a-zA-Z0-9$()\|/]\+\s*\)\+'
  let name.= sep
  let name.= '/'
  let name.= cd
  let name.= ct.'fluxkeyw,fluxsepr,fluxvars'
  exe m.'name '.name|exe h.'name Normal'

  let line = '/^.*$/'
  let line.= ct.'fluxkeyw,fluxsepr,fluxname,fluxvars,fluxcomm,fluxcut3,fluxcuts'
  exe m.'line '.line|exe h.'line Constant'

" }}}
" loop {{{3

  let sep  = '[:=]'
  let keyw = '^\s*loop'
  let loop = '/'.keyw.'\s\+/'
  let endl = '/^\s*endl\s*'.comm.'*$/'
  let endl.= ct.'fluxcomm'
  let cut1 = '/\('.keyw.'\s\+\|'.sep.'\s*\)\=-\+\s*\w\+/'.cd.ct.'fluxlkeyw,fluxsepr'
  let cut2 = '/\('.keyw.'\s\+\|'.sep.'\s*\)\=--\+.*$/'.cd.ct.'fluxlkeyw,fluxsepr'
  let lcut = ' start=/^\s*--*\s*\n*\s*loop/'
  let lcut.= '   end=/^\s*endl.*$/'
  let lcut.= ct.'fluxcut3'

  exe m.'lkeyw '.loop|exe h.'lkeyw Title'
  exe m.'lendl '.endl|exe h.'lendl fluxlkeyw'
  exe m.'lcut1 '.cut1|exe h.'lcut1 fluxcomm'
  exe m.'lcut2 '.cut2|exe h.'lcut2 fluxcomm'
  exe r.'lcuts '.lcut|exe h.'lcuts fluxcomm'

  let name = '/'.keyw.'\s\+\w\+\s*'.sep.'/'
  let name.= cd
  let name.= ct.'fluxlkeyw,fluxsepr'
  exe m.'lname '.name|exe h.'lname fluxvars'

  let head = '/'.keyw.'\s\+.*$/'
  let head.= ct.'fluxlkeyw,fluxsepr,fluxlname,fluxlcut1,fluxlcut2,fluxcomm'
  exe m.'lhead '.head|exe h.'lhead fluxline'

  exe m.'lnone /'.keyw.'\s\+-*\s*\w*s*'.sep.'\=\s*--\_.*endl.*$/'
  exe m.'lnone /^.*'.sep.'\(\s*-\s*\w\+\s*\)*\s*--\_.*endl.*$/'
  exe h.'lnone fluxcomm'

  exe m.'lbadf /'.keyw.'\s*-\+\s*\w*s*'.sep.'.*$/'
  exe h.'lbadf Error'

" }}}
" cuts {{{3

" lexis {

let lexis = []
if exists('g:arbo.flux.lexicon')
  let lexis = g:arbo.flux.lexicon
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

  let syn = r..'flux'..i
  let hi  = h..'flux'..i

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

  exe cpatt..ct..'fluxlendl,fluxlcuts,fluxlhead'
  exe cpat1..ct..'fluxlendl,fluxlcuts,fluxlhead'
  exe cpat2..ct..'fluxlendl,fluxlcuts,fluxlhead,fluxcut3'

  "exe h..i..'cuts Error'
  "exe h..i..'cut1 fluxcomm'
  "exe h..i..'cut2 SpellBad'
  exe h..i..'cuts fluxcomm'
  exe h..i..'cut1 fluxcomm'
  exe h..i..'cut2 fluxcomm'

endfor "}

" }}}

syntax sync minlines=100
endfu|call s:main()|delfunc s:main

" vim: nowrap sw=2 sts=2 ts=8 noet fdm=marker:
