projectfile = "D:\All-SIL-Publishing\github-SILAsiaPub\xrunner\branches\rexx\_xrunner_projects\Modify-LIFT\project.txt"
outfile = 'inisection-tasks.txt'
out1 = lineout(outfile,'',1)
trace r
infolevel = 5
say inisection(projectfile,outfile,'variables','rexxvar')
start outfile
exit

