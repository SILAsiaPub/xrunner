xslt:
  if fatal == "true" then return
  parse ARG a b c d e f g h
  if info2 == "on" then say "call xslt" a b c d e f g h
  call inccount
  xname = reverse(substr(reverse(a),6))
  a = scripts || "/" || a
  b = infile(b)
  c = outfile(c,group || "-" || count || "-" || xname || ".xml") 
  if lines(a) == 0 then do fatal = "true"; say "Fatal: Missing XSLT file"; return; end
  if lines(b) == 0 then do fatal = "true"; say "Fatal: Missing input XML file"; return; end
  c = "-o:" || c
  if info3 == "on" then say c
  if info2 = "on" then say "java -jar" SAXON c b a d e f g h
  "java -jar" SAXON c b a d e f g h
  call funcend
return
