infile:
  parse ARG in
  if in = passthrough 
    then inf = outfile 
    else inf = in
return inf

