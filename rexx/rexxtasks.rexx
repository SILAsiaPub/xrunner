rexxtasks: 
/* Description: converts xrun task to rexx structure 
   Usage: rexxtasks(outfile,name,value) */
   parse arg outf,name,value
	parse var value ':' func par.1 par.2 par.3 par.4 par.5 par.6
	/* say func par.1 par.2	*/
	pstr = ""
	first = substr(value,1,1)
	select
		when func == 'inputfile' then lineout(outf,'outfile =' stringwithvar(par.1))
		when name == 't' & first == ':'  then
			do
				do p = 1 to 6 by 1
					if length(par.p) > 0 then pstr = pstr stringwithvar(par.p)
					call info 5 pstr
				end
				/* now write result to file */
				rexxtreturn = lineout(outf,'call' func pstr )
				call info 5 'call' func  pstr									
			end
		when name == 't' & first \== ':' then
			do 
			call info 5 name value
			rexxtreturn = lineout(outf, '"'value'"')
			end	
		otherwise
			rexxtreturn = 0	
		end	
return rexxtreturn

