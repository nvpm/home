
  project   devl = plug {
    workspace ▣ zoom : zoom {
      tab  code
        file auto : autoload/zoom.vim
        file plug : plugin/zoom.vim
        -file init = meta/init.vim
      tab  meta
        file help : doc/zoom.txt
        file read : README.md
        file vers : version

    }
    workspace 🭹 line : line {
      tab  code
        file  auto : autoload/line.vim
        file  plug : plugin/line.vim
        -file  init = meta/init.vim
      --
      tab  meta
        file  help : doc/line.txt
        file read : README.md
        file vers : version
    }
    workspace Ⲅ text : text {
      tab  code
        file auto : autoload/text.vim
        file plug : plugin/text.vim
        -file init = meta/init.vim
      tab  test = test/text
        file case : case.case
        file expt : case.expt
      tab  meta
        file help : doc/text.txt
        file read : README.md
        file vers : version
    }
    workspace  nvpm : nvpm {
      tab  code
        file auto : autoload/nvpm.vim
        file plug : plugin/nvpm.vim
        -file init = meta/init.vim
      tab  meta
        file help : doc/nvpm.txt
        file read : README.md
        file vers : version
    }
    workspace ɸ flux : flux {
      tab  code
        file auto : autoload/flux.vim
        file synx :   syntax/flux.vim
        -file init = meta/init.vim
      tab  test = test/flux
        file case : case.flux
        file expt : case.expt
      tab  meta
        file help : doc/nvpm.txt
        file help : doc/flux.txt
        file read : README.md
        file vers : version
    }
  }
  project   meta = meta {
    tab  meta
      file conf.vim
      file init.vim
      file menu.vim
    tab  help = /usr/share/nvim/runtime/doc
      file intro.txt
      ---
  }

                     ✅ 
 
