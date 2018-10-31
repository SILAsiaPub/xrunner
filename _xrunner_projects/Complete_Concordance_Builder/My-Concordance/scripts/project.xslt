<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:f="myfunctions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"
                exclude-result-prefixes="f">
   <xsl:include href="inc-file2uri.xslt"/>
   <xsl:include href="inc-lookup.xslt"/>
   <xsl:include href="xrun.xslt"/>
   <xsl:variable name="projectpath"
                 select="'D:\All-SIL-Publishing\github-SILAsiaPub\xrunner\trunk\_xrunner_projects\Complete_Concordance_Builder\My-Concordance'"/>
   <xsl:variable name="sq">'</xsl:variable>
   <xsl:variable name="dq">"</xsl:variable>
   <xsl:param name="title" select="'LANGNAME Concordance'"/>
   <xsl:param name="iso" select="'iso'"/>
   <xsl:param name="langname" select="replace($title,' Concordance','')"/>
   <xsl:param name="subtitle" select="''"/>
   <xsl:param name="max-word-occurance-count" select="'1600'"/>
   <xsl:param name="min-word-length" select="'2'"/>
   <xsl:param name="compiler" select="concat($langname,' Translation Team  ','')"/>
   <xsl:param name="publisher" select="concat($langname,' Language Association','')"/>
   <xsl:param name="publication-date" select="'2018'"/>
   <xsl:param name="verso-top"
              select="concat('This concordance omits words less than ',$min-word-length,' letters in length and words occuring more than ',$max-word-occurance-count,' times.','')"/>
   <xsl:param name="verso-rights" select="'Public Domain'"/>
   <xsl:param name="verso-bottom"
              select="'Concordance builder: Xrunner Concordance Builder_https://github.com/SILAsiaPub/xrunner_Typesetting engine: PrinceXML_http://princexml.com'"/>
   <xsl:param name="titlepage-image" select="'../css/image.jpg'"/>
   <xsl:param name="ignorechar" select="concat($sq,'')"/>
   <xsl:param name="voltitle" select="concat($title,'')"/>
   <xsl:param name="booknamessource"
              select="concat('D:\My Paratext 8 Projects\',$iso,'\BookNames.xml','')"/>
   <xsl:param name="include-book_list"
              select="'GEN EXO LEV NUM DEU JOS JDG RUT 1SA 2SA 1KI 2KI 1CH 2CH EZR NEH EST JOB PSA PRO ECC SNG ISA JER LAM EZK DAN HOS JOL AMO OBA JON MIC NAM HAB ZEP HAG ZEC MAL MAT MRK LUK JHN ACT ROM 1CO 2CO GAL EPH PHP COL 1TH 2TH 1TI 2TI TIT PHM HEB JAS 1PE 2PE 1JN 2JN 3JN JUD REV'"/>
   <xsl:variable name="include-book" select="tokenize($include-book_list,'\s+')"/>
   <xsl:param name="usxpath" select="concat($projectpath,'\usx','')"/>
   <xsl:param name="getabbrev" select="'abbr'"/>
   <xsl:param name="collectionfile" select="'*.usx'"/>
   <xsl:param name="groupnodelist" select="'book chapter'"/>
   <xsl:param name="bookorderfile"
              select="concat($projectpath,'\resources\book-chaps.txt','')"/>
   <xsl:param name="remove-element-content_list"
              select="'bookGroup note chapter figure'"/>
   <xsl:variable name="remove-element-content"
                 select="tokenize($remove-element-content_list,'\s+')"/>
   <xsl:param name="remove-element_list" select="'char'"/>
   <xsl:variable name="remove-element" select="tokenize($remove-element_list,'\s+')"/>
   <xsl:param name="del-ec-attrib-name" select="'style'"/>
   <xsl:param name="del-ec-attrib-value_list"
              select="'s s1 s2 s3 sp ms r mt mt1 mt2 mt3 restore d periph d bk sr'"/>
   <xsl:variable name="del-ec-attrib-value"
                 select="tokenize($del-ec-attrib-value_list,'\s+')"/>
   <xsl:param name="del-e-attrib-name" select="'style'"/>
   <xsl:param name="conccss" select="'../css/conc1.css'"/>
   <xsl:param name="concfrontmattercss" select="'../css/concfront.css'"/>
   <xsl:param name="xvarset_file-list" select="concat($projectpath,'\xvars.txt','')"/>
   <xsl:variable name="xvarset" select="f:file2lines($xvarset_file-list)"/>
   <xsl:param name="incSeq" select="'false'"/>
</xsl:stylesheet>