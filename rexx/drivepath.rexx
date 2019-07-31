drivepath:
	parse arg p
	p = TRANSLATE(p,'','"')
	if address() == 'CMD'
		then dp = filespec("D",p) || filespec("P",p)
		else dp = filespec("P",p)
	call info 4 'drivepath =' dp
return dp

