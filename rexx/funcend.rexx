funcend:
  parse ARG a b
  if lines(outfile) > 0
    then call info 2 "Output:" outfile
    else call info 2 "Did not create:" outfile
return

