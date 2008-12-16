<stylesheet version="1.0" 
xmlns="http://www.w3.org/1999/XSL/Transform">
<output method="text"/>

<template match="originalAirDate|episodeTitle|title|time|movieYear|seriesTitle|description|isEpisode|seriesId|episodeNumber|displayMajorNumber|callsign|displayMinorNumber|startTime|stopTime|vProgramGenre|vSeriesGenre">
  <value-of select="name()"/>
  <text> : </text>
  <value-of select="."/>
  <text>
</text>

</template>

<template match="tvRating|starRating">
  <value-of select="name()"/>
  <text> : 0</text>
  <value-of select="@value"/>
  <text>
</text>

</template>

<template match="mpaaRating">
  <value-of select="name()"/>
  <text> : </text>
  <value-of select="substring(. , 1, 1)"/>
  <value-of select="@value"/>
  <text>
</text>

</template>

<template match="vActor|vGuestStar|vDirector|vExecProducer|vProducer|vWriter|vChoreographer">
  <for-each select="element">
    <for-each select="parent::*">
      <if test="not(@id)">
        <value-of select="name()"/>
      </if>
      <value-of select="./@id"/>
    </for-each>
    <text> : </text>
    <value-of select="."/>
    <text>
</text>
  </for-each>
</template>
  
<template match="*">
<apply-templates />
</template>

<template match="text()">
</template>

</stylesheet>
