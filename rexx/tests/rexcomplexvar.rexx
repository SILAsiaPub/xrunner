trace n
fb5 = 1
e = rexxcomplexvar('test','name','%projectpath%')
e = rexxcomplexvar('test','name','%projectpath%/file.txt')
e = rexxcomplexvar('test','name','%drive%%projectpath%')
e = rexxcomplexvar('test','name','text/%projectpath%')
exit


rexxcomplexvar:
	len = length(arg(3))
	new = ""
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
return out



/* 
		if char == '%' then; do
				if j \== 1 & j \== len then; do
				new = new"'"
				end
			end
		else
			do
				new = new/* concat */char
			end			
 */

