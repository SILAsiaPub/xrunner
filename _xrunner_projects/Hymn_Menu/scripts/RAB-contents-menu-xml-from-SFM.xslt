<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:     	RAB-make-contents-items.xslt
    # Purpose:		Take a Song file in SFM and generate a menu contents xml
    # Part of:  	Xrunner https://github.com/SILAsiaPub/xrunner
    # Author:   	Ian McQuay <ian_mcquay@sil.org>
    # Created:   	2016-10-31
    # Updated:		2018-05-08
    # Copyright:	(c) 2016 SIL International
    # Licence:  	<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:include href="project.xslt"/>
      <xsl:variable name="tree" select="cGroup"/>
      <xsl:variable name="screen" select="tokenize('1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20',' ')"/>
      <!-- <xsl:variable name="doc" select="/"/> -->
      <xsl:template match="/*">
            <xsl:variable name="doc" select="cGroup"/>
            <contents>
                  <feature name="show-titles" value="true"/>
                  <feature name="show-subtitles" value="false"/>
                  <feature name="show-references" value="false"/>
                  <contents-items>
                        <!-- $home-menu is the menu items starting with the home menu -->
                        <xsl:for-each select="$home-menu">
                              <xsl:call-template name="submenu-item">
                                    <xsl:with-param name="title" select="."/>
                                    <xsl:with-param name="target" select="position()"/>
                              </xsl:call-template>
                        </xsl:for-each>
                        <xsl:for-each select="$field">
                              <xsl:variable name="pos" select="position()"/>
                              <xsl:apply-templates select="$doc/cGroup/*[local-name() = .][1]" mode="contents-items">
                                    <xsl:with-param name="seq" select="$pos"/>
                              </xsl:apply-templates>
                              <!--<xsl:call-template name="bulkitems">
                                    <xsl:with-param name="seq" select="position()"/>
                                    <xsl:with-param name="doc" select="$doc"/>
                              </xsl:call-template> -->
                        </xsl:for-each>
                  </contents-items>
                  <contents-screens>
                        <contents-screen id="1">
                              <title lang="default">
                                    <xsl:value-of select="$home-menu[1]"/>
                              </title>
                              <items>
                                    <xsl:for-each select="$home-menu[position() gt 1]">
                                          <item id="{position() + 1}"/>
                                    </xsl:for-each>
                              </items>
                        </contents-screen>
                        <xsl:for-each select="$field">
                              <xsl:variable name="pos" select="position()"/>
                              <contents-screen id="{number($pos) + 1}">
                                    <title lang="default">
                                          <xsl:value-of select="$home-menu[number($pos) + 1]"/>
                                    </title>
                                    <items>
                                          <xsl:apply-templates select="$doc/cGroup/*[local-name() = .]" mode="screen-item">
                                                <xsl:sort select="replace(replace(*[name() = .][1],'Tunu. ',''),'\((.+)\)','$1')" data-type="{if(. = 'c') then 'number' else 'text'}"/>
                                                <xsl:with-param name="seq" select="$pos"/>
                                          </xsl:apply-templates >
                                    </items>
                              </contents-screen>
                             <!-- <xsl:apply-templates select="$doc/cGroup/*[local-name() = .]" mode="screen-item">
                                    <xsl:with-param name="seq" select="$pos"/>
                              </xsl:apply-templates> -->
                        </xsl:for-each>
                        <!--<xsl:call-template name="listscreen">
                                    <xsl:with-param name="seq" select="position()"/>
                             </xsl:call-template>
								<xsl:call-template name="listscreens"/> -->
                  </contents-screens>
            </contents>
      </xsl:template>
      <xsl:template match="*" mode="contents-items">
            <!-- What is the page-group defining -->
            <xsl:param name="seq"/>
            <xsl:variable name="thisfield" select="$field[number($seq)]"/>
            <xsl:if test="string-length(*[name() = $thisfield][1]) gt 0">
                  <contents-item id="{position() + 200 * number($seq)}">
                        <title lang="default">
                              <xsl:value-of select="replace(translate(*[name() = $thisfield][1],'()',''),'Tunu. ','')"/>
                              <xsl:text> - </xsl:text>
                              <xsl:choose>
                                    <xsl:when test="$thisfield = 'c'">
                                          <xsl:value-of select="s1[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                          <xsl:value-of select="c[1]"/>
                                    </xsl:otherwise>
                              </xsl:choose>
                              <xsl:if test="c = $audio">
                                    <xsl:text> &#x2713;</xsl:text>
                              </xsl:if>
                        </title>
                        <link type="reference" target="Kanta2000.{position()}"/>
                  </contents-item>
            </xsl:if>
      </xsl:template>
      <xsl:template match="*[local-name() = $page-group]" mode="screen-item">
            <xsl:param name="seq"/>
            <xsl:variable name="pos" select="count(preceding::cGroup) + 1 + 200 * number($seq)"/>
            <xsl:variable name="thisele" select="$field[number($seq)]"/>
            <xsl:if test="*[name() = $thisele][1] != ''">
                  <item id="{$pos}"/>
            </xsl:if>
      </xsl:template>
      <xsl:template name="submenu-item">
            <xsl:param name="title"/>
            <xsl:param name="target"/>
            <xsl:variable name="id" select="$target"/>
            <contents-item id="{$id}">
                  <title lang="default">
                        <xsl:value-of select="$title"/>
                  </title>
                  <link type="screen" target="{$target}"/>
            </contents-item>
      </xsl:template>
      <xsl:template name="listscreen">
            <xsl:param name="seq"/>
            <xsl:variable name="thisele" select="$field[number($seq)]"/>
            <contents-screen id="{number($seq) + 1}">
                  <title lang="default">
                        <xsl:value-of select="$home-menu[number($seq) + 1]"/>
                  </title>
                  <items>
                        <xsl:apply-templates select="*[local-name() = $thisele]" mode="order">
                              <xsl:sort select="replace(replace(*[name() = $thisele][1],'Tunu. ',''),'\((.+)\)','$1')" data-type="{if($thisele = 'c') then 'number' else 'text'}"/>
                              <xsl:with-param name="seq" select="$seq"/>
                        </xsl:apply-templates >
                  </items>
            </contents-screen>
      </xsl:template>
</xsl:stylesheet>
