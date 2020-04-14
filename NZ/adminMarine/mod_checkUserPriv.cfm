<cfparam name="ATTRIBUTES.userid" default="">
<cfparam name="ATTRIBUTES.userPriv" default="">
<cfinclude template="constants.cfm">
<cfset userType = "USER-PUBLIC">

<cfif ATTRIBUTES.userid eq "">
    <cfif IsDefined("session.thirdgenAS.userid") and IsDefined("session.thirdgenAS.rolecodelist")>
        <cfif ListFindNoCase(ADMIN_USERIDS,session.thirdgenAS.userid) gt 0>
            <cfset userType = "ADMIN-1">
        <cfelseif ListFindNoCase(session.thirdgenAS.roleIdlist,33) gt 0>  <!--- Site Specific : YMI NZ Admin Access --->
            <cfset userType = "ADMIN-2">
        <cfelseif ListFindNoCase(session.thirdgenAS.roleIdlist,29) gt 0>  <!--- Nautilus Wide Admin --->
            <cfset userType = "ADMIN-3">
        <cfelseif ListFindNoCase(session.thirdgenAS.roleIdlist,30) gt 0>  <!--- Nautilus Wide People Quote Admin --->
            <cfset userType = "ADMIN-4">
        <cfelseif ListFindNoCase(session.thirdgenAS.roleIdlist,5) gt 0>  <!--- Thirdgen User Admin --->
            <cfset userType = "ADMIN-5">
        <cfelse>
            <cfset userType = "USER-SECURE">
        </cfif>
    <cfelse>
        <cfset userType = "USER-PUBLIC">
    </cfif>
<cfelse>
    <cfquery name="getUserRoles" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    select ur.user_data_id, r.*
    from thirdgen_user_role ur
    inner join thirdgen_role r on ur.role_id = r.role_id
    where ur.user_data_id = #ATTRIBUTES.userid#
    </cfquery>
    
    <cfif getUserRoles.recordCount gt 0>
        <cfset userRoleIds = ValueList(getUserRoles.role_id)>
        <cfif ListFindNoCase(ADMIN_USERIDS,ATTRIBUTES.userid) gt 0>
            <cfset userType = "ADMIN-1">
        <cfelseif ListFindNoCase(userRoleIds,33) gt 0> <!--- Site Specific : YMI NZ Admin Access --->
            <cfset userType = "ADMIN-2">
        <cfelseif ListFindNoCase(userRoleIds,29) gt 0> <!--- Nautilus Wide Admin ---> 
            <cfset userType = "ADMIN-3">
        <cfelseif ListFindNoCase(userRoleIds,30) gt 0>  <!--- Nautilus Wide People Quote Admin --->
            <cfset userType = "ADMIN-4">
        <cfelseif ListFindNoCase(userRoleIds,5) gt 0>  <!--- Thirdgen User Admin --->
            <cfset userType = "ADMIN-5">
        <cfelse>
            <cfset userType = "USER-SECURE">
        </cfif>
    <cfelse>
        <cfset userType = "USER-PUBLIC">
    </cfif>
</cfif>

<cfif ATTRIBUTES.userPriv neq "">
    <cfset outputVar = "caller.#attributes.userPriv#"> 
    <cfset setVariable(outputVar,userType)>
</cfif>