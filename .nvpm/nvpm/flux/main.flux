

  project  devl = pack {
    workspace 🭹 line {
      tab  code
        file auto : autoload/line.vim
        file plug : plugin/line.vim
        file init = meta/init.vim
      tab 🯅 seng = seng/line
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/line.txt
        file read : README.md
        file vers : version
    }
    workspace  nvpm {
      tab  code
        file auto : autoload/nvpm.vim
        file plug : plugin/nvpm.vim
        file init = meta/init.vim
      tab  meta
        file help : doc/nvpm.txt
        file read : README.md
        file vers : version
    }
    workspace ɸ flux {
      tab  code
        file auto : autoload/flux.vim
        file synx :   syntax/flux.vim
        file init = meta/init.vim
      tab  test = test/flux
        file case : case.flux
        file expt : case.expt
      tab  meta
        file help : doc/flux.txt
        file read : README.md
        file vers : version
    }
    workspace ▣ zoom {
      tab  code
        file auto : autoload/zoom.vim
        file plug : plugin/zoom.vim
        file init = meta/init.vim
      tab  meta
        file help : doc/zoom.txt
        file read : README.md
        file vers : version

    }
    workspace Ⲅ text {
      tab  code
        file auto : autoload/text.vim
        file plug : plugin/text.vim
        file init = meta/init.vim
      tab  test = test/text
        file case : case.case
        file expt : case.expt
      tab  meta
        file help : doc/text.txt
        file read : README.md
        file vers : version
    }
  }
  project  meta = meta {
    tab  meta
      file conf:conf.vim
      file menu:menu.vim
      file init:init.vim
    tab  help = /usr/share/nvim/runtime/doc
      -file help.txt
      -file cmdline.txt
      -file eval:eval.txt
      file jobs:job_control.txt
      -file chan:channel.txt
      file btin:builtin.txt
  }

----------
                     ✅ 
 
# vim: fdm=marker fmr={,} fdl=0 fen
