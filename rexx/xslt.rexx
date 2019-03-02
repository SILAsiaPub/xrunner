xslt:
    if fatal \== "true" 
      then 
        do
          parse ARG a b c d e f g h
          call info 4 "call xslt" a b c d e f g h
          call inccount
          parse VAR a xname "." ext
          /* xname = reverse(substr(reverse(a),6)) */
          a = scripts || "/" || a
          b = infile(b)
          c = outfile(c,group || "-" || count || "-" || xname || ".xml") 
          if lines(a) == 0 then call fatal "Fatal: Missing XSLT file"
          if lines(b) == 0 then call fatal "Fatal: Missing input XML file"
          if fatal \== 'true' 
            then 
              do
                c = "-o:" || c
                call info 4 c
                call info 2 "java -jar" SAXON c b a d e f g h
                --if info3 == "on" then say c
                --if info2 = "on" then say "java -jar" SAXON c b a d e f g h
                "java -jar" SAXON c b a d e f g h
                call funcend 'xslt'
              end
        end
return

