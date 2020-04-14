<cfinclude template="constants.cfm">
<cfparam name="attributes.appFormsLoc" default=""> <!--- #application.BASE_FOLDER#admin\appforms\ --->
<cfparam name="attributes.pdfFilename" default="test.pdf">
<cfparam name="attributes.formDataID" default="0">
<cfparam name="attributes.pdfVariable" default="#StructNew()#">
<cfparam name="attributes.createPDF" default=true>
<cfparam name="attributes.output" >

<cfset attributes.formDefId = CONST_bikeQuoteFormDefId>

<cfset thePDFStruct = StructNew()>

<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.created, fd.xml_data, fd.user_data_id
    from thirdgen_form_data fd 
    where fd.form_data_id = #attributes.formDataID#
</cfquery>
<cfwddx action="WDDX2CFML" input="#getData.xml_data#" output="BikeQuoteDetails">

<!--- show the list-item 'real' value - only use this when necessary --->
<cfmodule template="../thirdgen/form/mod_get_form_data.cfm"
    formDefID = "#attributes.formDefId#"
    formDataId = "#attributes.formDataId#"
    output="theData">
    
<!--- distributor | reference_id | dealer_firstname | dealer_lastname --->
<cfloop collection="#attributes.pdfVariable#" item="anItem">
    <cfset x = StructInsert(thePDFStruct,anItem,StructFind(attributes.pdfVariable,anItem),"YES")>
</cfloop>

<cfset coverSelected = "">
<cfif StructKeyExists(BikeQuoteDetails,listGetAt(CONST_BQ_quoteSelected_FID,1,"|"))>
    <cfset coverSelected = StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_quoteSelected_FID,1,"|"))>
</cfif>
<cfset x = StructInsert(thePDFStruct,"opt_coverType",coverSelected,"YES")>
<cfset insTypesChosen = "">
<cfif ListFind(coverSelected,CONST_BQ_QuoteComp_ListItemID) gt 0>
    <cfset insTypesChosen = ListAppend(insTypesChosen,"comprehensive_cover_road_registered")>
<cfelseif ListFind(coverSelected,CONST_BQ_QuoteOffRoad_ListItemID) gt 0>
    <cfset insTypesChosen = ListAppend(insTypesChosen,"comprehensive_cover_non_registered")>
<cfelseif ListFind(coverSelected,CONST_BQ_QuoteTPD_ListItemID) gt 0>
    <cfset insTypesChosen = ListAppend(insTypesChosen,"third_party_theft")>
<cfelseif ListFind(coverSelected,CONST_BQ_QuoteTPO_ListItemID) gt 0>
    <cfset insTypesChosen = ListAppend(insTypesChosen,"third_party_only")>
</cfif>

<cfset x = StructInsert(thePDFStruct,"opt_gapCover","","YES")>
<cfif ListFind(coverSelected,CONST_BQ_QuoteGapCover_ListItemID) gt 0>
    <cfset insTypesChosen = ListAppend(insTypesChosen,"gap_extra")>
    <cfset gapCoverValue = StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_extraSelected_FID,1,"|"))> 
    <cfif findNoCase("$5000",gapCoverValue) gt 0>
         <cfset x = StructInsert(thePDFStruct,"opt_gapCover","opt_5000","YES")>
    <cfelseif findNoCase("$10000",gapCoverValue) gt 0>
         <cfset x = StructInsert(thePDFStruct,"opt_gapCover","opt_10000","YES")>
    </cfif>
</cfif>
<!--- <cfif ListFind(coverSelected,CONST_QuoteTyreRim_ListItemID) gt 0>
    <cfset insTypesChosen = ListAppend(insTypesChosen,"tyre_rim")>
</cfif> --->
<cfif ListFind(coverSelected,CONST_BQ_QuoteLoanProtect_ListItemID) gt 0>
    <cfset insTypesChosen = ListAppend(insTypesChosen,"loan_protection")>
</cfif>

<cfset x = StructInsert(thePDFStruct,"type_of_insurance", insTypesChosen,"YES")>

<cfset gapCoverValue = 0>
<cfif coverSelected neq "">
    <cfset LOCAL_insurancePremium = 0>
    
    <cfloop list="#coverSelected#" index="aCover">
        <cfquery name="getPremiumValue" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_image
            from thirdgen_list_item
            where list_item_id = #aCover#
        </cfquery>
        <cfset temp_insurancePremium = 0>
        <cfif getPremiumValue.recordCount gt 0>
            <cfset temp_insurancePremium = StructFind(BikeQuoteDetails,listGetAt(getPremiumValue.list_item_image,1,"|"))>
            <cfset temp_insurancePremium = reReplaceNoCase(temp_insurancePremium,"[$, ]","","all")>
        </cfif>

        <cfif listGetAt(getPremiumValue.list_item_image,1,"|") eq CONST_BQ_quoteGapCover_FID>
            <cfset gapCoverValue = temp_insurancePremium>
        </cfif>
        
        <cfset LOCAL_insurancePremium =  LOCAL_insurancePremium + temp_insurancePremium>
    </cfloop>
    <cfset LOCAL_insurancePremium =  LOCAL_insurancePremium + reReplaceNoCase(StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_quoteAdminFee_FID,"|")),"[$, ]","","all")>
    <!--- <cfset LOCAL_insurancePremium =  LOCAL_insurancePremium + reReplaceNoCase(StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_quoteFSLFee_FID,"|")),"[$, ]","","all")> --->
    
    <cfset LOCAL_insurancePremium = numberFormat(reReplaceNoCase(LOCAL_insurancePremium,"[$, ]","","all"),",.99")>
    <cfset x = StructInsert(thePDFStruct,"summary_premium","$#LOCAL_insurancePremium#","YES")>
    <cfset x = StructInsert(thePDFStruct,"summary_gap",numberFormat(gapCoverValue,".99"),"YES")>
