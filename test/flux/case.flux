
project a,file b
---
HOME libm

# a leafless tree dies!
fold,pack,--,file,file

  Folder root
    File main.c
    File Makefile
    entry config # this should be ignored (not in conf)

loop complex matrix -- number binary hexa string file {
  TAB $_:lib
    File $_.c
    File $_.h
endl }
  
Archive meta {
  Folder root@..
    File readme.txt
    --
    File license
    File version

  Folder scripts@../scripts
    File init.sh
    --
    File ~/makefile.mk
    File trash.sh
}
