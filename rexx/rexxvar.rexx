rexxvar:
	/* newvar = arg(2) '= "'arg(3)'"' */
	newvar = arg(2) '=' stringwithvar(arg(3))
	if fb2 == 1 then say newvar
  	writereturn = lineout(arg(1), newvar)
return writereturn