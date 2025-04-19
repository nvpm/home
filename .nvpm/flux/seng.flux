
  project 🯅 seng = seng{
      workspace root
        file init = meta/init.vim
        file char = char/char.txt
        file gen  = char/char.gen
    loop plugin: nvpm line flux zoom text {
      workspace $(plugin):$(plugin) 
        tab code {
          file Random   
          file Syntax
          file File     
          --
          file Data     
        }
        tab misc {
          file TODO     
          file Issues   
          file Concepts 
          file Features 
        }
        tab seng {
          file Usecases 
          file Workflows
          file read = seng/read
        }
    endl}
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
