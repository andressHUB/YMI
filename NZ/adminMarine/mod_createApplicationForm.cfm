<cfinclude template="constants.cfm">
<cfparam name="attributes.appFormsLoc" default=""> <!--- #application.BASE_FOLDER#adminMarine\appforms\ --->
<cfparam name="attributes.pdfFilename" default="test.pdf">
<cfparam name="attributes.formDataID" default="0">
<cfparam name="attributes.pdfVariable" default="#StructNew()#">
<cfparam name="attributes.createPDF" default=true>
<cfparam name="attributes.output" >

<cfset attributes.formDefId = CONST_marineQuoteFormDefId>

<cfset thePDFStruct = StructNew()>

<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.created, fd.xml_data, fd.user_data_id,fd.last_updated
    from thirdgen_form_data fd 
    where fd.form_data_id = #attributes.formDataID#
</cfquery>
<cfwddx action="WDDX2CFML" input="#getData.xml_data#" output="BoatQuoteDetails">

<!--- show the list-item 'real' value - only use this when necessary --->
<cfmodule template="../thirdgen/form/mod_get_form_data.cfm"
    formDefID = "#attributes.formDefId#"
    formDataId = "#attributes.formDataId#"
    output="theData">

<!--- distributor | reference_id | dealer_firstname | dealer_lastname --->
<cfloop collection="#attributes.pdfVariable#" item="anItem">
    <cfset x = StructInsert(thePDFStruct,anItem,StructFind(attributes.pdfVariable,anItem),"YES")>
</cfloop>  

<!--- 
<cfquery name="getUserData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
select ud.user_name, ud.user_data_id, ud.user_email, fhd.text1 as firstname, fhd.text2 as lastname, fhd.text3 as phone
from thirdgen_user_data ud
inner join thirdgen_form_data fd with (nolock) on fd.user_data_id = ud.user_data_id
    and ud.user_data_id = #getData.user_data_id#
inner join thirdgen_registration r on fd.form_def_id = r.form_def_id
inner join thirdgen_form_header_data fhd with (nolock) on fd.form_data_id = fhd.form_data_id    
</cfquery>

<cfset x = StructInsert(thePDFStruct,"dealer_firstname",getUserData.firstname,"YES")>
<cfset x = StructInsert(thePDFStruct,"dealer_lastname",getUserData.lastname,"YES")>
 --->

<cfset coverSelected = "">
<cfif StructKeyExists(BoatQuoteDetails,listGetAt(CONST_MQ_quoteSelected_FID,1,"|"))>
    <cfset coverSelected = StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_quoteSelected_FID,1,"|"))>
</cfif>
<cfset x = StructInsert(thePDFStruct,"opt_coverType",coverSelected,"YES")>

<!--- INSURANCE DETAILS (start) --->
<cfset x = StructInsert(thePDFStruct,"opt_gapCover","","YES")>
<cfif ListFind(coverSelected,CONST_MQ_QuoteGapCover_LID) gt 0>
    <cfset gapCoverValue = StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_extraSelected_FID,1,"|"))> 
    <cfif findNoCase("$5000",gapCoverValue) gt 0>
         <cfset x = StructInsert(thePDFStruct,"opt_gapCover","opt_5000","YES")>
    <cfelseif findNoCase("$10000",gapCoverValue) gt 0>
         <cfset x = StructInsert(thePDFStruct,"opt_gapCover","opt_10000","YES")>
    </cfif>
</cfif>

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
            <cfset temp_insurancePremium = StructFind(BoatQuoteDetails,listGetAt(getPremiumValue.list_item_image,1,"|"))>
            <cfset temp_insurancePremium = reReplaceNoCase(temp_insurancePremium,"[$, ]","","all")>
        </cfif>

        <cfif listGetAt(getPremiumValue.list_item_image,1,"|") eq CONST_MQ_quoteGapCover_FID>
            <cfset gapCoverValue = temp_insurancePremium>
        </cfif>
        
        <cfset LOCAL_insurancePremium =  LOCAL_insurancePremium + temp_insurancePremium>
    </cfloop>
    <cfset LOCAL_insurancePremium =  LOCAL_insurancePremium + reReplaceNoCase(StructFind(BoatQuoteDetails,ListFirst(CONST_MQ_quoteAdminFee_FID,"|")),"[$, ]","","all")>
    
    <cfset LOCAL_boatPremium = LOCAL_insurancePremium - gapCoverValue>
    <cfset x = StructInsert(thePDFStruct,"boat_premium","$#LOCAL_boatPremium#","YES")>
    <cfset LOCAL_insurancePremium = numberFormat(reReplaceNoCase(LOCAL_insurancePremium,"[$, ]","","all"),",.99")>
    <cfset x = StructInsert(thePDFStruct,"summary_premium","$#LOCAL_insurancePremium#","YES")>
    <!--- <cfset x = StructInsert(thePDFStruct,"summary_gap",numberFormat(gapCoverValue,".99"),"YES")> --->
</cfif>

