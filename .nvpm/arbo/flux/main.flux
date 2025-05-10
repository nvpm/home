

  project   devl {
    workspace ɸ flux {
      tab  code
        file auto : autoload/FLUX.vim
        file synx :   syntax/FLUX.vim
        file init = meta/init.vim
      tab  test = test/flux
        file case : case.flux
        file expt : case.expt
      -tab 🯅 seng = seng/flux
          file TODO     
          file Issues   
      -tab  meta
        file  help : doc/FLUX.txt
    }
    workspace  arbo {
      tab  code
        file auto : autoload/ARBO.vim
        -file conf = meta/conf.vim
        file plug : plugin/ARBO.vim
        file init = meta/init.vim
      tab 🯅 seng = seng/arbo
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/ARBO.txt
    }
    workspace 🭹 line {
      tab  code
        file auto : autoload/LINE.vim
        file plug : plugin/LINE.vim
        file init = meta/init.vim
      tab 🯅 seng = seng/line
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/LINE.txt
    }
    workspace ▣ zoom {
      tab  code
        file auto : autoload/ZOOM.vim
        file plug : plugin/ZOOM.vim
        file init = meta/init.vim
      tab 🯅 seng = seng/zoom
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/ZOOM.txt
    }
    workspace Ⲅ text {
      tab  code
        file auto : autoload/TEXT.vim
        file plug : plugin/TEXT.vim
        file init = meta/init.vim
      tab  test = test/text
        file case : case.case
        file expt : case.expt
      tab 🯅 seng = seng/text
          file TODO     
          file Issues   
      tab  meta
        file  help : doc/TEXT.txt
    }
  }
  project   meta {
    tab  meta = meta
      file conf.vim
      file meta.vim
      file init.vim
    tab  help = /usr/share/nvim/runtime/doc
      file api  : api.txt
      file chan : channel.txt
      file jobs : job_control.txt
      file libc = /iasj/snip/tuto/libc.txt
      file btin : builtin.txt
  }
