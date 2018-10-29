<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:   		kriol-parse-last-s.xslt
    # Purpose:		Parses second \s in each song and creates up to five fields.
    # Part of:		Vimod Pub - https://github.com/SILAsiaPub/vimod-pub
    # Author:		Ian McQuay <ian_mcquay@sil.org>
    # Created:		2018-05-07
    # Copyright:	(c) 2018 SIL International
    # Licence:		<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
      <xsl:include href="inc-copy-anything.xslt"/>
      <xsl:include href="project.xslt"/>
      <xsl:template match="s[1]">
            <xsl:element name="s">
                  <xsl:value-of select="replace(.,'^\d+\. ','')"/>
            </xsl:element>
      </xsl:template>
      <xsl:template match="s[position() = last() and position() ne 1]">
            <xsl:variable name="part" select="tokenize(.,'\. ')"/>
            <xsl:for-each select="$part">
                  <xsl:choose>
                        <xsl:when test="matches(.,'Words from ')">
                              <xsl:element name="s1">
                                    <xsl:value-of select="substring-after(.,'Words from ')"/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'Words: ')">
                              <xsl:element name="s1">
                                    <xsl:value-of select="substring-after(.,'Words: ')"/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'Words by ')">
                              <xsl:element name="s1">
                                    <xsl:value-of select="substring-after(.,'Words by ')"/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'Words and tune: ')">
                              <xsl:element name="s1">
                                    <xsl:value-of select="substring-after(.,'Words and tune: ')"/>
                              </xsl:element>
                              <xsl:element name="s2">
                                    <xsl:value-of select="substring-after(.,'Words and tune: ')"/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'Tune: ')">
                              <xsl:element name="s2">
                                    <xsl:value-of select="substring-after(.,'Tune: ')"/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'Tune from ')">
                              <xsl:element name="s2">
                                    <xsl:value-of select="substring-after(.,'Tune from ')"/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'©')">
                              <xsl:element name="s4">
                                    <xsl:value-of select="."/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'^Copyright ')">
                              <xsl:element name="s4">
                                    <xsl:value-of select="."/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'All rights reserved')">
                              <xsl:element name="s4">
                                    <xsl:value-of select="."/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'Used (with|by) ')">
                              <xsl:element name="s5">
                                    <xsl:value-of select="."/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'^Translated ')">
                              <xsl:element name="s5">
                                    <xsl:value-of select="."/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'By ')">
                              <xsl:element name="s3">
                                    <xsl:value-of select="substring-after(.,'By ')"/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:when test="matches(.,'Written by ')">
                              <xsl:element name="s3">
                                    <xsl:value-of select="substring-after(.,'Written by ')"/>
                              </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                              <xsl:element name="xx">
                                    <xsl:value-of select="."/>
                              </xsl:element>
                        </xsl:otherwise>
                  </xsl:choose>
            </xsl:for-each>
      </xsl:template>
</xsl:stylesheet>
