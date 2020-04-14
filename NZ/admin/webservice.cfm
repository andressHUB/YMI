<cfinclude template="constants.cfm">
<cfinclude template="constants_ws.cfm">
<cfinclude template="inc_ws_function.cfm">
<cfparam name="ATTRIBUTES.act" default="main">

<cfset ATTRIBUTES.xmlRequest = "">
<cfset ATTRIBUTES.xmlWSLogId = 0>
<cfset ATTRIBUTES.theXmlContent = "">
<cfset ATTRIBUTES.thirdgenDetails = "">
<cfset isOkToProceed = true>
<cfset outerErrorArray = ArrayNew(1)>

<cfif IsDefined("FORM.ws_user") and IsDefined("FORM.ws_pass") and IsDefined("FORM.ws_content") and IsDefined("FORM.ws_act")>
    <cfif len(trim(FORM.ws_content)) eq 0
        OR len(trim(FORM.ws_act)) eq 0>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Empty Form Field(s)")>
        <cfset isOkToProceed = false>
    </cfif>
<cfelse>
    <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Missing Form Field(s)")>
    <cfset isOkToProceed = false>
</cfif>


<cfif isOkToProceed>
    <cftry>
        <cfset ATTRIBUTES.act = FORM.ws_act>
        <cfif IsDefined("FORM.ws_param")>
            <cfset ATTRIBUTES.xmlRequest = "">
            <cfif CompareNoCase(FORM.ws_param,"enc;base64") eq 0>
                <cfset ATTRIBUTES.xmlRequest = encryptDecryptString(FORM.ws_content,"DEC")>
                <cfif len(ATTRIBUTES.xmlRequest) eq 0>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Invalid Encrypted XML")>
                    <cfset isOkToProceed = false>
                </cfif>
            </cfif>
        <cfelse>
            <cfset ATTRIBUTES.xmlRequest = FORM.ws_content>
        </cfif>
        
        <cfset ATTRIBUTES.theXmlContent = XmlParse(trim(ATTRIBUTES.xmlRequest))>
        <cfset ATTRIBUTES.xmlWSLogId = createWebServiceLog(ip_addr="#CGI.REMOTE_ADDR#"
            ,motorcycle_company_id="#CONST_MOTORCYCLE_COMP_ID#"
            ,external_id=""
            ,requester_id=""
            ,requestXML=ATTRIBUTES.theXmlContent
            )>
        <cfcatch type="Any">
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Invalid XML")>
            <cfset isOkToProceed = false>
        </cfcatch>
    </cftry>
</cfif>

<cfif isOkToProceed>
    <!--- CHECK XML HEADER --->
    <cfif ArrayLen(outerErrorArray) eq 0>
        <cfif isDefined("ATTRIBUTES.theXmlContent.NMPackage.header")>
            <cfset sectionDetails = getSectionDetails(ATTRIBUTES.theXmlContent.NMPackage.header)>
            <cfif StructCount(sectionDetails) eq 0 >
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Invalid Header")>
                <cfset isOkToProceed = false>
            </cfif>
        <cfelse>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Missing Header")>
            <cfset isOkToProceed = false>
        </cfif>
    </cfif>
</cfif>

<cfif isOkToProceed>
    <cfif CompareNoCase(StructFind(sectionDetails,"ID"),CONST_WS_ClientID) eq 0 and CompareNoCase(StructFind(sectionDetails,"Type"),CONST_WS_ClientType) eq 0>
        <!---  --->
    <cfelse>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Invalid Webservice Client Destination")>
        <cfset isOkToProceed = false>
    </cfif>
</cfif>

<cfif isOkToProceed>
    <cfif isDefined("ATTRIBUTES.theXmlContent.NMPackage.request")>
        <cfset tmpXML = ATTRIBUTES.theXmlContent.NMPackage.request>
        <cfif isDefined("tmpXML.id")>
            <cfif CompareNoCase(ATTRIBUTES.act,"DoAuth") eq 0>
                <cfset ATTRIBUTES.thirdgenDetails = getThirdgenDetails(tmpXML.id,true)>
            <cfelse>
                <cfset ATTRIBUTES.thirdgenDetails = getThirdgenDetails(tmpXML.id)>
            </cfif>
            
            <cfif StructCount(ATTRIBUTES.thirdgenDetails) eq 0 >
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Invalid Identities Set")>
                <cfset isOkToProceed = false>
            <cfelse>
                <cfif not StructKeyExists(ATTRIBUTES.thirdgenDetails,"userID")>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","User/Dealership does not exist")>
                    <cfset isOkToProceed = false>
                <cfelse>
                    <cfif CompareNoCase(ATTRIBUTES.act,"DoAuth") eq 0>
                        <!--- IGNORE PASSWORD CHECK | IT WILL BE REDIRECTED TO LOGIN PAGE AFTERWARDS --->
                    <cfelse>
                        <cfif StructFind(ATTRIBUTES.thirdgenDetails,"userID") eq 0>
                            <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Invalid password/Authentication Details")>
                            <cfset isOkToProceed = false>
                        </cfif>
                    </cfif>
                </cfif>
                
                <cfif isOkToProceed>
                    <cfif CompareNoCase(ATTRIBUTES.act,"DoUser") eq 0>
                        <!--- IGNORE ROLE CHECK --->
                    <cfelse>
                        <cfif ListFindNoCase(StructFind(ATTRIBUTES.thirdgenDetails,"userRoleIDs"),CONST_MOTORCYCLE_ROLEID) lte 0>
                            <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","User does not have the right role")>
                            <cfset isOkToProceed = false>
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>
        <cfelse>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Missing Identity Content")>
            <cfset isOkToProceed = false>
        </cfif>
        
    <cfelse>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Missing Request Content")>
        <cfset isOkToProceed = false>
    </cfif>
