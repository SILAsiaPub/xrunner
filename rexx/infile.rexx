infile:
	parse ARG in,prevout
	call info 2 'call infile' in '|' prevout 
	call info 2 'outfile =' prevout
  	Select
		when in == passthrough then infile = prevout
		when in == stream(in,'C','query exists') then infile = in
		otherwise infile = prevout
	end 
    /* if  pcount < pos
    then infile = outfile 
    else 
    	do
    		if in == placeholder
    			then infile = outfile 
    			else infile = in
    	end */
   if length(stream(infile,'C','query exists')) == 0 then call fatal "Missing input file" infile
return infile

