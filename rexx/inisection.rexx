inisection:
/* Description: find the ini section then process is with line handler
	Usage: inisection( sourceini, outfile, section, process)*/ 
	parse ARG in,outf,section,dofunc 
	out = 0
	comment = 'Auto generated temporary file. Created from' FILESPEC("n",in) 'extracting section ['section'] by process' dofunc
	select
		/* when arg(5) == 1 then out = lineout(arg(2),'/''* auto generated temporary file from' FILESPEC("n",arg(1)) 'from section' arg(3)'*''/ ',arg(5))  */
		when 'writexslt' == dofunc then
			do
				out = lineout(outf,'<!--' comment '-->',1)
				out = lineout(outf,'<?xml version="1.0"?>')
				out = out + lineout(outf,'<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">')
			end
		when 'writecmdtasks' == dofunc then nop /* out = out + lineout(outf,'rem' comment ,1) */
		when 'writecmdvar' == dofunc then  nop /* out = out + lineout(outf,'rem' comment ,1) */
		otherwise			
			out = lineout(outf,'/*' comment '*/',1)
	end
	call info 2 'Getting key-values from' FILESPEC("n",in) 'for section:' section
	found = 0
	if lines(in) == 1 
		then say nameext(in) 'found! Getting section [' || section || '] -------------------'
		else say 'XXX Did not detect file "' || in || '" lines returned' lines(in)
	do while lines(in) > 0 
		line = strip(linein(in))
		/* say line */
		select
			when line == section then; do; found = 1; end
			when line == '['section']' then; do; found = 1; end
			when substr(line,1,1) == '[' then; do; found = 0; end
			when pos('=',line) > 0 then; do	
				if found == 1 then
				 	do 
				 		parse var line name '=' value
						select
							when dofunc == 'rexxvar' then; do; out = out + rexxvar(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'rexxvarwithvar' then; do; out = out + rexxvarwithvar(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'rexxtasks' then; do; out = out + rexxtasks(outfile,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writexslt' then; do; out = out + writexslt(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writecmdtasks' then; do; out = out + writecmdtasks(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writecmdvar' then; do; out = out + writecmdvar(outf,name,value); if out \== 0 then say dofunc out name; end
							otherwise; do; say 'Unhandled: write to screen' dofunc name value; end
						end				 	
					end				
				end
			otherwise
				nop
		end
	end
	if 'writexslt' == dofunc then out = out + lineout(outf,'</xsl:stylesheet>')
	else out = out + lineout(outf,' ')
	if out \== 0 then say 'errors' out
	call info 3 STREAM(in,"C",'close')
	call info 3 STREAM(outf,"C",'close')
return out

