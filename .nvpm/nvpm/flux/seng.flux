
  project 🯅 seng = seng{
      -workspace root
        file init = meta/init.vim
        file char = char/char.txt
        file gen  = char/char.gen
    loop plugin: line nvpm flux zoom text {
      workspace $(plugin):$(plugin) 
        tab misc {
          file TODO     
          file Issues   
          --
          file Concepts 
          file Features 
        }
        tab code {
          file Random   
          file Syntax
          file File     
          --
          file Data     
        }
        tab seng {
          file Usecases 
          file Workflows
          file read = seng/read
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
