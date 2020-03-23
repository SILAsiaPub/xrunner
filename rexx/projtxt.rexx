projtxt:
/* Description: process xrun.ini
	Usage: projini( sourceini, projxslt, rexxtasks)*/ 
	parse arg sourceini,projxslt,rexxtasks
	call checkdir projxslt
	xout = lineout(projxslt,'<?xml version="1.0"?>',1)
	xout = xout + lineout(projxslt,'<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">',2)
	xout = xout + lineout(projxslt,'<xsl:include href="inc-file2uri.xslt"/>')
	xout = xout + lineout(projxslt,'<xsl:include href="inc-lookup.xslt"/>')
	xout = xout + lineout(projxslt,'<xsl:include href="xrun.xslt"/>')
	xout = xout + lineout(projxslt,'<xsl:variable name="projectpath" select="'sq||projectpath||sq'"/>')
	xout = xout + lineout(projxslt,'<xsl:variable name="sq"><xsl:text>'sq'</xsl:text></xsl:variable>')
	xout = xout + lineout(projxslt,'<xsl:variable name="dq"><xsl:text>'dq'</xsl:text></xsl:variable>')
	call info 2 'Getting key-values from xrun.ini' 
	found = ''
	rout = 0
	xout = 0
	call checkdir rexxtasks
	say 'project.txt has' lines(sourceini) 'lines.' '-------------------'
	do while lines(sourceini) > 0 
		line = linein(sourceini)
		parse var line name'='value
    	parse var value ':'func par.1 par.2 par.3 par.4 par.5 par.6
    	parse VAR name ln'_'lt
    	first = substr(value,1,1)
    	separator = listseparator(lt)
    	pstr = ' '
		/* say line */
		select
			when substr(line,1,1) == '[' then; 
				do; 
					prevsection = projsection
					projsection = strip(translate(line,' :','[]'))
					select
						when projsection == 'variables:' then; 
							do
								rout = lineout(rexxtasks,'/* auto generated content from project.txt from section variables */',1)
							end
						otherwise
							do
								if prevsection \== 'variables:' then rout = rout + lineout(rexxtasks,'return') + lineout(rexxtasks,' ')
								if prevsection == 'variables:' then; do; rout = rout + lineout(rexxtasks,'call' groupin) + lineout(rexxtasks,'exit')  + lineout(rexxtasks,' '); end
								rout = rout + lineout(rexxtasks,projsection)
							end
					end
				end
			when pos('=',line) > 0 then;
				do;
					select 
						when projsection == 'variables:' then; 
							do 
                  				new = rxstringwithvar(value)
                				xout = xout + lineout(projxslt,'<xsl:param name='dq||name||dq ' select='dq||new||dq|| '/>')
                				rout = rout + lineout(rexxtasks,name '=' new) 
                  				if COUNTSTR('_',name) > 0 then
			                    	
				                    select
				                        when lt == 'file-list' then xout = xout + lineout(projxslt,'<xsl:variable name='dq||ln||dq 'select='dq 'f:file2lines($'new')"/>')
				                        when lt == 'equal-list' then xout = xout + lineout(projxslt,'<xsl:variable name='dq||ln||dq 'select='dq 'tokenize($'new ','sq || lt (lt) ||sq ')"/>')
				                        otherwise 
				                          do
				                            xout = xout + lineout(projxslt,'<xsl:variable name='dq ||ln||dq 'select='dq 'tokenize($'name||','sq||separator||sq||')"/>')
				                            if COUNTSTR('=',v) > 0 then xout = xout + lineout(projxslt,'<xsl:variable name='dq||ln||'-key'dq 'select='dq || 'tokenize($'n || ','sq || '=[^'separator']*['separator']?'sq ')"/>')
				                          end
				            		end
							end
						otherwise
							do
				                select
				              		when func == 'inputfile' then; 
				              			do 
				              				rout = rout + lineout(rexxtasks,'outfile =' rxstringwithvar(par.1))
				              				say '83' rout 
				              			end
				              		when name == 't' then 
				              			if first == ':'  then
					              			do
					              				do p = 1 to 6 by 1
					              					if length(par.p) > 0 then pstr = pstr rxstringwithvar(par.p)
					              					call info 5 pstr
					              				end
					              				/* now write result to file */
					              				rout = rout + lineout(rexxtasks,'call' func pstr )
					              				say '93' rout
					              				call info 5 'call' func  pstr									
					              			end
					              		else
					              			do 
						              			call info 5 name value
						              			rout = rout + lineout(rexxtasks, '"'value'"')
						              			say '100' rout
					              			end	
				              		otherwise
				              			nop
				              	end
							end
					end
				end
			otherwise 
				nop	
		end
	end
	rout = rout + lineout(rexxtasks,'return') + lineout(rexxtasks,' ')
	xout = xout + lineout(projxslt,'</xsl:stylesheet>')
	if xout \== 0 then say 'xslt errors' xout
	if rout \== 0 then say 'tasks errors' rout
	out = xout + rout
return out



