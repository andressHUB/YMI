<cfsavecontent variable="theContent">
Welcome to YMI NZ Webservice
</cfsavecontent>

<cfset xmlReponse = createXMLPackage(xmlContent="#theContent#",responseType="test")>

<cfoutput>#xmlReponse#</cfoutput>