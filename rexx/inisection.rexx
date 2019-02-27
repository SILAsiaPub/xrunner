inisection:
/* Description: find the ini section then process is with line handler
	Usage: inisection( sourceini, outfile, section, process)*/ 
	select
		/* when arg(5) == 1 then out = lineout(arg(2),'/* auto generated temporary file from' FILESPEC("n",arg(1)) 'from section' arg(3)' ',arg(5))  */
		when pos('xslt',arg(2)) > 0 then
			do
				out = lineout(arg(2),'<?xml version="1.0"?>',1)
				out = out + lineout(arg(2),'<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">',2)
			end
		otherwise			
			out = lineout(arg(2),'/* auto generated temporary file from' FILESPEC("n",arg(1)) 'from section' arg(3)' */')
	end
	if fb2 == 1 then say 'Getting key-values from' FILESPEC("n",arg(1)) 'for section:' arg(3)
	found = 0
	say FILESPEC("n",arg(1)) 'has' lines(arg(1)) 'lines.' linein(arg(1),1) '-------------------'
	do while lines(arg(1)) > 0 
		line = linein(arg(1))
		/* say line */
		select
			when strip(line) == arg(3) then; do; found = 1; end
			when strip(line) == '['arg(3)']' then; do; found = 1; end
			when substr(line,1,1) == '[' then; do; found = 0; end
			when pos('=',line) > 0 then; do	
				if found == 1 then
				 	do 
				 		parse var line name '=' value
						select
							when arg(4) == 'rexxvar' then; do; out = out + rexxvar(arg(2),name,value); if out \== 0 then say arg(4) out name; end
							when arg(4) == 'rexxvarwithvar' then; do; out = out + rexxvarwithvar(arg(2),name,value); if out \== 0 then say arg(4) out name; end
							when arg(4) == 'rexxtasks' then; do; out = out + rexxtasks(arg(2),name,value); if out \== 0 then say arg(4) out name; end
							when arg(4) == 'writexslt' then; do; out = out + writexslt(arg(2),name,value); if out \== 0 then say arg(4) out name; end
							otherwise; do; say 'Unhandled: write to screen' arg(4) name value; end
						end				 	
					end				
				end
			otherwise
				nop
		end
	end
	if pos('xslt',arg(2)) > 0 then out = out + lineout(arg(2),'</xsl:stylesheet>')
	else out = out + lineout(arg(2),' ')
return out
