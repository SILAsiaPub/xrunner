t1 = 'C:\programs\xrunner\rexxini.rexx'
t2 = 'C:\programs\xrunner\xxx\rexxini.rexx'
slash = '\'
makedir = 'md'
drive = filespec("D",t1)
dirpath = strip(filespec("P",t1),'t',slash)
say 'drive =' filespec("D",t1)
say	'dirpath =' strip(filespec("P",t1),'t',slash)
say 'directory1 =' drive || dirpath
trace r
say checkdir(t1) checkdir(t2) 

exit

