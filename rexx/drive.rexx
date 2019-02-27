drive:
	parse arg p
	if address() == "bash" then
	  rv = ""
	else
	  rv = filespec("D",p)
return rv
