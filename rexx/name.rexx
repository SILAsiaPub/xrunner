name:
	extname = reverse(FILESPEC('n',arg(1)))
	parse var extname x '.' f
return reverse(f)


