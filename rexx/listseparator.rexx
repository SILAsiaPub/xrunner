listseparator:
	parse arg listtype
	select
		when listtype == 'list' then
			separator = ' '
		when listtype == 'file-list' then
			separator = r'\r?\n'
		when listtype == 'equal-list' then
			separator = '='
		when listtype == 'semicolon-list' then
			separator = ';'
		when listtype == 'tilde-list' then
			separator = '~'
		otherwise
			separator = ' '
	end
return separator

