-- get path parts
parse source system . filename
pf = '/Users/ianm/xrunner/project.txt'
say pf
say nameext(pf)
say name(pf)
say ext(pf)
say drivepath(pf)
say drive(pf)
say drive2(pf)
exit

endpos:
	parse arg p,f
	rvs = reverse(p)
	j = 0    
	do until (substr(rvs,j,1) == f) 
	   j = j + 1 
	end
return j

nameext:
	parse arg p
return right(p,endpos(p,'/') - 1)

ext:
	parse arg p
return right(p,endpos(p,'.'))

name:
	parse arg p
	nameext = right(p,endpos(p,'/') - 1)
	extpos = endpos(nameext,'.')
return left(nameext,length(nameext) - extpos)

drivepath:
	parse arg p
return left(p,length(p) - endpos(p,'/'))

drive:
	if system == "UNIX" then 
	return ""
	else
	return left(p,2)

drive2:
	parse arg p
	if system == "UNIX" then
	  rv = ''
	else
	  rv = left(p,2)
	return rv
