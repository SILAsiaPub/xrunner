xslt:
  parse ARG a b c d e f g h  
  -- say  a '|' b '|' c '|' d '|' e '|' f '|' g '|' h   
  if fatal \== "true" 
    then 
      do
        call info 4 "call xslt" a '|' b '|' c '|' d '|' e '|' f '|' g '|' h   
        call inccount
        parse VAR a xname "." ext
        /* xname = reverse(substr(reverse(a),6)) */
        script = scripts || slash || a
        altout = projectpath||slash'tmp'slash||group"-"count"-"xname".xml"
        infile = infile(b)
        outfile = strip(outfile(3,arg(),c,altout,nocheck))
        /* Select
          when arg() == 1
          then
          do
            
            outfile = altout
          end
          when arg() == 2
          then
          do
            
            outfile = altout
          end
          otherwise
          do
           
            outfile = c
          end
        end  
        say arg() */
        if lines(script) == 0 then call fatal "Missing XSLT file" script
        say 'infile' infile
        
        say 'outfile' outfile
        if fatal == 'true' 
          then taskskip = taskskip + 1
          else
          do
            c = "-o:" || c
            call info 4 c
            commandline = "java -jar" saxon "-o:"outfile infile script d e f g h
            call info 2 commandline
            commandline
            call funcend 'xslt'
          end
      end
return

