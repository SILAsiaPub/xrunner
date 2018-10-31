<?xml version="1.0"?>
<!--
    #############################################################
    # Name:         usx2usx-context.xslt
    # Purpose:      Combine multiple USX files and parse words.
    # Part of:      Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:       Ian McQuay <ian_mcquay@sil.org>
    # Created:      2018-10-28
    # Copyright:    (c) 2018 SIL International
    # Licence:      <MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:include href='inc-copy-anything.xslt'/>
      <!-- <xsl:include href="inc-file2uri.xslt"/> -->
      <!-- <xsl:include href="inc-list2xml-xattrib.xslt"/> -->
      <!-- <xsl:include href="inc-lookup.xslt"/> -->
      <xsl:include href="project.xslt"/>
      <xsl:strip-space elements="*"/>
      <!-- <xsl:param name="usxpath"/> -->
      <!-- <xsl:param name="bookorderfile"/> -->
      <xsl:variable name="bookorder" select="f:file2lines($bookorderfile)"/>
      <!-- <xsl:variable name="bookorderlist" select="unparsed-text($bookorderuri)"/> -->
      <xsl:variable name="usxpathuri" select="f:file2uri($usxpath)"/>
      <xsl:variable name="collection" select="collection(concat($usxpathuri,'?select=',$collectionfile))"/>
      <xsl:variable name="groupnodes" select="tokenize($groupnodelist,'\s+')"/>
      <!--<xsl:variable name="usxseq">
            <xsl:call-template name="list2xmlxattrib">
                  <xsl:with-param name="text" select="$bookorderlist"/>
                  <xsl:with-param name="attribnamelist" select="'seq book chapters'"/>
            </xsl:call-template>
      </xsl:variable> -->
      <xsl:output method="xml" encoding="utf-8" indent="yes"/>
      <xsl:template match="/">
            <data>
                  <xsl:for-each select="$collection/usx">
                        <xsl:sort select="number(f:position($include-book,string(book/@code)))"/>
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:variable name="book" select="string(book/@code)"/>
                        <xsl:if test="$book = $include-book">
                              <xsl:copy>
                                    <xsl:attribute name="book">
                                          <xsl:value-of select="$book"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="seq">
                                          <xsl:value-of select="f:position($include-book,$book)"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="info">
                                          <xsl:value-of select="book"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="@*|node()"/>
                              </xsl:copy >
                        </xsl:if>
                  </xsl:for-each>
            </data>
      </xsl:template>
      <xsl:template match="*[local-name() = $remove-element]" priority="2000"/>
      <xsl:template match="*[@style = $del-ec-attrib-value]" priority="1000"/>
      <xsl:template match="para[not(@style = $del-ec-attrib-value)]" priority="1000">
            <xsl:copy>
                  <xsl:apply-templates select="@*"/>
            </xsl:copy>
            <xsl:apply-templates select="node()"/>
      </xsl:template>
      <xsl:template match="text()" priority="1000">
            <xsl:analyze-string select="." regex="[\w\-]+">
<!-- ([^\w\-]*)([\w\-]+)([^\w\-]*) -->
                  <xsl:matching-substring>
                        <!-- <xsl:if test="$incSeq = $true"> -->
                        <!-- </xsl:if> -->
                        <xsl:choose>
                              <xsl:when test="matches(.,'^\d+')">
                                     <!-- <w s="{regex-group(2)}" o="0"/> -->
                                    <w s="{.}" o="0"/>
                              </xsl:when>
                              <xsl:when test="matches(.,'^\W')">
                                     <!-- <w s="{regex-group(2)}" o="{lower-case(substring(regex-group(2),2,1))}"/> -->
                                    <w s="{.}" o="{lower-case(substring(.,2,1))}"/>
                              </xsl:when>
                              <xsl:otherwise>
                                     <!-- <w s="{regex-group(2)}" o="{lower-case(substring(regex-group(2),1,1))}"/> -->
                                    <w s="{.}" o="{lower-case(substring(.,1,1))}"/>
                              </xsl:otherwise>
                        </xsl:choose>
                        <!-- <xsl:if test="$incSeq = $true"> -->
                        <!-- <xsl:if test="string-length(regex-group(3)) gt 0"> -->
                        <!-- <nw s="{regex-group(3)}"/> -->
                        <!-- </xsl:if> -->
                        <!-- </xsl:if> -->
                        <!-- <xsl:text> </xsl:text> -->
                  </xsl:matching-substring>
                  <xsl:non-matching-substring>
                        <xsl:if test="string-length(.) gt 0">
                              <nw s="{.}"/>
                        </xsl:if>
                  </xsl:non-matching-substring>
            </xsl:analyze-string>
      </xsl:template>
      <!-- <xsl:function name="f:sequence">
            <xsl:param name="string"/>
            <xsl:choose>
                  <xsl:when test="$string = $usxseq/element/@book">
                        <xsl:variable name="seq" select="$usxseq/element[@book = $string]/@seq"/>
                        <xsl:value-of select="$seq"/>
                  </xsl:when>
                  <xsl:otherwise>
                        <xsl:text>1000</xsl:text>
                  </xsl:otherwise>
            </xsl:choose>
      </xsl:function> -->
</xsl:stylesheet>