<cfset LOCAL_excessElected = StructFind(theData,listGetAt(CONST_MQ_ExcessOpt_FID,1,"|"))>
<cfif LOCAL_excessElected neq "">
    <cfset x = StructInsert(thePDFStruct,"excess","$"&numberFormat(reReplaceNoCase(LOCAL_excessElected,"[$, ]","","all"),",.99"),"YES")>
    <cfset x = StructInsert(thePDFStruct,"summary_excess","$"&numberFormat(reReplaceNoCase(LOCAL_excessElected,"[$, ]","","all"),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"excess","$0.00","YES")>
    <cfset x = StructInsert(thePDFStruct,"summary_excess","$0.00","YES")>
</cfif>

<cfif ListFind(thePDFStruct.opt_coverType,CONST_MQ_MotorOnly_LID) gt 0> <!--- MotorOnly cover - Got no Layup --->
    <cfset x = StructInsert(thePDFStruct,"LayUpMonths","","YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"LayUpMonths",StructFind(theData,listGetAt(CONST_MQ_layUpMths_FID,1,"|")),"YES")>
</cfif>

<cfif StructKeyExists(BoatQuoteDetails, listFirst(CONST_MQ_quoteComp_FID,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteComp",numberFormat(StructFind(BoatQuoteDetails, listFirst(CONST_MQ_quoteComp_FID,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteComp","","YES")>
</cfif>

<cfif StructKeyExists(BoatQuoteDetails, listFirst(CONST_MQ_quoteMotorOnly_FID,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteMotor",numberFormat(StructFind(BoatQuoteDetails, listFirst(CONST_MQ_quoteMotorOnly_FID,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteMotor","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listFirst(CONST_MQ_quoteTPO_FID,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteLiab",numberFormat(StructFind(BoatQuoteDetails, listFirst(CONST_MQ_quoteTPO_FID,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteLiab","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listFirst(CONST_MQ_quoteGapCover_FID,"|"))>
    <cfset x = StructInsert(thePDFStruct,"quoteGE",numberFormat(StructFind(BoatQuoteDetails, listFirst(CONST_MQ_quoteGapCover_FID,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"quoteGE","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listFirst(CONST_MQ_quoteAdminFee_FID,"|"))>
    <cfset x = StructInsert(thePDFStruct,"adminFee",numberFormat(StructFind(BoatQuoteDetails, listFirst(CONST_MQ_quoteAdminFee_FID,"|")),",.99"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"adminFee","","YES")>
</cfif>


<!--- <cfif coverSelected neq "">
    <cfset LOCAL_insurancePremium = "">
    <cfquery name="getPremiumValue" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select list_item_image
        from thirdgen_list_item
        where list_item_id = #coverSelected#
    </cfquery>
    <cfif getPremiumValue.recordCount gt 0>
        <cfset LOCAL_insurancePremium = StructFind(BoatQuoteDetails,listGetAt(getPremiumValue.list_item_image,1,"|"))>
        <cfset LOCAL_insurancePremium = numberFormat(reReplaceNoCase(LOCAL_insurancePremium,"[$, ]","","all"),",.99")>
        <cfset x = StructInsert(thePDFStruct,"summary_premium","$#LOCAL_insurancePremium#","YES")>
    </cfif>
</cfif> --->

<!--- 
<cfset gapCoverValue = 0>
<cfif StructKeyExists(BoatQuoteDetails,ListFirst(CONST_MQ_extraSelected_FID,"|")) and StructFind(BoatQuoteDetails,ListFirst(CONST_MQ_extraSelected_FID,"|")) neq "">
    <cfset gapCoverValue = StructFind(BoatQuoteDetails,ListFirst(CONST_MQ_extraSelected_FID,"|"))>
</cfif>

<cfif findNoCase("$5000",gapCoverValue) gt 0>
    <cfset x = StructInsert(thePDFStruct,"opt_gapCover","opt_5000","YES")>
    <cfset premstart = findNoCase("$",gapCoverValue,"2")>
    <cfset premend = findNoCase(" ",gapCoverValue,premstart)>
    <cfset tempNumber = mid(gapCoverValue,premstart,premend - premstart + 1)>
    <cfset tempNumber = "$"&numberFormat(reReplaceNoCase(tempNumber,"[$, ]","","all"),",.99")>
    <cfset x = StructInsert(thePDFStruct,"summary_gap",tempNumber,"YES")>
<cfelseif findNoCase("$10000",gapCoverValue) gt 0>
    <cfset x = StructInsert(thePDFStruct,"opt_gapCover","opt_10000","YES")>
    <cfset premstart = findNoCase("$",gapCoverValue,"2")>
    <cfset premend = findNoCase(" ",gapCoverValue,premstart)>
    <cfset tempNumber = mid(gapCoverValue,premstart,premend - premstart + 1)>
    <cfset tempNumber = "$"&numberFormat(reReplaceNoCase(tempNumber,"[$, ]","","all"),",.99")>
    <cfset x = StructInsert(thePDFStruct,"summary_gap",tempNumber,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"opt_gapCover","","YES")>
    <cfset x = StructInsert(thePDFStruct,"summary_gap","$0.00","YES")>
</cfif>

<cfset LOCAL_totalPayable = reReplaceNoCase(thePDFStruct.summary_premium,"[$, ]","","all") + reReplaceNoCase(thePDFStruct.summary_gap,"[$, ]","","all")>
<cfset x = StructInsert(thePDFStruct,"summary_payable","$"&numberFormat(LOCAL_totalPayable,",.99"),"YES")>
--->

<!--- INSURANCE DETAILS (end) --->


<!--- CUSTOM BOAT DETAILS (start) --->
<cfset LOCAL_boatMotorType = StructFind(BoatQuoteDetails,CONST_MQ_MotorType_FID)>
<cfif StructFind(BoatQuoteDetails,ListFirst(CONST_MQ_BoatType_FID,"|")) eq CONST_MQ_BoatTypePWC_LID>
    <cfset LOCAL_boatMotorType = "">
</cfif>
<cfif ListFindNoCase("#CONST_MQ_MotorType_IMM_LID#,#CONST_MQ_MotorType_IRM_LID#",LOCAL_boatMotorType) gt 0>
    <cfset LOCAL_boatMotorType = "#CONST_MQ_MotorType_IMM_LID#,#CONST_MQ_MotorType_IRM_LID#">
</cfif>
<cfset x = StructInsert(thePDFStruct,"opt_boat_motor_motorType",LOCAL_boatMotorType,"YES")>
<!--- CUSTOM BOAT DETAILS (end) --->

<!--- STANDARD BOAT DETAILS (start) --->
<cfset x = StructInsert(thePDFStruct,"opt_usageType","private","YES")>
<cfset x = StructInsert(thePDFStruct,"boatType",StructFind(BoatQuoteDetails,ListFirst(CONST_MQ_BoatType_FID,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"opt_boatType",StructFind(theData,ListFirst(CONST_MQ_BoatType_FID,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"insured_name",StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_FirstName_FID,1,"|")) & " " & StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_Surname_FID,1,"|")),"YES")>
<cfset tmpStr = StructFind(BoatQuoteDetails,ListFirst(CONST_MQ_BoatMake_FID,"|"))>
<cfif StructKeyExists(BoatQuoteDetails,ListFirst(CONST_MQ_BoatModel_FID,"|"))>
    <cfset tmpStr = tmpStr & " " & StructFind(BoatQuoteDetails,ListFirst(CONST_MQ_BoatModel_FID,"|"))>
</cfif>
<cfset x = StructInsert(thePDFStruct,"boat_hull_make",tmpStr,"YES")>
<cfset x = StructInsert(thePDFStruct,"boat_hull_construction",StructFind(theData,ListFirst(CONST_MQ_BoatConst_FID,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"opt_fuelType",StructFind(BoatQuoteDetails,CONST_MQ_BoatFuelType_FID),"YES")>
<cfset x = StructInsert(thePDFStruct,"opt_streetParking",StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_StreetParked_FID,1,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"opt_boatingCourse",StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_BoatingCourseOpt_FID,1,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"insured_boatingExp",StructFind(theData, listGetAt(CONST_MQ_BoatExp_FID,1,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"boatStorage_location",StructFind(theData, listGetAt(CONST_MQ_StorageMethod_FID,1,"|")),"YES")>


<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->
		
		<cfset agreedText = false>
		<cfset displayAgreedMarketValue = false>	
		
		<cfset purchaseDateExists = StructFind(BoatQuoteDetails,"CB_PurchasedDate")>
		<!--- <cfset policyCommDateExists = StructKeyExists(BikeQuoteDetails,"CB_CoverCommDate")> --->
			
		<cfset quoteSelected = BoatQuoteDetails.CQ_quoteSelected>	
		
		<cfset boatType = StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_BoatType_FID,1,"|"))>
		
		<!--- <cfdump var="#boatType#"> --->
		
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug YMI NZ Marine createAppForm 1" type="HTML">
	purchaseDateExists <cfdump var="#purchaseDateExists#"><br>
	quoteSelected <cfdump var="#quoteSelected#"><br>
	boatType <cfdump var="#boatType#"><br>
</cfmail> --->
		
		

		
		<!--- <cfif IsDefined("BikeQuoteDetails.CB_CoverCommDate") and BikeQuoteDetails.CB_CoverCommDate neq ""> --->
		<cfif IsDefined("getData.last_updated") and getData.last_updated neq ""
			and purchaseDateExists neq "">	
			<!--- <cfif policyCommDateExists eq "YES" and ---> 
			<!--- <cfif quoteSelected eq CONST_BQ_QuoteComp_ListItemID> comprehensive only --->
				<!--- <cfif boatType eq CONST_MQ_BoatTypePWC_LID> --->			<!--- Agreed value for PWC only - Remove this validation as per Michele request --->
				<!--- <cfif LSParseDateTime(BikeQuoteDetails.CB_CoverCommDate) ge CONST_START_AGREED_MARKET_VALUE> --->
					<cfif LSParseDateTime(getData.last_updated) ge CONST_START_AGREED_MARKET_VALUE>
						<cfset displayAgreedMarketValue = true>	
					</cfif>	
			    <!--- </cfif> --->
		</cfif>
		
	
			
		
		
		
		<cfset bikePurchaseDate =  BoatQuoteDetails.CB_PurchasedDate>
		
		<!--- <cfoutput>[#bikePurchaseDate#]</cfoutput>
		<cfabort> --->
		
		<cfset boatMake = "">
		
		<cfif StructKeyExists(BoatQuoteDetails,ListFirst(CONST_MQ_BoatMakeBrand_FID,"|")) and StructFind(theData,ListFirst(CONST_MQ_BoatMakeBrand_FID,"|")) neq "">
    		<cfset boatMake = StructFind(theData,ListFirst(CONST_MQ_BoatMakeBrand_FID,"|"))>
		<cfelse>
    		<cfset boatMake = StructFind(BoatQuoteDetails,ListFirst(CONST_MQ_BoatMake_FID,"|"))>
		</cfif>
		
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug YMI  NZ Marine createAppForm 2" type="HTML">
	displayAgreedMarketValue <cfdump var="#displayAgreedMarketValue#"><br>
	quoteSelected <cfdump var="#quoteSelected#"><br>
	boatType <cfdump var="#boatType#"><br>
	CONST_MQ_BoatTypePWC_LID <cfdump var="#CONST_MQ_BoatTypePWC_LID#"><br>
	last_updated <cfdump var="#getData.last_updated#"><br>
	purchaseDateExists <cfdump var="#purchaseDateExists#"><br>
	boatMake <cfdump var="#boatMake#"><br>
</cfmail> --->
		
			
		<cfif purchaseDateExists neq "" and bikePurchaseDate neq "" and displayAgreedMarketValue> 
		
				<cfif boatMake eq "YAMAHA">


					<cfset currentDate = now()>			
								
					<cfset monthsPurchaseDiff = DateDiff("m",bikePurchaseDate,currentDate)>

					<!--- <cfdump var="#bikePurchaseDate#">
					<cfdump var="#monthsPurchaseDiff#"> --->

					<cfif monthsPurchaseDiff lte CONST_YamahaAgreedMonths>
						<cfset agreedText = true>
					</cfif>
				<cfelse>
					<cfset currentDate = now()>			
					<cfset bikePurchaseDate =  LSParseDateTime(BoatQuoteDetails.CB_PurchasedDate)>			
					<cfset monthsPurchaseDiff = DateDiff("m",bikePurchaseDate,currentDate)>

					<!--- <cfdump var="#bikePurchaseDate#"><BR>
					<cfdump var="#monthsPurchaseDiff#"> --->

					<cfif monthsPurchaseDiff lte CONST_nonYamahaAgreedMonths>
						<cfset agreedText = true>
					</cfif>

				</cfif>
						
				<!--- <cfoutput>monthsPurchaseDiff #monthsPurchaseDiff#</cfoutput><br> --->
		</cfif>

<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug YMI Marine NZ createAppForm 3" type="HTML">
	agreedText <cfdump var="#agreedText#"><br>
	displayAgreedMarketValue <cfdump var="#displayAgreedMarketValue#">
</cfmail> --->	
		
		
		<cfif (IsDefined("BoatQuoteDetails.CB_NewMotorcycle") and BoatQuoteDetails.CB_NewMotorcycle eq "")
		or (IsDefined("BoatQuoteDetails.CB_NewMotorcycle") and BoatQuoteDetails.CB_NewMotorcycle eq "0")>
				<cfset agreedText = false>
				<cfset displayAgreedMarketValue = false>	
		</cfif>
		
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug YMI Marine NZ createAppForm 4" type="HTML">
	agreedText <cfdump var="#agreedText#"><br>
	displayAgreedMarketValue <cfdump var="#displayAgreedMarketValue#">
</cfmail> --->		



<cfset sumInsuredText = "">



	<cfif displayAgreedMarketValue>
		<cfif agreedText>
			<cfset sumInsuredText = "Agreed ($" & numberFormat(StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_InsuredValue_FID,1,"|"))) & ")">								
		<cfelse>
			<cfset sumInsuredText = "Market Value">					
		</cfif>
	<cfelse>
		<!--- <cfset sumInsuredText = "$"&numberFormat(StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_InsuredValue_FID,1,"|")))> --->					
		<cfset sumInsuredText = "Market Value">	
	</cfif>
		

<!--- Debug Code --->	
	
<!--- <cfoutput><b>purchaseDateExists </b> [#purchaseDateExists#]</cfoutput><br>	
<cfoutput><b>displayAgreedMarketValue </b> [#displayAgreedMarketValue#]</cfoutput><br>	
<cfoutput><b>agreedText </b> [#agreedText#]</cfoutput><br>		
<cfoutput><b>Boat Make </b> [#boatMake#]</cfoutput><br>	
<cfoutput><b>sumInsuredText</b> [#sumInsuredText#]</cfoutput>	--->

		
<!--- <cfset x = StructInsert(thePDFStruct,"sum_insured","$"&numberFormat(StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_InsuredValue_FID,1,"|"))),"YES")> --->

<cfset x = StructInsert(thePDFStruct,"sum_insured",sumInsuredText,"YES")>



<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->	
<!--- <cfset x = StructInsert(thePDFStruct,"sum_insured","$"&numberFormat(StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_InsuredValue_FID,1,"|")),",.99"),"YES")> --->



<cfset x = StructInsert(thePDFStruct,"bool_had_insurance_refused",StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_hadInsuranceRefused_FID,1,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"bool_had_claims",StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_hadClaims_FID,1,"|")),"YES")>
<cfset x = StructInsert(thePDFStruct,"bool_had_convict_charged",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_hadChargedWithOffence_FID,1,"|")),"YES")>

<cfif ListFind(thePDFStruct.opt_coverType,CONST_MQ_MotorOnly_LID) gt 0> <!--- MotorOnly cover - Got no liability --->
    <cfset x = StructInsert(thePDFStruct,"liability_limit","N/A","YES")>
<cfelse>
    <cfset LOCAL_liabilityLimit = StructFind(theData, listGetAt(CONST_MQ_LiabiltyLmt_FID,1,"|"))>
    <cfset LOCAL_liabilityLimit = reReplaceNoCase(LOCAL_liabilityLimit,"[$, ]","","all")>
    <cfset x = StructInsert(thePDFStruct,"liability_limit","$"&numberFormat(LOCAL_liabilityLimit,",.99"),"YES")>
</cfif>
<cfset x = StructInsert(thePDFStruct,"opt_waterSkiers",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_SkiersLiabilityOpt_FID,1,"|")),"YES")>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_HINNo_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_hull_HIN",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_HINNo_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_hull_HIN","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_RegoNo_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_hull_rego",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_RegoNo_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_hull_rego","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_MotorMake_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_motor_make",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_MotorMake_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_motor_make","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_MotorHP_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_motor_hp",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_MotorHP_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_motor_hp","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_MotorSerialNo_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_motor_serialNo",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_MotorSerialNo_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_motor_serialNo","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_TrailerMake_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_trailer_make",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_TrailerMake_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_trailer_make","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_TrailerRego_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_trailer_reg",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_TrailerRego_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_trailer_reg","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_CoverCommDate_FID,1,"|")) and StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_CoverCommDate_FID,1,"|")) neq "">
    <cfset coverStartAt = LSParseDateTime(StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_CoverCommDate_FID,1,"|")))>
    <cfset coverEndAt = DateAdd("yyyy",1,coverStartAt)>
    <cfset x = StructInsert(thePDFStruct,"period_start",DateFormat(coverStartAt,"DD/MM/YYYY"),"YES")>
    <cfset x = StructInsert(thePDFStruct,"period_end",DateFormat(coverEndAt,"DD/MM/YYYY"),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"period_start","","YES")>
    <cfset x = StructInsert(thePDFStruct,"period_end","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_InsurerDOB_FID,1,"|"))>
    <cfset tempDate = StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_InsurerDOB_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_dob",tempDate,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_dob","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_InsuredAddStreet_FID,1,"|"))>
    <cfset tempStr = StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_InsuredAddStreet_FID,1,"|"))>
    <cfset tempStr = replaceNoCase(tempStr,NewLineChars,", ","ALL")>
    <cfset x = StructInsert(thePDFStruct,"insured_streetAddress",tempStr,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_streetAddress","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_InsuredAddPost_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_postcode",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_InsuredAddPost_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_postcode","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_Homephone_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_phone_home",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_Homephone_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_phone_home","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_MobilePhone_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_phone_mobile",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_MobilePhone_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_phone_mobile","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_Email_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_email",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_Email_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_email","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_Occupation_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_occupation",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_Occupation_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_occupation","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_DriverLicense_No_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_driverLicense_no",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_DriverLicense_No_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_driverLicense_no","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_DriverLicense_Expiry_FID,1,"|"))>
    <cfset tempDate = StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_DriverLicense_Expiry_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_driverLicense_expiryDate",tempDate,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_driverLicense_expiryDate","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_InterestedParties_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"insured_interestedParties",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_InterestedParties_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"insured_interestedParties","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_HullYear_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_hull_year",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_HullYear_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_hull_year","","YES")>
</cfif>
<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_HullLength_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_hull_length",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_HullLength_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_hull_length","","YES")>
</cfif>

