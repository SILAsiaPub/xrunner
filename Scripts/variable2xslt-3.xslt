<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:    	variable2xslt-3.xslt
    # Purpose:	Generate a XSLT that takes the project.txt file and make var in there into param. Also includes xvarset files and xarray files as param and adds xslt files as includes in project.xslt 
    # Part of: 	Xrunner - 
    # Author:   	Ian McQuay <ian_mcquay.org>
    # Created:  	2018-03-01 Modified 2019-01-30
    # Copyright:	(c) 2018 SIL International
    # Licence:	<MIT>
    ################################################################-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions">
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:output method="text" encoding="utf-8" name="cmd"/>
    <xsl:include href="inc-file2uri.xslt"/>
    <xsl:include href="inc-lookup.xslt"/>
    <xsl:include href="xrun.xslt"/>
    <xsl:param name="projectpath"/>
    <xsl:param name="xrunnerpath"/>
    <xsl:param name="unittest"/>
    <xsl:param name="xsltoff"/>
    <xsl:param name="USERPROFILE"/>
    <xsl:variable name="projectsource" select="concat($projectpath,'\project.txt')"/>
    <xsl:variable name="projecttask" select="f:file2lines($projectsource)"/>
    <xsl:variable name="projecttext" select="f:file2text($projectsource)"/>
    <xsl:variable name="section" select="tokenize($projecttext,'\[')"/>
    <xsl:variable name="xruninisource" select="concat($xrunnerpath,'\setup\xrun.ini')"/>
    <xsl:variable name="xrunline" select="f:file2text($xruninisource)"/>
    <xsl:variable name="xruntext" select="f:file2text($xruninisource)"/>
    <xsl:variable name="xrunsection" select="tokenize($xruntext,'\[')"/>
    <xsl:variable name="project2source" select="concat($projectpath,'\project2.txt')"/>
    <!-- <xsl:variable name="projectlistsource" select="concat($projectpath,'\lists.tsv')"/> -->
    <!-- <xsl:variable name="projectkvsource" select="concat($projectpath,'\keyvalue.tsv')"/> -->
    <xsl:variable name="project2task" select="f:file2lines($project2source)"/>
    <xsl:variable name="project2text" select="f:file2text($project2source)"/>
    <!-- <xsl:variable name="projectkvtext" select="f:file2lines($projectkvsource)"/> -->
    <!-- <xsl:variable name="projectlisttext" select="f:file2lines($projectlistsource)"/> -->
    <xsl:variable name="project2section" select="tokenize($project2text,'\[')"/>
    <xsl:variable name="varparser" select="'^([^;]+);([^ ]+)[ \t]+([^ \t]+)[ \t]+(.+)'"/>
    <xsl:variable name="projectcmd" select="f:file2uri(concat($projectpath,'\tmp\project.cmd'))"/>
    <xsl:variable name="taskgroupprefix" select="''"/>
    <!-- <xsl:variable name="lists" select="'_semicolon-list|_list|_underscore-list|_tilde-list|_equal-list|_file-list'"/> -->
    <xsl:variable name="list-separator-kv_list" select="'semicolon-list=;|list= |underscore-list=_|tilde-list=~|equal-list=|file-list=&#10;'"/>
    <xsl:variable name="list-separator-kv" select="tokenize($list-separator-kv_list,'\|')"/>
    <xsl:variable name="sq">
        <xsl:text>'</xsl:text>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:element name="xsl:stylesheet">
            <xsl:attribute name="version">
                <xsl:text>2.0</xsl:text>
            </xsl:attribute>
            <xsl:namespace name="f" select="'myfunctions'"/>
            <xsl:attribute name="exclude-result-prefixes">
                <xsl:text>f</xsl:text>
            </xsl:attribute>
            <xsl:element name="xsl:include">
                <xsl:attribute name="href">
                    <xsl:text>inc-file2uri.xslt</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="xsl:include">
                <xsl:attribute name="href">
                    <xsl:text>inc-lookup.xslt</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="xsl:include">
                <xsl:attribute name="href">
                    <xsl:text>xrun.xslt</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="xsl:variable">
                <xsl:attribute name="name">
                    <xsl:text>projectpath</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="select">
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="$projectpath"/>
                    <xsl:text>'</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="xsl:variable">
                <xsl:attribute name="name">
                    <xsl:text>USERPROFILE</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="select">
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="$USERPROFILE"/>
                    <xsl:text>'</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="xsl:variable">
                <!-- Define single quote -->
                <xsl:attribute name="name">
                    <xsl:text>sq</xsl:text>
                </xsl:attribute>
                <xsl:text>'</xsl:text>
            </xsl:element>
            <xsl:element name="xsl:variable">
                <!-- Define double quote -->
                <xsl:attribute name="name">
                    <xsl:text>dq</xsl:text>
                </xsl:attribute>
                <xsl:text>"</xsl:text>
            </xsl:element>
            <xsl:for-each select="$section">
                <xsl:variable name="sectpart" select="tokenize(.,'\]')"/>
                <xsl:variable name="sectname" select="$sectpart[1]"/>
                <xsl:variable name="task" select="tokenize($sectpart[2],'\r?\n')"/>
                <xsl:choose>
                    <xsl:when test="$sectname = $xsltsection">
                        <!-- <xsl:if test="not($xsltoff = $true)"> -->
                        <xsl:call-template name="projectxslt">
                            <xsl:with-param name="task" select="$task"/>
                        </xsl:call-template>
                        <!-- </xsl:if> -->
                        <xsl:if test="$sectname = $batchsection">
                            <xsl:call-template name="projectcmd">
                                <xsl:with-param name="task" select="$task"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="$sectname = $guisection">
                              <!--<xsl:call-template name="projectgui">
                                    <xsl:with-param name="task" select="$task"/>
                              </xsl:call-template> -->
                        		 </xsl:when>
                    <xsl:when test="$sectname = $includesection">
                        <xsl:call-template name="projectinclude">
                            <xsl:with-param name="task" select="$task"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="matches($sectpart[2],'\nt=') or matches($sectpart[2],'\nbutton=')">
                            <!-- tasks -->
                            <xsl:call-template name="xruncmdfile">
                                <xsl:with-param name="sectname" select="$sectname"/>
                                <xsl:with-param name="tasklist" select="$task"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="matches($sectpart[2],'\nut=') or matches($sectpart[2],'t=:unittest')">
                            <!-- unit tests -->
                            <xsl:call-template name="unittestcmd">
                                <xsl:with-param name="sectname" select="$sectname"/>
                                <xsl:with-param name="tasklist" select="$task"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <!--  <xsl:for-each select="$inisect">
