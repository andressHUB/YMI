<cfinclude template="../adminMarine/constants.cfm">

<cfset attributes.formUuid = "form418530">
<cfset attributes.formDefId = CONST_marineQuoteFormDefId>
<cfset attributes.registrationID = 1> <!--- this is hack ?! --->
<cfset attributes.siteID = session.thirdgenAS.siteID>
<cfset attributes.regUserID = session.thirdgenas.userid>
<cfset attributes.formDataID = URL.fdid>
<cfset attributes.formAction = "edit">
<cfif IsDefined("URL.formact") and URL.formact neq "">
    <cfset attributes.formAction = URL.formact>
</cfif>
<cfif NOT isdefined("attributes.fml")>
    <cfset attributes.fml="">
</cfif>

<cfinclude template="../thirdgen/query/qry_form_def_fields.cfm" >
<cfquery name="readOnlyFields" dbtype="query">
select key_name
from FormDefFieldsQuery
where key_name not like 'CB_%'
</cfquery>
<cfloop query="readOnlyFields">
<cfset attributes.fml = listAppend(attributes.fml,"#readOnlyFields.key_name#~R")>
</cfloop>

<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteComp_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteMotorOnly_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteTPO_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteSelected_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_extraSelected_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteGapCover_FID,'|')#~H")>

<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteAdminFee_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteFSLFee_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_ignoreCompl_FID,'|')#~H")> 
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_ignoreComplReason_FID,'|')#~H")> 
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_manualEditReason_FID,'|')#~H")> 
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_manualEditor_FID,'|')#~H")> 

<cfset attributes.fml = listAppend(attributes.fml,"CB_NewMotorcycle~R")> 
<cfset attributes.fml = listAppend(attributes.fml,"CB_PurchasedDate~R")> 

<!--- <cfset attributes.redirectURL = "adminMarine.cfm?act=printCoverBound&fdid=#attributes.formDataID#"> --->
<cfset attributes.redirectURL = "adminMarine.cfm?act=printCoverBound&fdid=#attributes.formDataID#&redir=myquotes_marine.cfm&format=pdfEmail">

<cfinclude template="..\thirdgen\form\inc_form_handler.cfm">
<cfif IsDefined("session.thirdgenAS.userid") and session.thirdgenAS.userid neq 1> <!--- only Super Admin can view all fields --->
    <cfmodule template="../custom/mod_marineQuoteForm.cfm" incValidation=true formDataId="#attributes.formDataID#">
</cfif>

<cfoutput>
<script type="text/javascript">
var x = document.getElementById("field_#CONST_MQ_QuoteStatus_FID#");
x.value = #CONST_MQ_QuoteStatus_stage3_LID#;
x = document.getElementById("field_#ListFirst(CONST_MQ_ExtId_FID,'|')#");
if(x && x.value != ""){ /* do nothing */ }
else
{
    try {
        x = document.getElementById("tr_field_#ListFirst(CONST_MQ_TotLoanValue_FID,'|')#");
        x.style.display = "none";
    }
    catch(err) {}
}
</script>
</cfoutput>


