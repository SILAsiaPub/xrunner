rexxvarwithvar:
	newvar2 = arg(2) '=' stringwithvar(arg(3))
	if fb2 == 1 then say newvar2
	rexxvreturn = lineout(arg(1),newvar2)
return rexxvreturn