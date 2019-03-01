rexxvar:
	/* newvar = arg(2) '= "'arg(3)'"' */
	newvar = arg(2) '=' stringwithvar(arg(3))
	call info 2 newvar
  	writereturn = lineout(arg(1), newvar)
return writereturn

