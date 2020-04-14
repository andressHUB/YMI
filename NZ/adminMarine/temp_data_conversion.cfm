<cfsetting requesttimeout="300">
<cfinclude template="constants.cfm">
<!--- 
<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
select fd.form_data_id, fd.form_Def_id, fd.created, fd.last_updated, fd.xml_data, fdlv.field_value as quoteStatus       
from thirdgen_form_data fd
inner join thirdgen_form_header_data fhd on fd.form_data_id =  fhd.form_data_id
left outer join thirdgen_form_data_list_values fdlv on fd.form_data_id = fdlv.form_data_id 
    and fdlv.key_name = '#CONST_MQ_QuoteStatus_FID#'
where fd.form_def_id = #CONST_marineQuoteFormDefId#
</cfquery>

<cfquery name="getEmptyStatus" dbtype="query">
select * from getData
where quoteStatus is null
</cfquery>

<cfset a = 0>
<cfset b = 0>
<cfloop query="getEmptyStatus">
    <cfwddx action="WDDX2CFML" input="#getEmptyStatus.xml_data#" output="xml_data_cfml">
    
    <cfif not StructKeyExists(xml_data_cfml,"20894") or StructFind(xml_data_cfml,"20894") eq "">
        <cfset x = StructInsert(xml_data_cfml,CONST_MQ_QuoteStatus_FID,CONST_MQ_QuoteStatus_stage1_LID,"true")>
    <cfelseif StructFind(xml_data_cfml,"20894") neq "" and StructFind(xml_data_cfml,"20892") neq "">
        <cfset x = StructInsert(xml_data_cfml,CONST_MQ_QuoteStatus_FID,CONST_MQ_QuoteStatus_stage2_LID,"true")>
    <cfelse>
        <cfset x = StructInsert(xml_data_cfml,CONST_MQ_QuoteStatus_FID,CONST_MQ_QuoteStatus_stage1_LID,"true")>
    </cfif>
    
    <cfwddx action="CFML2WDDX" input="#xml_data_cfml#" output="xml_data_wddx">
    <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    update thirdgen_form_data
    set xml_data = '#xml_data_wddx#'
    where form_data_id = #getEmptyStatus.form_data_id#
    </cfquery>

    <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#getEmptyStatus.form_def_id#" formDataID="#getEmptyStatus.form_data_id#">  
    
</cfloop>
 --->




STEP 1
 
 <!--- MUST NOT UPDATE THE FORM DEF FIELD FIRST ON DESTINATION !!!!! --->
<!--- 
 <cfquery name="formDefDefinition" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
 select cms_fdf.form_def_field_id as cms_form_def_field_id , cms_fdf.form_def_id as cms_form_def_id, 
	cms_fdf.form_def_field_type_id as cms_form_def_field_type_id, cms_fdf.prompt as cms_prompt, 
	cms_fdf.key_name as cms_key_name, cms_fdf.short_name as cms_short_name,
	fdf.form_def_id, 
	fdf.form_def_field_type_id, fdf.prompt, fdf.key_name, fdf.short_name
from (
select b.form_def_id, b.form_def_field_type_id, b.prompt, b.key_name, b.short_name, b.internal_key, a.form_def_field_id, a.seq
from [202.40.163.15].[3rdgen_cms05].[dbo].thirdgen_form_def_field a
inner join [202.40.163.15].[3rdgen_cms05].[dbo].thirdgen_form_def_field b on a.form_header_def_id = b.form_def_id 
	and a.form_header_def_field_id = b.form_def_field_id
	and a.form_header_def_id is not null
where a.form_Def_id = 974

union

select a.form_def_id, a.form_def_field_type_id, a.prompt, a.key_name, a.short_name, a.internal_key, a.form_def_field_id, a.seq
from [202.40.163.15].[3rdgen_cms05].[dbo].thirdgen_form_def_field a
where a.form_Def_id = 974
and a.form_header_def_id is null
) cms_fdf
left outer join 
(
select b.form_def_id, b.form_def_field_type_id, b.prompt, b.key_name, b.short_name, b.internal_key, a.form_def_field_id, a.seq
from [as_nautilus].[dbo].thirdgen_form_def_field a
inner join [as_nautilus].[dbo].thirdgen_form_def_field b on a.form_header_def_id = b.form_def_id 
	and a.form_header_def_field_id = b.form_def_field_id
	and a.form_header_def_id is not null
where a.form_Def_id = 974

union

select a.form_def_id, a.form_def_field_type_id, a.prompt, a.key_name, a.short_name, a.internal_key, a.form_def_field_id, a.seq
from [as_nautilus].[dbo].thirdgen_form_def_field a
where a.form_Def_id = 974
and a.form_header_def_id is null
) fdf on cms_fdf.form_def_field_id = fdf.form_def_field_id and cms_fdf.form_def_field_type_id = fdf.form_def_field_type_id
where cms_fdf.key_name COLLATE DATABASE_DEFAULT != fdf.key_name COLLATE DATABASE_DEFAULT
order by cms_fdf.seq
 </cfquery>
 
