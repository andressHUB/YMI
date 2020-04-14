<cfsetting requesttimeout="180">
<cfif IsDefined("FORM.FIELDNAMES")>
<cfloop list="#FORM.FIELDNAMES#" index="aField">
    <cfif ucase(left(aField,10) ) eq "INP_ISINS_" and StructFind(FORM,aField) neq "">
        <cfset formDataID = ReplaceNoCase(aField,"INP_ISINS_","")>
        <cfquery name="getFormData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select xml_data
        from thirdgen_form_data
        where form_data_id = #formDataID#
        </cfquery>
        
        <cfif getFormData.recordCount gt 0>
            <cfwddx action="WDDX2CFML" input="#getFormData.xml_data#" output="theData">
            <cfif StructKeyExists(theData,CONST_BD_IsInsurable_FID)>
                 <cfset x = StructUpdate(theData,CONST_BD_IsInsurable_FID,StructFind(FORM,aField))>
            <cfelse>
                 <cfset x = StructInsert(theData,CONST_BD_IsInsurable_FID,StructFind(FORM,aField))>
            </cfif>           
            <cfif StructKeyExists(theData,CONST_BD_ReviewedDate_FID)>
                 <cfset x = StructUpdate(theData,CONST_BD_ReviewedDate_FID,DateFormat(now(),"DD/MM/YYYY"))>
            <cfelse>
                 <cfset x = StructInsert(theData,CONST_BD_ReviewedDate_FID,DateFormat(now(),"DD/MM/YYYY"))>
            </cfif> 
            <cfwddx action="CFML2WDDX" input="#theData#" output="theDataWDDX">
            
            <cfquery name="updateInsurable" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            update  thirdgen_form_data
            set xml_data = '#theDataWDDX#'
            where form_data_id = #formDataID#
            
            update thirdgen_form_header_data
            set yesno1 = #StructFind(FORM,aField)#, date1 = #CreateODBCDateTime(now())#
            where form_data_id = #formDataID#
            </cfquery>
            
            <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#CONST_bikeDataFormDefId#" formDataID="#formDataID#">
        </cfif>
    </cfif>
</cfloop>
</cfif>
<cfif IsDefined("URL.redir") and URL.redir neq "">
    <cflocation url="admin.cfm?#URLDecode(URL.redir)#" addtoken="no">
<cfelse>
    <cflocation url="admin.cfm?p=searchData" addtoken="no">
</cfif>
