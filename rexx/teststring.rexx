teststring:
  parse arg input,output,expected,message
  say "         ----------" message
  say 'input   ' input
  say 'output  ' output
  say 'expected' expected
  if output == expected then 
    do
    say '         PASS'
    tf = tf + 0
    end
  else 
    do 
    say center(center(' FAIL ',24,'>'),80,' ')
    tf = tf + 1
    end
return tf

