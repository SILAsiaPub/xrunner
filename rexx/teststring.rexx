teststring:
  parse arg input output expected
  say ""
  say 'input   ' input
  say 'output  ' output
  say 'expected' expected
  if output == expected then 
    say '         PASS'
  else 
    say center(' FAIL ',80,'>')
return