<xsl:comment select="concat('  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ','xrun.ini',' variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ')"/>

                <xsl:variable name="sectpart" select="tokenize(.,'\]')"/>
                <xsl:variable name="sectname" select="$sectpart[1]"/>
                <xsl:variable name="task" select="tokenize($sectpart[2],'\r?\n')"/>
                <xsl:if test="matches($sectname,'^setup')">
                    <xsl:call-template name="projectxslt">
                        <xsl:with-param name="task" select="$task"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each> -->
            <xsl:if test="unparsed-text-available(f:file2uri($project2source))">
                <xsl:comment select="'project2.txt variables'"/>
                <xsl:for-each select="$project2task">
                    <!-- handle each line of the file with = sign in it project2.txt only has two sections all should be included so no section filtering -->
                    <xsl:if test="matches(.,'=')">
                        <xsl:call-template name="parseline">
                            <xsl:with-param name="line" select="."/>
                            <xsl:with-param name="curpos" select="position()"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:call-template name="listhandling">
                <xsl:with-param name="listsource" select="'keyvalue.tsv'"/>
            </xsl:call-template>
            <xsl:call-template name="listhandling">
                <xsl:with-param name="listsource" select="'lists.tsv'"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    <xsl:template name="projectxslt">
        <xsl:param name="task"/>
        <xsl:comment select="concat('  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ','project.txt',' variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ')"/>
        <xsl:for-each select="$task">
            <!-- handle each line of the file with = sign in it -->
            <xsl:choose>
                <xsl:when test="matches(.,'^#')"/>
                <xsl:otherwise>
                    <xsl:if test="matches(.,'=')">
                        <xsl:call-template name="parseline">
                            <xsl:with-param name="line" select="."/>
                            <xsl:with-param name="curpos" select="position()"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="projectcmd">
        <xsl:param name="task"/>
        <xsl:result-document href="{$projectcmd}" format="cmd">
            <xsl:for-each select="$task">
                <xsl:choose>
                    <xsl:when test="matches(.,'^#')"/>
                    <!-- Commented out lines -->
                    <xsl:when test="matches(.,'=')">
                        <!-- Match variables not section heads -->
                        <xsl:if test="not(matches(.,'&amp;'))">
                            <!-- This removes any ampersands in variables that are fine in XSLT but cause issues in CMD file. -->
                            <xsl:text>set </xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>&#13;&#10;</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:for-each>
            <xsl:call-template name="cmdlists">
                <xsl:with-param name="listsource" select="'lists.tsv'"/>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="projectinclude">
        <xsl:param name="task"/>
        <xsl:for-each select="$task">
            <xsl:if test="matches(.,'^i=')">
                <xsl:variable name="incgroup" select="substring-after(.,'i=')"/>
                <xsl:variable name="incproject" select="concat($projectpath,'\include\',$incgroup,'.txt')"/>
                <xsl:variable name="incprojects" select="concat($projecthome,'\include\',$incgroup,'.txt')"/>
                <xsl:variable name="incxrunner" select="concat($xrunnerpath,'\include\',$incgroup,'.txt')"/>
                <xsl:variable name="includetask">
                    <xsl:choose>
                        <xsl:when test="unparsed-text-available(f:file2uri($incproject))">
                            <xsl:value-of select="$incproject"/>
                        </xsl:when>
                        <xsl:when test="unparsed-text-available(f:file2uri($incprojects))">
                            <xsl:value-of select="$incprojects"/>
                        </xsl:when>
                        <xsl:when test="unparsed-text-available(f:file2uri($incxrunner))">
                            <xsl:value-of select="$incxrunner"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat($xrunnerpath,'\include\missinginclude.txt')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="xruncmdfile">
                    <xsl:with-param name="sectname" select="$incgroup"/>
                    <xsl:with-param name="tasklist" select="f:file2lines($includetask)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="unittestcmd">
        <xsl:param name="sectname"/>
        <xsl:param name="tasklist"/>
        <xsl:if test="string-length($sectname) gt 0">
            <xsl:result-document href="{f:file2uri(concat($xrunnerpath,'/scripts/ut-',$sectname,'.xrun'))}" format="cmd">
                <xsl:text>rem Auto generated file. Do not edit.&#10;</xsl:text>
                <xsl:for-each select="$tasklist">
                    <xsl:variable name="tname" select="substring-before(.,'=')"/>
                    <xsl:variable name="tcmd" select="substring-after(.,'=')"/>
                    <xsl:choose>
                        <xsl:when test="$tname = $unittestlabel[1]">
                            <!-- <xsl:if test="substring($tcmd,1,1) = ':'"> -->
                            <xsl:text>call :test </xsl:text>
                            <!-- </xsl:if> -->
                            <xsl:value-of select="$tcmd"/>
                            <xsl:text>&#13;&#10;</xsl:text>
                            <!-- <xsl:text> &gt;&gt; scripts\sub.txt &#10;</xsl:text> -->
                        </xsl:when>
                        <xsl:when test="$tname = $unittestlabel[2]">
                            <xsl:text>call </xsl:text>
                            <xsl:value-of select="$tcmd"/>
                            <xsl:text>&#13;&#10;</xsl:text>
                        </xsl:when>
                        <xsl:when test="$tname = $commentlabel">
                            <xsl:text>rem </xsl:text>
                            <xsl:value-of select="$tcmd"/>
                            <xsl:text>&#13;&#10;</xsl:text>
                        </xsl:when>
                        <xsl:when test="matches(.,'^#')">
                            <xsl:text>rem </xsl:text>
                            <xsl:value-of select="substring-after(.,'# ')"/>
                            <xsl:text>&#13;&#10;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
    <xsl:template name="cmdsection">
        <xsl:param name="task"/>
        <xsl:for-each select="$task">
            <xsl:if test="matches(.,'^t=')">
                <xsl:variable name="tname" select="substring-before(.,'=')"/>
                <xsl:variable name="tcmd" select="substring-after(.,'=')"/>
                <xsl:text>set </xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>&#13;&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="parseline">
        <xsl:param name="line"/>
        <xsl:param name="curpos"/>
        <!-- parse into name and data -->
        <xsl:variable name="varname" select="tokenize($line,'=')[1]"/>
        <xsl:variable name="vardata" select="substring-after($line,'=')"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="writeparam">
            <xsl:with-param name="varname" select="$varname"/>
            <xsl:with-param name="iscommand" select="f:batvarcheck($vardata)"/>
            <xsl:with-param name="vardata">
                <xsl:value-of select="f:handlevar($vardata)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="writeparam">
        <xsl:param name="varname"/>
        <xsl:param name="vardata"/>
        <xsl:param name="iscommand"/>
        <xsl:element name="xsl:param">
            <xsl:attribute name="name">
                <xsl:value-of select="$varname"/>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:if test="not($iscommand = $true)">
                    <xsl:text>'</xsl:text>
                </xsl:if>
                <xsl:value-of select="$vardata"/>
                <xsl:if test="not($iscommand = $true)">
                    <xsl:text>'</xsl:text>
                </xsl:if>
            </xsl:attribute>
        </xsl:element>
        <xsl:if test="matches($varname,'[_\-]list$')">
            <!-- space (\s+) delimited list -->
            <xsl:call-template name="arrayvar">
                <xsl:with-param name="vardata" select="$vardata"/>
                <xsl:with-param name="varname" select="$varname"/>
                <!-- <xsl:with-param name="listype" select="substring-after($varname,'_')"/> -->
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template name="arrayvar">
        <xsl:param name="vardata"/>
        <xsl:param name="varname"/>
        <xsl:variable name="listtype" select="replace($varname,'^.+_([^_]+)$','$1')"/>
        <!-- <xsl:param name="listname"/> -->
        <xsl:variable name="listdelim" select="f:listdelim($listtype)"/>
        <xsl:variable name="varnewname" select="replace($varname,'^(.+)_[^_]+$','$1')"/>
        <!-- delimited list -->
        <xsl:choose>
            <xsl:when test="matches($varname,'_file-list$')">
                <!-- adds a tokenized list from a file. Good for when the list is too long for batch line -->
                <xsl:element name="xsl:variable">
                    <xsl:attribute name="name">
                        <xsl:value-of select="replace($varname,'_file-list','')"/>
                    </xsl:attribute>
                    <xsl:attribute name="select">
                        <xsl:text>f:file2lines($</xsl:text>
                        <xsl:value-of select="$varname"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="xsl:variable">
                    <xsl:attribute name="name">
                        <xsl:value-of select="$varnewname"/>
                    </xsl:attribute>
                    <xsl:attribute name="select">
                        <xsl:value-of select="concat('tokenize($',$varname,',',$sq,$listdelim,$sq,')')"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        <!--  now test if there are = in the list and make a key list -->
        <xsl:if test="matches($vardata,'=')">
            <xsl:if test="$listdelim ne '='">
                <xsl:call-template name="write-key-var">
                    <xsl:with-param name="varname" select="$varname"/>
                    <xsl:with-param name="varnewname" select="$varnewname"/>
                    <xsl:with-param name="separator" select="$listdelim"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template name="write-key-var">
        <xsl:param name="varname"/>
        <xsl:param name="varnewname"/>
        <xsl:param name="separator"/>
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name">
                <xsl:value-of select="concat($varnewname,'-key')"/>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'=[^',$separator,']*[',$separator,']?',$sq,')')"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template name="xruncmdfile">
        <xsl:param name="sectname"/>
        <xsl:param name="tasklist"/>
        <xsl:if test="string-length($sectname) gt 0">
            <xsl:result-document href="{f:file2uri(concat($xrunnerpath,'/scripts/',$sectname,'.xrun'))}" format="cmd">
                <xsl:text>rem Auto generated file. Do not edit.&#13;&#10;</xsl:text>
                <xsl:for-each select="$tasklist">
                    <xsl:choose>
                        <xsl:when test="matches(.,'^#')"/>
                        <xsl:otherwise>
                            <xsl:variable name="tname" select="substring-before(.,'=')"/>
                            <xsl:variable name="tcmd" select="substring-after(.,'=')"/>
                            <xsl:choose>
                                <xsl:when test="$tname = $tasklabel">
                                    <xsl:if test="substring($tcmd,1,1) = ':'">
                                        <xsl:text>call </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of select="$tcmd"/>
                                    <xsl:text>&#13;&#10;</xsl:text>
                                </xsl:when>
                                <xsl:when test="$tname = $commentlabel">
                                    <xsl:text>rem </xsl:text>
                                    <xsl:value-of select="$tcmd"/>
                                    <xsl:text>&#13;&#10;</xsl:text>
                                </xsl:when>
                                <xsl:when test="matches(.,'^#')">
                                    <xsl:text>rem </xsl:text>
                                    <xsl:value-of select="substring-after(.,'# ')"/>
                                    <xsl:text>&#13;&#10;</xsl:text>
                                </xsl:when>
                                <xsl:otherwise/>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
    <xsl:template name="listhandling">
        <xsl:param name="listsource"/>
        <!-- <xsl:param name="comment"/> -->
        <xsl:variable name="list" select="concat($projectpath,'\',$listsource)"/>
        <xsl:variable name="listtext" select="f:file2lines($list)"/>
        <!-- <xsl:variable name="listuri" select="f:file2uri($list)"/> -->
        <!-- <xsl:variable name="test" select="unparsed-text-available($listuri)"/> -->
        <xsl:if test="not(matches($listtext[1],'text not imported'))">
            <!-- get variable values from listsource tsv in the project folder -->
            <xsl:comment select="concat('  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ',$listsource,' variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ')"/>
            <xsl:variable name="lists-data">
                <xsl:for-each select="$listtext">
                    <xsl:variable name="cell" select="tokenize(.,'&#9;')"/>
                    <xsl:variable name="countfields" select="count(tokenize(.,'&#9;'))"/>
                    <xsl:choose>
                        <xsl:when test="matches(.,'#')"/>
                        <!-- This is a coment line starting with a hash # -->
                        <xsl:when test="string-length($cell[1]) gt 0">
                            <xsl:element name="row">
                                <xsl:attribute name="vname">
                                    <xsl:value-of select="$cell[1]"/>
                                </xsl:attribute>
                                <xsl:attribute name="{if (matches($listsource,'keyvalue')) then 'key' else 'value'}">
                                    <xsl:value-of select="$cell[2]"/>
                                </xsl:attribute>
                                <xsl:if test="matches($listsource,'keyvalue')">
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="$cell[3]"/>
                                    </xsl:attribute>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                                 <!-- this should be an empty line or mal formed line with no variable name before the tab-->
                         </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each-group select="$lists-data/row" group-by="@vname">
                <xsl:variable name="varname" select="current-grouping-key()"/>
                <xsl:variable name="shortname" select="substring-before($varname,'_list')"/>
                <xsl:variable name="listtype" select="tokenize($varname,'_')[last()]"/>
                <xsl:variable name="listdelim" select="f:listdelim($listtype)"/>
                <xsl:element name="xsl:param">
                    <xsl:attribute name="name">
                        <xsl:value-of select="$varname"/>
                    </xsl:attribute>
                    <xsl:attribute name="select">
                        <xsl:text>'</xsl:text>
                        <xsl:for-each select="current-group()">
                            <xsl:variable name="pos" select="position()"/>
                            <xsl:if test="@key">
                                <xsl:value-of select="./@key"/>
                                <xsl:text>=</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="./@value"/>
                            <xsl:value-of select="if ($pos ne last()) then $listdelim else ''"/>
                            <!-- <xsl:text> </xsl:text> -->
                        </xsl:for-each>
                        <xsl:text>'</xsl:text>
                    </xsl:attribute>
                </xsl:element>
                <xsl:if test="matches($varname,'_.*list$')">
                    <!-- any delimited list like: _list, _semicolon-list, etc -->
                    <xsl:call-template name="arrayvar">
                        <xsl:with-param name="vardata" select="'='"/>
                        <xsl:with-param name="varname" select="$varname"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:template>
    <xsl:template name="cmdlists">
        <xsl:param name="listsource"/>
        <!-- <xsl:param name="comment"/> -->
        <xsl:variable name="list" select="concat($projectpath,'\',$listsource)"/>
        <xsl:variable name="listuri" select="concat('file:///',replace($list,'\\','/'))"/>
        <xsl:variable name="test" select="unparsed-text-available($listuri)"/>
        <xsl:if test="unparsed-text-available($listuri)">
            <xsl:variable name="listtext" select="f:file2lines($listuri)"/>
            <!-- get variable values from listsource tsv in the project folder -->
            <xsl:comment select="concat($listsource,' variables')"/>
            <xsl:variable name="lists-data">
                <xsl:for-each select="$listtext">
                    <xsl:variable name="cell" select="tokenize(.,'&#9;')"/>
                    <xsl:variable name="countfields" select="count(tokenize(.,'&#9;'))"/>
                    <xsl:if test="string-length($cell[1]) gt 0">
                        <xsl:element name="row">
                            <xsl:attribute name="vname">
                                <xsl:value-of select="$cell[1]"/>
                            </xsl:attribute>
                            <xsl:attribute name="{if ($countfields = 3) then 'key' else 'value'}">
                                <xsl:value-of select="$cell[2]"/>
                            </xsl:attribute>
                            <xsl:if test="$countfields = 3">
                                <xsl:attribute name="value">
                                    <xsl:value-of select="$cell[3]"/>
                                </xsl:attribute>
                            </xsl:if>
                        </xsl:element>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each-group select="$lists-data/row" group-by="@vname">
                <xsl:variable name="varname" select="current-grouping-key()"/>
                <xsl:variable name="shortname" select="substring-before($varname,'_list')"/>
                <xsl:variable name="listtype" select="tokenize($varname,'_')[last()]"/>
                <xsl:variable name="listdelim" select="f:listdelim($listtype)"/>
                <xsl:text>&#10;set </xsl:text>
                <xsl:value-of select="$varname"/>
                <xsl:text>=</xsl:text>
                <xsl:for-each select="current-group()">
                    <xsl:variable name="pos" select="position()"/>
                    <xsl:if test="@key">
                        <xsl:value-of select="./@key"/>
                        <xsl:text>=</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="./@value"/>
                    <xsl:value-of select="if ($pos ne last()) then $listdelim else ''"/>
                    <!-- <xsl:text> </xsl:text> -->
                </xsl:for-each>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:template>
    <xsl:function name="f:handlevar">
        <xsl:param name="string"/>
        <!-- parse the data part for variables -->
        <xsl:choose>
            <xsl:when test="matches($string,'^&#34;?%[\w\d\-_]+:.*=.*%&#34;?$')">
                <!-- Matches batch variable with a find and replace structure %name:find=replace% -->
                <xsl:variable name="re" select="'^&#34;?%([\w\d\-_]+):(.*)=(.*)%&#34;?$'"/>
                <xsl:text>replace(</xsl:text>
                <xsl:value-of select="replace($string,$re,'\$$1')"/>
                <xsl:text>,'</xsl:text>
                <xsl:value-of select="replace($string,$re,'$2')"/>
                <xsl:text>','</xsl:text>
                <xsl:value-of select="replace($string,$re,'$3')"/>
                <xsl:text>')</xsl:text>
            </xsl:when>
            <xsl:when test="matches($string,'%[\w\d\-_]+%')">
                <!-- variable % name1-more% -->
                <xsl:text>concat(</xsl:text>
                <xsl:analyze-string select="replace($string,'&#34;','')" regex="%[\w\d\-_]+%">
                    <!-- match variable string -->
                    <xsl:matching-substring>
                        <xsl:if test="position() gt 1">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                        <xsl:text>$</xsl:text>
                        <xsl:value-of select="replace(.,'%','')"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <xsl:text>'</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,'</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="."/>
                        <xsl:text>'</xsl:text>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                <xsl:text>,'')</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($string,'&#34;','')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:batvarcheck">
        <xsl:param name="string"/>
        <xsl:choose>
            <xsl:when test="matches($string,'%[\w\d\-_]+?%')">
                <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>false</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:listdelim">
        <xsl:param name="listtype"/>
        <xsl:value-of select="if($listtype = 'equal-list') then '=' else f:keyvalue($list-separator-kv,$listtype)"/>
    </xsl:function>
</xsl:stylesheet>
