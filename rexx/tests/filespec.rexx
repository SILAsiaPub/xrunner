-- say filespec('path',directory()'x.rexx')
-- not work on mac say SysFileExists('t.rexx')
-- call test 'hello'
say SUBWORD("file.ext",1,1)
file = 'C:\WINDOWS\UTIL\file.ext'
parse var file f '.' .
say f
say word(changestr('.',FILESPEC("n",file),' '),1)
thisfile = "C:\WINDOWS\UTIL\SYSTEM.INI"
-- ext = FILESPEC('e',thisfile)
say changestr(ext,FILESPEC("name",thisfile),'')
exit

test:
say arg() arg(1)
return 0