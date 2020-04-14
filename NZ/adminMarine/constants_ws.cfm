<cfset CONST_WS_ExtUser_FID = "extUserId|text4">
<cfset CONST_WS_ExtDealership_FID = "extDealershipId|text11"> 
<cfset CONST_WS_SecurityId = 5>

<!--- GET SECTION DETAILS (start) --->
<cfquery name="getWSDetails" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" result="getWSDetails_res">
select * from ws_client_details where ws_security_id = #CONST_WS_SecurityId#
</cfquery>
<cfset CONST_WS_ClientID = getWSDetails.ws_clientId>
<cfset CONST_WS_ClientType = getWSDetails.ws_clientType>
<!--- GET SECTION DETAILS (end) --->
