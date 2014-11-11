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

	<xsl:template match="pa">
		<uri>urn:cabi.org:id:abstracts:pan:<xsl:value-of select="."/></uri>
		<pan><xsl:value-of select="."/></pan>
	</xsl:template>

	<xsl:template match="bibl">
		<bibliographic>
			<xsl:apply-templates select="it"/>
			<xsl:apply-templates select="do"/>
			<xsl:apply-templates select="et"/>
			<xsl:apply-templates select="au">
				<xsl:with-param name="emails" select="em"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="." mode="publication-info"/>
			<xsl:apply-templates select="index"/>
		</bibliographic>
	</xsl:template>

	<xsl:template match="ab"><abstract-text><xsl:copy-of select="@*|node()"/></abstract-text></xsl:template>
	<xsl:template match="ex"><export-date><xsl:copy-of select="@*|node()"/></export-date></xsl:template>
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

	<xsl:template match="et">
		<item-title xml:lang="en"><xsl:value-of select="."/></item-title>
	</xsl:template>

	<xsl:template match="au">
		<xsl:param name="emails"/>
		<authors>
			<xsl:apply-templates select="*" mode="author-name">
				<xsl:with-param name="emails" select="$emails"/>
			</xsl:apply-templates>
			<!--<xsl:apply-templates select="*[position() ne 1]" mode="author-name"/>-->
		</authors>
	</xsl:template>

	<!-- This code correlates email addresses (in bibl/em elements) to authors by relative position.
		That may not always be correct, but works for one email, which is the most common case. -->
	<xsl:template match="*" mode="author-name">
		<xsl:param name="emails"/>
		<xsl:variable name="pos" select="position()"/>
		<author>
			<display-name><xsl:value-of select="."/></display-name>
			<xsl:if test="exists($emails[$pos])">
				<email><xsl:value-of select="$emails[$pos]"/></email>
			</xsl:if>
		</author>
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
			<xsl:apply-templates select="la" mode="publication-info"/>
			<xsl:apply-templates select="re" mode="publication-info"/>
			<xsl:apply-templates select="." mode="institution-info"/>

			<xsl:apply-templates select="*" mode="publication-info-unknown"/>
		</publication-info>
	</xsl:template>

	<!-- Institution info with a publication info block -->
	<xsl:template match="bibl" mode="institution-info">
		<institution>
			<xsl:apply-templates select="pb" mode="institution-info"/>
			<xsl:apply-templates select="em" mode="institution-info"/>
			<location>
				<address>
					<xsl:apply-templates select="aa" mode="institution-info"/>
					<xsl:apply-templates select="lp" mode="institution-info"/>
					<xsl:apply-templates select="cp" mode="institution-info"/>
				</address>
			</location>
		</institution>
	</xsl:template>

	<xsl:template match="oi" mode="publication-info"><doi><xsl:value-of select="."/></doi></xsl:template>
	<xsl:template match="ur" mode="publication-info"><url><xsl:value-of select="."/></url></xsl:template>
	<xsl:template match="yr" mode="publication-info"><year><xsl:value-of select="."/></year></xsl:template>
	<xsl:template match="vl" mode="publication-info"><year><xsl:value-of select="."/></year></xsl:template>
	<xsl:template match="no" mode="publication-info"><issue><xsl:value-of select="."/></issue></xsl:template>
	<xsl:template match="pp" mode="publication-info"><page-range><xsl:value-of select="."/></page-range></xsl:template>
	<xsl:template match="sn" mode="publication-info"><issn><xsl:value-of select="."/></issn></xsl:template>
	<xsl:template match="la" mode="publication-info"><language><xsl:value-of select="."/></language></xsl:template>
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

	<xsl:template match="pb" mode="institution-info"><name><xsl:value-of select="."/></name></xsl:template>
	<xsl:template match="aa" mode="institution-info"><display><xsl:value-of select="."/></display></xsl:template>
	<xsl:template match="lp" mode="institution-info"><city><xsl:value-of select="."/></city></xsl:template>
	<!-- ToDo: Need to lookup ISO2 code for iso2="cc" on country element -->
	<xsl:template match="cp" mode="institution-info"><country><xsl:value-of select="."/></country></xsl:template>

	<!-- To catch unmatched pub-info nodes.  The first ignores any node that's been explicitly matched,
		the second catches anything not in the list.
		Update this XPath with any element names that have been explicitly matched for publication info
		processing.  Anything not in this list will be flagged as unhandled.
	-->
	<xsl:template match="do|it|et|au|oi|yr|vl|no|pp|sn|ur|la|pb|aa|lp|cp|em|re" mode="publication-info-unknown"/>
	<xsl:template match="*" mode="publication-info-unknown">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- Index / vocabulary-terms -->
	<xsl:template match="index">
		<vocabulary-terms>
			<xsl:apply-templates mode="vocab-terms"/>
		</vocabulary-terms>
	</xsl:template>

	<xsl:template match="de|gl" mode="vocab-terms">
		<xsl:variable name="vocab" select="local-name(.)"/>
		<xsl:for-each select="tokenize(., '\\')" >
			<preferred-term vocab="{$vocab}"><xsl:value-of select="."/></preferred-term>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="id" mode="vocab-terms">
		<xsl:variable name="vocab" select="local-name(.)"/>
		<xsl:for-each select="tokenize(., '\\')" >
			<alternate-term vocab="{$vocab}"><xsl:value-of select="."/></alternate-term>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="up" mode="vocab-terms">
		<xsl:variable name="vocab" select="local-name(.)"/>
		<xsl:for-each select="tokenize(., '\\')" >
			<ancestor-term vocab="{$vocab}"><xsl:value-of select="."/></ancestor-term>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="vocab-terms">
		<xsl:variable name="vocab">
			<xsl:choose>
				<xsl:when test="local-name(.) = 'cc'">cabicode</xsl:when>
				<xsl:when test="local-name(.) = 'sc'">cabisubject</xsl:when>
				<xsl:otherwise><xsl:value-of select="local-name(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="tokenize(., '\\')" >
			<term vocab="{$vocab}"><xsl:value-of select="."/></term>
		</xsl:for-each>
	</xsl:template>

	<!-- catchall -->
	<xsl:template match="*">
		<cabi:UNHANDLED>
			<xsl:copy-of select="."/>
		</cabi:UNHANDLED>
	</xsl:template>

</xsl:stylesheet>