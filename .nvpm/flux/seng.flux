
home seng

  file devl:todo     
  loop plugin: nvpm flux line zoom text {
    workspace $(plugin):$(plugin) 
      tab misc {
        file TODO     
        file Issues   
        file Concepts 
        file Features 
      }
      tab code {
        file Random   
        file Syntax
        file Data     
        file File     
      }
      tab seng {
        file Usecases 
        file Workflows
        file read = seng/read
      }
  endl}
