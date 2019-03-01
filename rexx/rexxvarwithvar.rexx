rexxvarwithvar:
	newvar2 = arg(2) '=' stringwithvar(arg(3))
	call info 2 newvar2
	rexxvreturn = lineout(arg(1),newvar2)
return rexxvreturn

