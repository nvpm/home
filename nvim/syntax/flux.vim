" Vim syntax file
" Language: flux
" Maintainer: @iasj

if exists("b:current_syntax")
  finish
else
  let b:current_syntax = "flux"
  syntax clear
  syntax case ignore
endif
fu! s:main()

let c  = 'syn cluster FLUX'
let k  = 'syn keyword FLUX'
let r  = 'syn  region FLUX'
let m  = 'syn   match FLUX'
let h  = 'hi def link FLUX'
let cd = ' contained '
let ct = ' contains='

let comm = '[#{}]'
let sepr = '[:=@,\_/]'
let cut3 = '/\(^\|,\)\s*---\_.*/'
exe m.'comm /'.comm.'.*$/'.cd|exe h.'comm Comment'
exe m.'vars /\$(\w\+)/'   .cd|exe h.'vars Title'
exe m.'sepr /'.sepr.'/'   .cd|exe h.'vars Normal'
exe m.'cut3 '. cut3          |exe h.'cut3 fluxcomm'

let keyw = '\(^\|,\)\s*\w\+\s*'
exe m.'keyw /'.keyw.'/'.cd.ct.'fluxsepr'|exe h.'keyw Keyword'

let sep='[:=@]' 
let name = '/'
let name.= '\('.keyw.'\)*'
let name.= '\([-_+a-zA-Z0-9$()\|/]\+\s*\)\+'
let name.= sep
let name.= '/'
let name.= cd
let name.= ct.'fluxkeyw,fluxsepr,fluxvars'
exe m.'name '.name|exe h.'name Normal'

let line = ' start=/^/'
let line.= '   end=/$/'
let line.= ct.'fluxkeyw,fluxsepr,fluxname,fluxvars,fluxcomm,fluxcut3'
exe r.'line '.line|exe h.'line Operator'


endfu|call s:main()|delfunc s:main

" vim: nowrap sw=2 sts=2 ts=8 noet fdm=marker:
