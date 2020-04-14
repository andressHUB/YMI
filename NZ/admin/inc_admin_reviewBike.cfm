<script language="JavaScript">
    var thirdgenRelativeRoot = true;
</script>

<cfif not IsDefined("URL.fid") or URL.fid eq "">
    Failed No Form dAta ID!
<cfelse>
    <cfoutput>
    <a href="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/html/admin.cfm?p=searchData">Back to search</a><br/><br/>
    </cfoutput>
    
    <cfif IsDefined("URL.act") and URL.act neq "">
        <cfset attributes.formAction = URL.act>
    <cfelse>
        <cfset attributes.formAction = "view">
    </cfif>
    <cfset attributes.siteID = session.thirdgenAS.siteID>
    <cfset attributes.formDefID = CONST_bikeDataFormDefId>
    <cfset attributes.formDataId = URL.fid>
    <cfset attributes.redirectURL = "#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/html/admin.cfm?p=searchData">
    <cfset attributes.regUserID = session.thirdgenas.userid>
    
    <cfset attributes.overrideSuppressTreeNodeSelector = false>
    <cfset showTreenodeSelector = false>
    <cfinclude template="..\thirdgen\form\inc_form_handler.cfm">   

</cfif>

