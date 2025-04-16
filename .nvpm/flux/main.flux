    home nvim
    workspace line {
      tab code
        file auto : autoload/line.vim
        -file plug : plugin/line.vim
        file conf = meta/conf.vim
        -file init = meta/init.vim
    }
    workspace nvpm {
      tab code
        file auto : autoload/nvpm.vim
        file plug : plugin/nvpm.vim
        -file init = meta/init.vim
      tab oldnvpm = ../nvpm
        file plug : plugin/nvpm.vim
        file synx : syntax/nvpm.vim
    }
    --
    workspace zoom {

      -file Concepts = seng/zoom/Concepts
      tab code
        file auto : autoload/zoom.vim
        file plug : plugin/zoom.vim

      -tab nvimdocs = /usr/share/nvim/runtime/doc
        file windows.txt
        file options.txt
        --
        file eval.txt
        file api.txt
        file usr_41.txt

    }
    workspace flux {
      tab code
        file auto : autoload/flux.vim
        file init = meta/init.vim
      tab test = test/flux
        file case : case.case
        file expt : case.expt
    }
    workspace text {
      tab code
        file auto : autoload/text.vim
        file plug : plugin/text.vim
      tab test = test/text
        file case : case.case
        file expt : case.expt
    }
