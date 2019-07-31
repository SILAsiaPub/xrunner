outfile:
	parse ARG clo,default,nocheck
	say clo '|' default '|' nocheck
	Select
		when clo == passthrough then outfile = default
		when pos(slash,clo) > 0 then outfile = clo
		otherwise outfile = default
	end 
	if length(nocheck) > 0
		then nop
		else call info 3 checkdir(outfile)
	if stream(infile,'C','query exists') == infile /* check existence of out file and rename if needed */
		then move outfile outfile || ".prev"  
return outfile

    