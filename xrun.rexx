/* rexx implementation of xrun 
   parse the arguments and the system */
parse arg projectfile groupin infolevel pauseatend
parse source os . rscript
/* send header to display */
say center(' xrun.rexx ',80) 
say center('' time("E") '',80,'=') 
if infolevel == 6 then trace r
if ADDRESS() == 'CMD' 
	then 
	Do 
		slash = '\'
		delete = 'del'
		move = 'move'
	end
	else
	Do
		slash = '/'
		delete = 'rm'
		move = 'mv'
	end
/* test parameters */
/* call info 2 arg(1) arg(2) arg(3) */
if arg() < 1 then signal missingproject
if length(groupin) < 1 then groupin = 'a'
/* say linein(projectfile) */

/* run main program and setup tasks and xslt */
call info 5 'projectfile passed to script'
projectfile = strip(TRANSLATE(projectfile,'','"'))
call info 5 "projectfile =" projectfile
projectpath = drivepath(projectfile)
call info 5 'projectpath =' projectpath

/* setup named system and temp file */
ini = 'setup/xrun.ini'
xsetup = 'xsetup'
psetup = 'psetup'
tasks = 'tasks.rexx'
inixslt = projectpath'scripts'slash'xrun.xslt'
projectxslt = projectpath'scripts'slash'project.xslt'
projectvar = 'variables'
sq = "'"
dq = '"'

call info 2 projectfile groupin infolevel pauseatend
if os == 'WIN64' then del tasks else rm tasks
se1 = lineout(tasks,'',1)
se1 = se1 + lineout(tasks,'projectpath =' sq||strip(projectpath,'t',slash)||sq)
se1 = se1 + lineout(tasks,'infolevel =' infolevel)
call info 3 stream(tasks,'C','close')
se1 = se1 + linecopy('init.rexx',tasks)
se1 = se1 + inisection(ini,tasks,'tools','rexxvar')
se1 = se1 + inisection(projectfile,tasks,projectvar,'rexxvar')
se1 = se1 + inisection(projectfile,tasks,groupin,'rexxtasks')
se1 = se1 + lineout(tasks,'exit')
se1 = se1 + linecopy('func.rexx',tasks)
if address() == 'CMD' then del inixslt else rm inixslt
se1 = se1 + inisection(ini,inixslt,'setup','writexslt')
if address() == 'CMD' then del projectxslt else rm projectxslt
se1 = se1 + inisection(projectfile,projectxslt,'variables','writexslt')
trace r
rexx tasks.rexx
say center('' time("E") '',80,'-') 
exit se1

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
 
fatal:
	parse ARG message
	fatal = 'true'
	say 'Fatal:' message
returnfuncend:
  parse ARG a b
  if lines(outfile) > 0
    then call info 2 "Output:" outfile
    else call info 2 "Did not create:" outfile
return

inccount:
  count = count + 1
return count

infile:
  parse ARG pos,pcount,in
  call info 2 pos '|' pcount '|' in
  call info 2 'outfile =' outfile
  if  pcount < pos
    then infile = outfile 
    else 
    	do
    		if in == placeholder
    			then infile = outfile 
    			else infile = in
    	end
   if lines(infile) == 0 then call fatal "Missing input XML file" infile
return infile

info:
  parse ARG level message
  if level <= infolevel then say 'i'level
  if level <= infolevel then say message 
return

