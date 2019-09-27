<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="ead xlink"
>

  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="html" />

  <xsl:template match="/">
      <xsl:apply-templates />
  </xsl:template>

  <!--
  ~~~~~~~~~~~~~~~~~~~~~~~~
  Lists
  ~~~~~~~~~~~~~~~~~~~~~~~~
  -->

  <xsl:template match="list[@type='ordered']">
    <xsl:apply-templates select="head" />
    <ol><xsl:apply-templates select="item" /></ol>
  </xsl:template>

  <xsl:template match="list[@type='deflist']">
    <table class="table deflist">
      <xsl:apply-templates />
    </table>
  </xsl:template>

  <xsl:template match="list[@type='deflist']/listhead">
    <thead>
      <tr>
        <th scope="col">
          <xsl:apply-templates select="head01" />
        </th>
        <th scope="col">
          <xsl:apply-templates select="head02" />
        </th>
      </tr>
    </thead>
  </xsl:template>

  <xsl:template match="list">
    <xsl:apply-templates select="head"/>
    <ul><xsl:apply-templates select="item" /></ul>
  </xsl:template>

  <xsl:template match="defitem">
    <tr>
      <td><xsl:apply-templates select="label" /></td>
      <td><xsl:apply-templates select="item" /></td>
    </tr>
  </xsl:template>

  <xsl:template match="list/head">
    <strong><xsl:apply-templates /></strong>
  </xsl:template>

  <xsl:template match="list/item">
    <li><xsl:apply-templates /></li>
  </xsl:template>

  <!--
  ~~~~~~~~~~~~~~~~~~~~~~~~
  Chronlist
  ~~~~~~~~~~~~~~~~~~~~~~~~
  -->
  <xsl:template match="chronlist">
    <table class="table chronlist">
      <xsl:if test="head">
        <caption class="chronlist-head">
          <xsl:value-of select="head" />
        </caption>
      </xsl:if>
      <thead>
        <tr>
          <th scope="col">
            <xsl:choose>
                <xsl:when test="listhead/head01">
                    <xsl:apply-templates select="listhead/head01"/>
                </xsl:when>
                <xsl:otherwise>
                    Date
                </xsl:otherwise>
            </xsl:choose>
          </th>
          <th scope="col">
            <xsl:choose>
                <xsl:when test="listhead/head02">
                    <xsl:apply-templates select="listhead/head02"/>
                </xsl:when>
                <xsl:otherwise>
                    Event
                </xsl:otherwise>
            </xsl:choose>
          </th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="chronitem" />
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="chronlist/chronitem">
    <tr class="chronlist-item">
      <td class="chronlist-item-date"><xsl:apply-templates select="date"/></td>
      <td class="chronlist-item-event"><xsl:apply-templates select="descendant::event"/></td>
    </tr>
  </xsl:template>

  <xsl:template match="chronitem//event">
    <xsl:choose>
      <xsl:when test="following-sibling::*">
        <xsl:apply-templates /><br/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Misc render styles
  E.g., in <emph> or <title>
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -->

  <xsl:template match="emph[not(@render)]">
    <em><xsl:apply-templates /></em>
  </xsl:template>

  <xsl:template match="*[@render='bold']">
    <strong><xsl:value-of select="."/></strong>
  </xsl:template>

  <xsl:template match="*[@render='italic']">
    <em><xsl:value-of select="."/></em>
  </xsl:template>

  <xsl:template match="*[@render='sub']">
    <sub><xsl:value-of select="."/></sub>
  </xsl:template>

  <xsl:template match="*[@render='super']">
    <sup><xsl:value-of select="."/></sup>
  </xsl:template>

  <xsl:template match="*[@render='bolditalic']">
    <em><strong><xsl:value-of select="."/></strong></em>
  </xsl:template>

  <xsl:template match="*[@render='underline']">
    <span class="underline"><xsl:value-of select="."/></span>
  </xsl:template>

  <xsl:template match="*[@render='boldunderline']">
    <span class="underline"><strong><xsl:value-of select="."/></strong></span>
  </xsl:template>

  <xsl:template match="*[@render='doublequote']">
    "<xsl:value-of select="." />"
  </xsl:template>

  <xsl:template match="*[@render='bolddoublequote']">
    <strong>"<xsl:value-of select="." />"</strong>
  </xsl:template>

  <xsl:template match="*[@render='singlequote']">
    '<xsl:value-of select="." />'
  </xsl:template>

  <xsl:template match="*[@render='boldsinglequote']">
    <strong>'<xsl:value-of select="." />'</strong>
  </xsl:template>

  <xsl:template match="*[@render='smcaps']">
    <small class="text-uppercase"><xsl:value-of select="."/></small>
  </xsl:template>

  <xsl:template match="*[@render='boldsmcaps']">
    <small class="text-uppercase"><strong><xsl:value-of select="."/></strong></small>
  </xsl:template>

</xsl:stylesheet>
