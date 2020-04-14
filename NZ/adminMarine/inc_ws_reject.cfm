<cfif not IsDefined("outerErrorArray")>
    <cfset outerErrorArray = ArrayNew(1)>
    <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Rejected")>
</cfif>

<cfset respType = "REJECT">
<cfif IsDefined("ATTRIBUTES.theXmlContent")>
    <cftry>
        <cfset respType = ATTRIBUTES.theXmlContent.NMPackage.request>
        <cfset respType = respType.XmlAttributes.type>
        <cfcatch type="Any">
            <cfset respType = "REJECT">
        </cfcatch>
    </cftry>
</cfif>

<cfif IsDefined("ATTRIBUTES.thirdgenDetails") and IsStruct(ATTRIBUTES.thirdgenDetails)>
    <cfset xmlResponse = createXMLPackage(errorMsg=outerErrorArray[1],responseType="#respType#",idStruct=ATTRIBUTES.thirdgenDetails)>
    <cftry>
        <cfset xmlRequestId = updateWebServiceRequestLog( ws_request_id=ATTRIBUTES.xmlWSLogId
            ,external_id=ATTRIBUTES.thirdgenDetails.extDataID
            ,requester_id=ATTRIBUTES.thirdgenDetails.extDataProvider
            ,dealership_id=ATTRIBUTES.thirdgenDetails.extDealerID
            ,dealership_name=ATTRIBUTES.thirdgenDetails.extDealerName
            ,req_type=respType
            )>
        <cfcatch type="Any">
        </cfcatch>
    </cftry>
<cfelse>
    <cfset xmlResponse = createXMLPackage(errorMsg=outerErrorArray[1],responseType="#respType#")>
</cfif>

<cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=ATTRIBUTES.xmlWSLogId
    ,responseXML=XmlParse(xmlResponse)
    ,note="Error - #respType#"
    )>
<cfoutput>#xmlResponse#</cfoutput>
