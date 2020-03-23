drivepath:
  parse arg dir
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
	call info 3 'drivepath =' dp
return dp

