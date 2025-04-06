
  project NVPM devl : nvim {
    workspace flux {
      tab code
        file auto : autoload/flux.vim
        file init @ meta/init.vim
      tab test @ test/flux
        file case : case.case
        file expt : case.expt
    }
    --
    workspace zoom {

      -file init @ meta/init.vim
      tab code
        file auto : autoload/zoom.vim
        file plug : plugin/zoom.vim

      tab oldzoom @ ../nvpm
        -file help : doc/nvpm.txt
        file auto : autoload/zoom.vim
        file plug : plugin/zoom.vim

      tab nvimdocs @ /usr/share/nvim/runtime/doc
        file windows.txt
        file options.txt
        --
        file eval.txt
        file api.txt
        file usr_41.txt

    }
    workspace line {
      tab code
        file auto : autoload/line.vim
        file plug : plugin/line.vim
      tab oldnvpm @ ../nvpm
        file plug : plugin/nvpm.vim
        file synx : syntax/nvpm.vim
    }
    workspace nvpm {
      tab code
        file auto : autoload/nvpm.vim
        file plug : plugin/nvpm.vim
       -file init @ meta/init.vim
      tab oldnvpm @ ../nvpm
        file plug : plugin/nvpm.vim
        file synx : syntax/nvpm.vim
    }
    workspace text {
      tab code
        file auto : autoload/text.vim
        file plug : plugin/text.vim
      tab test @ test/text
        file case : case.case
        file expt : case.expt
    }
  }
  -loop plugin: zoom flux --nvpm line text {
    project SENG $(plugin): seng/$(plugin)
      tab misc
        file TODO
        file Issues
        --
        file Concepts
        file Features
       
      -tab code
        file Random,file Syntax,file Data,file File
      -tab seng
        file Usecases,file Workflows,-,file read @ seng/read
  endl }
  project NVPM meta @ meta {
    tab meta
      file conf.vim
      -file menu.vim
      file init.vim
    tab root @
      file README.md
    tab code@nvim
      file version
      file README.md
      -file LICENSE
  }
