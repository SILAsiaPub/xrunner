outputfile:
	parse ARG f s
	if address() == 'CMD' 
	then 
		do 
			if lines(f) > 0 then del f 
		end
	else 
		do 
			if lines(f) > 0 then rm f
		end

	call linecopy outfile,f
	outfile = f
	if address() == 'CMD'
		then 
			do	
				if s == '' 
				then nop 
				else start "" f
			end
		else
		    do 
			    if s 
			    then nop 
			    else start f
			end
	call info 2 'Output:' f
return

