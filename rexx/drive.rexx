drive:
	parse arg p
  rv = filespec("D",p)
  /* rv = ''
  if os == "WIN64" 
    then rv = filespec("D",p)
    else nop */
return rv

