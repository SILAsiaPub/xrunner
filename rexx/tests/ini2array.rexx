/* ini to array */
trace r

proj. = ''
ini = 'setup/xrun.ini'
call ini2array 
do d = 1 to 10
	say proj.1.d
end
do d = 1 to 10
	if length(proj.2.d) >0 then say proj.2.d
end


ini2array:  procedure expose proj. ini 
sect = 0
section = 'default'
inilines = lines(ini)
t = 0
seq = 0






do while lines(ini) > 0
t = t + 1
line = linein(ini)
if substr(line,1,1) == '[' then 
do
sect = sect+1
proj.sect = strip(translate(line,'','[]'))
sectseq = 0
proj.sect.0 = t
end
else 
do
	if length(strip(line)) > 0 then 
		do
		    sectseq = sectseq + 1
			proj.sect.sectseq = strip(translate(line,'','[]')) 
		end	



end
end
return

