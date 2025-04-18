
home plug/flux/syntax

project Syntax CODE {

  tab flux
    file flux : flux.vim
    file test = test/flux/synx.flux

  tab meta = meta
    file conf.vim

}
project NVIM runtime= /usr/share/nvim/runtime {

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