inisection:
/* Description: find the ini section then process is with line handler
	Usage: inisection( sourceini, outfile, section, process)*/ 
	parse ARG in,outf,section,dofunc 
	out = 0
	comment = 'Auto generated file. Do not edit! Source:' FILESPEC("n",in) ', Section: ['section'] by process' dofunc

	call info 3 STREAM(outf,"C",'open')
	select
		/* when arg(5) == 1 then out = lineout(arg(2),'/''* auto generated temporary file from' FILESPEC("n",arg(1)) 'from section' arg(3)'*''/ ',arg(5))  */
		when 'writexslt' == dofunc then
			do
				out = lineout(outf,'<?xml version="1.0" encoding="utf-8"?>',1)
				out = lineout(outf,'<!--' comment '-->')
				out = out + lineout(outf,'<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">')
			end
		when 'writecmdtasks' == dofunc then  out = out + lineout(outf,'rem' comment ) 
		when 'writecmdvar' == dofunc then   out = out + lineout(outf,'rem' comment ) 
		otherwise			
			out = lineout(outf,'/*' comment '*/')
	end
	/* call info 2 'Getting key-values from' FILESPEC("n",in) 'for section:' section */
	call info 3 STREAM(outf,"C",'close')
	found = 0
	if lines(in) == 1 
		then 
			do 
				call info 2 '== Source:' FILESPEC("n",in) 'Sect: ['section'] Format:' dofunc 'Output:' FILESPEC("n",outf)
				loop 10
				do
					waisttime = COUNTSTR('o',in)
				end
			end
		else say 'XXX Did not detect file "' || in || '" lines returned' lines(in)
	do while lines(in) > 0 
		line = strip(linein(in))
		call info 3 STREAM(outf,"C",'open')
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
							when dofunc == 'rexxtasks' then; do; out = out + rexxtasks(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writexslt' then; do; out = out + writexslt(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writecmdtasks' then; do; out = out + writecmdtasks(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'writecmdvar' then; do; out = out + writecmdvar(outf,name,value); if out \== 0 then say dofunc out name; end
							when dofunc == 'rexxvarwithvar' then; do; out = out + rexxvarwithvar(outf,name,value); if out \== 0 then say dofunc out name; end
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
  parse ARG pos,pcount,clo,def,nocheck
  if clo = passthrough 
    then outfile = def 
    else outfile = clo
  if lines(outfile) > 0 
  	then "mv" outfile outfile || ".prev"  
return outfile

outputfile:
	parse ARG f s
	if address() == 'CMD' 
	then 
		do 
			if lines(f) > 0 then del f 
		end
	else 
		do 
			if lines(f) > 0 then rm f
		end

	call linecopy outfile,f
	outfile = f
	if address() == 'CMD'
		then 
			do	
				if s == '' 
				then nop 
				else start "" f
			end
		else
		    do 
			    if s 
			    then nop 
			    else start f
			end
	call info 2 'Output:' f
return

/* placeholder */

rexxtasks: 
/* Description: converts xrun task to rexx structure 
   Usage: rexxtasks(outfile,name,value) */
   parse arg outf,name,value
	parse var value ':' func par.1 par.2 par.3 par.4 par.5 par.6
	/* say func par.1 par.2	*/
	pstr = ""
	first = substr(value,1,1)
	select
		when func == 'inputfile' then lineout(outf,'outfile =' stringwithvar(par.1))
		when name == 't' & first == ':'  then
			do
				do p = 1 to 6 by 1
					if length(par.p) > 0 then pstr = pstr stringwithvar(par.p)
					call info 5 pstr
				end
				/* now write result to file */
				rexxtreturn = lineout(outf,'call' func pstr )
				call info 5 'call' func  pstr									
			end
		when name == 't' & first \== ':' then
			do 
			call info 5 name value
			rexxtreturn = lineout(outf, '"'value'"')
			end	
		otherwise
			rexxtreturn = 0	
		end	
return rexxtreturn

rexxvar:
	/* newvar = arg(2) '= "'arg(3)'"' */
	newvar = arg(2) '=' stringwithvar(arg(3))
	call info 3 newvar
  	writereturn = lineout(arg(1), newvar)
return writereturn

rexxvarwithvar:
	newvar2 = arg(2) '=' stringwithvar(arg(3))
	call info 2 newvar2
	rexxvreturn = lineout(arg(1),newvar2)
return rexxvreturn

start:
	parse ARG f
	if address() == 'CMD'
		then start f
		else say 'not implimented yet'
return

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
		when length(name) == 0 then nop
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
        infile = infile(2,arg(),b)
        outfile = outfile(3,arg(),c,altout,nocheck)
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
            commandline = "java -jar" SAXON "-o:"outfile infile script d e f g h
            call info 2 commandline
            commandline
            call funcend 'xslt'
          end
      end
return

