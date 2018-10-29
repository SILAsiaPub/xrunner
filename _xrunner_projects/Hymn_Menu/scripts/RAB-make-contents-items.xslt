<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:     	RAB-make-contents-items.xslt
    # Purpose:		Take a Song file in SFM and generate a menu contents xml
    # Part of:		Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:  	Ian McQuay <ian_mcquay@sil.org>
    # Created: 	2016-10-31
    # Copyright:	(c) 2016 SIL International
    # Licence:  	<LGPL>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" name="xml"/>
      <xsl:include href="inc-file2uri.xslt"/>
      <xsl:include href="project.xslt"/>
      <xsl:variable name="chapter-count" select="count(//c)"/>
      <xsl:variable name="screen-count" select="count(distinct-values($menu))"/>
      <xsl:template match="/*">
            <contents>
                   <!-- <xsl:comment select="$screen-count"/> -->
                   <!-- <xsl:comment select="$chapt-count"/> -->
                  <title lang="default">
                        <xsl:value-of select="$app-name"/>
                  </title>
                  <feature name="show-titles" value="true"/>
                  <feature name="show-subtitles" value="true"/>
                  <feature name="show-references" value="false"/>
                  <feature name="launch-action" value="contents"/>
                  <contents-items>
                        <xsl:for-each select="$menu">
                              <xsl:call-template name="submenu-item">
                                    <xsl:with-param name="title" select="."/>
                                    <xsl:with-param name="target" select="position()"/>
                              </xsl:call-template>
                        </xsl:for-each>
                        <xsl:call-template name="words-caller">
                              <!-- This construction is used to start a recursive template that can make use of the data in $field -->
                              <xsl:with-param name="seq" select="1"/>
                        </xsl:call-template>
                  </contents-items>
                  <contents-screens>
                        <contents-screen id="1">
                              <title lang="default">
                                    <xsl:value-of select="$menu[1]"/>
                              </title>
                              <items>
                                    <xsl:for-each select="$menu[position() gt 1]">
                                          <item id="{position() + 1}"/>
                                    </xsl:for-each>
                              </items>
                        </contents-screen>
                        <xsl:call-template name="screen-caller">
                              <xsl:with-param name="seq" select="1"/>
                        </xsl:call-template>
                  </contents-screens>
            </contents>
      </xsl:template>
      <xsl:template name="words-caller">
            <xsl:param name="seq"/>
            <xsl:apply-templates select="cGroup" mode="words">
                  <xsl:sort select="replace(*[name() = $field[number($seq)]][1],'^© \d+ ','')" data-type="{if($field[number($seq)] = 'c') then 'number' else 'text'}"/>
                  <xsl:with-param name="element" select="$field[number($seq)]"/>
                  <xsl:with-param name="seq" select="$seq"/>
            </xsl:apply-templates>
            <xsl:if test="$field[number($seq)] ne $field[last()]">
                  <xsl:call-template name="words-caller">
                        <xsl:with-param name="seq" select="$seq + 1"/>
                  </xsl:call-template>
            </xsl:if>
      </xsl:template>
      <xsl:template name="screen-caller">
            <xsl:param name="seq"/>
            <contents-screen id="{number($seq) +1}">
                  <title lang="default">
                        <xsl:value-of select="$menu[number($seq) +1]"/>
                  </title>
                  <items>
                        <xsl:apply-templates select="cGroup" mode="order">
                              <xsl:sort select="*[name() = $field[number($seq)]][1]" data-type="{if($field[number($seq)] = 'c') then 'number' else 'text'}"/>
                              <xsl:with-param name="element" select="$field[number($seq)]"/>
                              <xsl:with-param name="seq" select="$seq"/>
                        </xsl:apply-templates>
                  </items>
            </contents-screen>
            <xsl:if test="$field[number($seq)] ne $field[last()]">
                  <xsl:call-template name="screen-caller">
                        <xsl:with-param name="seq" select="$seq + 1"/>
                  </xsl:call-template>
            </xsl:if>
      </xsl:template>
      <xsl:template match="cGroup" mode="words">
            <xsl:param name="element"/>
            <xsl:param name="seq"/>
            <xsl:if test="string-length(*[name() = $element][1]) gt 0">
                  <contents-item id="{number(c) + number($screen-count) + number($chapter-count) * (number($seq) - 1)}">
                        <title lang="default">
                              <xsl:value-of select="*[name() = $element][1]"/>
                        </title>
                        <subtitle lang="default">
                              <xsl:value-of select="*[name() = $field-subtitle[number($seq)]][1]"/>
                        </subtitle>
                        <link type="reference" target="{$collection}.{c}"/>
                  </contents-item>
            </xsl:if>
      </xsl:template>
      <xsl:template match="cGroup" mode="order">
            <xsl:param name="seq"/>
            <xsl:param name="element"/>
            <xsl:variable name="pos" select="number(c) + number($screen-count) + number($chapter-count) * (number($seq) - 1)"/>
            <xsl:if test="string-length(*[name() = $element][1]) gt 0">
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
</xsl:stylesheet>
<!--                               <xsl:text> - </xsl:text>
                              <xsl:choose>
                                    <xsl:when test="$song/. = 'c'">
                                          <xsl:value-of select="$song/s1[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                          <xsl:value-of select="$song/c"/>
                                    </xsl:otherwise>
                              </xsl:choose> -->
