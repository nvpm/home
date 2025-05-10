
  home seng
  project 🯅  seng {
    loop plugin: arbo --line flux zoom text {
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
  --
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
