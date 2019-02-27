drivepath:
	parse arg p
	p = TRANSLATE(p,'','"')
	if address() == 'CMD'
		then dp = filespec("D",p) || filespec("P",p)
		else dp = filespec("P",p)
return dp

