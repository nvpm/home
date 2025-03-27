home nvim/syntax

project Syntax CODE {
  tab flux
    file flux : flux.vim
    file file @ test/case.flux
  -
  tab code @ nvim/autoload
    file nvpm.vim
    file flux.vim
    file line.vim
  tab meta @ meta
    file conf.vim
}
project NVIM runtime@ /usr/share/nvim/runtime {

  tab doc/synx: doc
    file us44 : usr_44.txt
    file us27 : usr_27.txt
    file synx : syntax.txt
    file patt : pattern.txt

  tab synxtax : syntax
    file markdown.vim
    file html.vim
    --
    file c.vim
    file vim.vim

}
---
project NVPM meta @ meta {
  tab meta 
    file conf.vim
    file menu.vim
   -buff init.vim
  tab root @
    file README.md
    file LICENSE
  tab code@nvim
    file version
    file README.md
}
