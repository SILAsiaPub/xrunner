<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions">
      <!--
    #############################################################
    # Name:  		sfm2xml-general-pv.xslt
    # Purpose:		Convert generic sfm to xml making use of project variables in project.xslt
    # Part of:      		Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:       	Ian McQuay <ian_mcquay@sil.org>
    # Created:      	2016- -
    # Copyright:    	(c) 2016 SIL International
    # Licence:      	<LGPL>
    ################################################################ -->
      <!-- 
Simple SFM to XML importer
This imports a sfm text and converts to a flat xml file.
It can import inline sfm codes. like \bd bold words\bd*
It is designed to remove _ occuring as the first character after the \ 
and to include the first line.
-->
      <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>
      <xsl:include href="inc-file2uri.xslt"/>
      <xsl:include href="project.xslt"/>
      <!-- <xsl:param name="sourcetextfile"/> -->
      <xsl:variable name="sourcetexturi" select="f:file2uri($sourcetextfile)"/>
      <xsl:template match="/">
            <xsl:element name="database">
                  <xsl:analyze-string select="replace(unparsed-text($sourcetexturi),'(\r)',' $1')" regex="\n\\">
                        <!-- split on backslash, add a space to the end of every line so every empty sfm can be found -->
                        <xsl:matching-substring/>
                        <xsl:non-matching-substring>
                              <xsl:choose>
                                    <xsl:when test="substring(.,1,1) = '\'">
                                          <!-- this is to handle the first line, often the \id line -->
                                          <xsl:element name="{substring-after(substring-before(.,' '),'\')}">
                                                <!-- create element with sfm marker as element name without first _ character -->
                                                <xsl:value-of select="normalize-space(substring-after(.,' '))"/>
                                                <!-- Output data folowing space after sfm marker -->
                                          </xsl:element>
                                    </xsl:when>
                                    <xsl:when test="substring(.,1,1) = '_'">
                                          <!-- this is to handle the sfm markers that start with an underscore _  -->
                                          <xsl:element name="{substring-after(substring-before(.,' '),'_')}">
                                                <!-- create element with sfm marker as element name without first _ character -->
                                                <xsl:value-of select="normalize-space(substring-after(.,' '))"/>
                                                <!-- Output data folowing space after sfm marker -->
                                          </xsl:element>
                                    </xsl:when>
                                    <xsl:when test="string-length(.) = 1">
                                          <!-- handle empty elements -->
                                          <xsl:element name="{.}"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                          <xsl:element name="{substring-before(.,' ')}">
                                                <!-- create element with sfm marker as element name -->
                                                <xsl:value-of select="normalize-space(substring-after(.,' '))"/>
                                                <!-- Output data folowing space after sfm marker -->
                                          </xsl:element>
                                    </xsl:otherwise>
                              </xsl:choose>
                        </xsl:non-matching-substring>
                  </xsl:analyze-string>
            </xsl:element>
      </xsl:template>
</xsl:stylesheet>
