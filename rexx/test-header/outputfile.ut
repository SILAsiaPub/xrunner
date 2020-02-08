-- trace r
infolevel = 0
if arg(1) == '' 
	then nop
	else infolevel = arg(1)

initialfile = 'source\initialoutput.txt'
outfile = initialfile
newout = 'output\newoutput.txt'
if address() == 'CMD' 
	then 
		do 
			if lines(newout) > 0 then del newout 
		end
	else 
		do 
			if lines(newout) > 0 then rm newout
		end
call outputfile newout
say 'original file' initialfile
say 'renamed file ' outfile

exit