</cfif>


<cfset LOCAL_excessElected = StructFind(theData,listGetAt(CONST_BQ_Excess_FID,1,"|"))>
<cfif LOCAL_excessElected neq "">
    <cfset x = StructInsert(thePDFStruct,"excess","$"&numberFormat(reReplaceNoCase(LOCAL_excessElected,"[$, ]","","all"),",.99"),"YES")>
    <cfset x = StructInsert(thePDFStruct,"summary_excess","$"&numberFormat(reReplaceNoCase(LOCAL_excessElected,"[$, ]","","all"),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"excess","$0.00","YES")>
    <cfset x = StructInsert(thePDFStruct,"summary_excess","$0.00","YES")>
</cfif>

<!--- <cfset LOCAL_totalPayable = reReplaceNoCase(thePDFStruct.summary_premium,"[$, ]","","all") + reReplaceNoCase(thePDFStruct.summary_gap,"[$, ]","","all")>
<cfset x = StructInsert(thePDFStruct,"summary_payable","$"&numberFormat(LOCAL_totalPayable,",.99"),"YES")> --->
<cfset x = StructInsert(thePDFStruct,"LayUpMonths",StructFind(theData,listGetAt(CONST_BQ_layUpMths_FID,1,"|")),"YES")>

<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_quoteComp_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteComp",numberFormat(StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_quoteComp_FID,1,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteComp","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_quoteOffRoad_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteOffRoad",numberFormat(StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_quoteOffRoad_FID,1,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteOffRoad","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_quoteTPD_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteTPD",numberFormat(StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_quoteTPD_FID,1,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteTPD","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_quoteTPO_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteTPO",numberFormat(StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_quoteTPO_FID,1,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteTPO","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_quoteGapCover_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteGE",numberFormat(StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_quoteGapCover_FID,1,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteGE","","YES")>
</cfif>
<cfif StructKeyExists(theData, listGetAt(CONST_BQ_gapCoverTerm_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteGE_term",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_gapCoverTerm_FID,1,"|")),"YES")>
    <cfset x = StructInsert(thePDFStruct,"quoteGE_term_disp",StructFind(theData, listGetAt(CONST_BQ_gapCoverTerm_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteGE_term","","YES")>
    <cfset x = StructInsert(thePDFStruct,"quoteGE_term_disp","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_quoteTyreRim_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteTR",numberFormat(StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_quoteTyreRim_FID,1,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteTR","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_quoteLoanProtect_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteLP",numberFormat(StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_quoteLoanProtect_FID,1,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteLP","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_loanProtectDetails_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteLP_details",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_loanProtectDetails_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteLP_details","","YES")>
</cfif>
<cfif StructKeyExists(theData, listGetAt(CONST_BQ_loanProtectTerm_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteLP_term",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_loanProtectTerm_FID,1,"|")),"YES")>
    <cfset x = StructInsert(thePDFStruct,"quoteLP_term_disp",StructFind(theData, listGetAt(CONST_BQ_loanProtectTerm_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteLP_term","","YES")>
    <cfset x = StructInsert(thePDFStruct,"quoteLP_term_disp","","YES")>
</cfif>
<!--- INSURANCE DETAILS (end) --->


<!--- STANDARD BIKE DETAILS (start) --->
<cfset x = StructInsert(thePDFStruct,"bikeModel",StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_BikeModel_FID,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"insured_name",StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_FirstName_FID,1,"|")) & " " & StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_Surname_FID,1,"|")),"YES")>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_InsurerSex_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_sex",StructFind(theData,listGetAt(CONST_BQ_InsurerSex_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_sex","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_RidingExp_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_riding_exp",StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_RidingExp_FID,1,"|")),"YES")> 
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_riding_exp","","YES")>
</cfif>
<cfset x = StructInsert(thePDFStruct,"sum_insured","$"&numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99"),"YES")>
<cfset x = StructInsert(thePDFStruct,"bool_had_insurance_refused",StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsRefCan_FID,1,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"bool_had_claims",StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_Claims_FID,1,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"bool_had_convict_charged",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_Charged_FID,1,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"bool_had_license_suspended",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_Suspended_FID,1,"|")),"YES")>

<cfif StructKeyExists(BikeQuoteDetails, "QD_Is_CurrentValid_License")>
    <cfset x = StructInsert(thePDFStruct,"bool_has_current_valid_license",StructFind(BikeQuoteDetails, "QD_Is_CurrentValid_License"),"YES")>
</cfif>    

<cfif StructKeyExists(BikeQuoteDetails, "QD_Is_BusinessUse")>
    <cfset x = StructInsert(thePDFStruct,"bool_is_business_use",StructFind(BikeQuoteDetails, "QD_Is_BusinessUse"),"YES")>
</cfif>    

 <cfset x = StructInsert(thePDFStruct,"had_insurance_refused_detail","","YES")>
 <cfset x = StructInsert(thePDFStruct,"suffered_claims_detail","","YES")>
 <cfset x = StructInsert(thePDFStruct,"charged_with_offence_detail","","YES")>
 <cfset x = StructInsert(thePDFStruct,"had_license_suspended_detail","","YES")>


<!--- If Ignore compliance selected get compliance reason --->
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_ignoreCompl_FID,1,"|")) and StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_ignoreCompl_FID,1,"|")) eq 1>
            
     <!--- Refused or cancelled question --->
     <cfif thePDFStruct.bool_had_insurance_refused eq true>
            <cfset x = StructInsert(thePDFStruct,"had_insurance_refused_detail",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_ignoreComplReason_FID,1,"|")),"YES")>
     </cfif>
     <!--- Suffered claim question --->
     <cfif thePDFStruct.bool_had_claims eq true>
            <cfset x = StructInsert(thePDFStruct,"suffered_claims_detail",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_ignoreComplReason_FID,1,"|")),"YES")>
     </cfif>
     <!--- Charged with offence question --->
     <cfif thePDFStruct.bool_had_convict_charged eq true>
            <cfset x = StructInsert(thePDFStruct,"charged_with_offence_detail",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_ignoreComplReason_FID,1,"|")),"YES")>
     </cfif>
     <!--- License suspended question --->
     <cfif thePDFStruct.bool_had_license_suspended eq true>
            <cfset x = StructInsert(thePDFStruct,"had_license_suspended_detail",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_ignoreComplReason_FID,1,"|")),"YES")>
     </cfif>
     <!--- Current/valid New Zealand Motorcycle License question --->     
     <cfif thePDFStruct.bool_has_current_valid_license eq true>
            <cfset x = StructInsert(thePDFStruct,"has_valid_license",1,"YES")>
     <cfelse>
            <cfset x = StructInsert(thePDFStruct,"has_valid_license",0,"YES")>
     </cfif>         
     <!---  Motorcycle used for any business/ commercial use question --->
     <cfif thePDFStruct.bool_is_business_use eq true>
            <cfset x = StructInsert(thePDFStruct,"is_business_use",1,"YES")>
     <cfelse>
            <cfset x = StructInsert(thePDFStruct,"is_business_use",0,"YES")>
     </cfif>        
