linecopy:
	lce = 0	
	do while lines(arg(1)) > 0
		 lce = lce + lineout(arg(2),linein(arg(1)))
	end
return lce
 
