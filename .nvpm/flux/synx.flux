home nvim/syntax

project Syntax CODE {
  tab nvpm
    file nvpm : nvpm.vim,file flux : flux.vim,file file @ test/case
  tab code @ nvim/autoload
    file nvpm.vim
    file flux.vim
  tab flux
    file flux : flux.vim
    file file @ test/case
}
project NVIM runtime@ /usr/share/nvim/runtime {
  file us27 : doc/usr_27.txt
  file us44 : doc/usr_44.txt
  file synx : doc/syntax.txt
  file patt : doc/pattern.txt
}
