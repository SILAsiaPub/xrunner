checkdir:
	parse ARG dir
	call info 4 'call checkdir' dir
  if os == "WIN64" then set slash = '\' else set slash = '/'
  say 'slash is' slash
  if os == "WIN64" then makedir = 'md' else makedir = 'mkdir'
	if os == "WIN64" then drive = filespec("D",dir) else drive = ''
	dirpath = strip(filespec("P",dir),'t',slash)
	dp = drive || dirpath
	/* call info 3 'just dp =' dp
	newdir = directory(dp) Linux type subdirectory
	call info 4 'newdir =' newdir 'Drive path =' dp */
	if stream(dp,'c','query size')  == 0 
		then call info 2 'Directory exists:' dp
		else 
		do
			call makedir dp
      if stream(dp,'c','query size') == 0 then call info 2 'Directory created:' dp else say call fatal 'Directory was not found'
		end
return 

