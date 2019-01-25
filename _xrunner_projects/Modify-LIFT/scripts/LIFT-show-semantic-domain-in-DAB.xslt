<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:   		LIFT-show-semantic-domain-in-DAB.xslt
    # Purpose:		Reorder gloss entries based on order of langs param.
    # Part of:		Vimod Pub - https://github.com/SILAsiaPub/vimod-pub
    # Author:		Ian McQuay <ian_mcquay@sil.org>
    # Created:		2017-04-08
    # Copyright:   	(c) 2017 SIL International
    # Licence:		<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:strip-space elements="*"/>
      <xsl:include href="inc-copy-anything.xslt"/>
      <xsl:include href="project.xslt"/>
      <!-- <xsl:param name="semantic" select="'on'"/> -->
      <!-- <xsl:param name="classification" select="'classification'"/> -->
      <!-- <xsl:param name="langorder" select="'id en'"/> -->
      <!-- <xsl:param name="beforesemnumb" select="'s'"/> -->
      <xsl:template match="trait[@name = $semanticclassificationsystem]">
            <xsl:variable name="value" select="replace(@value,'^[\d\.]+ ','')"/>
            <xsl:variable name="sdnumb" select="substring-before(@value,' ')"/>
            <xsl:if test="$showsemanticentry = 'on'">
                  <note type="{$classification}">
                        <form lang="sdm">
                              <xsl:element name="text">
                                    <xsl:if test="$showsemanticnumberentry">
                                          <xsl:value-of select="normalize-space(@sdnumb)"/>
                                          <xsl:text> </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of select="@value"/>
                              </xsl:element>
                        </form>
                  </note>
            </xsl:if>
            <xsl:if test="$showsemanticwordtab = $true">
                  <reversal type="sdm">
                        <form lang="sdm">
                              <xsl:element name="text">
                                    <xsl:value-of select="lower-case($value)"/>
                                    <!-- <xsl:value-of select="@value"/> -->
                              </xsl:element>
                        </form>
                  </reversal>
            </xsl:if>
            <xsl:if test="$showsemanticnumbertab = $true">
                  <reversal type="sdn">
                        <form lang="sdn">
                              <xsl:element name="text">
                                    <xsl:if test="$beforesemnumb">
                                          <xsl:value-of select="concat($beforesemnumb,' ')"/>
                                    </xsl:if>
                                    <xsl:value-of select="$sdnumb"/>
                              </xsl:element>
                        </form>
                  </reversal>
            </xsl:if>
            <xsl:copy>
                  <xsl:apply-templates select="@*"/>
            </xsl:copy>
      </xsl:template>
</xsl:stylesheet>
