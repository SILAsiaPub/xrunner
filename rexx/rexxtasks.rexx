rexxtasks: 
/* Description: converts xrun task to rexx structure 
   Usage: rexxtasks(outfile,name,value) */
   parse arg outfile,name,value
	parse var value ':' func par.1 par.2 par.3 par.4 par.5 par.6
	/* say func par.1 par.2	*/
	pstr = ""
	first = substr(value,1,1)
	select
		when name == 't' & first == ':'  then
			do
				do p = 1 to 6 by 1
					if length(par.p) > 0 then pstr = pstr stringwithvar(par.p)
					if fb5 == 1 then say 'fb5' pstr
				end
				/* now write result to file */
				rexxtreturn = lineout(arg(1),'call' func pstr )
				if fb5 == 1 then say  'fb5' 'call' func  pstr									
			end
		when name == 't' & first \== ':' then
			do 
			if fb5 == 1 then say 'fb5' name value
			rexxtreturn = lineout(arg(1), '"'value'"')
			end	
		otherwise
			rexxtreturn = 0	
		end	
return rexxtreturn