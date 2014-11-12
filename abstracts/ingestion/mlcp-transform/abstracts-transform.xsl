<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:cabi="http://namespaces.cabi.org/namespaces/cabi"
	xmlns="http://namespaces.cabi.org/namespaces/cabi"
	>

	<xsl:template match="/records">
		<xsl:apply-templates select="record"/>
	</xsl:template>

	<xsl:template match="record">
		<cabi-abstract>
			<xsl:apply-templates/>
		</cabi-abstract>
	</xsl:template>

	<!-- Top-level elements (children of root -->
	<xsl:template match="an">
		<xsl:call-template name="backslash-split"><xsl:with-param name="element-name">abstract-number</xsl:with-param><xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param></xsl:call-template>
	</xsl:template>

	<xsl:template match="pa">
		<uri>urn:cabi.org:id:abstracts:pan:<xsl:value-of select="."/></uri>
		<pan><xsl:value-of select="."/></pan>
	</xsl:template>

	<xsl:template match="nd">
		<and><xsl:value-of select="."/></and>
	</xsl:template>

	<xsl:template match="bt">
		<xsl:call-template name="backslash-split"><xsl:with-param name="element-name">batch-name</xsl:with-param><xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param></xsl:call-template>
	</xsl:template>


	<xsl:template match="bibl">
		<bibliographic>
			<xsl:apply-templates select="it"/>
			<xsl:apply-templates select="do"/>
			<xsl:apply-templates select="ct"/>
			<xsl:apply-templates select="cl"/>
			<xsl:apply-templates select="et"/>
			<xsl:apply-templates select="ft"/>
			<xsl:apply-templates select="at"/>
			<xsl:apply-templates select="." mode="author-list">
				<xsl:with-param name="emails" select="em"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="ed" mode="editor-list"/>
			<xsl:apply-templates select="." mode="publication-info"/>
			<xsl:apply-templates select="index"/>

			<xsl:apply-templates select="*" mode="unknown"/>
		</bibliographic>
	</xsl:template>

	<xsl:template match="ab"><abstract-text><xsl:copy-of select="@*|node()"/></abstract-text></xsl:template>
	<xsl:template match="ex">
		<xsl:choose>
			<xsl:when test="matches(., '^[0-9]{8}$')">
				<export-date><xsl:value-of select="substring(., 1, 4)"/>-<xsl:value-of select="substring(., 5, 2)"/>-<xsl:value-of select="substring(., 7, 2)"/></export-date>
			</xsl:when>
			<xsl:when test="matches(., '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')">
				<export-date><xsl:copy-of select="@*|node()"/></export-date>
			</xsl:when>
			<xsl:otherwise>
				<UNMAPPABLE-EXPORT-DATE><xsl:copy-of select="@*|node()"/></UNMAPPABLE-EXPORT-DATE>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="co">
		<xsl:variable name="str" select="string(.)"/>
		<abstract-copyright>
			<xsl:if test="matches($str, '^[12][0-9][0-9][0-9]\s.*')">
				<xsl:attribute name="year"><xsl:value-of select="substring($str, 1, 4)"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="matches($str, '^.\s[12][0-9][0-9][0-9]\s.*')">
				<xsl:attribute name="year"><xsl:value-of select="substring($str, 3, 4)"/></xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@*|node()"/>
		</abstract-copyright>
	</xsl:template>

	<!-- Bibliographic -->
	<xsl:template match="it">
		<item-type><xsl:value-of select="."/></item-type>
	</xsl:template>

	<xsl:template match="do">
		<document-title><xsl:value-of select="."/></document-title>
	</xsl:template>

	<xsl:template match="ct">
		<conference-title><xsl:value-of select="."/></conference-title>
	</xsl:template>

	<xsl:template match="cl">
		<conference-location><xsl:value-of select="."/></conference-location>
	</xsl:template>

	<xsl:template match="et">
		<item-title xml:lang="en"><xsl:value-of select="."/></item-title>
	</xsl:template>

	<xsl:template match="ft">
		<non-english-title><xsl:value-of select="."/></non-english-title>
	</xsl:template>

	<xsl:template match="at">
		<additional-title-info><xsl:value-of select="."/></additional-title-info>
	</xsl:template>

	<xsl:template match="ed" mode="editor-list">
		<editors>
			<xsl:apply-templates select="*" mode="author-name">
				<xsl:with-param name="element-name">editor</xsl:with-param>
			</xsl:apply-templates>
		</editors>
	</xsl:template>

	<xsl:template match="bibl" mode="author-list">
		<xsl:param name="emails"/>
		<authors>
			<xsl:apply-templates select="au" mode="author-name">
				<xsl:with-param name="emails" select="$emails"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="ad" mode="author-name"/>
			<xsl:apply-templates select="av" mode="author-name"/>
			<xsl:apply-templates select="ca" mode="author-name"/>
		</authors>
	</xsl:template>

	<xsl:template match="ad" mode="author-name">
		<xsl:for-each select="tokenize(., '\\')" >
			<additional-author>
				<display-name><xsl:value-of select="."/></display-name>
			</additional-author>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="av" mode="author-name">
		<xsl:for-each select="tokenize(., '\\')" >
			<author-variant>
				<display-name><xsl:value-of select="."/></display-name>
			</author-variant>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="au|ca" mode="author-name">
		<xsl:param name="emails"/>
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="local-name(.) = 'au'">author</xsl:when>
				<xsl:when test="local-name(.) = 'ca'">corporate-author</xsl:when>
				<xsl:otherwise>UNRECOGNIZED-AUTHOR-ELEMENT</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates select="*" mode="author-name">
			<xsl:with-param name="emails" select="$emails"/>
			<xsl:with-param name="element-name" select="$element-name"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- This code correlates email addresses (in bibl/em elements) to authors by relative position.
		That may not always be correct, but works for one email, which is the most common case. -->
	<xsl:template match="*" mode="author-name">
		<xsl:param name="emails"/>
		<xsl:param name="element-name">author</xsl:param>
		<xsl:variable name="pos" select="position()"/>
		<xsl:element name="{$element-name}">
			<display-name><xsl:value-of select="."/></display-name>
			<xsl:if test="exists($emails[$pos])">
				<email><xsl:value-of select="$emails[$pos]"/></email>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- Bibliographic/Publication Info -->
	<xsl:template match="bibl" mode="publication-info">
		<publication-info>
			<xsl:apply-templates select="oi" mode="publication-info"/>
			<xsl:apply-templates select="ur" mode="publication-info"/>
			<!-- ToDo: Publisher copyright name and year -->
			<xsl:apply-templates select="yr" mode="publication-info"/>
			<xsl:apply-templates select="vl" mode="publication-info"/>
			<xsl:apply-templates select="no" mode="publication-info"/>
			<xsl:apply-templates select="pp" mode="publication-info"/>
			<xsl:apply-templates select="sn" mode="publication-info"/>
			<xsl:apply-templates select="bn" mode="publication-info"/>
			<xsl:apply-templates select="la" mode="publication-info"/>
			<xsl:apply-templates select="re" mode="publication-info"/>
			<xsl:apply-templates select="ms" mode="publication-info"/>
			<xsl:apply-templates select="." mode="affiliation-info"/>
			<xsl:apply-templates select="." mode="publisher-info"/>

			<xsl:apply-templates select="*" mode="unknown"/>
		</publication-info>
	</xsl:template>

	<xsl:template match="oi" mode="publication-info"><doi><xsl:value-of select="."/></doi></xsl:template>
	<xsl:template match="ur" mode="publication-info"><url><xsl:value-of select="."/></url></xsl:template>
	<xsl:template match="yr" mode="publication-info"><year><xsl:value-of select="."/></year></xsl:template>
	<xsl:template match="vl" mode="publication-info"><volume><xsl:value-of select="."/></volume></xsl:template>
	<xsl:template match="no" mode="publication-info"><issue><xsl:value-of select="."/></issue></xsl:template>
	<xsl:template match="pp" mode="publication-info"><page-range><xsl:value-of select="."/></page-range></xsl:template>
	<xsl:template match="sn" mode="publication-info"><issn><xsl:value-of select="."/></issn></xsl:template>
	<xsl:template match="bn" mode="publication-info">
		<xsl:call-template name="backslash-split"><xsl:with-param name="element-name">isbn</xsl:with-param><xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param></xsl:call-template>
	</xsl:template>
	<xsl:template match="la" mode="publication-info">
		<xsl:call-template name="backslash-split"><xsl:with-param name="element-name">language</xsl:with-param><xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param></xsl:call-template>
	</xsl:template>
	<xsl:template match="ms" mode="publication-info"><supplementary-information><xsl:value-of select="."/></supplementary-information></xsl:template>
	<xsl:template match="re" mode="publication-info">
		<number-of-references>
			<xsl:attribute name="orginal-content"><xsl:value-of select="."/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="matches(., '^\d+$')"><xsl:value-of select="."/></xsl:when>
				<xsl:when test="matches(., '^\d+ ref\.$')"><xsl:value-of select="tokenize(., '\s+')[1]"/></xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="cannot-parse">Cannot parse reference count</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</number-of-references>
	</xsl:template>

	<!-- Bibliographic/Affiliation info with a publication info block -->
	<xsl:template match="bibl" mode="affiliation-info">
		<affiliation>
			<xsl:apply-templates select="aa" mode="affiliation-info"/>
			<location>
				<address/>
			</location>
		</affiliation>
	</xsl:template>

	<xsl:template match="aa" mode="affiliation-info"><display><xsl:value-of select="."/></display></xsl:template>

	<!-- Bibliographic/Publisher Info -->
	<xsl:template match="bibl" mode="publisher-info">
		<publisher>
			<xsl:apply-templates select="pb" mode="publisher-info"/>
			<location>
				<address>
					<xsl:apply-templates select="lp" mode="publisher-info"/>
					<xsl:apply-templates select="cp" mode="publisher-info"/>
				</address>
			</location>
		</publisher>
	</xsl:template>

	<xsl:template match="pb" mode="publisher-info"><display><xsl:value-of select="."/></display></xsl:template>
	<xsl:template match="lp" mode="publisher-info"><city><xsl:value-of select="."/></city></xsl:template>
	<!-- ToDo: Need to lookup ISO2 code for iso2="cc" on country element -->
	<xsl:template match="cp" mode="publisher-info"><country><xsl:value-of select="."/></country></xsl:template>

	<!-- To catch unmatched pub-info nodes.  The first ignores any node that's been explicitly matched,
		the second catches anything not in the list.
		Update this XPath with any element names that have been explicitly matched for publication info
		processing.  Anything not in this list will be flagged as unhandled.
	-->
	<xsl:template match="do|it|et|ft|at|au|ad|av|ca|oi|yr|vl|no|pp|sn|ur|la|pb|aa|lp|cp|em|re|ms|bn|bt|ed|ct|cl" mode="unknown"/>
	<xsl:template match="*" mode="unknown">
			<UNHANDLED-ELEMENT>
				<xsl:copy-of select="."/>
			</UNHANDLED-ELEMENT>
	</xsl:template>

	<!-- Index / vocabulary-terms -->
	<xsl:template match="index">
		<vocabulary-terms>
			<xsl:apply-templates mode="vocab-terms"/>
		</vocabulary-terms>
	</xsl:template>

	<xsl:template match="de|gl|od|ry" mode="vocab-terms">
		<xsl:call-template name="backslash-split">
			<xsl:with-param name="element-name">preferred-term</xsl:with-param>
			<xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
			<xsl:with-param name="attr-name">vocab</xsl:with-param>
			<xsl:with-param name="attr-value"><xsl:value-of select="local-name(.)"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="id" mode="vocab-terms">
		<xsl:call-template name="backslash-split">
			<xsl:with-param name="element-name">alternate-term</xsl:with-param>
			<xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
			<xsl:with-param name="attr-name">vocab</xsl:with-param>
			<xsl:with-param name="attr-value"><xsl:value-of select="local-name(.)"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="up" mode="vocab-terms">
		<xsl:call-template name="backslash-split">
			<xsl:with-param name="element-name">ancestor-term</xsl:with-param>
			<xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
			<xsl:with-param name="attr-name">vocab</xsl:with-param>
			<xsl:with-param name="attr-value"><xsl:value-of select="local-name(.)"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*" mode="vocab-terms">
		<xsl:variable name="vocab">
			<xsl:choose>
				<xsl:when test="local-name(.) = 'cc'">cabicode</xsl:when>
				<xsl:when test="local-name(.) = 'sc'">cabisubject</xsl:when>
				<xsl:otherwise><xsl:value-of select="local-name(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="backslash-split">
			<xsl:with-param name="element-name">term</xsl:with-param>
			<xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
			<xsl:with-param name="attr-name">vocab</xsl:with-param>
			<xsl:with-param name="attr-value"><xsl:value-of select="$vocab"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- catchall -->
	<xsl:template match="*">
		<UNHANDLED-ELEMENT>
			<xsl:copy-of select="."/>
		</UNHANDLED-ELEMENT>
	</xsl:template>

	<!-- =================================================================== -->

	<xsl:template name="backslash-split">
		<xsl:param name="element-name"/>
		<xsl:param name="value"/>
		<xsl:param name="attr-name" required="no">__none__</xsl:param>
		<xsl:param name="attr-value" required="no"/>
		<xsl:for-each select="tokenize($value, '\\')">
			<xsl:element name="{$element-name}">
				<xsl:if test="$attr-name ne '__none__'">
					<xsl:attribute name="{$attr-name}"><xsl:value-of select="$attr-value"/></xsl:attribute>
				</xsl:if>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>