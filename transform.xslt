<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="canRoam/text()">true</xsl:template>
  <xsl:template match="assignedNode"/>
  <xsl:template match="hudson.plugins.promoted__builds.PromotionProcess/assignedLabel"/>
  <xsl:template match="jdk/text()">jdk-8-jce</xsl:template>
  <xsl:template match="builders/hudson.tasks.Maven/settings[contains(@class, 'jenkins.mvn.DefaultSettingsProvider')]">
    <settings class="org.jenkinsci.plugins.configfiles.maven.job.MvnSettingsProvider" plugin="config-file-provider@2.10.1">
      <settingsConfigId>org.jenkinsci.plugins.configfiles.maven.MavenSettingsConfig1356080761741</settingsConfigId>
    </settings>
  </xsl:template>
  <xsl:template match="builders/hudson.tasks.Maven/jvmOptions/text()">-Dhttps.protocols=TLSv1.1,TLSv1.2</xsl:template>
  <xsl:template match="builders/hudson.tasks.Maven[not(jvmOptions)]">
    <xsl:copy>
      <xsl:copy-of select="node()|@*"/>
      <jvmOptions>-Dhttps.protocols=TLSv1.1,TLSv1.2</jvmOptions>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="buildWrappers/hudson.plugins.build__timeout.BuildTimeoutWrapper/strategy[contains(@class, 'hudson.plugins.build_timeout.impl.AbsoluteTimeOutStrategy')]/timeoutMinutes/text()">90</xsl:template>
  <xsl:template match="buildWrappers[not(hudson.plugins.build__timeout.BuildTimeoutWrapper)]">
    <xsl:copy>
      <xsl:copy-of select="node()|@*"/>
      <hudson.plugins.build__timeout.BuildTimeoutWrapper plugin="build-timeout@1.16">
        <strategy class="hudson.plugins.build_timeout.impl.AbsoluteTimeOutStrategy">
          <timeoutMinutes>90</timeoutMinutes>
        </strategy>
        <operationList/>
      </hudson.plugins.build__timeout.BuildTimeoutWrapper>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
