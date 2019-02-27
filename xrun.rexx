/* rexx implementation of xrun 
   parse the arguments and the system */
parse arg projectfile groupin infolevel pauseatend
parse source system . filename
say time("E")

/* test parameters */
say arg() arg(1) arg(2) arg(3)
if arg() < 1 then signal missingproject
if length(arg(2)) < 1 then groupin = 'a'
/* say linein(projectfile) */


/* setup feedback levels */
select
when infolevel == 1 then; do; fb1 = 1; fb2 = 0; fb3 = 0; fb4 = 0; fb5 = 0; fb6 = 0; end
when infolevel == 2 then; do; fb1 = 1; fb2 = 1; fb3 = 0; fb4 = 0; fb5 = 0; fb6 = 0; end
when infolevel == 3 then; do; fb1 = 1; fb2 = 1; fb3 = 1; fb4 = 0; fb5 = 0; fb6 = 0; end
when infolevel == 4 then; do; fb1 = 1; fb2 = 1; fb3 = 1; fb4 = 1; fb5 = 0; fb6 = 0; end
when infolevel == 5 then; do; fb1 = 1; fb2 = 1; fb3 = 1; fb4 = 1; fb5 = 1; fb6 = 0; end
when infolevel == 6 then; do; trace R; end
otherwise; do; fb1 = 0; fb2 = 0; fb3 = 0; fb4 = 0; fb5 = 0; fb6 = 0; end
end

/* send header to display */
say center(' xrun.rexx ',80) 
say center('==',80,'=') 

/* run main program and setup tasks and xslt */
if fb5 == 1 then say 'fb5 projectfile passed to script'
projectpath = filespec('path',projectfile)

/* setup named system and temp file */
ini = 'setup/xrun.ini'
xsetup = 'xsetup'
psetup = 'psetup'
tasks = 'tasks.rexx'
inixslt = projectpath'/scripts/xrun.xslt'
projectxslt = projectpath'/scripts/project.xslt'


if fb2 == 1 then say 'fb2' arg(1) arg(2) arg(3) arg(4) arg(5)
se1 = lineout(tasks,'',1)
se1 = linecopy('init.rexx',tasks)
se1 = se1 + inisection(ini,tasks,'tools','rexxvar')
se1 = se1 + inisection(projectfile,tasks,'variables','rexxvar')
se1 = se1 + inisection(projectfile,tasks,groupin,'rexxtasks')
se1 = linecopy('func.rexx',tasks)
se1 = se1 + inisection(ini,inixslt,'setup','writexslt')
se1 = se1 + inisection(projectfile,projectxslt,'variables','writexslt')
/* "cat init xsetup psetup tasks func > tasks.rexx"
-- "rexx tasks.rexx" projectpath */
if se1 == 0 then say 'Completed successfully' TIME("R") seconds
exit se1

nameext:
	parse arg p
	if fb5 == 1 then say p 'fb5'
return FILESPEC("n",p)

writexslt:
	len = length(arg(3))
	if lines(arg(1)) > 0 then del arg(1)
	new = ""
	do j = 1 to len by 1
		char = substr(arg(1),j,1)
		select
			when j == 1 & char == '%' then nop
			when j == 1 & char \== '%' then new = "'"char
			when j > 1 & j < len & char == '%' then new = new"'"
			when j == len & char == '%' then nop
			when j == len & char \== '%' then new = new/* concat */char"'"
			otherwise new = new/* concat */char
		end
	end
	rtv = lineout(arg(1) '<xsl:param name="'arg(2)'" select="'new'"/>')
return new

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
	
/* support functions not in batch */
linecopy:
	lce = 0	
	do while lines(arg(1)) > 0
		 lce = lce + lineout(arg(2),linein(arg(1)))
	end
return lce

rexxvar:
	/* newvar = arg(2) '= "'arg(3)'"' */
	newvar = arg(2) '=' stringwithvar(arg(3))
	if fb2 == 1 then say newvar
  	writereturn = lineout(arg(1), newvar)
return writereturn
  
stringwithvar:
	len = length(arg(1))
	new = ""
	do j = 1 to len by 1
		char = substr(arg(1),j,1)
		select
			when j == 1 & char == '%' then nop
			when j == 1 & char \== '%' then new = "'"char
			when j > 1 & j < len & char == '%' then new = new"'"
			when j == len & char == '%' then nop
			when j == len & char \== '%' then new = new/* concat */char"'"
			otherwise new = new/* concat */char
		end
	end
	if fb5 == 1 then say  'fb5' 'Out string:' new
return new

rexxvarwithvar:
	newvar2 = arg(2) '=' stringwithvar(arg(3))
	if fb2 == 1 then say newvar2
	rexxvreturn = lineout(arg(1),newvar2)
return rexxvreturn

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

missingproject:
	say 'A valid project file must be provided. It is a required parameter.'
	say 'Usage: xrun C:\path\project.txt [group [infolevel [pauseatend]]]'
	say 'This script will exit.'
return


badwrite:
	say 'A write produced a non zero value'
return










