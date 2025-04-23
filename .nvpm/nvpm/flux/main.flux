

  project  devl = pack {
    workspace 🭹 line {
      tab  code
        file auto : autoload/line.vim
        -file init = meta/init.vim
        file plug : plugin/line.vim
      tab 🯅 seng = seng/line
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/line.txt
        file  read = readme/line.md
        file  vers = version/line
    }
    workspace  nvpm {
      tab  code
        file auto : autoload/nvpm.vim
        file plug : plugin/nvpm.vim
        file init = meta/init.vim
      tab 🯅 seng = seng/nvpm
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/nvpm.txt
        file  read = readme/nvpm.md
        file  vers = version/nvpm
    }
    workspace ɸ flux {
      tab  code
        file auto : autoload/flux.vim
        file synx :   syntax/flux.vim
        file init = meta/init.vim
      tab  test = test/flux
        file case : case.flux
        file expt : case.expt
      tab 🯅 seng = seng/flux
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/flux.txt
        file  read = readme/flux.md
        file  vers = version/flux
    }
    workspace ▣ zoom {
      tab  code
        file auto : autoload/zoom.vim
        file plug : plugin/zoom.vim
        file init = meta/init.vim
      tab 🯅 seng = seng/zoom
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/zoom.txt
        file  read = readme/zoom.md
        file  vers = version/zoom

    }
    --
    workspace Ⲅ text {
      tab  code
        file auto : autoload/text.vim
        file plug : plugin/text.vim
        file init = meta/init.vim
      tab  test = test/text
        file case : case.case
        file expt : case.expt
      tab 🯅 seng = seng/text
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/text.txt
        file  read = readme/text.md
        file  vers = version/text
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
  
# vim: fdm=marker fmr={,} fdl=0 fen
