<cfparam name="ratesId">

<!--- Copy this rate table to a new one --->
<cftransaction>
    <!--- get a new rate id --->
    <cfquery name="lastRateId" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select isnull(max(motorcycle_rateControlID),0) as lastRateIdUsed from ymi_motorcycle_rateControl
    </cfquery>
    <cfset newRatesId = lastRateId.lastRateIdUsed + 1>
    <cfset tmpRatesId = newRatesId>


<!--- Get the current details --->
    <!--- Get Existing Rates --->
    <cfquery name="getYmiRateData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select motorcycle_rate_item_id, motorcycle_rateCategoryID, motorcycle_rateControlID, rateEnd, rateFor, loadingPercent, feeDollar 
        from ymi_motorcycle_rateData
        where motorcycle_rateControlID=#ratesId#
    </cfquery>
    
    <cfset tomorrow=DateAdd("d",1,now())>
    <cfset effectiveDate=CreateDate(DatePart("yyyy",tomorrow),  DatePart("m",tomorrow),  DatePart("d",tomorrow))>
    <cfset disp_effectiveDate = DateFormat(effectiveDate,"dd/mm/yyyy")> 
    
    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        insert into ymi_motorcycle_rateControl
        (motorcycle_rateControlID, startAt, motorcycle_company_id)
        values
        (#tmpRatesId#,#CreateODBCDate(effectiveDate)#,#CONST_MOTORCYCLE_COMP_ID#)
    </cfquery>

<!--- get the next rate_item_id (DONT DO THIS - AUTOMATICALLY WORKED OUT BY SQL)
    <cfquery name="lastRateItemId" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select isnull(max(motorcycle_rate_item_ID),0) as lastRateItemIdUsed from ymi_motorcycle_rateData
    </cfquery>
    
    <cfset newRateItemId = lastRateItemId.lastRateItemIdUsed + 1>
    <cfset tmpRateItemId = newRateItemId>
 --->

    <cfloop query="getYmiRateData">
        <!--- get list of column names --->
        <cfset collist = "#getYmiRateData.columnlist#">
        <!--- remove id column as its value is automatically worked out by sql --->
        <cfset rateItemIdPos = ListFindNoCase(collist,"motorcycle_rate_item_id")>
        <cfif rateItemIdPos gt 0>
            <cfset collist = listDeleteAt(collist, rateItemIdPos)>
        </cfif>
        <cfset colvalslist = "">
        
        <!--- loop list of column names to get values --->
        <cfloop list="#collist#" index="colname">
            <cfset colname2 = "getYmiRateData." & colname>
            
            <!--- if its the rate control id, use the new id --->
            <cfif lcase(colname) eq "motorcycle_ratecontrolid">
                <cfset colval = tmpRatesId>
            <!--- if its the ratefor column, put quotes because its a varchar --->
            <cfelseif lcase(colname) eq "ratefor">
                <cfset colval = "'" & evaluate(colname2) & "'">
            <!--- otherwise just get the value --->
            <cfelse>
                <cfset colval = evaluate(colname2)>
            </cfif>
            
            <!--- if the value is blank, put null --->
            <cfif colval eq "" or colval eq "''">
                <cfset colval = "null">
            </cfif>
            <!--- build list of values for columns --->
            <cfset colvalslist = listappend(colvalslist,colval)>
        </cfloop>
        
        <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            insert into ymi_motorcycle_rateData
            <!--- insert into all columns (except id) --->
            (#collist#)
            values
            <!--- all values (except id) - they are in the same order as columns (obviously).  Get rid of double single quotes --->
            (#replacenocase(colvalslist,"''","'","all")#)
        </cfquery>
    </cfloop>
</cftransaction>

<!--- relocate to edit rates page --->
<cflocation url="#admin#rateEdit&ratesId=#tmpRatesId#" addtoken="No">