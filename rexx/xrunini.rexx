xrunini:
/* Description: process xrun.ini
	Usage: xinisection( sourceini, outxslt, outrexx)*/ 
	parse var sourceini,outfile1,outfile2
	xout = lineout(arg(2),'<?xml version="1.0"?>',1)
	xout = xout + lineout(arg(2),'<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">')
	xout = xout + lineout(arg(2),'<xsl:include href="inc-file2uri.xslt"/>')
	xout = xout + lineout(arg(2),'<xsl:include href="inc-lookup.xslt"/>')
	xout = xout + lineout(arg(2),'<xsl:include href="xrun.xslt"/>')
	xout = xout + lineout(arg(2),'<xsl:variable name="projectpath" select="'projectpath'"/>')
	xout = xout + lineout(arg(2),'<xsl:variable name="sq"><xsl:text>'</xsl:text></xsl:variable>')
	xout = xout + lineout(arg(2),'<xsl:variable name="dq"><xsl:text>"</xsl:text></xsl:variable>')
	rout = lineout(arg(3),'/* auto generated content from xrun.ini from section tools */',1)
	call info 2 'Getting key-values from xrun.ini' 
	found = ''
	say 'xrun.ini has' stream(arg(1)) ' -------------------'
	do while lines(arg(1)) > 0 
		line = linein(arg(1))
		parse var line name'='value	
		/* say line */
		select
			when left(line,1) == '[' then; do; section = strip(translate(line,'  ','[]')); say "found section" section; end
			when left(line,1) == '#' then nop
			when pos('=',line) > 0 and section == 'setup' then xout = xout + writexslt(arg(2),name,value)
			when pos('=',line) > 0 and section == 'tools' then rout = rout + rexxvar(arg(3),name,value)
			otherwise 
				nop	
		end
		-- if rout \== 0 then say arg(3) rout name
		-- if xout \== 0 then say arg(2) xout name
	end
	xout = xout + lineout(arg(2),'</xsl:stylesheet>')
	if xout \== 0 then say 'xrun.ini xslt errors' xout
	if rout \== 0 then say 'xrun.ini var errors' rout
	numb = xout + rout
return numb