</cfif>

<cfif StructFind(thePDFStruct,"bikeModel") neq "">
    <cfif StructFind(thePDFStruct,"bikeModel") eq -1 > <!--- NEW MODEL NOT YET LISTED Bike --->
        <cfset x = StructInsert(thePDFStruct,"detailsManufacturer1",trim(ListFirst(StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_customBikeMake,"|")),"-")),"YES")>
        <cfset x = StructInsert(thePDFStruct,"detailsManufacturer2",trim(ListLast(StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_customBikeMake,"|")),"-")),"YES")>
        <cfset x = StructInsert(thePDFStruct,"detailsModel1","New Model Not Yet Listed","YES")>
        <cfset x = StructInsert(thePDFStruct,"bikeAllDetails",StructFind(theData,ListFirst(CONST_BQ_customBikeStyle,"|")) & " / " & StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_customBikeYear,"|")),"YES")>
        <cfset x = StructInsert(thePDFStruct,"detailsModel2",StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_customBikeDetail1,"|")),"YES")>
        <cfset x = StructInsert(thePDFStruct,"bikeAllDetails",thePDFStruct.bikeAllDetails & " / " & thePDFStruct.detailsModel2,"YES")> <!--- add custom field into all bike details --->
        
    <cfelse>
        <cfmodule template="../thirdgen/form/mod_get_form_data.cfm"
            formDefID = "#CONST_bikeDataFormDefId#"
            formDataId = "#StructFind(thePDFStruct,'bikeModel')#"
            output="theBikeDetailsData">
    
        <cfset x = StructInsert(thePDFStruct,"detailsManufacturer1",evaluate("theBikeDetailsData." & CONST_BD_Make_FID),"YES")>
        <cfset x = StructInsert(thePDFStruct,"detailsManufacturer2","","YES")>
        <cfset x = StructInsert(thePDFStruct,"detailsModel1",evaluate("theBikeDetailsData." & CONST_BD_Code_FID),"YES")>
        
        <cfset detailsModel2 = evaluate("theBikeDetailsData." & CONST_BD_Year_FID) & "/">
        <cfset detailsModel2 = detailsModel2 & evaluate("theBikeDetailsData." & CONST_BD_Variant_FID) & "/">
        <cfset detailsModel2 = detailsModel2 & evaluate("theBikeDetailsData." & CONST_BD_Family_FID)>
        <cfset x = StructInsert(thePDFStruct,"detailsModel2",detailsModel2,"YES")>
        
        <cfset bikeAllDetails = detailsModel2  >
        <cfif CompareNoCase(StructFind(theBikeDetailsData,CONST_BD_Country_FID),"Not Sufficient Data") neq 0>
            <cfset bikeAllDetails = bikeAllDetails & " / " & StructFind(theBikeDetailsData,CONST_BD_Country_FID) >
        </cfif>
        <cfset bikeAllDetails = bikeAllDetails & " <br/> " & APPLICATION.NEWLINE>
        <cfset bikeAllDetails = bikeAllDetails & StructFind(theBikeDetailsData,CONST_BD_Style_FID) & " / ">
        <cfset bikeAllDetails = bikeAllDetails & StructFind(theBikeDetailsData,CONST_BD_Engine_FID) & " <br/> " & APPLICATION.NEWLINE>
        <cfset bikeAllDetails = bikeAllDetails & StructFind(theBikeDetailsData,CONST_BD_Drive_FID) & " / ">
        <cfset bikeAllDetails = bikeAllDetails & StructFind(theBikeDetailsData,CONST_BD_Trans_FID) & " / ">
        <cfset bikeAllDetails = bikeAllDetails & "Tank: " & StructFind(theBikeDetailsData,CONST_BD_Ftank_FID) & " lt" >
        <cfset x = StructInsert(thePDFStruct,"bikeAllDetails",bikeAllDetails,"YES")>
    </cfif>
    
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"detailsManufacturer1","","YES")>
    <cfset x = StructInsert(thePDFStruct,"detailsManufacturer2","","YES")>
    <cfset x = StructInsert(thePDFStruct,"detailsModel1","","YES")>
    <cfset x = StructInsert(thePDFStruct,"detailsModel2","","YES")>
