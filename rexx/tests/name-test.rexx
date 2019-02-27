say "expect  file file.bak"
say "returns" name('C:\WINDOWS\UTIL\file.ext') name('C:\WINDOWS\UTIL\file.bak.ext')
exit

name:
	extname = reverse(FILESPEC('n',arg(1)))
	parse var extname x '.' f
return reverse(f)