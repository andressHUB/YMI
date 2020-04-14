<cfinclude template="constants.cfm">
<cfinclude template="constants_ws.cfm">
<cffunction name="getWebServiceTempData" returntype="string">
    <cfargument name="form_data_id" required="Yes" type="numeric">
    <cfargument name="external_id" required="Yes" type="string">
    <cfargument name="data_type" required="No" type="string" default="">
    <cfargument name="requester_id" required="No" type="string" default="">
    
    <cfset ws_data = "">
    
    <cfquery name="getWSTempData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" >
    select ws_data_id, last_updated, ws_data
    from ymi_motorcycle_ws_data
    where form_data_id = #ARGUMENTS.form_data_id# and external_id = '#ARGUMENTS.external_id#' 
    and requester_id = '#ARGUMENTS.requester_id#' and data_type = '#ARGUMENTS.data_type#'
    </cfquery>
    
    <cfif getWSTempData.recordCount gt 0>
        <cfset ws_data = getWSTempData.ws_data>
    </cfif>
    
    <cfreturn ws_data>
</cffunction>

<cffunction name="updateWebServiceTempData" returntype="numeric">
    <cfargument name="form_data_id" required="Yes" type="numeric">
    <cfargument name="external_id" required="Yes" type="string">
    <cfargument name="data_type" required="No" type="string" default="">
    <cfargument name="requester_id" required="No" type="string" default="">
    <cfargument name="theData" required="Yes" type="any">
    
    <cfset dataId = "">
    
    <cfquery name="getWSTempData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" >
    select ws_data_id, last_updated, data_type
    from ymi_motorcycle_ws_data
    where form_data_id = #ARGUMENTS.form_data_id# and external_id = '#ARGUMENTS.external_id#' 
    and requester_id = '#ARGUMENTS.requester_id#' and data_type = '#ARGUMENTS.data_type#'
    </cfquery>
    
    <cfwddx action="CFML2WDDX" input="#ARGUMENTS.theData#" output="theWDDXData">
    <cfif getWSTempData.recordCount gt 0>
        <cfquery name="updateWSTempData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" >
        update ymi_motorcycle_ws_data
        set ws_data = '#theWDDXData#', last_updated = #CreateODBCDateTime(now())#
        where ws_data_id = #getWSTempData.ws_data_id#
        </cfquery>
        <cfset dataId = getWSTempData.ws_data_id>
    <cfelse>
        <cfquery name="insertWSTempData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" >
        declare @next_id int
        set @next_id = (select isnull(max(ws_data_id),0)+1 from ymi_motorcycle_ws_data)
    
        insert into ymi_motorcycle_ws_data (ws_data_id, form_data_id, external_id, requester_id, data_type, last_updated, ws_data)
        values (@next_id ,#ARGUMENTS.form_data_id#,'#ARGUMENTS.external_id#','#ARGUMENTS.requester_id#','#ARGUMENTS.data_type#', #CreateODBCDateTime(now())#, '#theWDDXData#')
        
        select @next_id as newDataId
        </cfquery>
        <cfset dataId = insertWSTempData.newDataId>
    </cfif>
    
    <cfreturn dataId>
</cffunction>



<cffunction name="createWebServiceLog" returntype="numeric">
    <cfargument name="ip_addr" required="Yes" type="string">
    <cfargument name="motorcycle_company_id" required="Yes" type="numeric">
    <cfargument name="requester_id" required="Yes" type="string">
    <cfargument name="external_id" required="Yes" type="string">
    <cfargument name="requestedAt" required="No" type="date">
    <cfargument name="requestXML" required="Yes" type="string">
    
    <cfif StructKeyExists(ARGUMENTS,"requestedAt")>
        <cfset requestDT = CreateODBCDateTime(ARGUMENTS.requestedAt)>
    <cfelse>
        <cfset requestDT = CreateODBCDateTime(now())>
    </cfif>
    
    <cfquery name="getWSLog" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" result="getUserData_res">
    declare @next_id int
    set @next_id = (select isnull(max(ws_request_id),0)+1 from ymi_motorcycle_ws_log)
    
    insert into ymi_motorcycle_ws_log (ws_request_id, ip_addr, motorcycle_company_id, requester_id, requestedAt, requestXML, external_id)
    values (@next_id, '#ARGUMENTS.ip_addr#',#ARGUMENTS.motorcycle_company_id#,'#ARGUMENTS.requester_id#',#requestDT#,'#ARGUMENTS.requestXML#','#ARGUMENTS.external_id#')
    
    select @next_id as newLogId
    </cfquery>
    
    <!--- <cfreturn getUserData_res.IDENTITYCOL> --->
    <cfreturn getWSLog.newLogId>
</cffunction>

<cffunction name="updateWebServiceRequestLog" returntype="numeric">
    <cfargument name="ws_request_id" required="Yes" type="numeric">
    <cfargument name="requester_id" required="Yes" type="string">
    <cfargument name="external_id" required="Yes" type="string">
    <cfargument name="req_type" required="No" type="string">
    <cfargument name="dealership_id" required="No" type="string">
    <cfargument name="dealership_name" required="No" type="string">
    <cfargument name="requestXML" required="No" type="string" default="">

    <cfif StructKeyExists( ARGUMENTS,"responsedAt")>
        <cfset responseDT = CreateODBCDateTime(ARGUMENTS.responsedAt)>
    <cfelse>
        <cfset responseDT = CreateODBCDateTime(now())>
    </cfif>
    <cfquery name="updateWSLog" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    update ymi_motorcycle_ws_log
    set requester_id = '#ARGUMENTS.requester_id#', external_id = '#ARGUMENTS.external_id#'
    <cfif IsDefined("ARGUMENTS.req_type")>
        ,requestType = '#ARGUMENTS.req_type#'
    </cfif>
    <cfif IsDefined("ARGUMENTS.dealership_id")>
        ,dealership_id = '#ARGUMENTS.dealership_id#'
    </cfif>
    <cfif IsDefined("ARGUMENTS.dealership_name")>
        ,dealership_name = '#ARGUMENTS.dealership_name#'
    </cfif>
    <cfif StructKeyExists(ARGUMENTS,"requestXML") and trim(ARGUMENTS.requestXML) neq "">
        , requestXML = '#ARGUMENTS.requestXML#'
    </cfif>
    where ws_request_id = #ARGUMENTS.ws_request_id#
    </cfquery>
    
    <cfreturn arguments.ws_request_id>
</cffunction>

<cffunction name="updateWebServiceResponseLog" returntype="numeric">
    <cfargument name="ws_request_id" required="Yes" type="numeric">
    <cfargument name="form_data_id" required="No" type="numeric">
    <cfargument name="note" required="No" type="string" default="">
    <cfargument name="responsedAt" required="No" type="date">
    <cfargument name="responseXML" required="Yes" type="string">
    
    <cfif StructKeyExists( ARGUMENTS,"responsedAt")>
        <cfset responseDT = CreateODBCDateTime(ARGUMENTS.responsedAt)>
    <cfelse>
        <cfset responseDT = CreateODBCDateTime(now())>
    </cfif>
    <cfquery name="updateWSLog" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    update ymi_motorcycle_ws_log
    set responsedAt = #responseDT#, responseXML = '#ARGUMENTS.responseXML#', note = '#ARGUMENTS.note#'
    <cfif IsDefined("ARGUMENTS.form_data_id")>
        ,form_data_id = #ARGUMENTS.form_data_id#
    <cfelse>
        ,form_data_id = null
    </cfif>
    where ws_request_id = #ARGUMENTS.ws_request_id#
    </cfquery>
    
    <cfreturn arguments.ws_request_id>
</cffunction>

<cffunction name="XMLToCF_dateTime" returntype="date">
    <cfargument name="xmlDateTime" required="Yes" type="string">
    <cfargument name="isUTC" required="No" type="boolean" default="false">
    
    <cfset dt=arguments.xmlDateTime>
    <cfset dt=REReplace(dt,"[T|Z]"," ","ALL")>
    <cfset dt2=LSParseDateTime(dt)>
    
    <cfif arguments.isUTC>
        <cfset dt2 = DateConvert("utc2local", dt2)> 
    </cfif>
    
    <cfreturn dt2>
</cffunction>

<cffunction name="CFToXML_dateTime" returntype="string">
    <cfargument name="CFDateTime" required="Yes" type="date">
    <cfargument name="convertToUTC" required="No" type="boolean" default="false">
    
    <cfset dt=arguments.CFDateTime>
    <cfif arguments.convertToUTC>
        <cfset dt = DateConvert("local2utc", dt)>
        <cfset dt2 = DateFormat(dt,"yyyy-mm-dd") & "T" & TimeFormat(dt,"HH:mm:ss") & "Z">
    <cfelse>
        <cfset dt2 = DateFormat(dt,"yyyy-mm-dd") & "T" & TimeFormat(dt,"HH:mm:ss")>
    </cfif>
    
    <cfreturn dt2>
</cffunction>

<cffunction name="getMthAsNum" returntype="numeric">
    <cfargument name="monthName" required="Yes" type="string">
    <cfset mthNum = 0>
    
    <cfswitch expression="#arguments.monthName#">
        <cfcase value="jan,january">
            <cfset mthNum = 1>
        </cfcase>
        <cfcase value="feb,february">
            <cfset mthNum = 2>
        </cfcase>
        <cfcase value="mar,march">
            <cfset mthNum = 3>
        </cfcase>
        <cfcase value="apr,april">
            <cfset mthNum = 4>
        </cfcase>
        <cfcase value="may">
            <cfset mthNum = 5>
        </cfcase>
        <cfcase value="jun,june">
            <cfset mthNum = 6>
        </cfcase>
        <cfcase value="jul,july">
            <cfset mthNum = 7>
        </cfcase>
        <cfcase value="aug,august">
            <cfset mthNum = 8>
        </cfcase>
        <cfcase value="sep,september">
            <cfset mthNum = 9>
        </cfcase>
        <cfcase value="oct,october">
            <cfset mthNum = 10>
        </cfcase>
        <cfcase value="nov,november">
            <cfset mthNum = 11>
        </cfcase>
        <cfcase value="dec,december">
            <cfset mthNum = 12>
        </cfcase>
    </cfswitch>
    
    <cfreturn mthNum>
</cffunction>
    
<!--- 
sample:
<header>
    <clientId>YMINZ</clientId>
    <clientType>Motorcycle</clientType>
</header>
--->
<cffunction name="getSectionDetails" returntype="struct">
    <cfargument name="detailXML" required="Yes" type="string">
    <cfset detailStruct = StructNew()>
    <cfif IsXML(ARGUMENTS.detailXML)>
        <cftry>
            <cfset tmpXml = XmlParse(ARGUMENTS.detailXML)>
            <cfset x = StructInsert(detailStruct,"ID",trim(tmpXml.header.clientId.XmlText))>
            <cfset x = StructInsert(detailStruct,"Type",trim(tmpXml.header.clientType.XmlText))>
            <cfcatch type="Any">
            
            </cfcatch>
        </cftry>
    </cfif>
    <cfreturn detailStruct>
    
</cffunction>


<!--- 
sample:
<id>
    <refId>82583<refId>
    <extRefId provider="YMF">Y9IA801279<extRefId>
    <extDealer id="D987">ROCKAFELLER MOTORCYCLE LTD</extDealer>
    <extUser id="123">Fred.flinstone</extUser>
</id>

<id>
    <refId>82583<refId>
    <extRefId provider="YMF">Y9IA801279<extRefId>
    <intUser>Fred.flinstone</intUser>
    <intUserPwd>x189Po!</intUserPwd>
</id>
--->
<cffunction name="getThirdgenDetails" returntype="struct">
    <cfargument name="detailXML" required="Yes" type="string">
    <cfargument name="ignorePassword" required="No" type="boolean" default=false>
    <cfset detailStruct = StructNew()>

    <cfif IsXML(ARGUMENTS.detailXML)>
        <cftry>
            <cfset isValid = true>
            
            <cfset tmpXml = XmlParse(ARGUMENTS.detailXML)>
            <cfif len(trim(tmpXml.id.extRefId.XmlText)) gt 40>
                <cfset isValid = false>
            </cfif>
            
            <cfif isValid>
                <cfset x = StructInsert(detailStruct,"extDataID",trim(tmpXml.id.extRefId.XmlText))>
                <cfset x = StructInsert(detailStruct,"extDataProvider",tmpXml.id.extRefId.XmlAttributes.provider)>
    
                <cfif StructKeyExists(tmpXml.id,"intUser")>
                    <cfset x = StructInsert(detailStruct,"intUserName",trim(tmpXml.id.intUser.XmlText))>
                    <cfif ARGUMENTS.ignorePassword>
                        <cfset x = StructInsert(detailStruct,"intUserPwd","[[IGNORE]]")>
                    <cfelse>
                        <cfset x = StructInsert(detailStruct,"intUserPwd",trim(tmpXml.id.intUserPwd.XmlText))>
                    </cfif>
                <cfelseif StructKeyExists(tmpXml.id,"extUser")>
                    <cfset x = StructInsert(detailStruct,"extDealerName",trim(tmpXml.id.extDealer.XmlText))>
                    <cfset x = StructInsert(detailStruct,"extDealerID",tmpXml.id.extDealer.XmlAttributes.id)>
                    <cfset x = StructInsert(detailStruct,"extUserName",trim(tmpXml.id.extUser.XmlText))>
                    <cfset x = StructInsert(detailStruct,"extUserID",tmpXml.id.extUser.XmlAttributes.id)>
                </cfif>
                
                <cfif StructKeyExists(tmpXml.id,"refId") and trim(tmpXml.id.refId.XmlText) neq "">
                    <cfset x = trim(tmpXml.id.refId.XmlText)>
                    <cfif isNumeric(x)>
                        <cfset x = StructInsert(detailStruct,"intDataID",x)>
                    <cfelse>
                        <cfset isValid = false>
                    </cfif>
                </cfif>
            </cfif>
            <cfcatch type="Any">
                <cfset detailStruct = StructNew()>
            </cfcatch>
        </cftry>
        
        <cfif not isValid>
            <cfset detailStruct = StructNew()>
        </cfif>
    </cfif>
    
    <cfif StructKeyExists(detailStruct,"extUserID") and StructKeyExists(detailStruct,"extDealerID")
        and StructFind(detailStruct,"extUserID") neq "" and  StructFind(detailStruct,"extDealerID") neq "">
    
        <cfquery name="getUserData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        <!---   
        select ud.user_data_id, ud.user_name, ud.user_email, c.default_tree_node_id
        from thirdgen_user_data ud 
        inner join thirdgen_user_control c on ud.user_data_id = c.user_data_id and c.user_control_status_id = 1
        inner join thirdgen_form_data fd on c.user_data_id = fd.user_data_id
        inner join thirdgen_registration r on r.form_def_id = fd.form_def_id
        inner join thirdgen_form_header_data fhd on fd.form_data_id = fhd.form_data_id
            and fhd.#ListLast(CONST_WS_ExtUser_FID,"|")# = '#detailStruct.extUserID#'
        inner join thirdgen_tree_node_data tnd on c.default_tree_node_id = tnd.tree_node_id
        inner join thirdgen_form_header_data fhd2 on tnd.form_data_id = fhd2.form_data_id
            and fhd2.#ListLast(CONST_WS_ExtDealership_FID,"|")# = '#detailStruct.extDealerID#'
        --->
        SELECT top 1 ud.user_data_id, ud.user_name, ud.user_email, c.default_tree_node_id, 
            fhd.text4, utn.tree_node_id, fhd2.text11
        FROM thirdgen_user_data AS ud 
        INNER JOIN thirdgen_user_control AS c ON ud.user_data_id = c.user_data_id and c.user_control_status_id = 1
        INNER JOIN thirdgen_form_data AS fd ON ud.user_data_id = fd.user_data_id 
        INNER JOIN thirdgen_registration AS r ON r.form_def_id = fd.form_def_id 
        INNER JOIN thirdgen_form_header_data AS fhd ON fd.form_data_id = fhd.form_data_id 
        INNER JOIN thirdgen_user_tree_node AS utn ON ud.user_data_id = utn.user_data_id 
        INNER JOIN thirdgen_tree_node_data AS tnd ON utn.tree_node_id = tnd.tree_node_id 
        INNER JOIN thirdgen_form_header_data AS fhd2 ON tnd.form_data_id = fhd2.form_data_id
        INNER JOIN thirdgen_user_role ur on ud.user_data_id = ur.user_data_id and ur.role_id = #CONST_MOTORCYCLE_ROLEID#
        WHERE (fhd.#ListLast(CONST_WS_ExtUser_FID,"|")# = '#detailStruct.extUserID#') 
        AND (fhd2.#ListLast(CONST_WS_ExtDealership_FID,"|")# = '#detailStruct.extDealerID#')
        </cfquery>

        <cfif getUserData.recordCount eq 1>
            <cfquery name="getUserRole" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select role_id from thirdgen_user_role where user_data_id = #getUserData.user_data_id#
            </cfquery>       
        
            <cfset x = StructInsert(detailStruct,"userName",getUserData.user_name)>
            <cfset x = StructInsert(detailStruct,"userID",getUserData.user_data_id)>
            <cfset x = StructInsert(detailStruct,"userEmail",getUserData.user_email)>
            <cfset x = StructInsert(detailStruct,"defaultTreeNodeID",getUserData.default_tree_node_id)>
            <cfset x = StructInsert(detailStruct,"userRoleIDs",ValueList(getUserRole.role_id))>
            <cfset x = StructInsert(detailStruct,"siteID",session.thirdgenAS.siteID)>
            <cfset x = StructInsert(detailStruct,"currentTreeNodeId",getUserData.tree_node_id)>
            
            <!--- create SESSION --->
            <cfif StructKeyExists(detailStruct,"userID") and StructFind(detailStruct,"userID") neq "" >
                <cfset restoreSessionThirdgenASUserId="#detailStruct.userID#">
                <cfinclude template="../thirdgen/registration/reauthenticate.cfm" >
                <cfset SESSION.currentTreeNodeId = detailStruct.currentTreeNodeId>
            </cfif>
        </cfif>
    
    <cfelseif StructKeyExists(detailStruct,"intUserName") and StructKeyExists(detailStruct,"intUserPwd")
        and StructFind(detailStruct,"intUserName") neq "" and  StructFind(detailStruct,"intUserPwd") neq "">
        
        <cfquery name="getUserData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        SELECT ud.user_data_id, ud.user_name, ud.user_email, uc.default_tree_node_id, ud.password
        FROM thirdgen_user_data AS ud 
        INNER JOIN thirdgen_user_control AS uc ON ud.user_data_id = uc.user_data_id and uc.user_control_status_id = 1  
        WHERE ud.user_name = '#detailStruct.intUserName#'
        </cfquery>

        <cfif getUserData.recordCount eq 1>
            <cfquery name="getUserRole" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select role_id from thirdgen_user_role where user_data_id = #getUserData.user_data_id#
            </cfquery>       
        
            <cfset x = StructInsert(detailStruct,"userName",getUserData.user_name)>
            <cfif Compare(getUserData.password, detailStruct.intUserPwd) eq 0
                or Compare( detailStruct.intUserPwd, "[[IGNORE]]") eq 0> 
                <cfset x = StructInsert(detailStruct,"userID",getUserData.user_data_id)>
            <cfelse> <!---  wrong password --->
                <cfset x = StructInsert(detailStruct,"userID",0)>
            </cfif>
            <cfset x = StructInsert(detailStruct,"userEmail",getUserData.user_email)>
            <cfset x = StructInsert(detailStruct,"defaultTreeNodeID",getUserData.default_tree_node_id)>
            <cfset x = StructInsert(detailStruct,"userRoleIDs",ValueList(getUserRole.role_id))>
            <cfset x = StructInsert(detailStruct,"siteID",session.thirdgenAS.siteID)>
            <cfset x = StructInsert(detailStruct,"currentTreeNodeId",getUserData.default_tree_node_id)>
            
            <!--- create SESSION --->
            <cfif StructKeyExists(detailStruct,"userID") and StructFind(detailStruct,"userID") neq "" and StructFind(detailStruct,"userID") neq 0 >
                <cfset restoreSessionThirdgenASUserId="#detailStruct.userID#">
                <cfinclude template="../thirdgen/registration/reauthenticate.cfm" >
                <cfset SESSION.currentTreeNodeId = detailStruct.currentTreeNodeId>
            </cfif>
        </cfif>
        
    </cfif>
    
    <cfreturn detailStruct>
    
</cffunction>

<cffunction name="appendErrArray" returntype="array">
    <cfargument name="errArray" required="no" type="array" default="#ArrayNew(1)#">
    <cfargument name="code" required="yes" type="string">
    <cfargument name="desc" required="yes" type="string" >
    <cfargument name="int_desc" required="no" type="string"  default="">
    
    <cfset var theArray = errArray>
    <cfset var tmpStruct = StructNew()>
    <cfset x = StructInsert(tmpStruct,"code",ARGUMENTS.code)>
    <cfset x = StructInsert(tmpStruct,"desc",ARGUMENTS.desc)>
    <cfset x = StructInsert(tmpStruct,"int_desc",ARGUMENTS.int_desc)>
    <cfset x = ArrayAppend(theArray,tmpStruct)>
    
    <cfreturn theArray>
</cffunction>

<cffunction name="createErrorElem" returntype="string">
    <cfargument name="code" required="No" type="string" default="">
    <cfargument name="desc" required="yes" type="string" >
    <cfargument name="int_desc" required="No" type="string" default="">
    
<cfsavecontent variable="theXML"><cfoutput>
<error>
    <cfif StructKeyExists(ARGUMENTS,"code")>
    <code>#XmlFormat(arguments.code)#</code>
    </cfif>
    <desc>#XmlFormat(arguments.desc)#</desc>
    <cfif StructKeyExists(ARGUMENTS,"int_desc") and trim(ARGUMENTS.int_desc) neq "">
    <int_desc>#XmlFormat(arguments.int_desc)#</int_desc>
    </cfif>
</error>
</cfoutput></cfsavecontent>

    <cfreturn theXML>
</cffunction>


<cffunction name="createXMLPackage" returntype="string">
    <cfargument name="responseType" required="Yes" type="string">
    <cfargument name="xmlContent" required="No" type="string" default="">
    <cfargument name="errorMsg" required="No" type="struct" default="#StructNew()#">
    <cfargument name="idStruct" required="No" type="struct" default="#StructNew()#">
    
    <cfset xmlResult = "">
    <cfset isOk = true>
    
    <cfif not IsDefined("CONST_WS_ClientID")>
        <cfinclude template="../adminMotor/constants_ws.cfm">
    </cfif>
    
<cfsavecontent variable="theXML"><cfoutput>
<NMPackage>
<header>
    <clientId>#CONST_WS_ClientID#</clientId>
    <clientType>#CONST_WS_ClientType#</clientType>
    <generatedAt>#CFToXML_dateTime(now(),true)#</generatedAt>
    <!--- <generatedAt>#DateFormat(now(),"dd-mmm-yyyy")# #TimeFormat(now(),"HH:mm:ss")#</generatedAt> --->
    <uniqueId>#CreateUUID()#</uniqueId>
</header>
<response type="#arguments.responseType#">
<cfif StructCount(idStruct) gt 0>
    <id>
        <cfif StructKeyExists(idStruct,"intDataID")>
            <refId>#idStruct.intDataID#</refId>
        </cfif>
        <extRefId provider="#XMLFormat(idStruct.extDataProvider)#">#XMLFormat(idStruct.extDataID)#</extRefId>
        <cfif StructKeyExists(idStruct,"extUserID")>
            <extDealer id="#idStruct.extDealerID#">#XMLFormat(idStruct.extDealerName)#</extDealer>
            <extUser id="#idStruct.extUserID#">#XMLFormat(idStruct.extUserName)#</extUser>
        <cfelseif StructKeyExists(idStruct,"intUserName")>
            <cfif StructKeyExists(idStruct,"userID")>
                <intUser id="#idStruct.userID#">#XMLFormat(idStruct.intUserName)#</intUser>
            <cfelse>
                <intUser>#XMLFormat(idStruct.intUserName)#</intUser>
            </cfif>
        </cfif>
    </id>
</cfif>
<cfif arguments.xmlContent neq "">
    <cfset tmpXML = "<temp>" & arguments.xmlContent & "</temp>"> <!--- this is just need to check if XML in valid format --->
    <cfif IsXML(tmpXML)>
        #Trim(arguments.xmlContent)#
    <cfelse>
        #createErrorElem("FUNCTION","Invalid XML","")#
        <cfset isOk = false>
    </cfif>
<cfelseif StructCount(arguments.errorMsg) gt 0 and StructKeyExists(ARGUMENTS.errorMsg,"desc")>
    <cfset tmpCode = "">
    <cfif StructKeyExists(ARGUMENTS.errorMsg,"code")>
        <cfset tmpCode = ARGUMENTS.errorMsg.code>
    </cfif>
    <cfset tmpIntDesc = "">
    <cfif StructKeyExists(ARGUMENTS.errorMsg,"int_desc")>
        <cfset tmpIntDesc = ARGUMENTS.errorMsg.int_desc>
    </cfif>
    #createErrorElem(tmpCode,ARGUMENTS.errorMsg.desc,tmpIntDesc)#
</cfif>
</response>
</NMPackage>
</cfoutput></cfsavecontent>

    <!--- <cfif isOk>
        <cfset xmlResult = theXML>
    <cfelse>
        <cfset xmlResult = "<NMPackage></NMPackage>">
    </cfif> --->
    <cfset xmlResult = theXML>
    <cfreturn xmlResult>
    
</cffunction>


<cffunction name="encryptDecryptString" returntype="string">
    <cfargument name="theString" required="Yes" type="string">
    <cfargument name="op" required="Yes" type="string" default="ENC"> <!--- ENC | DEC --->
    <cfargument name="sharedKey" required="No" type="string" default="YMIAUS14">
    <cfargument name="sharedIV" required="No" type="string" default="1fed8c3a30fd26e2">

    <cfset theKey = ToBase64(ARGUMENTS.sharedKey)>
    <cfset theIV = BinaryDecode(ARGUMENTS.sharedIV,"Hex")>
    <cfset theResult = "">
    <cftry>
        <cfif ARGUMENTS.op eq "ENC">
            <cfset theResult = encrypt(ARGUMENTS.theString, theKey, "DES/CBC/PKCS5Padding", "Base64", theIV)>
        <cfelse>
            <cfset theResult = decrypt(ARGUMENTS.theString, theKey,"DES/CBC/PKCS5Padding", "Base64", theIV)>
        </cfif>
        <cfcatch type="Any">
        </cfcatch>
    </cftry>
    
    <cfreturn theResult>
</cffunction>


<cffunction name="createToken" returntype="string">
    <cfargument name="uid" required="No" type="numeric" default="0">
    <cfargument name="length" required="No" type="numeric" default="8">
    <cfargument name="type" required="No" type="string" default="normal"> <!--- normal | UUID --->
    
    <cfset theToken = "">
    
    <cfif ARGUMENTS.type eq "normal">
        <cfset tokenLength = ARGUMENTS.length>
        <cfif tokenLength lt 8>
            <cfset tokenLength = 8>
        </cfif>
        <cfif tokenLength gt 32>
            <cfset tokenLength = 32>
        </cfif>
        
        <cfset okCharList="aAbBcCdDeEfFgGhHjJkKmMnNpPqQrRsStTuUvVwWxXyYzZ0123456789">
        <cfset randText = "">    
        <cfloop from="1" to="#tokenLength#" index="z">
            <cfset randText = randText & MID(okCharList,RandRange(1,len(okCharList)),1)>
        </cfloop>    
        
        <cfset theToken = randText>
        
    <cfelseif ARGUMENTS.type eq "UUID">
        <cfset theToken = CreateUUID()>
        
    </cfif>
    
    <cfreturn theToken>
</cffunction>
