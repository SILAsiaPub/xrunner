badwrite:
	say 'A write produced a non zero value'
return

drive:
	parse arg p
	if address() == "bash" then
	  rv = ""
	else
	  rv = filespec("D",p)
return rv

drivepath:
	parse arg p
	p = TRANSLATE(p,'','"')
	if address() == 'CMD'
		then dp = filespec("D",p) || filespec("P",p)
		else dp = filespec("P",p)
		call info 4 'drivepath =' dp
return dp

ext:
	extname = reverse(FILESPEC('n',arg(1)))
	parse var extname x '.' f
return '.' || reverse(x)
 
funcend:
  parse ARG a b
  if lines(outfile) > 0
    then call info 2 "Output:" outfile
    else call info 2 "Did not create:" outfile
return

inccount:
  count = count + 1
return count

infile:
  parse ARG in
  if in = passthrough 
    then inf = outfile 
    else inf = in
return inf

info:
  parse ARG level message
  if level <= infolevel then say " "
  if level <= infolevel then say message 'i'level
return

inisection:
/* Description: find the ini section then process is with line handler
	Usage: inisection( sourceini, outfile, section, process)*/ 
	parse ARG in,outf,section,dofunc 
	out = 0
	select
		/* when arg(5) == 1 then out = lineout(arg(2),'/''* auto generated temporary file from' FILESPEC("n",arg(1)) 'from section' arg(3)'*''/ ',arg(5))  */
		when 'writexslt' == dofunc then
			do
				out = lineout(outf,'<!-- auto generated temporary file from' FILESPEC("n",in) 'from section' section 'for process' dofunc '-->',1)
				out = lineout(outf,'<?xml version="1.0"?>',1)
				out = out + lineout(outf,'<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">',2)
			end
		when pos('cmd',outf) > 0 then out = out + lineout(outf,'rem auto generated temporary file from' FILESPEC("n",in) 'from section' section 'for process' dofunc )
		otherwise			
			out = lineout(outf,'/* auto generated temporary file from' FILESPEC("n",in) 'from section' section 'for process' dofunc '*/')
	end
	call info 2 'Getting key-values from' FILESPEC("n",in) 'for section:' section
	found = 0
	if lines(in) == 1 
		then say nameext(in) 'found! Getting section [' || section || '] -------------------'
		else say 'XXX Did not detect file "' || in || '" lines returned' lines(in)
	do while lines(in) > 0 
		line = strip(linein(in))
		/* say line */
		select
			when line == section then; do; found = 1; end
			when line == '['section']' then; do; found = 1; end
			when substr(line,1,1) == '[' then; do; found = 0; end
			when pos('=',line) > 0 then; do	
				if found == 1 then
				 	do 
				 		parse var line name '=' value
						select
							when dofunc == 'rexxvar' then; do; out = out + rexxvar(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'rexxvarwithvar' then; do; out = out + rexxvarwithvar(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'rexxtasks' then; do; out = out + rexxtasks(outfile,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writexslt' then; do; out = out + writexslt(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writecmdtasks' then; do; out = out + writecmdtasks(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writecmdvar' then; do; out = out + writecmdvar(outf,name,value); if out \== 0 then say dofunc out name; end
							otherwise; do; say 'Unhandled: write to screen' dofunc name value; end
						end				 	
					end				
				end
			otherwise
				nop
		end
	end
	if 'writexslt' == dofunc then out = out + lineout(outf,'</xsl:stylesheet>')
	else out = out + lineout(outf,' ')
	if out \== 0 then say 'errors' out
	call info 3 STREAM(in,"C",'close')
	call info 3 STREAM(outf,"C",'close')
return out

linecopy:
	parse ARG in,out
	lce = 0	
	do while lines(in) > 0
		 lce = lce + lineout(out,linein(in))
	end
	call info 3 stream(in,'C','close')
	call info 3 stream(out,'C','close')
return lce
 
listseparator:
  parse ARG list
  sep = ''
  select
    when list == 'list' then sep = ' '
    when list == 'semicolon-list' then sep = ';'
    when list == 'equal-list' then sep = '='
    when list == 'tilde-list' then sep = '~'
    when list == 'underscore-list' then sep = '_'
    otherwise nop
  end
return sep

missingproject:
	say 'A valid project file must be provided. It is a required parameter.'
	say 'Usage: xrun C:\path\project.txt [group [infolevel [pauseatend]]]'
	say 'This script will exit.'
return
 
name:
	extname = reverse(FILESPEC('n',arg(1)))
	parse var extname x '.' f
	rv = reverse(f)
	call info 4 'name =' rv
return rv

nameext:
	parse arg p
	call info 5 p 
return FILESPEC("n",p)

outfile:
  parse ARG clo , def , nocheck
  if clo = passthrough 
    then outfile = def 
    else outfile = clo
  if lines(outfile) > 0 then 
      "mv" outfile outfile || ".prev"  
      else nop
  
return outfile

/* placeholder */

rexxtasks: 
/* Description: converts xrun task to rexx structure 
   Usage: rexxtasks(outfile,name,value) */
   parse arg outfile,name,value
	parse var value ':' func par.1 par.2 par.3 par.4 par.5 par.6
	/* say func par.1 par.2	*/
	pstr = ""
	first = substr(value,1,1)
	select
		when name == 't' & first == ':'  then
			do
				do p = 1 to 6 by 1
					if length(par.p) > 0 then pstr = pstr stringwithvar(par.p)
					call info 5 pstr
				end
				/* now write result to file */
				rexxtreturn = lineout(arg(1),'call' func pstr )
				call info 5 'call' func  pstr									
			end
		when name == 't' & first \== ':' then
			do 
			call info 5 name value
			rexxtreturn = lineout(arg(1), '"'value'"')
			end	
		otherwise
			rexxtreturn = 0	
		end	
return rexxtreturn

rexxvar:
	/* newvar = arg(2) '= "'arg(3)'"' */
	newvar = arg(2) '=' stringwithvar(arg(3))
	call info 2 newvar
  	writereturn = lineout(arg(1), newvar)
return writereturn

rexxvarwithvar:
	newvar2 = arg(2) '=' stringwithvar(arg(3))
	call info 2 newvar2
	rexxvreturn = lineout(arg(1),newvar2)
return rexxvreturn

stringwithvar:
	len = length(arg(1))
	new = ""
	do j = 1 to len by 1
		char = substr(arg(1),j,1)
		select
			when j == 1 & char == '%' then nop
			when j == 1 & char \== '%' then new = "'"char
			when j > 1 & j < len & char == '%' then new = new"'"
			when j == len & char == '%' then nop
			when j == len & char \== '%' then new = new/* concat */char"'"
			otherwise new = new/* concat */char
		end
	end
	call info 5 'Out string:' new
return new

writecmdtasks:
	parse ARG outf name value
	rtv = 0
	select
		when name == 't' then rtv = rtv + lineout(outf,'call' value)
		otherwise nop
	end
return rtv
writecmdvar:
	parse ARG outf name value
	rtv = 0
	select
		when name == '' then nop
		otherwise rtv = rtv + lineout(outf,'set' name'='value)
	end
return rtv
writexslt:
	parse ARG xout,n,v
	parse VAR n ln '_' lt
	dq = '"'
	sq = "'"
	len = length(v)
	
	rtv = 0
	do j = 1 to len by 1
		char = substr(v,j,1)
		select
			when j == 1 & char == '%' then nop
			when j == 1 & char \== '%' then new = "'"char
			when j > 1 & j < len & char == '%' then new = new"'"
			when j == len & char == '%' then nop
			when j == len & char \== '%' then new = new/* concat */char"'"
			otherwise new = new/* concat */char
		end
	end
	rtv = rtv + lineout(xout,'<xsl:param name='dq||n||dq ' select='dq||new||dq|| '/>')
  if COUNTSTR('_',n) > 0
    then 
      select
        when lt == 'file-list' then rtv = rtv + lineout(xout,'<xsl:variable name='dq||ln||dq 'select='dq 'f:file2lines('sq || n || sq')"/>')
        when lt == 'equal-list' then rtv = rtv + lineout(xout,'<xsl:variable name='dq||ln||dq 'select='dq 'tokenize($'n ','sq || listseparator(lt) ||sq ')"/>')
        otherwise 
          do
            rtv = rtv + lineout(xout,'<xsl:variable name='dq ||ln||dq 'select='dq 'tokenize($'n || ','sq || listseparator(lt) ||sq||')"/>')
            if COUNTSTR('=',v) > 0 then rtv = rtv + lineout(xout,'<xsl:variable name='dq||ln || '-key'dq 'select='dq || 'tokenize($'n || ','sq || '=[^'listseparator(lt)']*['listseparator(lt)']?'sq ')"/>')
          end
      end
return rtv
xslt:
  if fatal == "true" then return
  parse ARG a b c d e f g h
  call info 4 "call xslt" a b c d e f g h
  call inccount
  parse VAR a xname "." ext
  /* xname = reverse(substr(reverse(a),6)) */
  a = scripts || "/" || a
  b = infile(b)
  c = outfile(c,group || "-" || count || "-" || xname || ".xml") 
  if lines(a) == 0 then do fatal = "true"; say "Fatal: Missing XSLT file"; return; end
  if lines(b) == 0 then do fatal = "true"; say "Fatal: Missing input XML file"; return; end
  c = "-o:" || c
  call info 3 c
  call info 2 "java -jar" SAXON c b a d e f g h
  --if info3 == "on" then say c
  --if info2 = "on" then say "java -jar" SAXON c b a d e f g h
  "java -jar" SAXON c b a d e f g h
  call funcend
return

