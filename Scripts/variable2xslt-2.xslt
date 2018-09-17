<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:    	variable2xslt.xslt
    # Purpose:		Generate a XSLT that takes the project.txt file and make var in there into param. Also includes xvarset files and xarray files as param and adds xslt files as includes in project.xslt 
    # Part of: 	Xrunner - 
    # Author:   	Ian McQuay <ian_mcquay.org>
    # Created:  	2018-03-01
    # Copyright:  (c) 2018 SIL International
    # Licence:  	<MIT>
    ################################################################-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:output method="text" encoding="utf-8" name="cmd"/>
      <xsl:include href="inc-file2uri.xslt"/>
      <xsl:include href="setup.xslt"/>
      <xsl:param name="projectpath"/>
      <xsl:param name="unittest"/>
      <xsl:variable name="projectsource" select="concat($projectpath,'\project.txt')"/>
      <xsl:variable name="projecttask" select="f:file2lines($projectsource)"/>
      <xsl:variable name="projecttext" select="f:file2text($projectsource)"/>
      <xsl:variable name="section" select="tokenize($projecttext,'\[')"/>
      <xsl:variable name="project2source" select="concat($projectpath,'\project2.txt')"/>
      <xsl:variable name="project2task" select="f:file2lines($project2source)"/>
      <xsl:variable name="project2text" select="f:file2text($project2source)"/>
      <xsl:variable name="section2" select="tokenize($project2text,'\[')"/>
      <xsl:variable name="cd" select="substring-before($projectpath,'\data\')"/>
      <xsl:variable name="varparser" select="'^([^;]+);([^ ]+)[ \t]+([^ \t]+)[ \t]+(.+)'"/>
      <xsl:variable name="projectcmd" select="f:file2uri(concat($projectpath,'\tmp\project.cmd'))"/>
      <xsl:variable name="taskgroupprefix" select="''"/>
      <xsl:variable name="lists" select="'_semicolon-list|_list|_underscore-list|_equal-list|_file-list'"/>
      <!--<xsl:variable name="var" select="tokenize('var xvar',' ')"/>
      <xsl:variable name="button-or-label" select="tokenize('button label',' ')"/>
      <xsl:variable name="nonunique" select="tokenize('t xt ut button label com',' ')"/>
      <xsl:variable name="unittestlabel" select="tokenize('ut utt',' ')"/>
      <xsl:variable name="nontasksection" select="tokenize('variables project proj',' ')"/>
      <xsl:variable name="tasklabel" select="tokenize('t',' ')"/>
      <xsl:variable name="batchsection" select="'variables project proj'"/>
        -->
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
                  <xsl:element name="xsl:variable">
                        <!-- Define single quote -->
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
                  <xsl:element name="xsl:variable">
                        <xsl:attribute name="name">
                              <xsl:text>true</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="select">
                              <xsl:text>tokenize('true yes on 1','\s+')</xsl:text>
                        </xsl:attribute>
                  </xsl:element>
                  <xsl:for-each select="$projecttask">
                        <!-- handle each line of the file with = sign in it -->
                        <xsl:if test="matches(.,'=')">
                              <xsl:call-template name="parseline">
                                    <xsl:with-param name="line" select="."/>
                                    <xsl:with-param name="curpos" select="position()"/>
                              </xsl:call-template>
                        </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="unparsed-text-available(f:file2uri($project2source))">
                        <xsl:for-each select="$project2task">
                              <!-- handle each line of the file with = sign in it -->
                              <xsl:if test="matches(.,'=')">
                                    <xsl:call-template name="parseline">
                                          <xsl:with-param name="line" select="."/>
                                          <xsl:with-param name="curpos" select="position()"/>
                                    </xsl:call-template>
                              </xsl:if>
                        </xsl:for-each>
                  </xsl:if>
            </xsl:element>
            <xsl:call-template name="projectcmd"/>
            <xsl:call-template name="taskgroup"/>
            <xsl:call-template name="include"/>
            <xsl:if test="$unittest = $true">
                  <xsl:call-template name="unittest"/>
            </xsl:if>
      </xsl:template>
      <xsl:template name="parseline">
            <xsl:param name="line"/>
            <xsl:param name="curpos"/>
            <!-- parse into name and data -->
            <xsl:variable name="varname" select="tokenize($line,'=')[1]"/>
            <xsl:variable name="vardata" select="substring-after($line,'=')"/>
            <xsl:choose>
                  <!-- when a task t= then ignore -->
                  <xsl:when test="$varname = $nonunique"/>
                  <!-- when a button or label ignore -->
                  <xsl:when test="$varname = $button-or-label"/>
                  <!-- <xsl:when test="matches($varname,'^\[.*$')"> -->
                  <xsl:otherwise>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:call-template name="writeparam">
                              <xsl:with-param name="varname" select="$varname"/>
                              <xsl:with-param name="iscommand">
                                    <xsl:choose>
                                          <xsl:when test="matches($vardata,'%[\w\d\-_]*%')">
                                                <xsl:text>true</xsl:text>
                                          </xsl:when>
                                          <xsl:when test="matches($vardata,'%[\w\d\-_]+[:\w\d=~,]*%')">
                                                <xsl:text></xsl:text>
                                          </xsl:when>
                                          <xsl:otherwise/>
                                    </xsl:choose>
                              </xsl:with-param>
                              <xsl:with-param name="vardata">
                                    <xsl:value-of select="f:handlevar($vardata)"/>
                              </xsl:with-param>
                        </xsl:call-template>
                  </xsl:otherwise>
            </xsl:choose>
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
                        <xsl:if test="string-length($iscommand) = 0">
                              <xsl:text>'</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$vardata"/>
                        <xsl:if test="string-length($iscommand) = 0">
                              <xsl:text>'</xsl:text>
                        </xsl:if>
                  </xsl:attribute>
            </xsl:element>
            <xsl:if test="matches($varname,'_list$')">
                  <!-- space (\s+) delimited list -->
                  <xsl:element name="xsl:variable">
                        <xsl:attribute name="name">
                              <xsl:value-of select="replace($varname,'_list','')"/>
                        </xsl:attribute>
                        <xsl:attribute name="select">
                              <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'\s+',$sq,')')"/>
                        </xsl:attribute>
                  </xsl:element>
                  <xsl:if test="matches($vardata,'=')">
                        <xsl:call-template name="write-key-var">
                              <xsl:with-param name="name" select="$varname"/>
                              <xsl:with-param name="separator" select="' '"/>
                        </xsl:call-template>
                  </xsl:if>
            </xsl:if>
            <xsl:if test="matches($varname,'_file-list$')">
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
            </xsl:if>
            <xsl:if test="matches($varname,'_underscore-list$')">
                  <!-- unerescore delimied list -->
                  <xsl:element name="xsl:variable">
                        <xsl:attribute name="name">
                              <xsl:value-of select="replace($varname,'_underscore-list','')"/>
                        </xsl:attribute>
                        <xsl:attribute name="select">
                              <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'_',$sq,')')"/>
                        </xsl:attribute>
                  </xsl:element>
                  <xsl:if test="matches($vardata,'=')">
                        <xsl:call-template name="write-key-var">
                              <xsl:with-param name="name" select="$varname"/>
                              <xsl:with-param name="separator" select="'_'"/>
                        </xsl:call-template>
                  </xsl:if>
            </xsl:if>
            <xsl:if test="matches($varname,'_equal-list$')">
                  <!-- equals delimited list -->
                  <xsl:element name="xsl:variable">
                        <xsl:attribute name="name">
                              <xsl:value-of select="replace($varname,'_equal-list','')"/>
                        </xsl:attribute>
                        <xsl:attribute name="select">
                              <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'=',$sq,')')"/>
                        </xsl:attribute>
                  </xsl:element>
            </xsl:if>
            <xsl:if test="matches($varname,'_semicolon-list$')">
                  <!-- semicolon delimited list -->
                  <xsl:element name="xsl:variable">
                        <xsl:attribute name="name">
                              <xsl:value-of select="replace($varname,'_semicolon-list','')"/>
                        </xsl:attribute>
                        <xsl:attribute name="select">
                              <xsl:value-of select="concat('tokenize($',$varname,',',$sq,';',$sq,')')"/>
                        </xsl:attribute>
                  </xsl:element>
                  <!--  now test if there are = in the list and make a key list -->
                  <xsl:if test="matches($vardata,'=')">
                        <xsl:call-template name="write-key-var">
                              <xsl:with-param name="name" select="$varname"/>
                              <xsl:with-param name="separator" select="';'"/>
                        </xsl:call-template>
                  </xsl:if>
            </xsl:if>
      </xsl:template>
      <xsl:template name="write-key-var">
            <xsl:param name="name"/>
            <xsl:param name="separator"/>
            <xsl:element name="xsl:variable">
                  <xsl:attribute name="name">
                        <xsl:value-of select="replace($name,concat('(',$lists,')$'),'-key')"/>
                  </xsl:attribute>
                  <xsl:attribute name="select">
                        <xsl:value-of select="concat('tokenize($',$name,',',$sq,'=[^',$separator,']*[',$separator,']?',$sq,')')"/>
                  </xsl:attribute>
            </xsl:element>
      </xsl:template>
      <xsl:template name="projectcmd">
            <xsl:result-document href="{$projectcmd}" format="cmd">
                  <xsl:call-template name="cmdsection">
                        <xsl:with-param name="segment" select="$section"/>
                  </xsl:call-template>
                  <xsl:call-template name="cmdsection">
                        <xsl:with-param name="segment" select="$section2"/>
                  </xsl:call-template>
            </xsl:result-document>
      </xsl:template>
      <xsl:template name="taskgroup">
            <xsl:for-each select="$section">
                  <!-- Now handle subs -->
                  <xsl:variable name="sectpart" select="tokenize(.,'\]')"/>
                  <xsl:variable name="sectname" select="$sectpart[1]"/>
                  <xsl:variable name="task" select="tokenize($sectpart[2],'\r?\n')"/>
                  <xsl:if test="not($sectname = $reservedsection)">
                        <xsl:call-template name="xrunfile">
                              <xsl:with-param name="filename" select="$sectname"/>
                              <xsl:with-param name="tasklist" select="$task"/>
                        </xsl:call-template>
                  </xsl:if>
            </xsl:for-each>
      </xsl:template>
      <xsl:template name="include">
            <xsl:if test="matches($projecttext,'[include]')">
                  <xsl:for-each select="$section">
                        <!-- Now handle subs -->
                        <xsl:variable name="sectpart" select="tokenize(.,'\]')"/>
                        <xsl:variable name="sectname" select="$sectpart[1]"/>
                        <xsl:if test="$sectname = $includesection">
                              <xsl:variable name="task" select="tokenize($sectpart[2],'\r?\n')"/>
                              <xsl:for-each select="$task">
                                    <xsl:variable name="iname" select="substring-before(.,'=')"/>
                                    <xsl:variable name="incgroup" select="substring-after(.,'=')"/>
                                    <xsl:if test="$iname = $includelabel">
                                          <xsl:variable name="incproject" select="concat($projectpath,'\include\',$incgroup,'.txt')"/>
                                          <xsl:variable name="incprojects" select="concat($projecthome,'\include\',$incgroup,'.txt')"/>
                                          <xsl:variable name="incxrunner" select="concat($xrunnerpath,'\include\',$incgroup,'.txt')"/>
                                          <xsl:variable name="includetask">
                                                <xsl:choose>
                                                      <xsl:when test="unparsed-text-available(f:file2uri($incproject))">
                                                            <xsl:sequence select="f:file2lines($incproject)"/>
                                                      </xsl:when>
                                                      <xsl:when test="unparsed-text-available(f:file2uri($incprojects))">
                                                            <xsl:sequence select="f:file2lines($incprojects)"/>
                                                      </xsl:when>
                                                      <xsl:when test="unparsed-text-available(f:file2uri($incxrunner))">
                                                            <xsl:sequence select="f:file2lines($incxrunner)"/>
                                                      </xsl:when>
                                                      <xsl:otherwise>
                                                            <xsl:value-of select="'t=echo Error: Include is not found in: project, projects, xrunner'"/>
                                                      </xsl:otherwise>
                                                </xsl:choose>
                                          </xsl:variable>
                                          <xsl:call-template name="xrunfile">
                                                <xsl:with-param name="filename" select="$incgroup"/>
                                                <xsl:with-param name="tasklist" select="$includetask"/>
                                          </xsl:call-template>
                                    </xsl:if>
                              </xsl:for-each>
                        </xsl:if>
                  </xsl:for-each>
            </xsl:if>
      </xsl:template>
      <xsl:template name="unittest">
            <xsl:for-each select="$section">
                  <!-- Now handle subs -->
                  <xsl:variable name="sectpart" select="tokenize(.,'\]')"/>
                  <xsl:variable name="sectname" select="$sectpart[1]"/>
                  <xsl:variable name="task" select="tokenize($sectpart[2],'\r?\n')"/>
                  <xsl:if test="not($sectname = $reservedsection)">
                        <xsl:result-document href="{concat('ut',$sectname,'.xrun')}" format="cmd">
                              <!-- <xsl:text>echo rem Auto generated file &gt; scripts\sub.txt &#10;</xsl:text> -->
                              <xsl:for-each select="$task">
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
                                          <xsl:otherwise/>
                                    </xsl:choose>
                              </xsl:for-each>
                        </xsl:result-document>
                  </xsl:if>
            </xsl:for-each>
      </xsl:template>
      <xsl:template name="cmdsection">
            <xsl:param name="segment"/>
            <xsl:for-each select="$segment">
                  <xsl:variable name="sectpart" select="tokenize(.,'\]')"/>
                  <xsl:if test="$sectpart[1] = $batchsection">
                        <xsl:variable name="task" select="tokenize($sectpart[2],'\r?\n')"/>
                        <xsl:variable name="taskline">
                              <xsl:for-each select="$task">
                                    <xsl:variable name="tname" select="substring-before(.,'=')"/>
                                    <xsl:variable name="tcmd" select="substring-after(.,'=')"/>
                                    <xsl:choose>
                                          <xsl:when test="$tname = 't'">
                                                <xsl:element name="task">
                                                      <xsl:value-of select="$tcmd"/>
                                                </xsl:element>
                                          </xsl:when>
                                          <xsl:otherwise/>
                                    </xsl:choose>
                              </xsl:for-each>
                        </xsl:variable>
                        <xsl:for-each select="$task">
                              <xsl:variable name="tname" select="substring-before(.,'=')"/>
                              <xsl:variable name="tcmd" select="substring-after(.,'=')"/>
                              <xsl:choose>
                                    <xsl:when test="$tname = ''"/>
                                    <xsl:when test="$tname = $nonunique"/>
                                    <xsl:when test="matches($tcmd,'[&amp;\|&gt;&lt;]')">
                                          <!-- Safety net for batch file creation to catch illegal characters -->
                                          <xsl:text>set </xsl:text>
                                          <xsl:value-of select="$tname"/>
                                          <xsl:text>=Illegal character in this parameter. Data ommitted. It is includded in the XSLT.&#13;&#10;</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                          <xsl:text>set </xsl:text>
                                          <xsl:value-of select="."/>
                                          <xsl:text>&#13;&#10;</xsl:text>
                                    </xsl:otherwise>
                              </xsl:choose>
                        </xsl:for-each>
                  </xsl:if>
            </xsl:for-each>
      </xsl:template>
      <xsl:template name="xrunfile">
            <xsl:param name="filename"/>
            <xsl:param name="tasklist"/>
            <xsl:result-document href="{concat('ut',$filename,'.xrun')}" format="cmd">
                  <xsl:text>rem Auto generated file. Do not edit.</xsl:text>
                  <xsl:for-each select="$tasklist">
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
                              <xsl:otherwise/>
                        </xsl:choose>
                  </xsl:for-each>
            </xsl:result-document>
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
                        <!-- <xsl:if test="$onevar = 'onevar'"> -->
                        <!-- This is incase there is only one variable passed to another variable, rare but possible -->
                        <!-- <xsl:text>,''</xsl:text> -->
                        <!-- </xsl:if> -->
                        <xsl:text>,'')</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                        <xsl:value-of select="replace($string,'&#34;','')"/>
                  </xsl:otherwise>
            </xsl:choose>
      </xsl:function>
      <xsl:template name="scrap">
            <xsl:text> </xsl:text>
            <!--<xsl:for-each select="$taskline/task">
                  <xsl:text>set </xsl:text>
                  <xsl:value-of select="'t'"/>
                  <xsl:value-of select="$sectpart[1]"/>
                  <xsl:value-of select="position()"/>
                  <xsl:text>=on</xsl:text> -->
            <!-- <xsl:value-of select="."/> -->
            <!-- testing here -->
            <!-- <xsl:text>&#10;</xsl:text> -->
            <!-- </xsl:for-each> -->
            <!-- matches ini section -->
            <!-- <xsl:element name="xsl:variable">
                              <xsl:attribute name="name">
                                    <xsl:value-of select="concat('comment',$curpos)"/>
                              </xsl:attribute>
                              <xsl:attribute name="select">
                                    <xsl:text>'</xsl:text>
                                    <xsl:value-of select="$line"/>
                                    <xsl:text>'</xsl:text>
                              </xsl:attribute>
                        </xsl:element>
                  </xsl:when> -->
            <!-- <xsl:variable name="key" select="tokenize($vardata,'=.*_?')"/>concat('=[^',$seperator,']*',$separator,'?') -->
            <!-- <xsl:element name="xsl:variable"> -->
            <!-- <xsl:attribute name="name"> -->
            <!-- <xsl:value-of select="replace($varname,'_semicolon-list','-key')"/> -->
            <!-- </xsl:attribute> -->
            <!-- <xsl:attribute name="select"> -->
            <!-- <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'=[^;]+;?',$sq,')')"/> -->
            <!-- </xsl:attribute> -->
            <!-- </xsl:element> -->
            <!-- <xsl:for-each select="$task">
                        <xsl:variable name="tname" select="substring-before(.,'=')"/>
                        <xsl:variable name="tcmd" select="substring-after(.,'=')"/>
                        <xsl:choose>
                              <xsl:when test="$tname = ''"/>
                              <xsl:when test="$tname = $tasklabel">
                                    <xsl:text>set </xsl:text>
                                    <xsl:value-of select="$tname"/>
                                    <xsl:value-of select="$sectpart[1]"/>
                                    <xsl:value-of select="position()"/>
                                    <xsl:text>=</xsl:text>
                                    <xsl:value-of select="$tcmd"/>
                                    <xsl:text>&#10;</xsl:text>
                              </xsl:when>
                              <xsl:when test="$tname = $butlab">
                                    <xsl:text>set </xsl:text>
                                    <xsl:value-of select="$tname"/>
                                    <xsl:value-of select="$sectpart[1]"/>
                                    <xsl:text>=</xsl:text>
                                    <xsl:value-of select="$tcmd"/>
                                    <xsl:text>&#10;</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>
                                    <xsl:text>set </xsl:text>
                                    <xsl:value-of select="."/>
                                    <xsl:text>&#10;</xsl:text>
                              </xsl:otherwise>
                        </xsl:choose>
                  </xsl:for-each> -->
            <!-- <xsl:value-of select="$tname"/> -->
            <!-- <xsl:value-of select="$sectpart[1]"/> -->
            <!-- <xsl:value-of select="position()"/> -->
            <!-- <xsl:text>=</xsl:text> -->
      </xsl:template>
</xsl:stylesheet>