<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_MotorAge_FID,1,"|"))>
    <!--- <cfif StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_MotorAge_FID,1,"|")) eq 7729> <!--- New, first warranted owner  --->
        <cfset x = StructInsert(thePDFStruct,"boat_motor_year",StructFind(theData, listGetAt(CONST_MQ_MotorAge_FID,1,"|")),"YES")>
    <cfelse> --->
        <cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_Motor_Year_FID,1,"|"))>
			<cfif StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_Motor_Year_FID,1,"|")) neq "">
            	<cfset x = StructInsert(thePDFStruct,"boat_motor_year",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_Motor_Year_FID,1,"|")),"YES")>
			<cfelse>
				<cfset x = StructInsert(thePDFStruct,"boat_motor_year",StructFind(theData, listGetAt(CONST_MQ_MotorAge_FID,1,"|")),"YES")>
			</cfif>		
        <cfelse>
			<cfif StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_MotorAge_FID,1,"|")) eq 7729> <!--- New, first warranted owner  --->
		        <cfset x = StructInsert(thePDFStruct,"boat_motor_year",StructFind(theData, listGetAt(CONST_MQ_MotorAge_FID,1,"|")),"YES")>
            <cfelse>
				<cfset x = StructInsert(thePDFStruct,"boat_motor_year","","YES")>
			</cfif>	
        </cfif>
    <!--- </cfif> --->
