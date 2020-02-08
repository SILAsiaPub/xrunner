/* Unit test header for xsltstringwithvar */
trace E
infolevel = 0
sq = "'"

t1 = 'projectpath\folder\out.txt'
t2 = '%projectpath%\folder\out.txt'
t3 = '%projectpath%\%folder%\out.txt'
t4 = '%projectpath%\folder\%out%.txt'
t5 = '%projectpath%\folder\%out%.%ext%'

p1 = 'projectpath\folder\out.txt'
p2 = "concat($projectpath,'\folder\out.txt')"
p3 = "concat($projectpath,'\',$folder,'\out.txt')"
p4 = "concat($projectpath,'\folder\',$out,'.txt')"
p5 = "concat($projectpath,'\folder\',$out,'.',$ext)"

r1 = xsltstringwithvar(t1)
r2 = xsltstringwithvar(t2)
r3 = xsltstringwithvar(t3)
r4 = xsltstringwithvar(t4)
r5 = xsltstringwithvar(t5)

call teststring t1 r1 p1
call teststring t2 r2 p2
call teststring t3 r3 p3
call teststring t4 r4 p4
call teststring t5 r5 p5


exit

