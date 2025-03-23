" Vim syntax file
" Language: flux
" Maintainer: @iasj

" init definitions {

if exists("b:current_syntax")
  finish
endif

syntax clear

" }
" main definitions {

syn match fluxcomm /[#{}].*$/
syn match fluxkeyw /^\c\s*\w\+/
syn match fluxvars /\$([a-z0-9_~-]\+)/ contained
syn match fluxcut3 /^\s*-\{3,}\_.*/

syn match fluxname /^\c\s*\w\+\s\+\$\=(\=[a-z0-9_~-])\=/ contains=fluxkeyw,fluxvars

syn region fluxinfo start=/[:=@]/ms=e+1 end=/\n/ contains=fluxcomm,fluxvars

hi def link fluxvars WarningMsg
hi def link fluxcomm Comment
hi def link fluxkeyw Keyword
hi def link fluxinfo Include
hi def link fluxname Normal
hi def link fluxcut3 fluxcomm

" }
" loop definitions {

syn match fluxlcut1 contained /\s*-\s*[a-z0-9_./\\:]\+/
syn match fluxlcut2 contained /\s*-\{2,}.*$/
syn match fluxlname contained /\w*\s*[:=@]/
syn match fluxlhead           /^\c\s*loop\s*\w*\s*[:=@].*$/ contains=fluxkeyw,fluxlname,fluxlinfo,fluxlcut1,fluxlcut2,fluxcomm
syn region fluxlcuts start=/^\c\s*-\{1,2}\s*.*\n*\s*loop/ end=/\(endl\|endlo\|endloo\|endloop\).*$/ contains=fluxcut3
b

hi def link fluxlcut1 fluxcomm
hi def link fluxlcut2 fluxcomm
hi def link fluxlkeyw fluxkeyw
hi def link fluxlname fluxvars
hi def link fluxlhead fluxinfo
hi def link fluxlcuts fluxcomm

"}
" foot definitions {

let b:current_syntax = "flux"

" }
