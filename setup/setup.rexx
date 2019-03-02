/* rexx implementation of xrun 
   parse the arguments and the system */
parse arg projectfile groupin infolevel pauseatend
/* send header to display */
say center(' xrun.rexx ',80) 
say center('' time("E") '',80,'=') 
if infolevel == 6 then trace r
slash = '/'
if ADDRESS() == 'CMD' then slash = '\'


/* test parameters */
call info 2 arg(1) arg(2) arg(3)
if arg() < 1 then signal missingproject
if length(arg(2)) < 1 then groupin = 'a'
/* say linein(projectfile) */

/* run main program and setup tasks and xslt */
call info 5 'projectfile passed to script'
projectfile = strip(TRANSLATE(projectfile,'','"'))
call info 5 "projectfile =" projectfile
projectpath = drivepath(projectfile)
call info 5 'projectpath =' projectpath

/* setup named system and temp file */
ini = 'setup/xrun.ini'
xsetup = 'xsetup'
psetup = 'psetup'
tasks = 'tasks.rexx'
inixslt = projectpath'scripts'slash'xrun.xslt'
projectxslt = projectpath'scripts'slash'project.xslt'
projectvar = 'variables'
sq = "'"
dq = '"'

call info 2 'i2' arg(1) arg(2) arg(3) arg(4) arg(5)
se1 = lineout(tasks,'',1)
se1 = linecopy('init.rexx',tasks)
se1 = se1 + inisection(ini,tasks,'tools','rexxvar')
se1 = se1 + inisection(projectfile,tasks,projectvar,'rexxvar')
se1 = se1 + inisection(projectfile,tasks,groupin,'rexxtasks')
se1 = se1 + lineout(projectfile,'exit')
se1 = linecopy('func.rexx',tasks)
se1 = se1 + inisection(ini,inixslt,'setup','writexslt')
se1 = se1 + inisection(projectfile,projectxslt,'variables','writexslt')
rexx tasks.rexx projectpath
say center('' time("E") '',80,'-') 
if se1 == 0 
	then say 'Completed successfully'
	else say 'Unsuccessful' se1 'errors'
exit se1

