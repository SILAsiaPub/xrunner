xrunini:
/* Description: process xrun.ini
	Usage: xinisection( sourceini, outxslt, outrexx)
  Depends on: xsltstringwithvar rxstringwithvar info checkdir
  */ 
	parse arg sourceini,outxslt,outrexx
  call checkdir outxslt
  call checkdir outrexx
	xout = lineout(outxslt,'<?xml version="1.0"?>',1)
	xout = xout + lineout(outxslt,'<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">')

	rout = lineout(outrexx,'/* auto generated content from xrun.ini from section tools */',1)
	call info 2 'Getting key-values from xrun.ini' 
	found = ''
	say 'xrun.ini has' lines(sourceini) ' -------------------'
	do while lines(sourceini) > 0 
		line = linein(sourceini)
    call info 4 'Line = 'line
    withequal = pos('=',line)
		parse var line name'='value	
		/* say line */
		select
			/* when left(line,1) == '[' then; do; section = strip(translate(line,'  ','[]')); say "found section" section; end  */
			when left(line,1) == '[' then 
        do 
          section = strip(translate(line,'  ','[]'))
          say "found section" section
        end
			when left(line,1) == '#' then nop
			/* when pos('=',line) > 0 and section == 'setup' then xout = xout + writexslt(outxslt,name,value)   */
			when withequal > 0 then
      do 
          call info 4 "in equal line"
          
          if section == 'setup' then 
            do 
              parse VAR name ln'_'lt
      	dq = '"'
      	sq = "'"
      	len = length(value)	
      	rtv = 0
              new = xsltstringwithvar(value)
            	rtv = rtv + lineout(outxslt,'<xsl:param name='dq||name||dq ' select='dq||new||dq|| '/>')
              if COUNTSTR('_',name) > 0 then
                Do 
            select
                    when lt == 'file-list' then rtv = rtv + lineout(outxslt,'<xsl:variable name='dq||ln||dq 'select='dq 'f:file2lines($'n')"/>')
                    when lt == 'equal-list' then rtv = rtv + lineout(outxslt,'<xsl:variable name='dq||ln||dq 'select='dq 'tokenize($'n ','sq || listseparator(lt) ||sq ')"/>')
              otherwise 
                do
                        rtv = rtv + lineout(outxslt,'<xsl:variable name='dq ||ln||dq 'select='dq 'tokenize($'n || ','sq || listseparator(lt) ||sq||')"/>')
                        if COUNTSTR('=',v) > 0 then rtv = rtv + lineout(outxslt,'<xsl:variable name='dq||ln || '-key'dq 'select='dq || 'tokenize($'n || ','sq || '=[^'listseparator(lt)']*['listseparator(lt)']?'sq ')"/>')
                end
            end
        end
            end
    			if section == 'tools' then 
            do
              rout = rout + lineout(outrexx, name '=' rxstringwithvar(value)) 
              say rout
            end
            
        end
      
			otherwise 
        do
          call info 4 "this is otherwise nop"
				nop	
        end	
		end
		-- if rout \== 0 then say arg(3) rout name
		-- if xout \== 0 then say arg(2) xout name
	end
	xout = xout + lineout(outxslt,'</xsl:stylesheet>')
	if xout \== 0 then say 'xrun.ini xslt errors' xout
	if rout \== 0 then say 'xrun.ini var errors' rout
	numb = xout + rout
return numb

