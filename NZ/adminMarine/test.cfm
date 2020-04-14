<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfinclude template="../adminMarine/constants.cfm">

      <cfquery name="getTheData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_data_id, fd.xml_data,  fd.last_updated,
        tli_excess.list_item_display as excess_display,
        tli_type.list_item_display as type_display,
        tli_speed.list_item_display as speed_display,
        tli_ll.list_item_display as ll_display,
        tli_constr.list_item_display as const_display,
        tli_boatexp.list_item_display as boatexp_display,
        tli_storage.list_item_display as storage_display
    from thirdgen_form_data fd
    inner join thirdgen_form_header_data fhd on fd.form_data_id = fhd.form_data_id
    left outer join thirdgen_list_item tli_excess on fhd.newlist1 = tli_excess.list_item_id
    left outer join thirdgen_list_item tli_type on fhd.newlist2 = tli_type.list_item_id
    left outer join thirdgen_list_item tli_speed on fhd.newlist3 = tli_speed.list_item_id
    left outer join thirdgen_list_item tli_ll on fhd.newlist4 = tli_ll.list_item_id
    left outer join thirdgen_list_item tli_constr on fhd.newlist5 = tli_constr.list_item_id
    left outer join thirdgen_list_item tli_boatexp on fhd.newlist6 = tli_boatexp.list_item_id
    left outer join thirdgen_list_item tli_storage on fhd.newlist7 = tli_storage.list_item_id
    where fd.form_data_id = 22793
</cfquery>  


<cfwddx action="WDDX2CFML" input="#getTheData.xml_data#" output="quoteFormStruct">
      <cfmodule template="../thirdgen/form/mod_get_form_data.cfm"
        formDefID = "#CONST_marineQuoteFormDefId#"
        formDataId = "#getTheData.form_data_id#"
        output="theData">
        
        <cfif StructKeyExists(quoteFormStruct,ListFirst(CONST_MQ_layUpMths_FID,"|"))
        and StructFind(quoteFormStruct,ListFirst(CONST_MQ_layUpMths_FID,"|")) neq "">
        <cfquery name="getLayUpMonths" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    	select list_item_id, list_item_display, list_item_image
    	from thirdgen_list_item
    	where list_item_id in (#StructFind(quoteFormStruct,ListFirst(CONST_MQ_layUpMths_FID,"|"))#)
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
        
    <cfset data_boatValue = StructFind(quoteFormStruct,ListFirst(CONST_MQ_InsuredValue_FID,"|"))>
	<cfset data_boatTypeID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_BoatType_FID,"|"))>
	<cfset data_boatSpeedID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_BoatSpeed_FID,"|"))>
	<cfset data_boatConstrID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_BoatConst_FID,"|"))>
    <cfset data_boatExcessID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_ExcessOpt_FID ,"|"))>
    <cfset data_boatExpID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_BoatExp_FID ,"|"))>
    <cfset data_boatLiabilityID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_LiabiltyLmt_FID,"|"))>
    <cfset data_boatStorageID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_StorageMethod_FID,"|"))>
    <cfset data_boatAge = StructFind(quoteFormStruct,ListFirst(CONST_MQ_BoatAge_FID,"|"))>
    <cfset data_motorTypeID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_MotorType_FID,"|"))>  
    <cfset data_motorAgeID =  StructFind(quoteFormStruct,ListFirst(CONST_MQ_MotorAge_FID,"|"))>
    <cfset data_sailorAgeID = StructFind(quoteFormStruct,ListFirst(CONST_MQ_SailorAge_FID,"|"))>
    <cfset data_isBoatingCourse = StructFind(quoteFormStruct,ListFirst(CONST_MQ_BoatingCourseOpt_FID,"|"))>
    <cfset data_isStreetParked = StructFind(quoteFormStruct,ListFirst(CONST_MQ_StreetParked_FID,"|"))>
    <cfset data_isWaterSkiers = StructFind(quoteFormStruct,ListFirst(CONST_MQ_SkiersLiabilityOpt_FID,"|"))> 
    <cfset data_isProduction = StructFind(quoteFormStruct,ListFirst(CONST_MQ_BoatProd_FID,"|"))> 
        <cfset data_sailorAge = StructFind(quoteFormStruct,ListFirst(CONST_MQ_SailorAge_FID,"|"))>
        
        
        
<cfmodule template="../adminMarine/mod_ratingMarine.cfm"
            boatValue="#data_boatValue#"
            boatTypeID="#data_boatTypeID#"
            boatSpeedID="#data_boatSpeedID#"
            boatConstrID="#data_boatConstrID#"            
            boatExcessID="#data_boatExcessID#"
            boatExpID="#data_boatExpID#"
            boatLiabilityID="#data_boatLiabilityID#"
            boatStorageID="#data_boatStorageID#"
            boatAge="#data_boatAge#"
            motorTypeID="#data_motorTypeID#"
            motorAgeID="#data_motorAgeID#"
            sailorAge="#data_sailorAge#"
            isBoatingCourse="#data_isBoatingCourse#"
            isStreetParked="#data_isStreetParked#"
            isWaterSkiers="#data_isWaterSkiers#"
        	layupMonths="#data_layUpMths#"
    	    output_comp="compStruct"
    	    output_motoronly="motoronlyStruct"
        	output_tpo="tpoStruct">
        
        <Cfdump var="#compStruct#">
        

</body>
</html>