</cfif>

<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_CoverCommDate_FID,1,"|")) and StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_CoverCommDate_FID,1,"|")) neq "">
    <cfset coverStartAt = LSParseDateTime(StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_CoverCommDate_FID,1,"|")))>
    <cfset coverEndAt = DateAdd("yyyy",1,coverStartAt)>
    <cfset x = StructInsert(thePDFStruct,"period_start",DateFormat(coverStartAt,"DD/MM/YYYY"),"YES")>
    <cfset x = StructInsert(thePDFStruct,"period_end",DateFormat(coverEndAt,"DD/MM/YYYY"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"period_start","","YES")>
    <cfset x = StructInsert(thePDFStruct,"period_end","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_InsurerDOB_FID,1,"|"))>
    <cfset tempDate = StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_InsurerDOB_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_dob",tempDate,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_dob","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_InsuredAddStreet_FID,1,"|"))>
    <cfset tempStr = StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_InsuredAddStreet_FID,1,"|"))>
    <cfset tempStr = replaceNoCase(tempStr,NewLineChars,", ","ALL")>
    <cfset x = StructInsert(thePDFStruct,"insured_streetAddress",tempStr,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_streetAddress","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_InsuredAddPost_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_postcode",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_InsuredAddPost_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_postcode","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_InsuredAddPost_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_state",StructFind(theData, listGetAt(CONST_BQ_State_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_state","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_InsuredAddPost_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_stateArea",StructFind(theData, listGetAt(CONST_BQ_StateArea_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_stateArea","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_Homephone_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_phone_home",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_Homephone_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_phone_home","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_MobilePhone_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_phone_mobile",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_MobilePhone_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_phone_mobile","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_Email_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_email",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_Email_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_email","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_Occupation_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_occupation",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_Occupation_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_occupation","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_NCB_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_ncb",StructFind(theData, listGetAt(CONST_BQ_NCB_FID,1,"|")),"YES")>
    <cfset x = StructInsert(thePDFStruct,"insured_ncb_disp",StructFind(theData, listGetAt(CONST_BQ_NCB_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_ncb","","YES")>
    <cfset x = StructInsert(thePDFStruct,"insured_ncb_disp","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_InterestedParties_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_interestedParties",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_InterestedParties_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_interestedParties","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_RegoNo_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_rego_no",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_RegoNo_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_rego_no","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_VinNo_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_vin_no",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_VinNo_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_vin_no","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_PurchasedDate_FID,1,"|"))>
    <cfset tempDate = StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_PurchasedDate_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_purchase_date",tempDate,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_purchase_date","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_StorageAddress_FID,1,"|"))>
    <cfset tempStr = StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_StorageAddress_FID,1,"|"))>
    <cfset tempStr = replaceNoCase(tempStr,NewLineChars,", ","ALL")>
    <cfset x = StructInsert(thePDFStruct,"bike_storageAddress",tempStr,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_storageAddress","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_StoragePostcode_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_storagePostcode",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_StoragePostcode_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_storagePostcode","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_StorageMethod_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_storageMethod",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_StorageMethod_FID,1,"|")),"YES")>
    <cfset x = StructInsert(thePDFStruct,"bike_storageMethod_disp",StructFind(theData, listGetAt(CONST_BQ_StorageMethod_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_storageMethod","","YES")>
    <cfset x = StructInsert(thePDFStruct,"bike_storageMethod_disp","","YES")>
</cfif>
<cfif StructKeyExists(theData, listGetAt(CONST_BQ_IsModified_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_is_modified",StructFind(theData, listGetAt(CONST_BQ_IsModified_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_is_modified","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_ModifiedDesc_FID ,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_is_modified_desc",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_ModifiedDesc_FID ,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_is_modified_desc","","YES")>
</cfif>
<cfif StructKeyExists(theData, listGetAt(CONST_BQ_IsUsable_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_is_usable",StructFind(theData, listGetAt(CONST_BQ_IsUsable_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_is_usable","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_UsableDesc_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_is_usable_desc",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_UsableDesc_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_is_usable_desc","","YES")>
</cfif>
<cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_PurchasePrice_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"bike_purchase_price",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_PurchasePrice_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"bike_purchase_price","","YES")>
</cfif>
<cfif StructKeyExists(theData, listGetAt(CONST_BQ_paymentType_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"payment_type",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_paymentType_FID,1,"|")),"YES")>
    <cfset x = StructInsert(thePDFStruct,"payment_type_disp",StructFind(theData, listGetAt(CONST_BQ_paymentType_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"payment_type","","YES")>
    <cfset x = StructInsert(thePDFStruct,"payment_type_disp","","YES")>
</cfif>

<cfset x = StructInsert(thePDFStruct,"bike_storageSuburb","","YES")>
<cfset x = StructInsert(thePDFStruct,"insured_suburb","","YES")>

<!--- STANDARD BIKE DETAILS (end) --->

    
<cfset discountJan = "">
<cfset discountFeb = "">
<cfset discountMar = "">
<cfset discountApr = "">
<cfset discountMay = "">
<cfset discountJun = "">
<cfset discountJul = "">
<cfset discountAug = "">
<cfset discountSep = "">
<cfset discountOct = "">
<cfset discountNov = "">
<cfset discountDec = "">
<cfif findNoCase("jan", thePDFStruct.LayUpMonths) gt 0><cfset discountJan="1"></cfif>
<cfif findNoCase("feb", thePDFStruct.LayUpMonths) gt 0><cfset discountFeb="1"></cfif>
<cfif findNoCase("mar", thePDFStruct.LayUpMonths) gt 0><cfset discountMar="1"></cfif>
<cfif findNoCase("apr", thePDFStruct.LayUpMonths) gt 0><cfset discountApr="1"></cfif>
<cfif findNoCase("may", thePDFStruct.LayUpMonths) gt 0><cfset discountMay="1"></cfif>
<cfif findNoCase("jun", thePDFStruct.LayUpMonths) gt 0><cfset discountJun="1"></cfif>
<cfif findNoCase("jul", thePDFStruct.LayUpMonths) gt 0><cfset discountJul="1"></cfif>
<cfif findNoCase("aug", thePDFStruct.LayUpMonths) gt 0><cfset discountAug="1"></cfif>
<cfif findNoCase("sep", thePDFStruct.LayUpMonths) gt 0><cfset discountSep="1"></cfif>
<cfif findNoCase("oct", thePDFStruct.LayUpMonths) gt 0><cfset discountOct="1"></cfif>
<cfif findNoCase("nov", thePDFStruct.LayUpMonths) gt 0><cfset discountNov="1"></cfif>
<cfif findNoCase("dec", thePDFStruct.LayUpMonths) gt 0><cfset discountDec="1"></cfif>

<cfif attributes.appFormsLoc neq "">
    <!--- 
    date_of_signature
    payment_type
    card_type
    card_number_1
    card_number_2
    card_number_3
    card_number_4
    card_number_5
    card_number_6
    card_number_7
    card_number_8
    card_number_9
    card_number_10
    card_number_11
    card_number_12
    card_number_13
    card_number_14
    card_number_15
    card_number_16
    card_expiry_day
    card_expiry_month
    card_expiry_year
    name_on_card
    pay_by_the_month
    --->
    <cfset tmpFile = "pdfResponse_motorcycle_YMINZ_#attributes.formDataId#.pdf">
    <!--- <cfif LSParseDateTime(thePDFStruct.period_start) lt CreateDateTime(2015,  10,  1, 00, 00, 00)>
        <cfset sourceTemplate = "#application.BASE_FOLDER#admin\pdf_template\YMINZ_Motor_application_online_form_2014.pdf">
    <cfelse>
        <cfset sourceTemplate = "#application.BASE_FOLDER#admin\pdf_template\YMINZ_Motorcycle_application_online_form.pdf">
    </cfif>    --->
    <!--- <cfset sourceTemplate = "#application.BASE_FOLDER#admin\pdf_template\YMINZ_Motorcycle_application_online_form.pdf"> --->
    <cfif LSParseDateTime(thePDFStruct.period_start) lt CreateDateTime(2018,  08,  30, 00, 00, 00)>
        <cfset sourceTemplate = "#application.BASE_FOLDER#admin\pdf_template\YMINZ_Motorcycle_application_online_form.pdf">
    <cfelse>
        <cfset sourceTemplate = "#application.BASE_FOLDER#admin\pdf_template\YMINZ_Motorcycle_application_online_form_30082018.pdf">
    </cfif>    
    
         
    <cfpdfform source="#sourceTemplate#" destination="#attributes.appFormsLoc##tmpFile#" overwrite="yes" action="populate">        
        <cfpdfformparam name="distributor" value="#thePDFStruct.distributor#">
        <cfpdfformparam name="reference_id" value="#thePDFStruct.reference_id#">
        <cfpdfformparam name="type_of_insurance" value="#ListFirst(thePDFStruct.type_of_insurance)#">
        <cfpdfformparam name="usage" value="private">
        <cfpdfformparam name="period_from" value="#thePDFStruct.period_start#">
        <cfpdfformparam name="period_to" value="#thePDFStruct.period_end#">
        <cfpdfformparam name="insured_name" value="#thePDFStruct.insured_name#">
        <cfpdfformparam name="insured_date_of_birth" value="#thePDFStruct.insured_dob#"> 
        <cfpdfformparam name="insured_address" value="#thePDFStruct.insured_streetAddress#">
        <cfpdfformparam name="postcode" value="#thePDFStruct.insured_postcode#">
        <cfpdfformparam name="phone_home" value="#thePDFStruct.insured_phone_home#"> 
        <cfpdfformparam name="phone_mobile" value="#thePDFStruct.insured_phone_mobile#"> 
        <cfpdfformparam name="email" value="#thePDFStruct.insured_email#"> 
        <cfpdfformparam name="occupation" value="#thePDFStruct.insured_occupation#"> 
        <cfpdfformparam name="interested_parties" value="#thePDFStruct.insured_interestedParties#"> 
        <cfpdfformparam name="details_manufacturer_1" value="#thePDFStruct.detailsManufacturer1#">
        <cfpdfformparam name="details_model_1" value="#thePDFStruct.detailsModel1#">
        <cfpdfformparam name="details_registration_1" value="#thePDFStruct.bike_rego_no#">
        <cfpdfformparam name="details_chassis_no_1" value="#thePDFStruct.bike_vin_no#">
        <cfpdfformparam name="details_sum_insured_1" value="#thePDFStruct.sum_insured#">
        <cfpdfformparam name="details_date_of_purchase_1" value="#thePDFStruct.bike_purchase_date#">
        <cfpdfformparam name="details_manufacturer_2" value="#thePDFStruct.detailsManufacturer2#">
        <cfpdfformparam name="details_model_2" value="#thePDFStruct.detailsModel2#">
        <cfpdfformparam name="details_registration_2" value="">
        <cfpdfformparam name="details_chassis_no_2" value="">
        <cfpdfformparam name="details_sum_insured_2" value="">
        <cfpdfformparam name="details_date_of_purchase_2" value="">
        <cfpdfformparam name="normal_storage_address" value="#thePDFStruct.bike_storageAddress#"> 
        <cfpdfformparam name="mods" value="#thePDFStruct.bike_is_modified#"> 
        <cfpdfformparam name="mods_details" value="#thePDFStruct.bike_is_modified_desc#"> 
        <cfpdfformparam name="suitable" value="#thePDFStruct.bike_is_usable#"> 
        <cfpdfformparam name="suitable_details" value="#thePDFStruct.bike_is_usable_desc#"> 
        <cfpdfformparam name="gap_cover" value="#thePDFStruct.opt_gapCover#">
        <cfpdfformparam name="discount_jan" value="#discountJan#">
        <cfpdfformparam name="discount_feb" value="#discountFeb#">
        <cfpdfformparam name="discount_mar" value="#discountMar#">
        <cfpdfformparam name="discount_apr" value="#discountApr#">
        <cfpdfformparam name="discount_may" value="#discountMay#">
        <cfpdfformparam name="discount_jun" value="#discountJun#">
        <cfpdfformparam name="discount_jul" value="#discountJul#">
        <cfpdfformparam name="discount_aug" value="#discountAug#">
        <cfpdfformparam name="discount_sep" value="#discountSep#">
        <cfpdfformparam name="discount_oct" value="#discountOct#">
        <cfpdfformparam name="discount_nov" value="#discountNov#">
        <cfpdfformparam name="discount_dec" value="#discountDec#">
        <cfpdfformparam name="rider_name_1" value="#thePDFStruct.insured_name#">
        <cfpdfformparam name="rider_dob_1" value="#thePDFStruct.insured_dob#"> 
        <cfpdfformparam name="rider_gender_1" value="#thePDFStruct.insured_sex#"> 
        <cfpdfformparam name="rider_experience_1" value="#thePDFStruct.insured_riding_exp#"> 
        <cfpdfformparam name="rider_name_2" value="">
        <cfpdfformparam name="rider_dob_2" value="">
        <cfpdfformparam name="rider_gender_2" value="">
        <cfpdfformparam name="rider_experience_2" value="">
        <cfpdfformparam name="rider_name_3" value="">
        <cfpdfformparam name="rider_dob_3" value="">
        <cfpdfformparam name="rider_gender_3" value="">
        <cfpdfformparam name="rider_experience_3" value="">
        
        <cfpdfformparam name="had_insurance_refused" value="#thePDFStruct.bool_had_insurance_refused#">
        <cfpdfformparam name="had_insurance_refused_detail" value="#thePDFStruct.had_insurance_refused_detail#">
        <cfpdfformparam name="suffered_claims" value="#thePDFStruct.bool_had_claims#">
        <cfpdfformparam name="suffered_claims_detail" value="#thePDFStruct.suffered_claims_detail#">
        <cfpdfformparam name="charged_with_offence" value="#thePDFStruct.bool_had_convict_charged#">
        <cfpdfformparam name="charged_with_offence_detail" value="#thePDFStruct.charged_with_offence_detail#">
        <cfpdfformparam name="had_license_suspended" value="#thePDFStruct.bool_had_license_suspended#">
        
        <cfif StructKeyExists(thePDFStruct, "bool_has_current_valid_license") and StructKeyExists(thePDFStruct, "bool_is_business_use") >
            <cfpdfformparam name="has_valid_license" value="#thePDFStruct.bool_has_current_valid_license#">
            <cfpdfformparam name="is_business_use" value="#thePDFStruct.bool_is_business_use#">
        </cfif>
        
        <cfpdfformparam name="had_license_suspended_detail" value="#thePDFStruct.had_license_suspended_detail#">
        
        <cfpdfformparam name="excess_elected" value="#thePDFStruct.excess#">
        <cfpdfformparam name="insurance_premium" value="#thePDFStruct.summary_premium#">
        <cfpdfformparam name="gap_premium" value="#thePDFStruct.summary_gap#">
        <cfpdfformparam name="total_payable" value="#thePDFStruct.summary_premium#"> <!--- summary_payable --->
        
        <cfpdfformparam name="amount" value="#replace(thePDFStruct.summary_premium,'$','')#"> <!--- summary_payable --->
        <cfpdfformparam name="representative_name" value="#thePDFStruct.dealer_firstname# #thePDFStruct.dealer_lastname#">
        
    </cfpdfform>
    
    
    <!--- <cfpdfform source="#sourceTemplate#" destination="#attributes.appFormsLoc##attributes.pdfFilename#" overwrite="yes" action="populate">        
        <cfpdfformparam name="distributor" value="#thePDFStruct.distributor#">
        <cfpdfformparam name="reference_id" value="#thePDFStruct.reference_id#">
        <cfpdfformparam name="type_of_insurance" value="#ListFirst(thePDFStruct.type_of_insurance)#">
        <cfpdfformparam name="usage" value="private">
        <cfpdfformparam name="period_from" value="#thePDFStruct.period_start#">
        <cfpdfformparam name="period_to" value="#thePDFStruct.period_end#">
        <cfpdfformparam name="insured_name" value="#thePDFStruct.insured_name#">
        <cfpdfformparam name="insured_date_of_birth" value="#thePDFStruct.insured_dob#"> 
        <cfpdfformparam name="insured_address" value="#thePDFStruct.insured_streetAddress#">
        <cfpdfformparam name="postcode" value="#thePDFStruct.insured_postcode#">
        <cfpdfformparam name="phone_home" value="#thePDFStruct.insured_phone_home#"> 
        <cfpdfformparam name="phone_mobile" value="#thePDFStruct.insured_phone_mobile#"> 
        <cfpdfformparam name="email" value="#thePDFStruct.insured_email#"> 
        <cfpdfformparam name="occupation" value="#thePDFStruct.insured_occupation#"> 
        <cfpdfformparam name="interested_parties" value="#thePDFStruct.insured_interestedParties#"> 
        <cfpdfformparam name="details_manufacturer_1" value="#thePDFStruct.detailsManufacturer1#">
        <cfpdfformparam name="details_model_1" value="#thePDFStruct.detailsModel1#">
        <cfpdfformparam name="details_registration_1" value="#thePDFStruct.bike_rego_no#">
        <cfpdfformparam name="details_chassis_no_1" value="#thePDFStruct.bike_vin_no#">
        <cfpdfformparam name="details_sum_insured_1" value="#thePDFStruct.sum_insured#">
        <cfpdfformparam name="details_date_of_purchase_1" value="#thePDFStruct.bike_purchase_date#">
        <cfpdfformparam name="details_manufacturer_2" value="#thePDFStruct.detailsManufacturer2#">
        <cfpdfformparam name="details_model_2" value="#thePDFStruct.detailsModel2#">
        <cfpdfformparam name="details_registration_2" value="">
        <cfpdfformparam name="details_chassis_no_2" value="">
        <cfpdfformparam name="details_sum_insured_2" value="">
        <cfpdfformparam name="details_date_of_purchase_2" value="">
        <cfpdfformparam name="normal_storage_address" value="#thePDFStruct.bike_storageAddress#"> 
        <cfpdfformparam name="mods" value="#thePDFStruct.bike_is_modified#"> 
        <cfpdfformparam name="mods_details" value="#thePDFStruct.bike_is_modified_desc#"> 
        <cfpdfformparam name="suitable" value="#thePDFStruct.bike_is_usable#"> 
        <cfpdfformparam name="suitable_details" value="#thePDFStruct.bike_is_usable_desc#"> 
        <cfpdfformparam name="gap_cover" value="#thePDFStruct.opt_gapCover#">
        <cfpdfformparam name="discount_jan" value="#discountJan#">
        <cfpdfformparam name="discount_feb" value="#discountFeb#">
        <cfpdfformparam name="discount_mar" value="#discountMar#">
        <cfpdfformparam name="discount_apr" value="#discountApr#">
        <cfpdfformparam name="discount_may" value="#discountMay#">
        <cfpdfformparam name="discount_jun" value="#discountJun#">
        <cfpdfformparam name="discount_jul" value="#discountJul#">
        <cfpdfformparam name="discount_aug" value="#discountAug#">
        <cfpdfformparam name="discount_sep" value="#discountSep#">
        <cfpdfformparam name="discount_oct" value="#discountOct#">
        <cfpdfformparam name="discount_nov" value="#discountNov#">
        <cfpdfformparam name="discount_dec" value="#discountDec#">
        <cfpdfformparam name="rider_name_1" value="#thePDFStruct.insured_name#">
        <cfpdfformparam name="rider_dob_1" value="#thePDFStruct.insured_dob#"> 
        <cfpdfformparam name="rider_gender_1" value="#thePDFStruct.insured_sex#"> 
        <cfpdfformparam name="rider_experience_1" value="#thePDFStruct.insured_riding_exp#"> 
        <cfpdfformparam name="rider_name_2" value="">
        <cfpdfformparam name="rider_dob_2" value="">
        <cfpdfformparam name="rider_gender_2" value="">
        <cfpdfformparam name="rider_experience_2" value="">
        <cfpdfformparam name="rider_name_3" value="">
        <cfpdfformparam name="rider_dob_3" value="">
        <cfpdfformparam name="rider_gender_3" value="">
        <cfpdfformparam name="rider_experience_3" value="">
        
        <cfpdfformparam name="had_insurance_refused" value="#thePDFStruct.bool_had_insurance_refused#">
        <cfpdfformparam name="had_insurance_refused_detail" value="#thePDFStruct.had_insurance_refused_detail#">
        <cfpdfformparam name="suffered_claims" value="#thePDFStruct.bool_had_claims#">
        <cfpdfformparam name="suffered_claims_detail" value="#thePDFStruct.suffered_claims_detail#">
        <cfpdfformparam name="charged_with_offence" value="#thePDFStruct.bool_had_convict_charged#">
        <cfpdfformparam name="charged_with_offence_detail" value="#thePDFStruct.charged_with_offence_detail#">
        <cfpdfformparam name="had_license_suspended" value="#thePDFStruct.bool_had_license_suspended#">
        
        <cfif StructKeyExists(thePDFStruct, "bool_has_current_valid_license") and StructKeyExists(thePDFStruct, "bool_is_business_use") >
            <cfpdfformparam name="has_valid_license" value="#thePDFStruct.bool_has_current_valid_license#">
            <cfpdfformparam name="is_business_use" value="#thePDFStruct.bool_is_business_use#">
        </cfif>
        
        <cfpdfformparam name="had_license_suspended_detail" value="#thePDFStruct.had_license_suspended_detail#">
        
        <cfpdfformparam name="excess_elected" value="#thePDFStruct.excess#">
        <cfpdfformparam name="insurance_premium" value="#thePDFStruct.summary_premium#">
        <cfpdfformparam name="gap_premium" value="#thePDFStruct.summary_gap#">
        <cfpdfformparam name="total_payable" value="#thePDFStruct.summary_premium#"> <!--- summary_payable --->
        
        <cfpdfformparam name="amount" value="#replace(thePDFStruct.summary_premium,'$','')#"> <!--- summary_payable --->
        <cfpdfformparam name="representative_name" value="#thePDFStruct.dealer_firstname# #thePDFStruct.dealer_lastname#">
        
    </cfpdfform> --->
    
    <cfpdf action="write" destination="#attributes.appFormsLoc##attributes.pdfFilename#" flatten="yes" source="#attributes.appFormsLoc##tmpFile#" overwrite="yes">
    <cftry>
        <cffile action="DELETE" file="#attributes.appFormsLoc##tmpFile#">
        <cfcatch type="Any">
        </cfcatch>
    </cftry>
</cfif>

<cfset outputVar = "caller.#attributes.output#"> 
<cfset setVariable(outputVar,thePDFStruct)>
