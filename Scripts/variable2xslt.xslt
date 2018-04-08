<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:         	variable2xslt.xslt
    # Purpose:		Generate a XSLT that takes the project.txt file and make var in there into param. Also includes xvarset files and xarray files as param and adds xslt files as includes in project.xslt 
    # Part of:      	Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:       	Ian McQuay <ian_mcquay.org>
    # Created:      	2014- -
    # Copyright:    	(c) 2013 SIL International
    # Licence:      	<LGPL>
    ################################################################-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:include href="inc-file2uri.xslt"/>
      <xsl:param name="projectpath"/>
      <xsl:variable name="projecturi" select="f:file2uri(concat($projectpath,'/project.txt'))"/>
      <xsl:variable name="projecttask" select="f:file2lines(concat($projectpath,'/project.txt'))"/>
      <!-- <xsl:variable name="projecttask" select="tokenize(unparsed-text($projecttaskuri),'\r?\n')"/> -->
      <xsl:variable name="cd" select="substring-before($projectpath,'\data\')"/>
      <xsl:variable name="varparser" select="'^([^;]+);([^ ]+)[ \t]+([^ \t]+)[ \t]+(.+)'"/>
      <xsl:variable name="var" select="tokenize('var xvar',' ')"/>
      <xsl:variable name="sq">
            <xsl:text>'</xsl:text>
      </xsl:variable>
      <xsl:variable name="apos">
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
                        <!-- copy the root folder files pub.cmd and local_var.cmd -->
                        <xsl:if test="matches(.,'=')">
                              <xsl:call-template name="parseline">
                                    <xsl:with-param name="line" select="."/>
                                    <xsl:with-param name="curpos" select="position()"/>
                              </xsl:call-template>
                        </xsl:if>
                  </xsl:for-each>
            </xsl:element>
      </xsl:template>
      <xsl:template name="parseline">
            <xsl:param name="line"/>
            <xsl:param name="curpos"/>
            <xsl:variable name="varname" select="tokenize($line,'=')[1]"/>
            <xsl:variable name="vardata" select="substring-after($line,'=')"/>
            <xsl:choose>
                  <xsl:when test="matches($varname,'^\[.*$')">
                        <!-- matches ini section -->
                        <xsl:element name="xsl:variable">
                              <xsl:attribute name="name">
                                    <xsl:value-of select="concat('comment',$curpos)"/>
                              </xsl:attribute>
                              <xsl:attribute name="select">
                                    <xsl:text>'</xsl:text>
                                    <xsl:value-of select="$line"/>
                                    <xsl:text>'</xsl:text>
                              </xsl:attribute>
                        </xsl:element>
                  </xsl:when>
                  <xsl:otherwise>
                        <!-- matches name=value line -->
                        <!--<xsl:element name="xsl:variable">
                              <xsl:attribute name="name">
                                    <xsl:value-of select="varname"/>
                              </xsl:attribute>
                              <xsl:attribute name="select">
                                    <xsl:text>'</xsl:text>
                                    <xsl:value-of select="$vardata"/>
                                    <xsl:text>'</xsl:text>
                              </xsl:attribute>
                        </xsl:element> -->
                        <xsl:choose>
                              <xsl:when test="matches($varname,'_list$')">
                                    <xsl:variable name="newname" select="replace($varname,'_list','')"/>
                                    <xsl:element name="xsl:variable">
                                          <xsl:attribute name="name">
                                                <xsl:value-of select="$newname"/>
                                          </xsl:attribute>
                                          <xsl:attribute name="select">
                                                <xsl:value-of select="concat('tokenize($',$varname,',',$apos,'\s+',$apos,')')"/>
                                          </xsl:attribute>
                                    </xsl:element>
                              </xsl:when>
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
                              <xsl:when test="matches($varname,'_semicolon-list$')">
                                    <!-- semicolon delimited list -->
                                    <xsl:element name="xsl:variable">
                                          <xsl:attribute name="name">
                                                <xsl:value-of select="replace($varname,'_semicolon-list','')"/>
                                          </xsl:attribute>
                                          <xsl:attribute name="select">
                                                <xsl:value-of select="concat('tokenize($',$varname,',',$apos,';',$apos,')')"/>
                                          </xsl:attribute>
                                    </xsl:element>
                                    <!--  now test if there are = in the list and make a key list -->
                                    <xsl:choose>
                                          <xsl:when test="unparsed-text-available($projecturi)">
                                                <xsl:variable name="projecttask" select="tokenize(unparsed-text($projecturi),'\r?\n')"/>
                                                <xsl:for-each select="$projecttask">
                                                      <!-- copy the root folder files pub.cmd and local_var.cmd -->
                                                      <xsl:call-template name="parseline">
                                                            <xsl:with-param name="line" select="."/>
                                                            <xsl:with-param name="curpos" select="$curpos"/>
                                                      </xsl:call-template>
                                                </xsl:for-each>
                                          </xsl:when>
                                          <xsl:otherwise>
                                                <xsl:text disable-output-escaping="yes">&lt;!-- </xsl:text>
                                                <!-- <xsl:value-of select="$command"/> -->
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="$varname"/>
                                                <xsl:text disable-output-escaping="yes"> not found --&gt;</xsl:text>
                                          </xsl:otherwise>
                                    </xsl:choose>
                              </xsl:when>
                              <xsl:otherwise>
                                    <!-- variable line
                                    <xsl:element name="xsl:variable">
                                          <xsl:attribute name="name">
                                                <xsl:value-of select="$label"/>
                                          </xsl:attribute>
                                          <xsl:value-of select="$comment"/>
                                    </xsl:element> -->
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:call-template name="writeparam">
                                          <xsl:with-param name="varname" select="$varname"/>
                                          <xsl:with-param name="iscommand">
                                                <xsl:choose>
                                                      <xsl:when test="matches($vardata,'%')">
                                                            <xsl:text>true</xsl:text>
                                                      </xsl:when>
                                                      <xsl:otherwise/>
                                                </xsl:choose>
                                          </xsl:with-param>
                                          <xsl:with-param name="vardata">
                                                <xsl:choose>
                                                      <!--<xsl:when test="matches($vardata,'%semicolon%')">
                                                            <xsl:text>';'</xsl:text>
                                                      </xsl:when> -->
                                                      <xsl:when test="matches($vardata,'^&#34;?%[\w\d\-_]+:.*=.*%&#34;?$')">
                                                            <!-- Matches batch variable with a find and replace structure -->
                                                            <xsl:variable name="re" select="'^&#34;?%([\w\d\-_]+):(.*)=(.*)%&#34;?$'"/>
                                                            <xsl:text>replace(</xsl:text>
                                                            <xsl:value-of select="replace($vardata,$re,'\$$1')"/>
                                                            <xsl:text>,'</xsl:text>
                                                            <xsl:value-of select="replace($vardata,$re,'$2')"/>
                                                            <xsl:text>','</xsl:text>
                                                            <xsl:value-of select="replace($vardata,$re,'$3')"/>
                                                            <xsl:text>')</xsl:text>
                                                      </xsl:when>
                                                      <xsl:when test="matches($vardata,'%[\w\d\-_]+%')">
                                                            <!-- variable -->
                                                            <xsl:text>concat(</xsl:text>
                                                            <xsl:analyze-string select="replace($vardata,'&#34;','')" regex="%[\w\d\-_]+%">
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
                                                            <xsl:text>)</xsl:text>
                                                      </xsl:when>
                                                      <xsl:otherwise>
                                                            <xsl:value-of select="replace($vardata,'&#34;','')"/>
                                                      </xsl:otherwise>
                                                </xsl:choose>
                                          </xsl:with-param>
                                    </xsl:call-template>
                              </xsl:otherwise>
                        </xsl:choose>
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
                              <xsl:value-of select="concat('tokenize($',$varname,',',$apos,'\s+',$apos,')')"/>
                        </xsl:attribute>
                  </xsl:element>
                  <xsl:if test="matches($vardata,'=')">
                        <xsl:element name="xsl:variable">
                              <xsl:attribute name="name">
                                    <xsl:value-of select="replace($varname,'_list','-key')"/>
                              </xsl:attribute>
                              <xsl:attribute name="select">
                                    <xsl:value-of select="concat('tokenize($',$varname,',',$apos,'=[^\s]+\s?',$apos,')')"/>
                              </xsl:attribute>
                        </xsl:element>
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
                              <xsl:value-of select="concat('tokenize($',$varname,',',$apos,'_',$apos,')')"/>
                        </xsl:attribute>
                  </xsl:element>
                  <xsl:if test="matches($vardata,'=')">
                        <xsl:element name="xsl:variable">
                              <xsl:attribute name="name">
                                    <xsl:value-of select="replace($varname,'_underscore-list','-key')"/>
                              </xsl:attribute>
                              <xsl:attribute name="select">
                                    <xsl:value-of select="concat('tokenize($',$varname,',',$apos,'=[^_]+_?',$apos,')')"/>
                              </xsl:attribute>
                        </xsl:element>
                  </xsl:if>
            </xsl:if>
            <xsl:if test="matches($varname,'_equal-list$')">
                  <!-- equals delimited list -->
                  <xsl:element name="xsl:variable">
                        <xsl:attribute name="name">
                              <xsl:value-of select="replace($varname,'_equal-list','')"/>
                        </xsl:attribute>
                        <xsl:attribute name="select">
                              <xsl:value-of select="concat('tokenize($',$varname,',',$apos,'=',$apos,')')"/>
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
                              <xsl:value-of select="concat('tokenize($',$varname,',',$apos,';',$apos,')')"/>
                        </xsl:attribute>
                  </xsl:element>
                  <!--  now test if there are = in the list and make a key list -->
                  <xsl:if test="matches($vardata,'=')">
                        <xsl:variable name="key" select="tokenize($vardata,'=.*_?')"/>
                        <xsl:element name="xsl:variable">
                              <xsl:attribute name="name">
                                    <xsl:value-of select="replace($varname,'_semicolon-list','-key')"/>
                              </xsl:attribute>
                              <xsl:attribute name="select">
                                    <xsl:value-of select="concat('tokenize($',$varname,',',$apos,'=[^;]+;?',$apos,')')"/>
                              </xsl:attribute>
                        </xsl:element>
                  </xsl:if>
            </xsl:if>
      </xsl:template>
</xsl:stylesheet>