<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
select fd.form_data_id, fd.form_Def_id, fd.created, fd.last_updated, fd.xml_data      
from thirdgen_form_data fd
where fd.form_def_id = #CONST_marineQuoteFormDefId#
and created >= '1-jan-2015'
--and created < '1-jan-2015'
</cfquery> 

<!--- <cfdump var="#formDefDefinition#"> --->

<cfloop query="getData">
    <cfwddx action="WDDX2CFML" input="#getData.xml_data#" output="xml_data_cfml">
    
    <cfoutput>
    <cfloop query="formDefDefinition">
        <cfif StructKeyExists(xml_data_cfml, formDefDefinition.key_name)>
            <cfset x = StructInsert(xml_data_cfml, formDefDefinition.cms_key_name, StructFind(xml_data_cfml, formDefDefinition.key_name), true)>
            <cfset x = StructDelete(xml_data_cfml, formDefDefinition.key_name)>
        </cfif>
    </cfloop>
    </cfoutput>
    
    
    <cfwddx action="CFML2WDDX" input="#xml_data_cfml#" output="xml_data_wddx">
    <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    update thirdgen_form_data
    set xml_data = '#xml_data_wddx#' --, last_updated = #CreateODBCDateTime(now())#
    where form_data_id = #getData.form_data_id#
    </cfquery>
    
    <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#getData.form_def_id#" formDataID="#getData.form_data_id#">
</cfloop>
done   --->


STEP 2

<!--- 
<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
select fd.form_data_id, fd.form_Def_id, fd.created, fd.last_updated, fd.xml_data  
from thirdgen_form_data fd
inner join thirdgen_form_header_data fhd on fd.form_data_id =  fhd.form_data_id
where fd.form_def_id = #CONST_marineQuoteFormDefId#
and fd.form_data_id in (104280,106550,108987,108285,109076,109233)
--and last_updated > '1-jul-2015'
order by form_Data_id
</cfquery>

<cfloop query="getData">
    <cfwddx action="WDDX2CFML" input="#getData.xml_data#" output="xml_data_cfml">
    
<!---     <cfset theCoverSelected = "">
    <cfif StructKeyExists(xml_data_cfml,"CQ_20894") and StructFind(xml_data_cfml,"CQ_20894") neq "">
        <cfset theCoverSelected = ListAppend(theCoverSelected,StructFind(xml_data_cfml, "CQ_20894"))>
    </cfif>
    
    <cfif StructKeyExists(xml_data_cfml,"CQ_20896") and StructFind(xml_data_cfml,"CQ_20896") neq "" and StructFind(xml_data_cfml,"CQ_20896") neq "0">
        <cfset theCoverSelected = ListAppend(theCoverSelected,"11209")>
        <cfif StructFind(xml_data_cfml,"CQ_20896") eq "$5000 - $195 inc. GST">
            <cfset x = StructInsert(xml_data_cfml, "CQ_quoteGapCover", 195.00, true)>
        <cfelseif StructFind(xml_data_cfml,"CQ_20896") eq "$10000 - $295 inc. GST">
            <cfset x = StructInsert(xml_data_cfml, "CQ_quoteGapCover", 295.00, true)>
        </cfif>
    </cfif>
    <cfset x = StructInsert(xml_data_cfml, "CQ_quoteSelected", theCoverSelected, true)> --->
    
    <cfset x = StructInsert(xml_data_cfml, "CQ_adminFeeTotal", 51.75, true)>  <!--- 57.50 --->
    
    <!--- <cfset insVal = StructFind(xml_data_cfml, "QD_insvalue")>
    <cfset x = StructInsert(xml_data_cfml, "CQ_fslFee", (0.0760 * insVal)/100, true)> --->
    
    <cfwddx action="CFML2WDDX" input="#xml_data_cfml#" output="xml_data_wddx">
    <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    update thirdgen_form_data
    set xml_data = '#xml_data_wddx#'
    where form_data_id = #getData.form_data_id#
    </cfquery>
    
    <!--- reset header field --->
    <!--- <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
     update thirdgen_form_header_data
     set newlist9 = null, text5 = null
     where form_data_id = #getData.form_data_id#
     </cfquery> --->
    
    <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#getData.form_def_id#" formDataID="#getData.form_data_id#">
</cfloop>
done 
 --->