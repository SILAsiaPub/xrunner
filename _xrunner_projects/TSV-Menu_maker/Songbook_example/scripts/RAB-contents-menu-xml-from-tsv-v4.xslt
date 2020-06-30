<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:		AB-contents-menu-xml-from-tsv-v4.xslt
    # Purpose:	Create a SAB/RAB contents menu from a TSV.
    # Part of:		Xrunner - https://github.com/SILAsiaPub/xrunner
    # Author:		Ian McQuay <ian_mcquay@sil.org>
    # Created:	2019-07-31
    # Copyright:	(c) 2019 SIL International
    # Licence:	<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:include href="project.xslt"/>
    <!-- <xsl:variable name="line" select="f:file2lines($inputfile)"/> -->
    <xsl:template match="/*">
        <contents>
            <!--<title lang="{$titlelanguage}">
                <xsl:value-of select="$title"/>
            </title> -->
            <feature name="show-titles" value="{$show-titles}"/>
            <feature name="show-subtitles" value="{$show-subtitles}"/>
            <feature name="show-references" value="{$show-references}"/>
            <feature name="launch-action" value="{$launch-action}"/>
            <feature name="navigation-type" value="up"/>
            <contents-items>
                <xsl:for-each select="$screen[position() gt 2]">
                    <xsl:variable name="pos" select="position()"/>
                    <xsl:variable name="cell" select="tokenize(.,'\t')"/>
                    <xsl:call-template name="item">
                        <xsl:with-param name="title" select="$cell[2]"/>
                        <xsl:with-param name="subtitle" select="$cell[3]"/>
                        <xsl:with-param name="picture" select="$cell[5]"/>
                        <xsl:with-param name="item-numb" select="$pos"/>
                        <xsl:with-param name="link-type" select="'screen'"/>
                        <xsl:with-param name="link-target" select="$cell[1]"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="$item[position() gt 1]">
                    <xsl:variable name="pos" select="position() + 200"/>
                    <xsl:variable name="cell" select="tokenize(.,'\t')"/>
                    <xsl:call-template name="item">
                        <xsl:with-param name="title" select="$cell[1]"/>
                        <xsl:with-param name="subtitle" select="$cell[2]"/>
                        <xsl:with-param name="picture" select="$cell[9]"/>
                        <xsl:with-param name="item-numb" select="$pos"/>
                        <xsl:with-param name="link-type" select="'reference'"/>
                        <xsl:with-param name="link-target" select="concat($cell[6], if (string-length($cell[7]) gt 0) then concat('.',$cell[7],if (string-length($cell[8]) gt 0) then concat('.',$cell[8]) else '')  else '' ) "/>
                        <xsl:with-param name="version" select="$cell[5]"/>
                        <xsl:with-param name="layout-mode" select="'single'"/>
                        
                    </xsl:call-template>
                </xsl:for-each>
            </contents-items>
            <contents-screens>
                <xsl:for-each select="$screen[position() gt 1]">
                    <xsl:variable name="pos" select="position()"/>
                    <xsl:variable name="scell" select="tokenize(.,'\t')"/>
                    <!-- <xsl:comment select="$scell[2]"/> -->
                    <xsl:call-template name="listscreen">
                        <xsl:with-param name="title" select="$scell[2]"/>
                        <xsl:with-param name="group" select="$scell[1]"/>
                        <!-- <xsl:with-param name="seq" select="$pos"/> -->
                    </xsl:call-template>
                </xsl:for-each>
            </contents-screens>
        </contents>
    </xsl:template>
    <xsl:template name="item">
        <xsl:param name="title"/>
        <xsl:param name="subtitle"/>
        <xsl:param name="picture"/>
        <xsl:param name="item-numb"/>
        <xsl:param name="link-type"/>
        <xsl:param name="link-target"/>
        <xsl:param name="version"/>
        <xsl:param name="layout-mode"/>
        <contents-item id="{$item-numb}">
            <title lang="{$titlelanguage}">
                <xsl:value-of select="$title"/>
            </title>
            <xsl:if test="string-length($subtitlelanguage) gt 0">
                <subtitle lang="{$subtitlelanguage}">
                    <xsl:value-of select="$subtitle"/>
                </subtitle>
            </xsl:if>
            <xsl:if test="string-length($picture) gt 0">
                <xsl:element name="image-filename">
                    <xsl:value-of select="$picture"/>
                </xsl:element>
            </xsl:if>
            <link type="{$link-type}" target="{$link-target}"/>
            <xsl:if test="$link-type = 'reference'">
                <layout mode="{$layout-mode}">
                    
                        <layout-collection id="{$version}"/>
                    
                </layout>
            </xsl:if>
        </contents-item>
    </xsl:template>
    <xsl:template name="listscreen">
        <xsl:param name="title"/>
        <xsl:param name="group"/>
        <!-- <xsl:param name="seq"/> -->
        <!-- <xsl:variable name="thisele" select="$field[number($seq)]"/> -->
        <contents-screen id="{$group}">
            <title lang="{$titlelanguage}">
                <xsl:value-of select="$title"/>
            </title>
            <items>
                <xsl:for-each select="$item[position() gt 1]">
                    <xsl:variable name="line-numb" select="position() + 100"/>
                    <xsl:variable name="cell" select="tokenize(.,'\t')"/>
                    <xsl:if test="$cell[3] = $group">
                        <item id="{$line-numb}"/>
                        <!-- <xsl:comment select="$cell[1]"/> -->
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$screen[position() gt 1]">
                    <xsl:variable name="cell" select="tokenize(.,'\t')"/>
                    <xsl:if test="$cell[4] = $group">
                        <item id="{$cell[1]}"/>
                        <!-- <xsl:comment select="$cell[2]"/> -->
                    </xsl:if>
                </xsl:for-each>
            </items>
        </contents-screen>
    </xsl:template>
</xsl:stylesheet>
