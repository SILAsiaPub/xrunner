<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:   		USX-fig-table.xslt
    # Purpose:		Extract fig information from one or more USX files. The fig information is for importing into a spreadsheet
    # Part of:		Vimod Pub - https://github.com/SILAsiaPub/vimod-pub
    # Author:		Ian McQuay <ian_mcquay@sil.org>
    # Created:		2017-07-19
    # Copyright:   	(c) 2017 SIL International
    # Licence:		<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
    <xsl:output method="text" encoding="utf-8"/>
    <!-- <xsl:include href="inc-file2uri.xslt"/> -->
    <!-- <xsl:include href="inc-lookup.xslt"/> -->
    <xsl:include href="project.xslt"/>
    <xsl:param name="divider" select="'&#9;'"/>
    <xsl:variable name="usxpathuri" select="f:file2uri($usxpath)"/>
    <xsl:variable name="collection" select="collection(concat($usxpathuri,'?select=','*.usx'))"/>
    <xsl:template match="/">
        <xsl:for-each select="$collection/usx">
            <xsl:sort select="number(f:keyvalue($bookorder,book/@code))"/>
            <xsl:apply-templates select="descendant::figure">
                <xsl:with-param name="bk" select="book/@code"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="figure">
        <xsl:param name="bk"/>
        <xsl:variable name="chap" select="preceding::chapter[1]/@number"/>
        <xsl:variable name="verse" select="preceding::verse[1]/@number"/>
        <xsl:value-of select="$bk"/>
        <xsl:value-of select="$divider"/>
        <xsl:value-of select="$chap"/>
        <xsl:value-of select="$divider"/>
        <xsl:value-of select="$verse"/>
        <xsl:value-of select="$divider"/>
        <xsl:value-of select="$divider"/>
        <xsl:value-of select="@file"/>
        <xsl:value-of select="$divider"/>
        <xsl:value-of select="$divider"/>
        <xsl:value-of select="@copy"/>
        <xsl:value-of select="$divider"/>
        <xsl:value-of select="."/>
        <xsl:text>&#13;&#10;</xsl:text>
    </xsl:template>
    <xsl:template match="text()"/>
    <xsl:variable name="bookorder" select="
tokenize('FRT=00
GEN=01
EXO=02
LEV=03
NUM=04
DEU=05
JOS=06
JDG=07
RUT=08
1SA=09
2SA=10
1KI=11
2KI=12
1CH=13
2CH=14
EZR=15
NEH=16
EST=17
JOB=18
PSA=19
PRO=20
ECC=21
SNG=22
ISA=23
JER=24
LAM=25
EZK=26
DAN=27
HOS=28
JOL=29
AMO=30
OBA=31
JON=32
MIC=33
NAM=34
HAB=35
ZEP=36
HAG=37
ZEC=38
MAL=39
MAT=41
MRK=42
LUK=43
JHN=44
ACT=45
ROM=46
1CO=47
2CO=48
GAL=49
EPH=50
PHP=51
COL=52
1TH=53
2TH=54
1TI=55
2TI=56
TIT=57
PHM=58
HEB=59
JAS=60
1PE=61
2PE=62
1JN=63
2JN=64
3JN=65
JUD=66
REV=67
TOB=68
JDT=69
ESG=70
WIS=71
SIR=72
BAR=73
LJE=74
S3Y=75
SUS=76
BEL=77
1MA=78
2MA=79
3MA=80
4MA=81
1ES=82
2ES=83
MAN=84
PS2=85
ODA=86
PSS=87
GLO=109','\r?\n')"/>
</xsl:stylesheet>
