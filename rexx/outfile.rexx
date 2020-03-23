outfile:
	parse ARG clo,default,nocheck
	call info 3 clo '|' default '|' nocheck
	Select
		when clo == passthrough then outfile = default
		when pos('\',clo) > 0 then outfile = clo
		when pos('/',clo) > 0 then outfile = clo
		otherwise outfile = default
	end 
	if length(nocheck) > 0
		then nop
		else 
    do 
    newdir = checkdir(outfile)
    call info 3 newdir
    end
	if stream(outfile,'C','query exists') == outfile /* check existence of out file and rename if needed */
		then move outfile outfile".prev"  
return outfile

    