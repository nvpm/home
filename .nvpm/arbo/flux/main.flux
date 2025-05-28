

  project   devl {
    workspace ɸ flux {
      tab  meta
        file  help : doc/flux.txt
        file  vimh = /usr/share/nvim/runtime/doc/helphelp.txt
       -file  nvpm : nvpm.md
       -file  read : README.md
      tab  code
        file auto : autoload/flux.vim
        file synx :   syntax/flux.vim
        file init = meta/init.vim
      --
      tab  test = test/flux
        file case : case.flux
        file expt : case.expt
      -tab 🯅 seng = seng/flux
          file TODO     
          file Issues   
    }
    workspace  arbo {
      tab  meta
        file  help : doc/arbo.txt
        file  vimh = /usr/share/nvim/runtime/doc/helphelp.txt
       -file  nvpm : nvpm.md
       -file  read : README.md
      tab  code
        file auto : autoload/arbo.vim
        file plug : plugin/arbo.vim
        file init = meta/init.vim
        --
      tab 🯅 seng = seng/arbo
          file TODO     
          file Issues   
    }
    --
    workspace 🭹 line {
      tab  meta
        file  help : doc/line.txt
        file  vimh = /usr/share/nvim/runtime/doc/helphelp.txt
       -file  nvpm : nvpm.md
       -file  read : README.md
      tab  code
        file auto : autoload/line.vim
        file plug : plugin/line.vim
        file init = meta/init.vim
        --
      tab 🯅 seng = seng/line
          file TODO     
          file Issues   
    }
    workspace ▣ zoom {
      tab  meta
        file  help : doc/zoom.txt
        file  vimh = /usr/share/nvim/runtime/doc/helphelp.txt
       -file  nvpm : nvpm.md
       -file  read : README.md
      tab  code
        file auto : autoload/zoom.vim
        file plug : plugin/zoom.vim
        file init = meta/init.vim
      --
      tab 🯅 seng = seng/zoom
          file TODO     
          file Issues   
    }
    workspace Ⲅ text {
      tab  meta
        file  help : doc/text.txt
        file  vimh = /usr/share/nvim/runtime/doc/helphelp.txt
       -file  nvpm : nvpm.md
       -file  read : README.md
      tab  code
        file auto : autoload/text.vim
        file plug : plugin/text.vim
        file init = meta/init.vim
      --
      tab  test = test/text
        file case : case.case
        file expt : case.expt
      tab 🯅 seng = seng/text
          file TODO     
          file Issues   
    }
  }
  project   meta {
    tab  meta = meta
      file conf.vim
      file init.vim
      -file meta.vim
    tab  help = /usr/share/nvim/runtime/doc
      file api  : api.txt
      file chan : channel.txt
      file jobs : job_control.txt
      file libc = /iasj/snip/tuto/libc.txt
      file btin : builtin.txt
  }
