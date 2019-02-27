-- say filespec('path',directory()'x.rexx')
-- not work on mac say SysFileExists('t.rexx')
-- call test 'hello'
say SUBWORD("file.ext",1,1)
file = 'C:\WINDOWS\UTIL\file.ext'
parse var file f '.' x
say f x
say word(changestr('.',FILESPEC("n",file),' '),1)
thisfile = "C:\WINDOWS\UTIL\SYSTEM.INI"
ext = FILESPEC('e',thisfile)
say changestr(ext,FILESPEC("name",thisfile),'')
say filespec("P",file)
say address()
say drivepath(file)
say drive(file)
exit

test:
say arg() arg(1)
return 0

drivepath:
	parse arg p
	if address() == 'CMD'
		then dp = filespec("D",p) || filespec("P",p)
		else dp = filespec("P",p)
return dp

drive:
	parse arg p
	if address() == "bash" then
	  rv = ""
	else
	  rv = filespec("D",p)
return rv