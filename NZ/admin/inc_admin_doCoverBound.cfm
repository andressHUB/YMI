<cfinclude template="../admin/constants.cfm">

<cfset attributes.formUuid = "form260460">
<cfset attributes.formDefId = CONST_bikeQuoteFormDefId>
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

<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteComp_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteOffRoad_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteTPD_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteTPO_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteSelected_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_extraSelected_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteTyreRim_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteLoanProtect_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_loanProtectTerm_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_loanProtectDetails_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteGapCover_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_gapCoverTerm_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteAdminFee_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_quoteFSLFee_FID,'|')#~H")>
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_ignoreCompl_FID,'|')#~H")> 
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_ignoreComplReason_FID,'|')#~H")> 
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_manualEditReason_FID,'|')#~H")> 
<cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_BQ_manualEditor_FID,'|')#~H")> 

<cfset attributes.fml = listAppend(attributes.fml,"CB_NewMotorcycle~R")> 
<cfset attributes.fml = listAppend(attributes.fml,"CB_PurchasedDate~R")> 

<!--- <cfset attributes.redirectURL = "admin.cfm?p=printCoverBound&fdid=#attributes.formDataID#"> --->
<cfset attributes.redirectURL = "admin.cfm?p=printCoverBound&fdid=#attributes.formDataID#&redir=myquotes.cfm&format=pdfEmail">

<cfif IsDefined("form.formSubmitted")>
    <!--- CUSTOM VALIDATION --->
    <cfset validateFormErrorList ="">
    
    <cfif StructKeyExists(FORM,"field_#ListFirst(CONST_BQ_IsModified_FID,'|')#") and StructFind(FORM,"field_#ListFirst(CONST_BQ_IsModified_FID,'|')#") eq "1">
        <cfset tmpString = trim(StructFind(FORM,"field_#ListFirst(CONST_BQ_ModifiedDesc_FID,'|')#"))>
        <cfif tmpString eq "" or len(tmpString) lt 5>
            <cfset validateFormErrorList = ListAppend(validateFormErrorList,"field_#ListFirst(CONST_BQ_ModifiedDesc_FID,'|')#:Please explain modification details")>
        </cfif>
    </cfif>
    
    <cfif StructKeyExists(FORM,"field_#ListFirst(CONST_BQ_Homephone_FID,'|')#") or StructKeyExists(FORM,"field_#ListFirst(CONST_BQ_MobilePhone_FID,'|')#") >
        <cfset tmpStr1 = trim(StructFind(FORM,"field_#ListFirst(CONST_BQ_Homephone_FID,'|')#"))>
        <cfset tmpStr2 = trim(StructFind(FORM,"field_#ListFirst(CONST_BQ_MobilePhone_FID,'|')#"))>
        <cfif (tmpStr1 eq "" or len(tmpStr1) lt 8) and (tmpStr2 eq "" or len(tmpStr2) lt 8)>
            <cfset validateFormErrorList = ListAppend(validateFormErrorList,"field_#ListFirst(CONST_BQ_Homephone_FID,'|')#:Valid home phone or mobile number is required")>
            <cfset validateFormErrorList = ListAppend(validateFormErrorList,"field_#ListFirst(CONST_BQ_MobilePhone_FID,'|')#:Valid home phone or mobile number is required")>
        </cfif>
    </cfif>
    
    <cfif StructKeyExists(FORM,"field_#ListFirst(CONST_BQ_CoverCommDate_FID,'|')#") and StructFind(FORM,"field_#ListFirst(CONST_BQ_CoverCommDate_FID,'|')#") neq "" >
        <cfset tmpDate = LSParseDateTime(StructFind(FORM,"field_#ListFirst(CONST_BQ_CoverCommDate_FID,'|')#"))>
        <cfif DateDiff("d",now(),tmpDate) lt 0>
            <cfset validateFormErrorList = ListAppend(validateFormErrorList,"field_#ListFirst(CONST_BQ_CoverCommDate_FID,'|')#:Invalid Cover Date")>
        </cfif>
    </cfif>
</cfif>

<cfinclude template="..\thirdgen\form\inc_form_handler.cfm">
<cfif IsDefined("session.thirdgenAS.userid") and session.thirdgenAS.userid neq 1> <!--- only Super Admin can view all fields --->
    <cfmodule template="../custom/mod_motorcycleQuoteForm.cfm" incValidation=true formDataId="#attributes.formDataID#">
</cfif>

<cfoutput>
<script type="text/javascript">
var x = document.getElementById("field_#CONST_BQ_QuoteStatus_FID#");
x.value = #CONST_BQ_QuoteStatus_stage3_LID#;
x = document.getElementById("field_#ListFirst(CONST_BQ_ExtId_FID,'|')#");
if(x && x.value != ""){ /* do nothing */ }
else
{
    try {
        x = document.getElementById("tr_field_#ListFirst(CONST_BQ_TotLoanValue_FID,'|')#");
        x.style.display = "none";
    }
    catch(err) {}
}
</script>
</cfoutput>


