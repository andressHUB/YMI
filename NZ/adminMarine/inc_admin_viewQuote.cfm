<cfinclude template="../adminMarine/constants.cfm">
<cfparam name="URL.fdid" default="0">


<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_data_id, fd.created, fd.last_updated, fdlv.field_value as quoteStatus
    from thirdgen_form_data fd
    left outer join thirdgen_form_data_list_values fdlv on fd.form_data_id = fdlv.form_data_id 
        and fdlv.key_name = '#CONST_MQ_QuoteStatus_FID#'
    where fd.form_data_id = #URL.fdid#
</cfquery>

<cfset attributes.formdefid = CONST_marineQuoteFormDefId>
<cfset attributes.formDataId = URL.fdid>
<cfset attributes.siteid =  session.thirdgenAS.siteID>
<cfset attributes.formaction = "VIEW">

<cfif getData.quoteStatus eq CONST_MQ_QuoteStatus_stage3_LID or getData.quoteStatus eq CONST_MQ_QuoteStatus_stage4_LID>
    <!--- do nothing --->
<cfelse>
    <cfinclude template="../thirdgen/query/qry_form_def_fields.cfm" >
    <cfquery name="CBFields" dbtype="query">
    select key_name
    from FormDefFieldsQuery
    where key_name like 'CB_%'
    </cfquery>
    
    <cfif NOT isdefined("attributes.fml")>
        <cfset attributes.fml="">
    </cfif>
    <cfloop query="CBFields">
    <cfset attributes.fml = listAppend(attributes.fml,"#CBFields.key_name#~H")>
    </cfloop>
</cfif>

<cfinclude template="..\thirdgen\form\inc_form_handler.cfm">

<cfif IsDefined("session.thirdgenAS.userid") and session.thirdgenAS.userid neq 1> <!--- only Super Admin can view all fields --->
    <cfif FileExists(ExpandPath("../custom/mod_marineQuoteForm.cfm"))>
        <cfmodule template="../custom/mod_marineQuoteForm.cfm" formDataId="#attributes.formDataId#" incValidation=false>
    </cfif>
</cfif>