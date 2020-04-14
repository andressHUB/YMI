<cfabort>

<cfquery name="getStatusList" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select CONVERT(varchar(50), list_item_id) as list_item_id, list_item_display, list_item_seq
    from thirdgen_list_item
    where list_id = 804
</cfquery>

<cfdump var="#getStatusList#">
<!--- <cfabort> --->

<cfset tempLoc = "#application.THIRDGENPLUS_TEMP_DIRECTORY#">
<cfset tmpFileName = tempLoc & "rpt_ymi_nz_quotes_#DateFormat(now(),'YYYYMMDD')##TimeFormat(now(),'HHMMSS')#.csv">


<cfscript>
    //Use an absolute path for the files. --->
       theDir=GetDirectoryFromPath(GetCurrentTemplatePath());
    //theFile=theDir & "courses.xls";
    theFile = tmpFileName;
    //Create two empty ColdFusion spreadsheet objects. --->
    theSheet = SpreadsheetNew("Status");

    //Populate each object with a query. --->
    SpreadsheetAddRows(theSheet,getStatusList);

</cfscript>

 
<cfoutput>#tmpFileName#</cfoutput>

<!--- <cfabort> --->

<!--- <cfspreadsheet action="write" filename="#tmpFileName#" sheetname="#getStatusList#"> --->

<cfspreadsheet action="write" filename="#theFile#" name="theSheet" format="csv"
    sheetname="getStatusList" overwrite=true>
    
<!--- <cfspreadsheet action="read" src="#tmpFileName#" sheetname="#getStatusList#" name="theSheet">     --->