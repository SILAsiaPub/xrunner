infile:
	parse ARG in
	call info 2 'call infile' in
  Select
		when length(in) > 0 then infile = in
		otherwise infile = outfile
	end 
    /* if  pcount < pos
    then infile = outfile 
    else 
    	do
    		if in == placeholder
    			then infile = outfile 
    			else infile = in
    	end */
  if length(stream(infile,'C','query size')) > 0 
    then nop
    else call fatal "Missing input file" infile
return infile

