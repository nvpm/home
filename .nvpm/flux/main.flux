
  project NVPM devl : nvim {
    workspace flux {
      tab code
        file auto : autoload/flux.vim
        file init @ meta/init.vim
      tab test @ test/flux
        file case : case.case
        file expt : case.expt
    }
    workspace nvpm {
      tab code
        file auto : autoload/nvpm.vim
        file plug : plugin/nvpm.vim
        file init @ meta/init.vim
      tab oldnvpm @ ../nvpm
        file plug : plugin/nvpm.vim
        file synx : syntax/nvpm.vim
    }
    --
    workspace line {
      tab code
        file auto : autoload/line.vim
        file plug : plugin/line.vim
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
    workspace zoom {
      tab code
        file auto : autoload/zoom.vim
        file plug : plugin/zoom.vim
      tab oldnvpm @ ../nvpm
        file plug : plugin/nvpm.vim
        file synx : syntax/nvpm.vim
    }
  }
  loop plugin: nvpm flux -- line zoom text {
    project SENG $(plugin): seng/$(plugin)
      tab misc
        file TODO,file Concepts,file Features,file Issues
      tab code
        file Random,file Syntax,file Data,file File
      tab seng
        file Usecases,file Workflows,-,file read @ seng/read
  endl }
  project NVPM meta @ meta {
    tab meta
      file conf.vim
      file menu.vim
     -file init.vim
    tab root @
      file README.md
      file LICENSE
    tab code@nvim
      file version
      file README.md
  }
