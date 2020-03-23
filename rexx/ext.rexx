ext:
	extname = reverse(FILESPEC('n',arg(1)))
	parse var extname x '.' f
        ext = '.'||reverse(x)
return ext
 
