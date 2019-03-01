name:
	extname = reverse(FILESPEC('n',arg(1)))
	parse var extname x '.' f
	rv = reverse(f)
	call info 4 'name =' rv
return rv

