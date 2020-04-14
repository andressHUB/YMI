<cfparam name="attributes.maxDaysOld" default="3">
<cfparam name="attributes.dirToBeCleaned" default="">

<cfset deletePriorTo = DateAdd("d",-1*attributes.maxDaysOld,now())> 
<cfdirectory directory="#attributes.dirToBeCleaned#" name="theDirList">
<cfloop query="theDirList">
    <cfset FullFileName = "#attributes.dirToBeCleaned##theDirList.name#">
    <cfset lastModifiedString = theDirList.dateLastModified>
    <cfset doDelete = false>
    <cftry>
        <cfset lastModifiedDate = LSParseDateTime(lastModifiedString)>      
        <cfif lastModifiedDate lt deletePriorTo>
            <cfset doDelete = true>
        </cfif>
        <cfcatch type="any">
            <cfset doDelete = true>
        </cfcatch>
    </cftry>
    <cfif doDelete>
        <cftry>
            <cffile action="DELETE" file="#FullFileName#">
            <cfcatch type="any">
            </cfcatch>
        </cftry>
    </cfif>
</cfloop>