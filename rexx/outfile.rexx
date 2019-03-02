outfile:
  parse ARG clo , def , nocheck
  if clo = passthrough 
    then outfile = def 
    else outfile = clo
  if lines(outfile) > 0 
  	then "mv" outfile outfile || ".prev"  
return outfile

