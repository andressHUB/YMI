<cfset rowsPerLoad_Default = 2000> <!--- how many rows will be processed in 1 iteration --->
<cfset loadQty_MAX = 15> <!--- MAX ITERATION - in case of crazy recursive happening --->

<cfset local.fullURL = "http://#CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/admin/index.cfm?p=uploadData">
<cfif IsDefined("URL.cont") and URL.cont eq 1>
    <cfset local.fullURL = "http://#CGI.SERVER_NAME#/admin/index.cfm?p=uploadData&cont=1">
</cfif>
<cfset local.jobName = "YMI UPLOAD DATA at #DateFormat(now(),'YYYYMMDD')#">

<cffunction name="textDelimitedToArray" returntype="array" output="false" access="public"> 
	<!--- Define arguments. --->
	<cfargument name="file" type="string" required="true" />
    <cfargument	name="startRow"	type="numeric" required="false" default="0" />
	<cfargument	name="endRow"	type="numeric" required="false" default="0" />
    <cfargument	name="splitter"	type="string" required="false" default="" />
    <cfargument	name="splitPosition" type="array" required="false" default="#ArrayNew(1)#" />
	
    <!--- Define the local scope. --->
    <cfset var local = {} />
    <cfset local.resultArray = ArrayNew(1)>
    
    <cfset local.currentRow = 0>
    <cfloop file="#arguments.file#" index="local.line">
        <cfset local.currentRow += 1>
        <cfif local.currentRow gt arguments.endRow and arguments.endRow neq 0 >
            <cfbreak>
        </cfif>
        <cfif local.currentRow gte arguments.startRow>
            <cfif arguments.splitter neq "">
                <cfset local.tempLine = reReplaceNoCase(local.line,"[#arguments.splitter#]+","#arguments.splitter#","ALL")><!--- shrink all delimiter into one --->
                <cfset local.tempArray = ArrayNew(1)>
                <cfloop list="#local.tempLine#" delimiters="#arguments.splitter#" index="local.attrbNo">
                    <cfset local.x = ArrayAppend(local.tempArray,trim(local.attrbNo))>
                </cfloop>
                <cfset local.x = ArrayAppend(local.resultArray,local.tempArray)>
            <cfelseif ArrayLen(arguments.splitPosition) gt 0 and arguments.splitPosition[1] neq "" and arguments.splitPosition[1] neq 0>
                <cfset local.currentPos = 1>
                <cfset local.tempArray = ArrayNew(1)>
                <cfloop array="#arguments.splitPosition#" index="local.aPost">
                    <cfif local.aPost gt local.currentPos>
                        <cfset local.x = ArrayAppend(local.tempArray,trim(mid(local.line,local.currentPos,local.aPost-local.currentPos)))>
                        <cfset local.currentPos = local.aPost>
                    </cfif>
                </cfloop>
                <cfset local.x = ArrayAppend(local.tempArray,trim(right(local.line,len(local.line)-local.currentPos)))>
                <cfset local.x = ArrayAppend(local.resultArray,local.tempArray)>
            <cfelse>
                <cfset local.x = ArrayAppend(local.resultArray,local.line)>
            </cfif>
        </cfif>
    </cfloop>
 
	<cfreturn local.resultArray />
</cffunction>


<!--- get the split position --->
<cfset x = textDelimitedToArray(file="#CONST_theProductFile#",startRow=2,endRow=2,splitter=" ")>

<!--- get column Name --->
<cfset y = textDelimitedToArray(file="#CONST_theProductFile#",startRow=1,endRow=1,splitPosition=x[1])>


<cfset startAtRow = 4><!--- data start at row 4 --->
<cfset loadQty = 0>
<cfif IsDefined("URL.sr") and URL.sr neq "" and IsDefined("URL.lq") and URL.lq neq "" >
    <cfset startAtRow = URL.sr>
    <cfset loadQty = URL.lq>
</cfif>
<cfset endAtrow = startAtRow + rowsPerLoad_Default>

<cfif endAtrow lte startAtRow>A<cfabort></cfif> <!--- should never happened!!! --->