</cfif>

<cfset x = StructInsert(thePDFStruct,"boat_motor_maxSpeed",StructFind(theData, listGetAt(CONST_MQ_BoatSpeed_FID,1,"|")),"YES")>

<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_TrailerYear_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_trailer_year",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_TrailerYear_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_trailer_year","","YES")>
</cfif>

<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_PurchasedDate_FID,1,"|"))>
    <cfset tempDate = StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_PurchasedDate_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"boat_purchase_date",tempDate,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_purchase_date","","YES")>
</cfif>

<cfif StructKeyExists(BoatQuoteDetails, listGetAt(CONST_MQ_PurchasedPrice_FID,1,"|"))>
    <cfset tempStr = StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_PurchasedPrice_FID,1,"|")) >
    <cfif tempStr neq "">
        <cfset tempStr = "$"&NumberFormat(tempStr,",.99")>
    </cfif>
    <cfset x = StructInsert(thePDFStruct,"boat_purchase_price",tempStr,"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_purchase_price","","YES")>
</cfif>

<cfif thePDFStruct.boat_motor_serialNo neq "">
    <cfset x = StructInsert(thePDFStruct,"boat_motor_qty","#ListLen(thePDFStruct.boat_motor_serialNo)#","YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"boat_motor_qty","","YES")>
</cfif>

<cfif StructKeyExists(theData, listGetAt(CONST_MQ_paymentType_FID,1,"|"))>
    <cfset x = StructInsert(thePDFStruct,"payment_type",StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_paymentType_FID,1,"|")),"YES")>
    <cfset x = StructInsert(thePDFStruct,"payment_type_disp",StructFind(theData, listGetAt(CONST_MQ_paymentType_FID,1,"|")),"YES")>