</cfif>

<cfif isOkToProceed>
    <cfquery name="getWSDetails" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" result="getWSDetails_res">
    select wed.ws_Ext_IPs, wed.ws_ext_username, wed.ws_ext_password, wed.id as extProvId
    from ws_client_details wcd
    inner join ws_extProv_details wed on wcd.ws_security_id = wed.ws_security_id
    where wcd.ws_clientId = '#StructFind(sectionDetails,"ID")#'
    and wcd.ws_clientType = '#StructFind(sectionDetails,"Type")#'
    and wed.ws_ext_dealer = '#StructFind(ATTRIBUTES.thirdgenDetails,"extDataProvider")#'
    </cfquery>
    
    <cfif getWSDetails.recordCount gt 0>
        <cfif CompareNoCase(FORM.ws_user,getWSDetails.ws_ext_username) neq 0
            OR Compare(FORM.ws_pass,getWSDetails.ws_ext_password) neq 0>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Wrong username/password")>
            <cfset isOkToProceed = false>
        </cfif>
    
        <cfif CompareNoCase(ATTRIBUTES.act,"DoAuth") eq 0>
            <!--- IGNORE IP RESTRICTION - SINCE REQUEST WILL BE COME FROM CLIENT MACHINE --->
        <cfelse>
            <cfif getWSDetails.ws_Ext_IPs eq "">
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Missing IP Restriction - " & CGI.REMOTE_ADDR)>
                <cfset isOkToProceed = false>
            <cfelse>
                <cfif ListFindNoCase(trim(getWSDetails.ws_Ext_IPs),CGI.REMOTE_ADDR) lte 0> <!--- limited IPs --->
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Rejected IP - " & CGI.REMOTE_ADDR)>
                    <cfset isOkToProceed = false>
                </cfif>
            </cfif>
        </cfif>
        
        <cfif isOkToProceed and IsDefined("SESSION.thirdgenas")>
            <cfset x = StructInsert(SESSION.thirdgenas,"extProvId",getWSDetails.extProvId,true)>
        </cfif>
        
    <cfelse>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Invalid/missing client WS Details")>
        <cfset isOkToProceed = false>
        
    </cfif>
</cfif>


<cfif isOkToProceed>
    <cfswitch expression="#ATTRIBUTES.act#">
        <cfcase value="main">
            <cfinclude template="inc_ws_main.cfm">
        </cfcase>
        
        <cfcase value="GetQuote">
            <cfinclude template="inc_ws_getQuote.cfm">
        </cfcase>

        <cfcase value="DoCompliance">
            <cfinclude template="inc_ws_doCompliance.cfm">
        </cfcase>
        
        <cfcase value="DoCoverBound">
            <cfinclude template="inc_ws_doCoverBound.cfm">
        </cfcase>
        
        <cfcase value="QuickCalc">
            <cfinclude template="inc_ws_quickCalc.cfm">
        </cfcase>
        
        <cfcase value="DoUser">
            <cfinclude template="inc_ws_getUser.cfm">
        </cfcase>

        <cfcase value="DoAuth">
            <cfinclude template="inc_ws_doAuth.cfm">
        </cfcase>
        
        <cfcase value="DoQuote">
            <cfinclude template="inc_ws_doQuote.cfm">
        </cfcase>
        
        <!--- <cfcase value="PrintQuote">
            <cfinclude template="inc_ws_printQuote.cfm">
        </cfcase>
        
        <cfcase value="PrintCoverBound">
            <cfinclude template="inc_ws_printCoverBound.cfm">
        </cfcase>
        
        <cfcase value="GetApplicationInfo">
            <cfinclude template="inc_ws_getApplication.cfm">
        </cfcase> --->
        
        
    </cfswitch>
<cfelse>
    <cfinclude template="inc_ws_reject.cfm">
</cfif>

<!--- CLEAR UP ALL SESSION --->
<cfset x = structClear(SESSION)>