<cfif loadQty lte loadQty_MAX>
    <cfoutput>
    <br/>Start at: #DateFormat(now(),"DD-MMM-YYYY")# #TimeFormat(now(),"HH:MM:SS")#<br/>
    </cfoutput>
    <!--- get column Name --->
    <cfset z = textDelimitedToArray(file="#CONST_theProductFile#",startRow="#startAtRow#",endRow="#endAtrow-1#",splitPosition=x[1])>
   
    <cfif ArrayLen(z) gt 0>
        <cfif startAtRow eq 4>
            <cfquery name="cleanYMIData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            delete from ymi_productData_raw
            </cfquery>
        </cfif>
        
        <cfloop array="#z#" index="aPost">
            <cfquery name="insertYMIData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                declare @newid int
                select @newid = isnull(max(entryid),0)+1  from ymi_productData_raw
            
                insert into ymi_productData_raw
                (   entryid,
                    code,
                    mth,
                    make,
                    family,
                    variant,
                    series,
                    style,
                    engine,
                    cc,
                    size,
                    transmission,
                    cyl,
                    valve_gear,
                    boreXStroke,
                    kW,
                    comp_ratio,
                    engine_cooling,
                    kerb_weight,
                    wheelbase,
                    seat_height,
                    drive,
                    front_tyres,
                    rear_tyres,
                    front_rims,
                    rear_rims,
                    ftank,
                    warranty_mths,
                    warranty_kms,
                    country,
                    released_date,
                    discount_date,
                    nvic,
                    [year],
                    new_pr,
                    trade_low,
                    trade,
                    retail)
                values
                (
                    @newid,
                    '#aPost[1]#',
                    '#aPost[2]#',
                    '#aPost[3]#',
                    '#aPost[4]#',
                    '#aPost[5]#',
                    '#aPost[6]#',
                    '#aPost[7]#',
                    '#aPost[8]#',
                    <cfif isnumeric(aPost[9])>CONVERT(smallint, '#aPost[9]#')<cfelse>NULL</cfif>,
                    '#aPost[10]#',
                    '#aPost[11]#',
                    '#aPost[12]#',
                    '#aPost[13]#',
                    '#aPost[14]#',
                    <cfif isnumeric(aPost[15])>CONVERT(decimal(10,2),'#aPost[15]#')<cfelse>NULL</cfif>,
                    <cfif isnumeric(aPost[16])>CONVERT(decimal(10,2),'#aPost[16]#')<cfelse>NULL</cfif>,
                    '#aPost[17]#',
                    <cfif isnumeric(aPost[18])>CONVERT(decimal(15,2),'#aPost[18]#')<cfelse>NULL</cfif>, 
                    <cfif isnumeric(aPost[19])>CONVERT(decimal(15,2),'#aPost[19]#')<cfelse>NULL</cfif>, 
                    <cfif isnumeric(aPost[20])>CONVERT(decimal(15,2),'#aPost[20]#')<cfelse>NULL</cfif>,
                    '#aPost[21]#',
                    '#aPost[22]#',
                    '#aPost[23]#',
                    '#aPost[24]#',
                    '#aPost[25]#',
                    <cfif isnumeric(aPost[26])>CONVERT(decimal(15,2),'#aPost[26]#')<cfelse>NULL</cfif>,
                    <cfif isnumeric(aPost[27])>CONVERT(smallint, '#aPost[27]#')<cfelse>NULL</cfif>,
                    <cfif isnumeric(aPost[28])>CONVERT(int, '#aPost[28]#')<cfelse>NULL</cfif>,
                    '#aPost[29]#',
                    <cfif IsNumericDate(aPost[30])>CONVERT(datetime, '#aPost[30]#',103)<cfelse>NULL</cfif>,
                    <cfif IsNumericDate(aPost[31])>CONVERT(datetime, '#aPost[31]#',103)<cfelse>NULL</cfif>,
                    '#aPost[32]#',
                    <cfif isnumeric(aPost[33])>CONVERT(smallint,'#aPost[33]#')<cfelse>NULL</cfif>,
                    <cfif isnumeric(aPost[34])>CONVERT(int,'#aPost[34]#')<cfelse>NULL</cfif>,
                    <cfif isnumeric(aPost[35])>CONVERT(int,'#aPost[35]#')<cfelse>NULL</cfif>,
                    <cfif isnumeric(aPost[36])>CONVERT(int,'#aPost[36]#')<cfelse>NULL</cfif>,
                    <cfif isnumeric(aPost[37])>CONVERT(int,'#aPost[37]#')<cfelse>NULL</cfif>
                )
            </cfquery>
        </cfloop>
      
      
        <cfset plusMinutes=DateAdd("n", 2, now())>
        
        <!--- check if the task status become EXPIRED - if so, we need to RE-CREATE it --->
        <cfschedule action="list" task="#local.jobName#" result="checkSched" />
        <cfif CompareNoCase(checkSched.status,"EXPIRED") eq 0>
            <cfschedule action="DELETE" task="#local.jobName#">
        </cfif>
        
        <CFSCHEDULE 
            ACTION="UPDATE" 
            TASK="#local.jobName#"
            OPERATION="HTTPRequest"
            starttime="#TimeFormat(plusMinutes,'HH:mm')#" 
            startdate="#DateFormat(now(),'DD-MMM-YYYY')#"
            enddate="#DateFormat(now(),'DD-MMM-YYYY')#"
            ENDTIME="23:58:00"
            URL="#local.fullURL#&sr=#endAtrow#&lq=#loadQty+1#"
            publish="yes"
            PATH = "#application.THIRDGENPLUS_TEMP_DIRECTORY#"
            FILE="YMI_UPLOAD_DATA.txt"
            INTERVAL="once"
            requesttimeout="120"
            >
        <cfoutput>
        <br/>Scheduling tasks: #DateFormat(now(),"DD-MMM-YYYY")# #TimeFormat(now(),"HH:MM:SS")#<br/>
        </cfoutput>
    <cfelse>
        <cfoutput>
            Finished uploading Raw Data
        </cfoutput>
        <CFSCHEDULE 
            ACTION="delete" 
            TASK="#local.jobName#">
            
        <!--- continue to insert data to form --->
        <cfif IsDefined("URL.cont") and URL.cont eq 1>
            <cflocation addtoken="No" url="http://#CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/admin/index.cfm?p=insertDataToForm">
        </cfif>
        <cfoutput>
        <br/>End at: #DateFormat(now(),"DD-MMM-YYYY")# #TimeFormat(now(),"HH:MM:SS")#<br/>
        now go to http://#CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/admin/index.cfm?p=insertDataToForm<br/>
        </cfoutput>
    </cfif>
    
<cfelse>
    <cfoutput>
    Reach Max Iteration at #startAtRow#
    </cfoutput>
    <CFSCHEDULE 
        ACTION="delete" 
        TASK="#local.jobName#">
</cfif>


