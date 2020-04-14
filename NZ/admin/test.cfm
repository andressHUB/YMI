<!--- <cfinclude template="../admin/constants.cfm">
<cfquery name="getTheData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_data_id, fd.xml_data, fd.last_updated, fhd.externallist10 as bikeModelId,
        tli_excess.list_item_display as excess_display,
        tli_excess.list_item_image as excess_discount,
        tli_region.list_item_display as region_display,
        tli_region.list_item_image as region_loading
    from thirdgen_form_data fd
    inner join thirdgen_form_header_data fhd on fd.form_data_id = fhd.form_data_id
    left outer join thirdgen_list_item tli_excess on fhd.newlist1 = tli_excess.list_item_id
    left outer join thirdgen_list_item tli_region on fhd.newlist2 = tli_region.list_item_id
    where fd.form_data_id = 22649
</cfquery>

	<cfwddx action="WDDX2CFML" input="#getTheData.xml_data#" output="quoteFormStruct">
    <cfif StructKeyExists(quoteFormStruct,ListFirst(CONST_BQ_layUpMths_FID,"|"))
        and StructFind(quoteFormStruct,ListFirst(CONST_BQ_layUpMths_FID,"|")) neq "">
        <cfquery name="getLayUpMonths" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    	select list_item_id, list_item_display, list_item_image
    	from thirdgen_list_item
    	where list_item_id in (#StructFind(quoteFormStruct,ListFirst(CONST_BQ_layUpMths_FID,"|"))#)
    	</cfquery>
    <cfelse>
        <cfquery name="getLayUpMonths" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    	select list_item_id, list_item_display, list_item_image
    	from thirdgen_list_item
    	where list_item_id = 0
    	</cfquery>
    </cfif>
    <cfset theLayUpMths = ValueList(getLayUpMonths.list_item_image)>
		
	<cfset data_layUpMths = "">
	<cfloop from="1" to="12" step="1" index="aMonth">
		<cfif ListFind(theLayUpMths,aMonth) gt 0>
			<cfset data_layUpMths = ListAppend(data_layUpMths,1)>
		<cfelse>
			<cfset data_layUpMths = ListAppend(data_layUpMths,0)>
		</cfif>	
	</cfloop>
    
	<cfset data_bikeValue = StructFind(quoteFormStruct,ListFirst(CONST_BQ_InsuredValue_FID,"|"))>
	<cfset data_excessId = StructFind(quoteFormStruct,ListFirst(CONST_BQ_Excess_FID,"|"))>
	<cfset data_regionId = StructFind(quoteFormStruct,ListFirst(CONST_BQ_Region_FID,"|"))>
	<cfset data_riderAge = StructFind(quoteFormStruct,ListFirst(CONST_BQ_Age_FID,"|"))>
	
	<cfquery name="getBikeData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
	select fd.xml_data, fhd.text1 as NVIC
	from thirdgen_form_data fd with (nolock)
	inner join thirdgen_form_header_data fhd with (nolock) on fd.form_data_id = fhd.form_data_id and fd.form_data_id = #getTheData.bikeModelId#
	</cfquery>

    <cfset data_bikeIsInsurable = 0 >
    <cfset data_bikeMake = "">
    <cfset data_bikeYear = "">
    <cfset data_bikeVariant = "">
    <cfset data_bikeFamily = "">
    <cfset data_bikeCode = "">
	<cfset data_bikeModel = "">
    <cfif getBikeData.recordCount eq 0 and getTheData.bikeModelId eq "-1"> <!--- NEW MODEL NOT YET LISTED  --->
        <cfset data_bikeIsInsurable = 1 >
        <cfset data_bikeMake = StructFind(quoteFormStruct,ListFirst(CONST_BQ_customBikeMake,"|")) >
        <cfset data_bikeModel = -1>
        <cfset data_bikeCode = StructFind(quoteFormStruct,ListFirst(CONST_BQ_customBikeDetail1,"|")) & " " & StructFind(quoteFormStruct,ListFirst(CONST_BQ_customBikeDetail2,"|"))>               
    <cfelse>
        <cfwddx action="WDDX2CFML" input="#getBikeData.xml_data#" output="bikeDataStruct">	
    	<cfset data_bikeIsInsurable = StructFind(bikeDataStruct,ListFirst(CONST_BD_IsInsurable_FID,"|"))>
        <cfset data_bikeMake = StructFind(bikeDataStruct,ListFirst(CONST_BD_Make_FID,"|"))>
        <cfset data_bikeYear = StructFind(bikeDataStruct,ListFirst(CONST_BD_Year_FID,"|"))>
        <cfset data_bikeVariant = StructFind(bikeDataStruct,ListFirst(CONST_BD_Variant_FID,"|"))>
        <cfset data_bikeFamily = StructFind(bikeDataStruct,ListFirst(CONST_BD_Family_FID,"|"))>
        <cfset data_bikeCode = StructFind(bikeDataStruct,ListFirst(CONST_BD_Code_FID,"|"))>
    	<cfset data_bikeModel = getBikeData.NVIC>
    </cfif>
    
	<!--- Call rating engine --->
    <cfif data_bikeIsInsurable neq "0" and data_bikeIsInsurable neq "" >
    	<cfmodule template="../admin/ratings.cfm"
        	bikeValue="#data_bikeValue#"
    	    bikeModel="#data_bikeModel#"
        	regionId="#data_regionId#"
    	    excessId="#data_excessId#"
    	    riderAge="#data_riderAge#"
        	layupMonths="#data_layUpMths#"
    	    output_comp="compStruct"
    	    output_offroad="offroadStruct"
        	output_tpd="tpdStruct"
            output_tpo="tpoStruct">
    </cfif>
    
    <cfdump var="#compStruct#"> --->
<!---     
     <CFSCHEDULE 
            ACTION="delete" 
            TASK=" YMI UPLOAD DATA - 2013-07-01 "> --->