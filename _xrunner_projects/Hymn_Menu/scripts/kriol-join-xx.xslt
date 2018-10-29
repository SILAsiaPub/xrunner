<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:   		kriol-join-xx.xslt
    # Purpose:		Join copyright information.
    # Part of:		Vimod Pub - https://github.com/SILAsiaPub/vimod-pub
    # Author:		Ian McQuay <ian_mcquay@sil.org>
    # Created:		2018- -
    # Copyright:   	(c) 2018 SIL International
    # Licence:		<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
      <xsl:include href="inc-copy-anything.xslt"/>
      <xsl:template match="s4">
            <xsl:copy>
                  <xsl:value-of select="."/>
                  <xsl:for-each select="following-sibling::xx">
                        <xsl:text>. </xsl:text>
                        <xsl:value-of select="."/>
                  </xsl:for-each>
                  
            </xsl:copy>
      </xsl:template>
      <xsl:template match="xx">

</xsl:template>
</xsl:stylesheet>
