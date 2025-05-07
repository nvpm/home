
home seng
  project 🯅 seng {
    loop plugin: nvpm line flux zoom text {
      workspace $(plugin):$(plugin) 
        tab misc {
          file todo : TODO     
          file bugs : Issues   
          file conc : Concepts 
          file feat : Features 
        }
        tab code {
          file rand : Random   
          file synx : Syntax
          file file : File     
          file data : Data     
        }
        tab seng {
          file usec : Usecases 
          file flow : Workflows
          file seng = seng/read
        }
    endl}
  }
  project  meta = meta{
    tab  meta
      file conf:conf.vim
      file init:init.vim
      file menu:menu.vim
    tab  help = /usr/share/nvim/runtime/doc
      file intro.txt
      ---
  }
