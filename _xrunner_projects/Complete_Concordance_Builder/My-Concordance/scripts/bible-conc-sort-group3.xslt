<?xml version="1.0" encoding="utf-8"?>
<!--#############################################################
    # Name:   		bible-conc-sort-group3.xslt
    # Purpose:		sort and group bible word list, alphaGroup, word, book and chapter.
    # Part of:		https://github.com/SILAsiaPub/xrunner
    # Author:		Ian McQuay <ian_mcquay@sil.org>
    # Created:		2015-09-24
    # Modified:	2018-10-27
    # Copyright:	(c) 2018 SIL International
    # Licence:		<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:include href="project.xslt"/>
      <xsl:include href="inc-copy-anything.xslt"/>
      <!-- <xsl:include href="inc-file2uri.xslt"/> Note: xrunner project.xslt now includes inc-file2uri.xslt -->
      <!-- <xsl:param name="max-word-occurance-count" select="1600"/> Now included in project.xslt -->
      <!-- <xsl:param name="min-word-length" select="3"/> Now included in project.xslt -->
      <xsl:template match="/*">
            <groupedWords>
                  <xsl:for-each-group select="w" group-by="@o">
                        <xsl:sort select="@o"/>
                        <xsl:element name="alphaGroup">
                              <xsl:attribute name="alpha">
                                    <xsl:value-of select="@o"/>
                              </xsl:attribute>
                              <xsl:for-each-group select="current-group()" group-by="lower-case(@s)">
                                    <!-- group on lower case so capitalized words are in same group as nocap words -->
                                    <xsl:sort select="replace(@s,concat('^[',$ignorechar,']'),'')" case-order="upper-first"/>
                                    <xsl:variable name="group-count" select="count(current-group())"/>
                                    <xsl:if test="$group-count le number($max-word-occurance-count) and string-length(current-group()[1]/@s) ge number($min-word-length)">
                                          <xsl:element name="w">
                                                <xsl:attribute name="word">
                                                      <xsl:choose>
                                                            <xsl:when test="current-group()/@word = lower-case(current-group()[1]/@s)">
                                                                  <!-- check if non capitalized word is present in current-group, if so output as lower case group -->
                                                                  <xsl:value-of select="lower-case(current-group()[last()]/@s)"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                  <!-- output capitialised word -->
                                                                  <xsl:value-of select="current-group()[1]/@s"/>
                                                            </xsl:otherwise>
                                                      </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:attribute name="count">
                                                      <xsl:value-of select="$group-count"/>
                                                </xsl:attribute>
                                                <xsl:call-template name="bkGroup">
                                                      <xsl:with-param name="data" select="current-group()"/>
                                                </xsl:call-template>
                                          </xsl:element>
                                    </xsl:if>
                              </xsl:for-each-group>
                        </xsl:element>
                  </xsl:for-each-group>
            </groupedWords>
      </xsl:template>
      <xsl:template name="bkGroup">
            <xsl:param name="data"/>
            <xsl:for-each-group select="$data" group-by="@bk">
                  <xsl:element name="bk">
                        <xsl:attribute name="book">
                              <xsl:value-of select="current-group()[1]/@bk"/>
                        </xsl:attribute>
                        <xsl:for-each-group select="current-group()" group-by="@c">
                              <xsl:element name="chapter">
                                    <xsl:attribute name="number">
                                          <xsl:value-of select="current-group()[1]/@c"/>
                                    </xsl:attribute>
                                    <xsl:for-each select="current-group()">
                                          <xsl:element name="verse">
                                                <xsl:attribute name="number">
                                                      <xsl:value-of select="@v"/>
                                                </xsl:attribute>
                                          </xsl:element>
                                    </xsl:for-each>
                              </xsl:element>
                        </xsl:for-each-group>
                  </xsl:element>
            </xsl:for-each-group>
      </xsl:template>
</xsl:stylesheet>
