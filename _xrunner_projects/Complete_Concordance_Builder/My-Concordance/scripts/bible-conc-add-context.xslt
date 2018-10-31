<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:   		.xslt
    # Purpose:		.
    # Part of:		Vimod Pub - https://github.com/SILAsiaPub/vimod-pub
    # Author:		Ian McQuay <ian_mcquay@sil.org>
    # Created:		2018- -
    # Copyright:   	(c) 2018 SIL International
    # Licence:		<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:strip-space elements="*"/>
      <xsl:include href="inc-copy-anything.xslt"/>
      <xsl:include href="project.xslt"/>
      <xsl:template match="usx">
            <xsl:choose>
                  <xsl:when test="$incSeq = $true">
                        <xsl:copy>
                              <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                  </xsl:when>
                  <xsl:otherwise>
                        <xsl:apply-templates select="node()"/>
                  </xsl:otherwise>
            </xsl:choose>
      </xsl:template>
      <xsl:template match="w">
            <xsl:copy>
                  <xsl:if test="$incSeq = $true">
                        <xsl:attribute name="seq">
                              <xsl:value-of select="position() div 2"/>
                        </xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="bk">
                        <xsl:value-of select="parent::*/@book"/>
                  </xsl:attribute>
                  <xsl:attribute name="c">
                        <xsl:value-of select="preceding::chapter[1]/@number"/>
                  </xsl:attribute>
                  <xsl:attribute name="v">
                        <xsl:value-of select="preceding::verse[1]/@number"/>
                  </xsl:attribute>
                  <xsl:apply-templates select="@*"/>
            </xsl:copy>
      </xsl:template>
      <xsl:template match="nw|para|chapter|verse">
            <xsl:if test="$incSeq = $true">
                  <xsl:copy>
                        <xsl:attribute name="seq">
                              <xsl:value-of select="position() div 2"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="@*"/>
                  </xsl:copy>
            </xsl:if>
      </xsl:template>
</xsl:stylesheet>
