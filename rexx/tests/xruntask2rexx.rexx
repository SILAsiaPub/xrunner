Trace n
fb5 = 1
e = lineout('test','',1)
--e = rexxvarwithvar('test','name','%projectpath%')
--e = rexxvarwithvar('test','name','%projectpath%/file.txt')
--e = rexxvarwithvar('test','name','%drive%%projectpath%')
--e = rexxvarwithvar('test','name','text/%projectpath%')
e = rexxtasks('test','t',':xslt LIFT-show-semantic-domain-in-DAB.xslt "%projectpath%\tmp\tile.txt"')
--e = rexxtasks('test','t',':inputfile "%sourcelift%"')
--e = rexxtasks('test','b','do stuff')

exit



xruntask2rexx: procedure
/* Description: converts xrun task to rexx structure 
   Usage: */
	len = length(arg(3))
	new = ""
	if arg(2) == 't' then
		do j = 1 to len by 1
			char = substr(arg(3),j,1)
			select
				when j == 1 & char == '%' then nop
				when j == 1 & char \== '%' then new = "'"char
				when j > 1 & j < len & char == '%' then new = new"'"
				when j == len & char == '%' then nop
				when j == len & char \== '%' then new = new/* concat */char"'"
				otherwise new = new/* concat */char
			end
		end
	if fb5 == 1 then say 'out string' new 'fb5'
	/* now write result to file */

	out = lineout(arg(1),arg(2) '=' new )
return

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
	if fb5 == 1 then say 'Out string:' new 'fb5'
return new

rexxvarwithvar:
	out = lineout(arg(1),arg(2) '=' stringwithvar(arg(3)) )
return out

rexxtasks: 
/* Description: converts xrun task to rexx structure 
   Usage: rexxtasks(outfile,name,value) */
   parse arg outfile,name,value
	parse var value ':' func par.1 par.2 par.3 par.4 par.5 par.6
	say par.1
	say par.2
	pstr = ""
	if arg(2) == 't' then
		do p = 1 to 6 by 1
			pstr = pstr stringwithvar(par.p)
		end
	if fb5 == 1 then say 'out string' new 'fb5'
	/* now write result to file */
	first = substr(value,1,1)
	if first == ':' then; do 
		out = lineout(arg(1),'call' func pstr )
		if fb5 == 1 then say  'fb5' 'call' func  pstr
		end
	else
		out = lineout(arg(1), '"'value'"')
return out