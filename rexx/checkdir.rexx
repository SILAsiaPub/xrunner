checkdir:
	parse ARG dir
	call info 4 'call checkdir' dir
	drive = filespec("D",dir)
	dirpath = strip(filespec("P",dir),'t',slash)
	dp = drive || dirpath
	/* call info 3 'just dp =' dp
	newdir = directory(dp) Linux type subdirectory
	call info 4 'newdir =' newdir 'Drive path =' dp */
	if stream(dp,'c','query size')  == 0 
		then cdr = 'Directory exists:' dp
		else 
		do
			makedir dp
			cdr = 'Directory created:' dp
		end
return cdr

