rexxvarwithvar:
	newvar2 = arg(2) '=' rxstringwithvar(arg(3))
	call info 2 newvar2
	rexxvreturn = lineout(arg(1),newvar2)
return rexxvreturn

