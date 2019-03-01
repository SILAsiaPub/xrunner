dq = '"'
sq = "'"
say "input writexslt('out.xslt','test1_list','a=aaa b=bbb c=ccc')"
say "input writexslt('out.xslt','test2_equal-list','a=b=c')"
say "input writexslt('out.xslt','test3_semicolon-list','a b c;d e f;g h i')"
say "input writexslt('out.xslt','test4_file-list','list.txt')"

say writexslt('out.xslt','test1_list','a=aaa b=bbb c=ccc')
say writexslt('out.xslt','test2_equal-list','a=b=c')
say writexslt('out.xslt','test3_semicolon-list','a b c;d e f;g h i')
say writexslt('out.xslt','test4_file-list','list.txt')
if address() == 'CMD' 
  then start 'out.xslt'
  else gedit 'out.xslt'
exit

