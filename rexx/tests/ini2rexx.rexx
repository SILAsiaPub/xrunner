/* var to rexx */ 
trace r
fb5 = 1
-- ini = 'setup/xrun.ini'
-- ini = 'project/project.txt'
-- setup = 'xsetup'
-- e1 = ini2rexx(ini,setup)
-- e1 = inisection(ini,'setup2.txt','[variables]','rexxvar')
e1 = rexxvar('test-rexxvar','button-or-label_list','button label b')
if e1 > 0 then say 'errors' e1
exit


inisection:
/* find the ini section */ 
	out = lineout(arg(2),'/* auto generated temporary file from 'arg(1) arg(3)' */',1)
	say 'looking for:' arg(3)
	found = 0
	do while lines(arg(1)) > 0 
		line = linein(arg(1))
		-- say line
		select
			when strip(line) == arg(3) then; do; found = 1; end
			when substr(line,1,1) == '[' then; do; found = 0; end
			when pos('=',line) > 0 then; do	
				if found == 1 then
				 	do 
				 		parse var line name '=' value
						select
							when arg(4) == 'rexxvar' then; do; out = out + rexxvar(arg(2),name,value); if out \== 0 then say arg(4) out name; end
							when arg(4) == 'rexxvarwithvar' then; do; out = out + rexxvarwithvar(arg(2),name,value); if out \== 0 then say arg(4) out name; end
							when arg(4) == 'rexxtasks' then; do; out = out + rexxtasks(arg(2),name,value); if out \== 0 then say arg(4) out name; end
							otherwise; do; say 'Unhandled: write to screen' arg(4) name value; end
						end				 	
					end
				end
			otherwise
				nop
		end
	end
	out = out + lineout(arg(2),'     -----')
return out

rexxvar:
	newvar = arg(2) "= '"arg(3)"'"
	if fb5 == 1 then say newvar
  	out = lineout(arg(1), newvar)
  return out
  


inisection2:
/* find the ini section */ 
	out = lineout(arg(2),'/* auto generated temporary file from 'arg(1) arg(3)' */',1)
	say arg(3)
	do while lines(arg(1)) > 0  
		line = linein(arg(1))
		say line
		-- check if section
		-- sectstart = pos('[',line)
		sectfound = TRANSLATE(strip(arg(3)),'','[]')
		if sectfound == arg(3) then; do
			var = linein(arg(1))  /* get next line */
			do while pos('[',line) \== 1 | lines(arg(1)) > 0
				say 'section' line var
				parse var var name '=' value
				if length(name) > 0 then
					select
					when arg(4) == 'rexxvar' then; do; out = out + lineout(arg(2),name '= "'value'"' ); end
					otherwise; do; say 'write to screen' name value; end
					end				
			end
		end
	end
	out = out + lineout(arg(2),'     -----')
return out


/*
do while lines(ini) > 0  
	line_str = linein(ini) 
	if pos("=",line_str) > 0 then
	do
	parse var line_str name '=' value
	out = lineout(setup,name' = "'value'"')
	end
end */
