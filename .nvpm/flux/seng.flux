
home seng

  loop plugin: line flux -- nvpm zoom - text {
    workspace $(plugin):$(plugin) 
      tab code {
        file Syntax
        file File     
        --
        file Data     
        file Random   
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
  project NVPM meta = meta {
    tab meta
      file conf.vim
      file menu.vim
    tab docs = /usr/share/nvim/runtime/doc
      file intro.txt
      ---
      file init.vim
    tab code=nvim
      file version
      file README.md
      file LICENSE
  }
