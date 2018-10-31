<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:         .xslt
    # Purpose:
    # Part of:      Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:       Ian McQuay <ian_mcquay@sil.org>
    # Created:      2015- -
    # Copyright:    (c) 2015 SIL International
    # Licence:      <LGPL>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:include href="project.xslt"/>
      <xsl:template match="/*">
            <wordlist>
                  <xsl:apply-templates select="usx"/>
            </wordlist>
      </xsl:template>
      <xsl:template match="verse">
            <xsl:param name="book"/>
            <xsl:param name="bookno"/>
            <xsl:param name="chaptno"/>
            <xsl:variable name="verseno" select="@number"/>
            <xsl:variable name="word" select="tokenize(normalize-space(translate(following::text()[1],'\/.,?!;:*“”‘’()[]—&quot;&lt;&gt;',' ')),' ')"/>
            <xsl:for-each select="$word">
                  <xsl:if test="string-length(.) ge number($min-word-length)">
                        <xsl:element name="w">
                              <xsl:attribute name="word">
                                    <xsl:value-of select="."/>
                              </xsl:attribute>
                              <xsl:attribute name="bk">
                                    <xsl:value-of select="$book"/>
                              </xsl:attribute>
                              <xsl:attribute name="bkno">
                                    <xsl:value-of select="$bookno"/>
                              </xsl:attribute>
                              <xsl:attribute name="c">
                                    <xsl:value-of select="$chaptno"/>
                              </xsl:attribute>
                              <xsl:attribute name="v">
                                    <xsl:value-of select="$verseno"/>
                              </xsl:attribute>
                        </xsl:element>
                  </xsl:if>
            </xsl:for-each>
      </xsl:template>
      <xsl:template match="usx">
            <xsl:apply-templates select="chapterGroup">
                  <xsl:with-param name="book" select="@book"/>
                  <xsl:with-param name="bookno" select="@pos"/>
            </xsl:apply-templates>
      </xsl:template>
      <xsl:template match="chapterGroup">
            <xsl:param name="book"/>
            <xsl:param name="bookno"/>
            <xsl:apply-templates select="verse">
                  <xsl:with-param name="book" select="@book"/>
                  <xsl:with-param name="bookno" select="@bookno"/>
                  <xsl:with-param name="chaptno" select="@number"/>
            </xsl:apply-templates>
      </xsl:template>
</xsl:stylesheet>
