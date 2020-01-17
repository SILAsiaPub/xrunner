writexslt:
	parse ARG xout,n,v
	parse VAR n ln '_' lt
	dq = '"'
	sq = "'"
	len = length(v)	
	rtv = 0
  new = rxstringwithvar(v)
	rtv = rtv + lineout(xout,'<xsl:param name='dq||n||dq ' select='dq||new||dq|| '/>')
  if COUNTSTR('_',n) > 0
    then 
      select
        when lt == 'file-list' then rtv = rtv + lineout(xout,'<xsl:variable name='dq||ln||dq 'select='dq 'f:file2lines($'n')"/>')
        when lt == 'equal-list' then rtv = rtv + lineout(xout,'<xsl:variable name='dq||ln||dq 'select='dq 'tokenize($'n ','sq || listseparator(lt) ||sq ')"/>')
        otherwise 
          do
            rtv = rtv + lineout(xout,'<xsl:variable name='dq ||ln||dq 'select='dq 'tokenize($'n || ','sq || listseparator(lt) ||sq||')"/>')
            if COUNTSTR('=',v) > 0 then rtv = rtv + lineout(xout,'<xsl:variable name='dq||ln || '-key'dq 'select='dq || 'tokenize($'n || ','sq || '=[^'listseparator(lt)']*['listseparator(lt)']?'sq ')"/>')
          end
      end
return rtv

