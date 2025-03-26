home nvim/syntax

project Syntax CODE {
  tab flux
    file flux : flux.vim
    file file @ test/case.flux
  tab code @ nvim/autoload
    file conf @ meta/conf.vim
    --
    file nvpm.vim
    file flux.vim
    file line.vim
}
project NVIM runtime@ /usr/share/nvim/runtime {
  file us27 : doc/usr_27.txt
  file us44 : doc/usr_44.txt
  file synx : doc/syntax.txt
  file patt : doc/pattern.txt
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
