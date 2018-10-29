<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:     	SAB-RAB-contents-menu-builder.xslt
    # Purpose:		Take a Song file in SFM and generate a menu contents xml
    # Part of: 	Vimod Pub - http://github.com/SILAsiaPub/Vimod-Pub
    # Author:    	Ian McQuay <ian_mcquay@sil.org>
    # Created:  	2017-11-22
    # Copyright: 	(c) 2017 SIL International
    # Licence:   	<LGPL>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" name="xml"/>
      <xsl:include href="inc-file2uri.xslt"/>
      <xsl:include href="project.xslt"/>
      <!-- <xsl:variable name="tree" select="."/> -->
      <xsl:variable name="tree">
            <xsl:apply-templates select="//cGroup" mode="flat"/>
      </xsl:variable>
      <xsl:variable name="tree-sort">
            <xsl:apply-templates select="$tree/*" mode="sort">
                  <xsl:sort select="@*[name() = $field[1]]"/>
            </xsl:apply-templates>
      </xsl:variable>
     <!-- <xsl:template match="*[name() = $page-group]" mode="flat">
            <xsl:variable name="page-ref">
                  <xsl:number value="count(preceding::*[name() = $page-group]) + 1" format="001"/>
            </xsl:variable>
            <xsl:apply-templates select="*/*" mode="flat">
                  <xsl:with-param name="page-ref" select="$page-ref"/>
                  <xsl:with-param name="subtitle" select="*[1]/*/replace(text(),'^\d+\. ','')"/>
            </xsl:apply-templates>
      </xsl:template> -->
      <xsl:template match="cGroup" mode="flat">
            <xsl:copy>

                  <xsl:for-each select="$field">
                        <xsl:attribute name="{.}">
                              <xsl:value-of select="*[name() = .][1]"/>
                        </xsl:attribute>
                  </xsl:for-each>

            </xsl:copy>
      </xsl:template>
      <xsl:template match="*" mode="sort">
            <xsl:copy-of select="."/>
      </xsl:template>
      <xsl:template match="text()" mode="flat">
            <xsl:value-of select="replace(.,'^\d+\. ','')"/>
      </xsl:template>
      <xsl:template match="/*">
            <xsl:result-document href="{f:file2uri(concat($projectpath,'\output\partial.xml'))}" format="xml">
                  <xsl:element name="data">
                        <xsl:copy-of select="$tree"/>
                  </xsl:element>
            </xsl:result-document>
            <contents>
                  <feature name="show-titles" value="true"/>
                  <feature name="show-subtitles" value="false"/>
                  <feature name="show-references" value="false"/>
                  <contents-items>
                        <!-- initial menu content -->
                        <xsl:for-each select="$home-menu">
                              <xsl:variable name="menu-pos" select="position()"/>
                              <contents-item id="{$menu-pos}">
                                    <title lang="default">
                                          <xsl:value-of select="."/>
                                    </title>
                                    <subtitle>
                                          <xsl:value-of select="$home-menu-subtitle[number($menu-pos)]"/>
                                    </subtitle>
                                    <link type="screen" target="{$menu-pos}"/>
                              </contents-item>
                        </xsl:for-each>
                        <!-- subpage data content ========================== -->
                        <xsl:for-each select="$field">
                              <!-- <xsl:comment select="'for each field'"/> -->
                              <!-- creates the items info for the menus -->
                              <xsl:variable name="cur-node" select="."/>
                              <xsl:variable name="cur-pos" select="position()"/>
                              <xsl:for-each select="$tree-sort/*[local-name() = $cur-node]">
                                    <xsl:sort select="."/>
                                    <!-- <xsl:comment select="'page group lines for each'"/> -->
                                    <contents-item id="{@seq}">
                                          <title lang="default">
                                                <xsl:value-of select="replace(.,'^\d+\. ','')"/>
                                          </title>
                                          <subtitle>
                                                <xsl:choose>
                                                      <xsl:when test="$cur-pos lt 5">
                                                            <xsl:for-each select="@*[name() ne $cur-node and matches(name(),'^..$')]">
                                                                  <xsl:if test="position() gt 1">
                                                                        <xsl:text> • </xsl:text>
                                                                  </xsl:if>
                                                                  <xsl:value-of select="."/>
                                                            </xsl:for-each>
                                                      </xsl:when>
                                                      <xsl:otherwise>
                                                            <xsl:value-of select="@*[substring(name(),2,2) = substring($cur-node,2,1)]"/>
                                                      </xsl:otherwise>
                                                </xsl:choose>
                                          </subtitle>
                                          <link type="reference" target="{@ref}"/>
                                    </contents-item>
                              </xsl:for-each>
                        </xsl:for-each>
                  </contents-items>
                  <contents-screens>
                        <!-- home page  -->
                        <contents-screen id="1">
                              <title lang="default">
                                    <xsl:value-of select="$home-menu[1]"/>
                              </title>
                              <items>
                                    <xsl:for-each select="$home-menu[position() gt 1]">
                                          <!-- this is working -->
                                          <item id="{position() + 1}"/>
                                    </xsl:for-each>
                              </items>
                        </contents-screen>
                        <!-- Other pages with menu place holders -->
                        <xsl:for-each select="$field">
                              <xsl:variable name="cur-node" select="."/>
                              <xsl:variable name="cur-pos" select="position()"/>
                              <contents-screen id="{position() +1}">
                                    <title lang="default">
                                          <xsl:value-of select="$home-menu[number($cur-pos) + 1]"/>
                                    </title>
                                    <items>
                                          <!-- <xsl:comment select="'inside for each homemenu'"/> -->
                                          <!-- Creates the pointers in the menu pages -->
                                          <xsl:for-each select="$tree-sort/*[local-name() = $cur-node]">
                                                <item id="{@seq}"/>
                                          </xsl:for-each>
                                          <!--  <xsl:apply-templates select="$tree//*[local-name() = $page-group]" mode="order">
                                                <xsl:with-param name="field-seq" select="position()"/>
                                                <xsl:with-param name="cur-node" select="$field[position()]"/>
                                          </xsl:apply-templates> -->
                                    </items>
                              </contents-screen>
                        </xsl:for-each>
                  </contents-screens>
            </contents>
      </xsl:template>
      <xsl:template match="*[name() = $page-group]" mode="items">
            <xsl:param name="field-seq"/>
            <xsl:param name="cur-node"/>
            <xsl:variable name="page-ref" select="@page-ref"/>
            <!-- <xsl:variable name="page-pos" select="count(preceding-sibling::*[name() = $page-group]) +1"/> -->
            <!-- <xsl:comment select="'page group lines'"/> -->
            <xsl:comment select="$cur-node"/>
            <xsl:for-each select="*[name() = $cur-node]">
                  <xsl:sort select="."/>
                  <!-- <xsl:comment select="'page group lines for each'"/> -->
                  <contents-item id="{number($field-seq) * number($jump) + count(preceding::*[local-name() = $cur-node] ) +1}">
                        <title lang="default">
                              <xsl:value-of select="replace(.,'^\d+\. ','')"/>
                        </title>
                        <link type="reference" target="{$page-ref}"/>
                  </contents-item>
            </xsl:for-each>
            <!--    <xsl:apply-templates select="*[name() = $subpage-group]" mode="items">
                  <xsl:with-param name="field-seq" select="$field-seq"/>
                  <xsl:with-param name="cur-node" select="$cur-node"/>
                  <xsl:with-param name="page-pos" select="$page-pos"/>
            </xsl:apply-templates> -->
      </xsl:template>
      <xsl:template match="*[name() = $page-group]" mode="order">
            <xsl:param name="field-seq"/>
            <xsl:param name="cur-node"/>
            <xsl:comment select="$cur-node"/>
            <xsl:variable name="page-pos" select="count(preceding-sibling::*[name() = $page-group]) +1"/>
            <!-- <xsl:comment select="'page group order'"/> -->
            <xsl:apply-templates select="*[name() = $subpage-group]" mode="order">
                  <xsl:with-param name="field-seq" select="$field-seq"/>
                  <xsl:with-param name="cur-node" select="$cur-node"/>
                  <xsl:with-param name="page-pos" select="$page-pos"/>
            </xsl:apply-templates>
      </xsl:template>
      <xsl:template match="*[name() = $subpage-group]" mode="items">
            <xsl:param name="field-seq"/>
            <xsl:param name="cur-node"/>
            <xsl:param name="page-pos"/>
            <!-- <xsl:comment select="'subpage group items'"/> -->
            <xsl:apply-templates select="*[name() = $cur-node]" mode="items">
                  <!-- <xsl:sort select="replace(.,'^\d+\. ','')"/>  -->
                  <xsl:with-param name="field-seq" select="$field-seq"/>
                  <xsl:with-param name="cur-node" select="$cur-node"/>
                  <xsl:with-param name="page-pos" select="$page-pos"/>
            </xsl:apply-templates>
      </xsl:template>
      <xsl:template match="*[name() = $subpage-group]" mode="order">
            <xsl:param name="field-seq"/>
            <xsl:param name="cur-node"/>
            <xsl:param name="page-pos"/>
            <!-- <xsl:comment select="'subpage group order'"/> -->
            <!-- <xsl:variable name="pos" select="count(preceding::*[local-name() = $page-group]) + 1 + number($multiplier) * number($field-seq)"/> -->
            <!-- <xsl:variable name="thisele" select="$field[number($field-seq)]"/> -->
            <xsl:apply-templates select="*[name() = $cur-node]" mode="order">
                  <xsl:sort select="replace(child::*[name() = $cur-node]/text(),'^\d+\. ','')"/>
                  <xsl:with-param name="field-seq" select="$field-seq"/>
                  <xsl:with-param name="cur-node" select="$cur-node"/>
                  <xsl:with-param name="page-pos" select="$page-pos"/>
            </xsl:apply-templates>
      </xsl:template>
      <xsl:template match="*[local-name() = $field]" mode="items">
            <xsl:param name="field-seq"/>
            <xsl:param name="cur-node"/>
            <xsl:param name="page-pos"/>
            <!-- <xsl:variable name="id" select="$target"/> -->
            <xsl:variable name="page-ref">
                  <xsl:number value="$page-pos" format="001"/>
            </xsl:variable>
            <contents-item id="{number($field-seq) * number($jump) + count(preceding::*[local-name() = $cur-node] ) +1}">
                  <title lang="default">
                        <xsl:value-of select="replace(.,'^\d+\. ','')"/>
                  </title>
                  <link type="reference" target="{$page-ref}"/>
            </contents-item>
      </xsl:template>
      <xsl:template match="*[local-name() = $field]" mode="order">
            <xsl:param name="field-seq"/>
            <xsl:param name="cur-node"/>
            <xsl:param name="page-pos"/>
            <xsl:variable name="pos" select="number($field-seq) * number($jump) + count(preceding::*[local-name() = $cur-node]) +1"/>
            <item id="{$pos}"/>
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