<cfelse>
    <cfset x = StructInsert(thePDFStruct,"payment_type","","YES")>
    <cfset x = StructInsert(thePDFStruct,"payment_type_disp","","YES")>
</cfif>
<!--- STANDARD BOAT DETAILS (end) --->


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
<cfif findNoCase("aug", thePDFStruct.LayUpMonths) gt 0><cfset discountAug="yes"></cfif>
<cfif findNoCase("sep", thePDFStruct.LayUpMonths) gt 0><cfset discountSep="yes"></cfif>
<cfif findNoCase("oct", thePDFStruct.LayUpMonths) gt 0><cfset discountOct="yes"></cfif>
<cfif findNoCase("nov", thePDFStruct.LayUpMonths) gt 0><cfset discountNov="yes"></cfif>
<cfif findNoCase("dec", thePDFStruct.LayUpMonths) gt 0><cfset discountDec="1"></cfif> 

<cfif attributes.appFormsLoc neq "">
    
    <cfset tmpFile = "pdfResponse_marine_YMINZ_#attributes.formDataId#.pdf">
    <cfpdfform source="#application.BASE_FOLDER#adminMarine\pdf_template\YMINZ_Marine_application_online_form.pdf" destination="#attributes.appFormsLoc##tmpFile#" overwrite="yes" action="populate">
        <cfpdfformparam name="distributor" value="#thePDFStruct.distributor#">
        <cfpdfformparam name="reference_id" value="#thePDFStruct.reference_id#">
        <cfpdfformparam name="opt_coverType" value="#ListFirst(thePDFStruct.opt_coverType)#">
        <cfpdfformparam name="boatType" value="#thePDFStruct.opt_boatType#">        
        <cfpdfformparam name="opt_usage_private" value="1">
        <cfpdfformparam name="insured_name" value="#thePDFStruct.insured_name#">
        <cfpdfformparam name="insured_dob" value="#thePDFStruct.insured_dob#">
        <cfpdfformparam name="insured_streetAddress" value="#thePDFStruct.insured_streetAddress#">
        <cfpdfformparam name="insured_postcode" value="#thePDFStruct.insured_postcode#">
        <cfpdfformparam name="insured_phone_home" value="#thePDFStruct.insured_phone_home#">
        <cfpdfformparam name="insured_phone_mobile" value="#thePDFStruct.insured_phone_mobile#">
        <cfpdfformparam name="insured_email" value="#thePDFStruct.insured_email#">
        <cfpdfformparam name="insured_occupation" value="#thePDFStruct.insured_occupation#">
        <cfpdfformparam name="insured_driverLicense_no" value="#thePDFStruct.insured_driverLicense_no#">
        <!--- <cfif thePDFStruct.insured_driverLicense_expiryDate neq "">
            <cfpdfformparam name="insured_driverLicense_expiryDay"  value="#day(thePDFStruct.insured_driverLicense_expiryDate)#">
            <cfpdfformparam name="insured_driverLicense_expiryMth"  value="#month(thePDFStruct.insured_driverLicense_expiryDate)#">
            <cfpdfformparam name="insured_driverLicense_expiryYear" value="#year(thePDFStruct.insured_driverLicense_expiryDate)#">
        </cfif> --->
        <cfpdfformparam name="insured_driverLicense_expiryDate" value="#thePDFStruct.insured_driverLicense_expiryDate#">
        <cfpdfformparam name="insured_interestedParties" value="#thePDFStruct.insured_interestedParties#">
        
        <cfpdfformparam name="bool_had_insurance_refused" value="#thePDFStruct.bool_had_insurance_refused#">
        <cfpdfformparam name="bool_had_claims" value="#thePDFStruct.bool_had_claims#">
        <cfpdfformparam name="bool_had_convict_charged" value="#thePDFStruct.bool_had_convict_charged#">
        
        <cfpdfformparam name="boat_hull_make" value="#thePDFStruct.boat_hull_make#">
        <cfpdfformparam name="boat_hull_construction" value="#thePDFStruct.boat_hull_construction#">
        <cfpdfformparam name="boat_motor_motorType" value="#thePDFStruct.opt_boat_motor_motorType#">
        <cfpdfformparam name="opt_fuelType" value="#thePDFStruct.opt_fuelType#">
        <cfpdfformparam name="opt_streetParking" value="#thePDFStruct.opt_streetParking#">
        <cfpdfformparam name="opt_boatingCourse" value="#thePDFStruct.opt_boatingCourse#">
        <cfpdfformparam name="insured_boatingExp" value="#thePDFStruct.insured_boatingExp#">
        <cfpdfformparam name="opt_gapCover" value="#thePDFStruct.opt_gapCover#">
        <cfpdfformparam name="boat_storage" value="#thePDFStruct.boatStorage_location#">
        <cfpdfformparam name="opt_waterSkiers" value="#thePDFStruct.opt_waterSkiers#">
        
        <cfpdfformparam name="boat_hull_HIN" value="#thePDFStruct.boat_hull_HIN#">
        <cfpdfformparam name="boat_hull_rego" value="#thePDFStruct.boat_hull_rego#">
        <cfpdfformparam name="boat_hull_year" value="#thePDFStruct.boat_hull_year#">
        <cfpdfformparam name="boat_hull_length" value="#thePDFStruct.boat_hull_length#">
        <cfpdfformparam name="boat_motor_make" value="#thePDFStruct.boat_motor_make#">
        <cfpdfformparam name="boat_motor_hp" value="#thePDFStruct.boat_motor_hp#">
        <cfpdfformparam name="boat_motor_year" value="#thePDFStruct.boat_motor_year#">
        <cfpdfformparam name="boat_motor_qty" value="#thePDFStruct.boat_motor_qty#">    
        <cfpdfformparam name="boat_motor_serialNo" value="#thePDFStruct.boat_motor_serialNo#">
        <cfpdfformparam name="boat_motor_maxSpeed" value="#thePDFStruct.boat_motor_maxSpeed#">
        <cfpdfformparam name="boat_trailer_make" value="#thePDFStruct.boat_trailer_make#">
        <cfpdfformparam name="boat_trailer_reg" value="#thePDFStruct.boat_trailer_reg#">
        <cfpdfformparam name="boat_trailer_year" value="#thePDFStruct.boat_trailer_year#">
        
        <!--- <cfif thePDFStruct.boat_purchase_date neq "">
            <cfpdfformparam name="boat_purchase_day"  value="#day(thePDFStruct.boat_purchase_date)#">
            <cfpdfformparam name="boat_purchase_mth"  value="#month(thePDFStruct.boat_purchase_date)#">
            <cfpdfformparam name="boat_purchase_year" value="#year(thePDFStruct.boat_purchase_date)#">
        </cfif> --->
        <cfpdfformparam name="boat_purchase_date" value="#thePDFStruct.boat_purchase_date#">
        <cfpdfformparam name="boat_purchase_price" value="#thePDFStruct.boat_purchase_price#">
        
        <cfpdfformparam name="layup_disc_jan" value="#discountJan#">
        <cfpdfformparam name="layup_disc_feb" value="#discountFeb#">
        <cfpdfformparam name="layup_disc_mar" value="#discountMar#">
        <cfpdfformparam name="layup_disc_apr" value="#discountApr#">
        <cfpdfformparam name="layup_disc_may" value="#discountMay#">
        <cfpdfformparam name="layup_disc_jun" value="#discountJun#">
        <cfpdfformparam name="layup_disc_jul" value="#discountJul#">
        <cfpdfformparam name="layup_disc_aug" value="#discountAug#">
        <cfpdfformparam name="layup_disc_sep" value="#discountSep#">
        <cfpdfformparam name="layup_disc_oct" value="#discountOct#">
        <cfpdfformparam name="layup_disc_nov" value="#discountNov#">
        <cfpdfformparam name="layup_disc_dec" value="#discountDec#">
        <cfpdfformparam name="layup_mth_total" value="#ListLen(thePDFStruct.LayUpMonths)#">
        
        <cfpdfformparam name="period_start" value="#thePDFStruct.period_start#">
        <cfpdfformparam name="period_end" value="#thePDFStruct.period_end#">
        
        <cfpdfformparam name="sum_insured" value="#thePDFStruct.sum_insured#">
        <cfpdfformparam name="liability_limit" value="#thePDFStruct.liability_limit#">    
        <cfpdfformparam name="excess" value="#thePDFStruct.excess#">    
        <cfpdfformparam name="summary_excess" value="#thePDFStruct.summary_excess#">
        <cfpdfformparam name="summary_premium" value="#thePDFStruct.boat_premium#">
        <cfpdfformparam name="summary_payable" value="#thePDFStruct.summary_premium#">
        <!--- <cfpdfformparam name="summary_gap" value="#thePDFStruct.summary_gap#">
        <cfpdfformparam name="summary_payable" value="#thePDFStruct.summary_payable#"> --->
        
        <cfpdfformparam name="dealer_rep_name" value="#thePDFStruct.dealer_firstname# #thePDFStruct.dealer_lastname#">
    </cfpdfform>
    
    
    
