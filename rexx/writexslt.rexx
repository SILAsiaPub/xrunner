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
