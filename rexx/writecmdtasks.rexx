writecmdtasks:
	parse ARG outf name value
	rtv = 0
	select
		when name == 't' then rtv = rtv + lineout(outf,'call' value)
		otherwise nop
	end
return rtv

