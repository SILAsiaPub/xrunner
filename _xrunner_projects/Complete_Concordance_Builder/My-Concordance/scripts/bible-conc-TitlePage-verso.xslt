<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:     .xslt
    # Purpose:
    # Part of:      Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:       Ian McQuay <ian_mcquay@sil.org>
    # Created:      2016- -
    # Copyright:    (c) 2015 SIL International
    # Licence:      <LGPL>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="html" version="5.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:include href="project.xslt"/>
      <xsl:template match="/*">
            <html lang="en">
                  <head>
                        <!--  ščřžýŠČŘŽÝ -->
                        <meta name="generator" content="PSPad editor, www.pspad.com"/>
                        <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
                        <title>
                              <xsl:value-of select="$title"/>
                        </title>
                        <link rel="stylesheet" href="{$concfrontmattercss}" type="text/css"/>
                  </head>
                  <body>
                        <div class="titlepage">
                              <div class="title">
                                    <h1>
                                          <xsl:value-of select="$title"/>
                                    </h1>
                                    <h2>
                                          <xsl:value-of select="$subtitle"/>
                                    </h2>
                              </div>
                              <div class="titlemid">
                                    <h6>Compiled by</h6>
                                    <h4>
                                          <xsl:value-of select="$compiler"/>
                                    </h4>
                              </div>
                              <p class="titlepub">
                                    <xsl:value-of select="$publisher"/>
                                    <br/>
                                    <xsl:value-of select="$publication-date"/>
                              </p>
                        </div>
                        <div class="verso">
                              <p class="verso-top">
                                    <xsl:call-template name="lines">
                                          <xsl:with-param name="string" select="$verso-top"/>
                                    </xsl:call-template>
                              </p>
                              <p class="verso-rights">
                                    <xsl:value-of select="$verso-rights"/>
                              </p>
                              <p class="verso-bottom">
                                    <xsl:call-template name="lines">
                                          <xsl:with-param name="string" select="$verso-bottom"/>
                                    </xsl:call-template>
                              </p>
                        </div>
                  </body>
            </html>
      </xsl:template>
      <xsl:template name="lines">
            <xsl:param name="string"/>
            <xsl:variable name="line" select="tokenize($string,'_')"/>
            <xsl:for-each select="$line">
                  <xsl:value-of select="."/>
                  <xsl:if test="position() ne last()">
                        <br/>
                  </xsl:if>
            </xsl:for-each>
      </xsl:template>
</xsl:stylesheet>
