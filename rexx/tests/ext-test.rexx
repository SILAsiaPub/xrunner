say ext('C:\WINDOWS\UTIL\file.ext') ext('C:\WINDOWS\UTIL\file.bak.ext')
exit

ext:
	extname = reverse(FILESPEC('n',arg(1)))
	parse var extname x '.' f
return '.' || reverse(x)


