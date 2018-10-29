<!--
    #############################################################
    # Name:		generic-grouping-start-with-list.xslt
    # Purpose:	Used to group via a list of sibling elements. 
    # Part of:      	Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:       	Ian McQuay <ian_mcquay.org>
    # Created:      	2012-06-14
    # Modified:	2013-09-04 2014-04-01 changed xml var to tokenize()
    # Copyright:    (c) 2013 SIL International
    # Licence:      	<LGPL>
    ################################################################
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
      <xsl:output method="xml" indent="yes"/>
      <xsl:include href='inc-copy-anything.xslt'/>
      <xsl:param name="parentnode"/>
      <xsl:param name="groupnodelist"/>
      <xsl:variable name="groupnodes" select="tokenize($groupnodelist,'\s+')"/>
      <xsl:template match="*[local-name() = $parentnode]">
            <xsl:copy>
                  <xsl:apply-templates select="@*"/>
                  <xsl:for-each-group select="node()" group-starting-with="*[local-name() = $groupnodes]">
                        <!-- Changed the select from select="*" to 'node()" so text nodes were included -->
                        <xsl:choose>
                              <xsl:when test="preceding-sibling::*[local-name() != $groupnodes] or self::*[local-name() = $groupnodes]">
                                    <xsl:element name="{local-name()}Group">
                                          <xsl:apply-templates select="current-group()"/>
                                    </xsl:element>
                              </xsl:when>
                              <xsl:otherwise>
                                    <xsl:apply-templates select="current-group()"/>
                              </xsl:otherwise>
                        </xsl:choose>
                  </xsl:for-each-group>
            </xsl:copy >
      </xsl:template>
</xsl:stylesheet>
