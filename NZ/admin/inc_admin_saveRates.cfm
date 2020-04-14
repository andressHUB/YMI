<cfparam name="ratesId" default="0">
<cfparam name="effectiveDate" default="#DateAdd('d',1,now())#">

<cfset effectiveDate = LSParseDateTime(effectiveDate)>    

<cfif ratesId eq "0">
    <cftransaction>
        <!--- get a new rate id --->
        <cfquery name="lastRateId" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select isnull(max(motorcycle_rateControlID),0) as lastRateIdUsed from ymi_motorcycle_rateControl where motorcycle_company_id = #CONST_MOTORCYCLE_COMP_ID#
        </cfquery>
        <cfset newRatesId = lastRateId.lastRateIdUsed + 1>
        <cfset tmpRatesId = newRatesId>
        
        
        <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            insert into ymi_motorcycle_rateControl
            (motorcycle_rateControlID, startAt, motorcycle_company_id)
            values
            (#tmpRatesId#,#CreateODBCDate(effectiveDate)#, #CONST_MOTORCYCLE_COMP_ID#)
        </cfquery>
    </cftransaction>
<cfelse>
    <cftransaction>
        <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            update ymi_motorcycle_rateControl
            set motorcycle_rateControlID = #ratesId#, 
            startAt = #CreateODBCDate(effectiveDate)#
            where motorcycle_rateControlID = #ratesId#
            and motorcycle_company_id = #CONST_MOTORCYCLE_COMP_ID#
        </cfquery>
    </cftransaction>
    <cfset tmpRatesId = ratesId>
</cfif>

<cfquery name="getCurrentData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
select motorcycle_rate_item_id from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId#
</cfquery>

<cfset allItemID = ValueList(getCurrentData.motorcycle_rate_item_id)>

<!--- <cfdump var="#form#">
<cfabort> --->
<div style="background-color:white">
<!--- <cfdump var="#allItemID#"> --->
<cftransaction>
<cfloop index="fname" list="#form.fieldnames#">
    <cfif CompareNoCase(left(fname,4),"FLD_") eq 0>
        <cfif CompareNoCase(right(fname,8),"_RATEPER") eq 0 and StructFind(FORM,fname) neq "">
            <cfset fieldData = replaceNoCase(fname,"_RATEPER","")>
            <cfif StructKeyExists(FORM,fieldData&"_RATEEND")>
                <cfset rateEnd = StructFind(FORM, fieldData&"_RATEEND") >
            <cfelse>
                <cfset rateEnd = "NULL">          
            </cfif>
            <cfif StructKeyExists(FORM,fieldData&"_RATEFOR")>
                <cfset rateFor = StructFind(FORM, fieldData&"_RATEFOR") >
            <cfelse>
                <cfset rateFor = "NULL">          
            </cfif>
            <cfset fieldData = replaceNoCase(fieldData,"FLD_","")>
            <cfset rateCatID = ListFirst(fieldData,"_")>
            <cfset rateItemID = ListLast(fieldData,"_")>
            <cfset loadingPercent = StructFind(FORM,fname)>
            <!--- <cfoutput> #rateItemID# | #rateCatID# | #rateEnd# | #rateFor# | #loadingPercent# <br></cfoutput> ---> 
            <cfif left(rateItemID,1) eq 0>
                <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                insert into ymi_motorcycle_rateData (motorcycle_rateCategoryID, motorcycle_rateControlID, rateEnd, rateFor, loadingPercent, feeDollar)
                values (#rateCatID#,#ratesId#,#rateEnd#,<cfif rateFor eq "NULL">NULL<cfelse>'#rateFor#'</cfif>, #loadingPercent#, NULL)
                </cfquery>
            <cfelse>
                <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                update ymi_motorcycle_rateData
                set rateEnd = #rateEnd#, rateFor = <cfif rateFor eq "NULL">NULL<cfelse>'#rateFor#'</cfif>, feeDollar = NULL, loadingPercent = #loadingPercent#
                where motorcycle_rateCategoryID = #rateCatID#
                and motorcycle_rate_item_id =  #rateItemID#
                </cfquery>
            </cfif>
            
            <cfset listpos = ListFindNoCase(allItemID,rateItemID)>
            <cfif listpos gt 0>
                <cfset allItemID = ListDeleteAt(allItemID,listpos)>
            </cfif>
        <cfelseif CompareNoCase(right(fname,8),"_RATEFEE") eq 0 and StructFind(FORM,fname) neq "">
            <cfset fieldData = replaceNoCase(fname,"_RATEFEE","")>
            <cfif StructKeyExists(FORM,fieldData&"_RATEEND")>
                <cfset rateEnd = StructFind(FORM, fieldData&"_RATEEND") >
            <cfelse>
                <cfset rateEnd = "NULL">          
            </cfif>
            <cfif StructKeyExists(FORM,fieldData&"_RATEFOR")>
                <cfset rateFor = StructFind(FORM, fieldData&"_RATEFOR") >
            <cfelse>
                <cfset rateFor = "NULL">          
            </cfif>
            <cfset fieldData = replaceNoCase(fieldData,"FLD_","")>
            <cfset rateCatID = ListFirst(fieldData,"_")>
            <cfset rateItemID = ListLast(fieldData,"_")>
            <cfset feeDollar = StructFind(FORM,fname)>
            <!--- <cfoutput> #rateItemID# | #rateCatID# | #rateEnd# | #rateFor# | #feeDollar# <br></cfoutput> --->
            <cfif left(rateItemID,1) eq 0>
                <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                insert into ymi_motorcycle_rateData (motorcycle_rateCategoryID, motorcycle_rateControlID, rateEnd, rateFor, loadingPercent, feeDollar)
                values (#rateCatID#,#ratesId#,#rateEnd#,<cfif rateFor eq "NULL">NULL<cfelse>'#rateFor#'</cfif>, NULL, #feeDollar#)
                </cfquery>
            <cfelse>
                <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                update ymi_motorcycle_rateData
                set rateEnd = #rateEnd#, rateFor = <cfif rateFor eq "NULL">NULL<cfelse>'#rateFor#'</cfif>, feeDollar = #feeDollar#, loadingPercent = NULL
                where motorcycle_rateCategoryID = #rateCatID#
                and motorcycle_rate_item_id =  #rateItemID#
                </cfquery>
            </cfif>
            <cfset listpos = ListFindNoCase(allItemID,rateItemID)>
            <cfif listpos gt 0>
                <cfset allItemID = ListDeleteAt(allItemID,listpos)>
            </cfif>
        </cfif>
    </cfif>
</cfloop>
<!--- <cfdump var="#allItemID#"> --->
<cfif ListLen(allItemID) gt 0>
    <cfloop list="#allItemID#" index="anItemID">
        <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        delete ymi_motorcycle_rateData
        where motorcycle_rate_item_id = #anItemID#
        </cfquery>
    </cfloop>
</cfif>
</cftransaction>
</div>

<cflocation addtoken="no" url="#admin#rateEdit&ratesId=#ratesid#">