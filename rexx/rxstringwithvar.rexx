rxstringwithvar:
-- Description: Modify batch variable for Rexx
-- Usage:  rxstringwithvar(value-string)
-- Type: function
-- Date: 2020-01-15
	len = length(arg(1))
	if pos('%',arg(1)) > 0 then
		do
		new = ""
		do j = 1 to len by 1
			char = substr(arg(1),j,1)
			select
				when j == 1 & char == '%' then nop
				when j == 1 & char \== '%' then new = "'"char
				when j > 1 & j < len & char == '%' then new = new"'"
				when j == len & char == '%' then nop
				when j == len & char \== '%' then new = new||char"'"
				otherwise new = new||char
			end
		end
  	end
  else 
  	do
  		new = sq||arg(1)||sq
  	end
	call info 5 'Out string:' new
return new

