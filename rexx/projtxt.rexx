projtxt:
/* Description: process xrun.ini
	Usage: projini( sourceini, projxslt, rexxtasks)*/ 
	parse arg sourceini,projxslt,rexxtasks
	xout = lineout(arg(2),'<?xml version="1.0"?>',1)
	xout = xout + lineout(arg(2),'<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">',2)
	call info 2 'Getting key-values from xrun.ini' 
	found = ''
	say 'project.txt has' lines(arg(1)) 'lines.' '-------------------'
	do while lines(arg(1)) > 0 
		line = linein(arg(1))
		parse var line name'='value	
		/* say line */
		select
			when substr(line,1,1) == '[' then; 
				do; 
					prevsection = psection
					psection = strip(translate(line,' :','[]'))
					select
						when psection == 'variables:' then; 
							do
								rout = rout + lineout(arg(3),'/* auto generated content from project.txt from section variables */')
							end
						otherwise
							do
								if prevsection \== 'variables:' then rout = rout + lineout(arg(3),'return') + lineout(arg(3),' ')
								if prevsection == 'variables:' then; do; rout = rout + lineout(arg(3),'call' groupin) + lineout(arg(3),'exit')  + lineout(arg(3),' '); end
								rout = rout + lineout(arg(3),psection)
							end
					end

				end
			when pos('=',line) > 0 then;
				do;
					select 
						when section == '[variables]' then; 
							do; 
								xout = xout + writexslt(arg(2),name,value); 
								if xout \== 0 then; do; say arg(2) xout name; end;
								rout = rout + rexxvar(arg(3),name,value); 
								if rout \== 0 then; do; say arg(3) rout name; end;
							end	
						otherwise
							do;
								rout = rout + rexxtasks(arg(3),name,value); 
								if rout \== 0 then; do; say arg(3) rout name; end;
							end
					end
				end
			otherwise 
				nop	
		end
	end
	rout = rout + lineout(arg(3),'return') + lineout(arg(3),' ')
	xout = xout + lineout(arg(2),'</xsl:stylesheet>')
	if xout \== 0 then say 'xslt errors' xout
	if rout \== 0 then say 'tasks errors' rout
	out = xout + rout
return out

