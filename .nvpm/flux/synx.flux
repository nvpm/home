
home nvim/syntax

project Syntax CODE {

  tab flux
    file flux : flux.vim
    file file @ test/case.flux

  tab meta @ meta
    file conf.vim

  -
  tab code @ nvim/autoload
    file nvpm.vim
    file flux.vim
    file line.vim

}
project NVIM runtime@ /usr/share/nvim/runtime {

  tab doc/synx: doc
    file usr_44.txt , file usr_27.txt
    file syntax.txt , file pattern.txt

  tab synxtax : syntax
    file markdown.vim
    file html.vim
    --
    file c.vim
    file vim.vim

}
--
project NVPM meta @ meta {
  tab meta 
    file conf.vim
    file menu.vim
   -file init.vim
  tab root @
    file README.md
    file LICENSE
  tab code@nvim
    file version
    file README.md
}
