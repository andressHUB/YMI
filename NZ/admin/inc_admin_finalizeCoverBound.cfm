<cfinclude template="../admin/constants.cfm">

<cfset attributes.formDefID = CONST_bikeQuoteFormDefId>

<cfquery name="getFormData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
select xml_data, form_def_id, form_data_id
from thirdgen_form_data
where form_data_id = #URL.fdid#
</cfquery>

<cfif getFormData.recordCount gt 0>
    <cfwddx action="WDDX2CFML" input="#getFormData.xml_data#" output="theData">
     <cfif StructKeyExists(theData,ListFirst(CONST_BQ_QuoteStatus_FID,"|"))>
          <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_QuoteStatus_FID,"|"),CONST_BQ_QuoteStatus_stage4_LID)>
     <cfelse>
          <cfset x = StructInsert(theData,ListFirst(CONST_BQ_QuoteStatus_FID,"|"),CONST_BQ_QuoteStatus_stage4_LID)>
     </cfif>
     <cfwddx action="CFML2WDDX" input="#theData#" output="theDataWDDX">
        
     <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
     update thirdgen_form_data
     set xml_data = '#theDataWDDX#'
     where form_data_id = #getFormData.form_data_id#
     </cfquery>

    <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#getFormData.form_def_id#" formDataID="#getFormData.form_data_id#">        
</cfif>

<cflocation url="admin.cfm?p=quoteAdmin&fdid=#URL.fdid#" addtoken="no">

