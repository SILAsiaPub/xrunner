/* auto generated tasks.rexx */
/* auto generated temporary file from xrun.ini from section tools */
 
/* auto generated temporary file from project.txt from section variables */
 
/* auto generated temporary file from project.txt from section a */
 
saxon = 'users/ianm/xrunner/tools/saxon/saxon9he.jar'
editor = 'textedit'
foxe = '/Users/ianm/.wine/drive_c/Program Files/foxe/foxe.exe'
xmleditor = '/Users/ianm/.wine/drive_c/Program Files/foxe/foxe.exe'
 
/* auto generated temporary file from project.txt from section variables */
title = 'Modify LIFT file for DAB'
sourcelift = projectpath'\source\lexicon.lift'
outputlift = projectpath'\output\lexicon-mod.lift'
showsemanticentry = 'on'
showsemanticwordtab = 'on'
showsemanticnumbertab = 'off'
showsemanticnumberentry = 'on'
classification = 'category'
beforesemnumb = 'no.'
semanticclassificationsystem = 'semantic-domain-ddp4'
 
/* auto generated temporary file from project.txt from section a */
call inputfile  '"'sourcelift'"'
call xslt  'LIFT-show-semantic-domain-in-DAB.xslt'
call outputfile  '"'outputlift'"'
call start  '"'outputlift'"'
 
/* Procedures from batch */

setinfolevel: procedure expose infolevel arg
	say info
	say arg(3,E)



/* batch functions carried over but true functions not procedures */

nameext:
	parse arg p
	say p
return right(p,endpos(p,'/') - 1)

ext:
	parse arg p
return right(p,endpos(p,'.'))

name:
	parse arg p
	nameext = right(p,endpos(p,'/') - 1)
	extpos = endpos(nameext,'.')
return left(nameext,length(nameext) - extpos)

drivepath:
	parse arg p
	endpos = endpos(p,'/')
return left(p,length(p) - endpos)

drive:
	parse arg p
	if system == "UNIX" then
	  rv = nil
	else
	  rv = left(p,2)
	return rv
	
inisection:
/* find the ini section */ 
	out = lineout(arg(2),'/* auto generated temporary file from 'arg(1) arg(3)' */')
	say arg(3)
	do while lines(arg(1)) > 0  
		line = linein(arg(1))
		-- check if section
		sectstart = pos('[',line)
		if 1 == sectstart then; do
			say 'section' sectstart line
			vstart = pos(arg(3),line)
			say vstart
			if vstart == 2 then; do
				-- out = linein(arg(1))
				do while pos('[',line) \== 1 | lines(arg(1)) > 0
					var = linein(arg(1))
					parse var var name '=' value
					select
					when arg(4) == 'rexxvar' then; do; out = out + lineout(arg(2),name '= "'value'"' ); end
					when arg(4) == 'rexxcomplexvar' then; do; out = out + lineout(arg(2),name '= "'value'"' ); end
					otherwise; do; say 'write to screen' name value; end
					end
				end
			end
		end
	end
	out = out + lineout(arg(2),'     -----')
return out
	
/* support functions not in batch */
endpos:
	parse arg p,f
	rvs = reverse(p)
	j = 1    
	do until (substr(rvs,j,1) = f) 
	   if fb4 == 1 then say substr(rvs,j,1)
	   j = j + 1 
	   -- if j > length(p) then say p; exit
	end
return j

