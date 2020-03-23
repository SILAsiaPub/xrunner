checkdir:
  parse ARG dir
  call info 4 'call checkdir' dir
  if os == "WIN64" then 
    do 
      slash = '\'
      dirpath = filespec("P",dir)
      drive = filespec("D",dir)
      dirtrim = reverse(substr(reverse(dirpath),2))
      dp = drive||dirtrim
      
    end
    else
    do
      slash = '/'
      dirpath = filespec("P",dir)
      dp = reverse(substr(reverse(dirpath),2))
    end 
  if stream(dp,'c','query size') == 0 
    then call info 2 'Folder 'dp' exists!'
    else 
      do 
      mkdir dp
      call info 2 'Created folder' dp
      end
return dp

