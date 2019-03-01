linecopy:
	parse ARG in,out
	lce = 0	
	do while lines(in) > 0
		 lce = lce + lineout(out,linein(in))
	end
	call info 3 stream(in,'C','close')
	call info 3 stream(out,'C','close')
return lce
 