<!---     <cfpdfform source="#application.BASE_FOLDER#adminMarine\pdf_template\YMINZ_Marine_application_online_form.pdf" destination="#attributes.appFormsLoc##attributes.pdfFilename#" overwrite="yes" action="populate">
        <cfpdfformparam name="distributor" value="#thePDFStruct.distributor#">
        <cfpdfformparam name="reference_id" value="#thePDFStruct.reference_id#">
        <cfpdfformparam name="opt_coverType" value="#ListFirst(thePDFStruct.opt_coverType)#">
        <cfpdfformparam name="boatType" value="#thePDFStruct.opt_boatType#">        
        <cfpdfformparam name="opt_usage_private" value="1">
        <cfpdfformparam name="insured_name" value="#thePDFStruct.insured_name#">
        <cfpdfformparam name="insured_dob" value="#thePDFStruct.insured_dob#">
        <cfpdfformparam name="insured_streetAddress" value="#thePDFStruct.insured_streetAddress#">
        <cfpdfformparam name="insured_postcode" value="#thePDFStruct.insured_postcode#">
        <cfpdfformparam name="insured_phone_home" value="#thePDFStruct.insured_phone_home#">
        <cfpdfformparam name="insured_phone_mobile" value="#thePDFStruct.insured_phone_mobile#">
        <cfpdfformparam name="insured_email" value="#thePDFStruct.insured_email#">
        <cfpdfformparam name="insured_occupation" value="#thePDFStruct.insured_occupation#">
        <cfpdfformparam name="insured_driverLicense_no" value="#thePDFStruct.insured_driverLicense_no#">
        <!--- <cfif thePDFStruct.insured_driverLicense_expiryDate neq "">
            <cfpdfformparam name="insured_driverLicense_expiryDay"  value="#day(thePDFStruct.insured_driverLicense_expiryDate)#">
            <cfpdfformparam name="insured_driverLicense_expiryMth"  value="#month(thePDFStruct.insured_driverLicense_expiryDate)#">
            <cfpdfformparam name="insured_driverLicense_expiryYear" value="#year(thePDFStruct.insured_driverLicense_expiryDate)#">
        </cfif> --->
        <cfpdfformparam name="insured_driverLicense_expiryDate" value="#thePDFStruct.insured_driverLicense_expiryDate#">
        <cfpdfformparam name="insured_interestedParties" value="#thePDFStruct.insured_interestedParties#">
        
        <cfpdfformparam name="bool_had_insurance_refused" value="#thePDFStruct.bool_had_insurance_refused#">
        <cfpdfformparam name="bool_had_claims" value="#thePDFStruct.bool_had_claims#">
        <cfpdfformparam name="bool_had_convict_charged" value="#thePDFStruct.bool_had_convict_charged#">
        
        <cfpdfformparam name="boat_hull_make" value="#thePDFStruct.boat_hull_make#">
        <cfpdfformparam name="boat_hull_construction" value="#thePDFStruct.boat_hull_construction#">
        <cfpdfformparam name="boat_motor_motorType" value="#thePDFStruct.opt_boat_motor_motorType#">
        <cfpdfformparam name="opt_fuelType" value="#thePDFStruct.opt_fuelType#">
        <cfpdfformparam name="opt_streetParking" value="#thePDFStruct.opt_streetParking#">
        <cfpdfformparam name="opt_boatingCourse" value="#thePDFStruct.opt_boatingCourse#">
        <cfpdfformparam name="insured_boatingExp" value="#thePDFStruct.insured_boatingExp#">
        <cfpdfformparam name="opt_gapCover" value="#thePDFStruct.opt_gapCover#">
        <cfpdfformparam name="boat_storage" value="#thePDFStruct.boatStorage_location#">
        <cfpdfformparam name="opt_waterSkiers" value="#thePDFStruct.opt_waterSkiers#">
        
        <cfpdfformparam name="boat_hull_HIN" value="#thePDFStruct.boat_hull_HIN#">
        <cfpdfformparam name="boat_hull_rego" value="#thePDFStruct.boat_hull_rego#">
        <cfpdfformparam name="boat_hull_year" value="#thePDFStruct.boat_hull_year#">
        <cfpdfformparam name="boat_hull_length" value="#thePDFStruct.boat_hull_length#">
        <cfpdfformparam name="boat_motor_make" value="#thePDFStruct.boat_motor_make#">
        <cfpdfformparam name="boat_motor_hp" value="#thePDFStruct.boat_motor_hp#">
        <cfpdfformparam name="boat_motor_year" value="#thePDFStruct.boat_motor_year#">
        <cfpdfformparam name="boat_motor_qty" value="#thePDFStruct.boat_motor_qty#">    
        <cfpdfformparam name="boat_motor_serialNo" value="#thePDFStruct.boat_motor_serialNo#">
        <cfpdfformparam name="boat_motor_maxSpeed" value="#thePDFStruct.boat_motor_maxSpeed#">
        <cfpdfformparam name="boat_trailer_make" value="#thePDFStruct.boat_trailer_make#">
        <cfpdfformparam name="boat_trailer_reg" value="#thePDFStruct.boat_trailer_reg#">
        <cfpdfformparam name="boat_trailer_year" value="#thePDFStruct.boat_trailer_year#">
        
        <!--- <cfif thePDFStruct.boat_purchase_date neq "">
            <cfpdfformparam name="boat_purchase_day"  value="#day(thePDFStruct.boat_purchase_date)#">
            <cfpdfformparam name="boat_purchase_mth"  value="#month(thePDFStruct.boat_purchase_date)#">
            <cfpdfformparam name="boat_purchase_year" value="#year(thePDFStruct.boat_purchase_date)#">
        </cfif> --->
        <cfpdfformparam name="boat_purchase_date" value="#thePDFStruct.boat_purchase_date#">
        <cfpdfformparam name="boat_purchase_price" value="#thePDFStruct.boat_purchase_price#">
        
        <cfpdfformparam name="layup_disc_jan" value="#discountJan#">
        <cfpdfformparam name="layup_disc_feb" value="#discountFeb#">
        <cfpdfformparam name="layup_disc_mar" value="#discountMar#">
        <cfpdfformparam name="layup_disc_apr" value="#discountApr#">
        <cfpdfformparam name="layup_disc_may" value="#discountMay#">
        <cfpdfformparam name="layup_disc_jun" value="#discountJun#">
        <cfpdfformparam name="layup_disc_jul" value="#discountJul#">
        <cfpdfformparam name="layup_disc_aug" value="#discountAug#">
        <cfpdfformparam name="layup_disc_sep" value="#discountSep#">
        <cfpdfformparam name="layup_disc_oct" value="#discountOct#">
        <cfpdfformparam name="layup_disc_nov" value="#discountNov#">
        <cfpdfformparam name="layup_disc_dec" value="#discountDec#">
        <cfpdfformparam name="layup_mth_total" value="#ListLen(thePDFStruct.LayUpMonths)#">
        
        <cfpdfformparam name="period_start" value="#thePDFStruct.period_start#">
        <cfpdfformparam name="period_end" value="#thePDFStruct.period_end#">
        
        <cfpdfformparam name="sum_insured" value="#thePDFStruct.sum_insured#">
        <cfpdfformparam name="liability_limit" value="#thePDFStruct.liability_limit#">    
        <cfpdfformparam name="excess" value="#thePDFStruct.excess#">    
        <cfpdfformparam name="summary_excess" value="#thePDFStruct.summary_excess#">
        <cfpdfformparam name="summary_premium" value="#thePDFStruct.boat_premium#">
        <cfpdfformparam name="summary_payable" value="#thePDFStruct.summary_premium#">
        <!--- <cfpdfformparam name="summary_gap" value="#thePDFStruct.summary_gap#">
        <cfpdfformparam name="summary_payable" value="#thePDFStruct.summary_payable#"> --->
        
        <cfpdfformparam name="dealer_rep_name" value="#thePDFStruct.dealer_firstname# #thePDFStruct.dealer_lastname#">
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