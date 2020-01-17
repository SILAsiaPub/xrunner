trace e
infolevel = 0
dq = '"'
sq = "'"
parse source os . .
t1 = 'a=aaa b=bbb c=ccc'
t2 = 'a=b=c'
t3 = 'a b c;d e f;g h i'
t4 = 'list.txt'
resetfile = lineout('output/out.xslt','',1)
/* if os == 'WIN64' 
  then resetfile = lineout('output\out.xslt','',1)
  else rem "output/out.xslt"  */


say "input writexslt('output/out.xslt','test1_list','"t1"')"
say "input writexslt('output/out.xslt','test2_equal-list','"t2"')"
say "input writexslt('output/out.xslt','test3_semicolon-list','"t3"')"
say "input writexslt('output/out.xslt','test4_file-list','"t4"')"

say writexslt('output/out.xslt','test1_list',t1)
say writexslt('output/out.xslt','test2_equal-list',t2)
say writexslt('output/out.xslt','test3_semicolon-list',t3)
say writexslt('output/out.xslt','test4_file-list',t4)
say os
if os == 'WIN64' 
  then start 'output/out.xslt'
  else gedit 'output/out.xslt'
exit

