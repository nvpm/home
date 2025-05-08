

  project   meta {
    tab  meta = meta
      file meta.vim
      file conf.vim
      file init.vim
    tab  help = /usr/share/nvim/runtime/doc
      file api  : api.txt
      file chan : channel.txt
      file jobs : job_control.txt
      file libc = /iasj/snip/tuto/libc.txt
      file btin : builtin.txt
  }
  project   devl {
    workspace  arbo {
      tab  code
        file auto : autoload/arbo.vim
        file plug : plugin/arbo.vim
        file init = meta/init.vim
      tab 🯅 seng = seng/arbo
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/arbo.txt
        file  read : readme/arbo.md
        file  vers : version/arbo
    }
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
        file  read : readme/line.md
        file  vers : version/line
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
        file  read : readme/zoom.md
        file  vers : version/zoom

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
        file  read : readme/flux.md
        file  vers : version/flux
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
        file  read : readme/text.md
        file  vers : version/text
    }
  }
