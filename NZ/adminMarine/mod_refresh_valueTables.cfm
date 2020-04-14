<cfparam name="attributes.formDataID" default="0">
<cfparam name="attributes.formDefID" default="0">


<cfif attributes.formDataID neq 0 and attributes.formDataID neq ""
    and attributes.formDefID neq 0 and attributes.formDefID neq "">

    <cfinclude template="../thirdgen/query/qry_form_def_fields.cfm"> <!--- this to get FormDefFieldsQuery --->
    
    <cfquery name="getExistingData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select xml_data
        from thirdgen_form_data
        where form_data_id = #attributes.formDataID#
    </cfquery>
    <cfwddx action="WDDX2CFML" input="#getExistingData.xml_data#" output="formData">

    <!--- delete any existing records from the reference tables for this formDataId --->
    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    delete from thirdgen_form_data_shorttext_values
    where form_data_id = #attributes.formDataID# 
    </cfquery>
    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    delete from thirdgen_form_data_date_values
    where form_data_id = #attributes.formDataID# 
    </cfquery>
    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    delete from thirdgen_form_data_list_values
    where form_data_id = #attributes.formDataID# 
    </cfquery>
    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    delete from thirdgen_form_data_number_values
    where form_data_id = #attributes.formDataID# 
    </cfquery>
    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    delete from thirdgen_form_data_yesno_values
    where form_data_id = #attributes.formDataID# 
    </cfquery>

    <cfloop query="FormDefFieldsQuery">
        <cfif StructKeyExists(formData,key_name)>
        <cfswitch expression="#form_def_field_type_id#">
            <!--- populate shorttext values --->
            <cfcase value=1>
                <cfset keyname = key_name>
                <cfset fieldValue = formData["#keyName#"]>
                <cftry>
                    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" timeout="120">
                    insert into thirdgen_form_data_shorttext_values
                    (form_data_id,form_def_id,form_def_field_id,key_name,field_value)
                    values
                    (#attributes.formDataID#,#form_def_id#,#form_def_field_id#,'#keyname#','#fieldValue#')
                    </cfquery>
                    <cfcatch type="ANY">
                    </cfcatch>
                </cftry>
            </cfcase>
    
            <!--- populate date values --->
            <cfcase value=4>
                <cfset keyname = key_name>
                <cfset fieldValue = formData["#keyName#"]>
                <cfif len(trim(fieldValue)) gt 0>
                	<cfset fieldValueAsDate = LSParseDateTime(fieldValue)>
                    <cfset fieldValue = createODBCDate(fieldValueAsDate)>
                </cfif>
                <cfif fieldValue eq "">
                	<cfset fieldValue = "NULL">
                </cfif>
                <cftry>
                    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" timeout="120">
                    insert into thirdgen_form_data_date_values
                    (form_data_id,form_def_id,form_def_field_id,key_name,field_value)
                    values
                    (#attributes.formDataID#,#form_def_id#,#form_def_field_id#,'#keyname#',#fieldValue#)
                    </cfquery>
                    <cfcatch type="ANY">
                    </cfcatch>
                </cftry>
            </cfcase>
    
            <!--- populate number values --->
            <cfcase value=7>
                <cfset keyname = key_name>
                <cfset fieldValue = formData["#keyName#"]>
                <cfif fieldValue eq "">
                	<cfset fieldValue = "NULL">
                </cfif>
                <cftry>
                    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" timeout="120">
                    insert into thirdgen_form_data_number_values
                    (form_data_id,form_def_id,form_def_field_id,key_name,field_value)
                    values
                    (#attributes.formDataID#,#form_def_id#,#form_def_field_id#,'#keyname#',#fieldValue#)
                    </cfquery>
                    <cfcatch type="ANY">
                    </cfcatch>
                </cftry>
            </cfcase>
    
            <!--- populate yesno values --->
            <cfcase value=8>
                <cfset keyname = key_name>
                <cfset fieldValue = formData["#keyName#"]>
                <cfif fieldValue eq "">
                    <cfset fieldValue = "NULL">
                <cfelse>
                    <cfif FindNoCase(",",fieldValue)>
                        <cfset fieldValue = Left(fieldValue,1)>
                    </cfif>
                </cfif>
                <cftry>
                    <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" timeout="120">
                    insert into thirdgen_form_data_yesno_values
                    (form_data_id,form_def_id,form_def_field_id,key_name,field_value)
                    values
                    (#attributes.formDataID#,#form_def_id#,#form_def_field_id#,'#keyname#',#fieldValue#)
                    </cfquery>
                    <cfcatch type="ANY">
                    </cfcatch>
                </cftry>
            </cfcase>
    
            <!--- populate list values --->
            <cfcase value="11;15" delimiters=";">
                <cfset listType = "L">
                <cfif form_def_field_type_id eq 15>
                	<cfset listType = "E">
                </cfif>
                <cfset keyname = key_name>
                <cfset listItemValue = formData["#keyName#"]>
                <cfloop list="#listItemValue#" index="i">
                    <cftry>
                        <cfquery datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" timeout="120">
                        insert into thirdgen_form_data_list_values
                        (form_data_id,form_def_id,form_def_field_id,key_name,list_type,field_value)
                        values
                        (#attributes.formDataID#,#form_def_id#,#form_def_field_id#,'#keyname#','#listType#','#i#')
                        </cfquery>
                        <cfcatch type="ANY">
                        </cfcatch>
                    </cftry>
                </cfloop>
            </cfcase>
            
        </cfswitch>
        </cfif>
    </cfloop>

</cfif>