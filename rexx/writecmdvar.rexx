writecmdvar:
	parse ARG outf name value
	rtv = 0
	select
		when length(name) == 0 then nop
		otherwise rtv = rtv + lineout(outf,'set' name'='value)
	end
return rtv

