<cfset admin="../html/admin.cfm?p=">
<cfset NewLineChars = Chr(13) & Chr(10)>
<cfset CONST_theProductFile = "">
<cfif IsDefined("application.BASE_FOLDER")>
    <cfset CONST_theProductFile = "#application.BASE_FOLDER#temp/MOTORCYCLE_GLASSDATA.U12">
</cfif>


<cfset inDev = false>
<cfif FindNoCase("dev",CGI.SERVER_NAME)>
        <cfset inDev = true>
</cfif>        

<cfif inDev eq true>
    <cfset CONST_stateTreeNodeId = 99> <!--- the tree node id of "NZ DEALERS" --->
    <cfset CONST_BDM_Email = "andress@3rdmill.com.au"> <!--- NZYMI@ymi.co.nz--->
    <cfset environment = "DEV">
<cfelse>
    <cfset CONST_stateTreeNodeId = 800> <!--- the tree node id of "NZ DEALERS" --->
    <cfset CONST_BDM_Email = "NZYMI@ymi.co.nz">
    <cfset environment = "">
</cfif> 

<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->	
	

<cfset CONST_START_AGREED_MARKET_VALUE = CreateDateTime(2020,  2,  12,  0,  0,  0)>  
<cfset CONST_nonYamahaAgreedMonths = 24> 
<cfset CONST_YamahaAgreedMonths    = 36> 	
	
<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->		
 

<cfset CONS_YMI_Motor_Promo_ID = 0>  <!--- Ticket 46175 - PromoCode --->	
	
<cfset CONST_BQ_QD_promoCode = "QD_promoCode">	<!--- Ticket 46175 - PromoCode --->  

    
<cfset ADMIN_USERIDS = "1,3,131">

<cfset CONS_YMI_TreeNodeNZ_Id = 673>

<cfset CONST_QUOTE_VALIDITY = 30 > <!--- in DAYS --->
<!--- <cfset CONST_BDM_Email = "NZYMI@ymi.co.nz"> --->

<cfset CONST_USER_FIRST_NAME_FID = "20483">
<cfset CONST_USER_LAST_NAME_FID = "20484">

<cfset CONST_MOTORCYCLE_ROLEID = 19>  <!--- ymiMotorcycleDealer --->
<cfset CONST_MOTORCYCLE_COMP_ID = 4> <!--- ID for rating engine --->

<cfset CONST_treeNodeFormDefId = 965>
    <cfset CONST_TND_address_FID = "20493">
    <cfset CONST_TND_companyName_FID = "20489|text1">
    <cfset CONST_TND_stateRegion_FID = "20490|newlist1">
    <cfset CONST_TND_city_FID = "20728|text3">
    <cfset CONST_TND_postcode_FID = "20730|text4">
    <cfset CONST_TND_phone_FID = "20732|text5">
    <cfset CONST_TND_fax_FID = "20734|text6">
    <cfset CONST_TND_salesContact_FID = "20736|text7">
    <cfset CONST_TND_salesPhone_FID = "20738|text8">
    <cfset CONST_TND_salesEmail_FID = "20740|text9">
    <cfset CONST_TND_website_FID = "20742|text10">
    
<cfset CONST_bikeDataFormDefId = 967>
    <cfset CONST_BD_NVIC_FID = 20513>
    <cfset CONST_BD_IsInsurable_FID = 20575>
    <cfset CONST_BD_ReviewedDate_FID = 20511>    
    
    <cfset CONST_BD_Code_FID = 20547>
    <cfset CONST_BD_Mth_FID = 20517>
    <cfset CONST_BD_Make_FID = 20518>
    <cfset CONST_BD_Family_FID = 20519>
    <cfset CONST_BD_Variant_FID = 20520>
    <cfset CONST_BD_Series_FID = 20521>
    <cfset CONST_BD_Style_FID = 20522>
    <cfset CONST_BD_Engine_FID = 20523>
    <cfset CONST_BD_CC_FID = 20524>
    <cfset CONST_BD_Size_FID = 20525>
    <cfset CONST_BD_Trans_FID = 20526>
    <cfset CONST_BD_CYL_FID = 20527>
    <cfset CONST_BD_ValveG_FID = 20528>
    <cfset CONST_BD_BoreStr_FID = 20529>
    <cfset CONST_BD_KW_FID = 20530>
    <cfset CONST_BD_CompRatio_FID = 20531>
    <cfset CONST_BD_EngCool_FID = 20532>
    <cfset CONST_BD_KerbW_FID = 20533>
    <cfset CONST_BD_WheelBase_FID = 20534>
    <cfset CONST_BD_SeatHeight_FID = 20535>
    <cfset CONST_BD_Drive_FID = 20536>
    <cfset CONST_BD_FrontTyres_FID = 20537>
    <cfset CONST_BD_RearTyres_FID = 20538>
    <cfset CONST_BD_FrontRims_FID = 20539>
    <cfset CONST_BD_RearRims_FID = 20540>
    <cfset CONST_BD_Ftank_FID = 20541>
    <cfset CONST_BD_WarrantyMth_FID = 20542>
    <cfset CONST_BD_WarranttKm_FID = 20543>
    <cfset CONST_BD_Country_FID = 20544>
    <cfset CONST_BD_ReleasedDate_FID = 20545>
    <cfset CONST_BD_DiscDate_FID = 20546>    
    <cfset CONST_BD_Year_FID = 20548>
    <cfset CONST_BD_NewPR_FID = 20549>
    <cfset CONST_BD_TradeLow_FID = 20550>
    <cfset CONST_BD_Trade_FID = 20551>
    <cfset CONST_BD_Retail_FID = 20552>

<cfset CONST_bikeQuoteFormDefId = 953>
    <cfset CONST_BQ_QuoteStatus_FID = "GLOBAL_quoteStatus">
    <cfset CONST_BQ_QuoteStatus_stage1_LID = "7542">
    <cfset CONST_BQ_QuoteStatus_stage2_LID = "7543">
    <cfset CONST_BQ_QuoteStatus_stage3_LID = "7544">
    <cfset CONST_BQ_QuoteStatus_stage4_LID = "7545">
    
    <!--- QUOTE DETAILS STAGE FIELDs --->
    <cfset CONST_BQ_FirstName_FID = "QD_20356|text1">
    <cfset CONST_BQ_Surname_FID = "QD_20357|text2">
    <cfset CONST_BQ_InsuredValue_FID = "QD_20358|number1">
    <cfset CONST_BQ_Age_FID = "QD_20359|number2">
    <cfset CONST_BQ_Excess_FID = "QD_20360|newlist1">
    <!--- <cfset CONST_BQ_Region_FID = "QD_20361|newlist2"> --->
    <cfset CONST_BQ_State_FID = "QD_State|newlist3">
    <cfset CONST_BQ_RoadReg_FID = "QD_20718|yesno5">
    <cfset CONST_BQ_BikeModel_FID = "QD_20366|externallist10">
	<cfset CONST_BQ_customBikeDetail1 = "QD_20832|text5">
    <cfset CONST_BQ_customBikeDetail2 = "QD_20834|text6">
    <cfset CONST_BQ_customBikeMake = "QD_20836|text7">
    <cfset CONST_BQ_InsurerSex_FID = "QD_22670|newlist4">
    <cfset CONST_BQ_RidingExp_FID = "QD_22674|number7">
    <cfset CONST_BQ_InsRefCan_FID = "QD_20362|yesno1">
    <cfset CONST_BQ_Claims_FID = "QD_20363|yesno2">
    <cfset CONST_BQ_Charged_FID = "QD_20364|yesno3">
    <cfset CONST_BQ_Suspended_FID = "QD_20365|yesno4">
    <cfset CONST_QD_Is_CurrentValid_License_FID = "QD_Is_CurrentValid_License|yesno4">
    <cfset CONST_QD_Is_BusinessUse_FID = "QD_Is_BusinessUse|yesno4">
    <cfset CONST_BQ_ExtProvider_FID = "QD_extProv|text8">
    <cfset CONST_BQ_ExtId_FID = "QD_extId|text9">
    
    <cfset CONST_BQ_customBikeStyle = "QD_bikeCustomStyle">
    <cfset CONST_BQ_customBikeYear = "QD_bikeCustomYear">
    <cfset CONST_BQ_layUpMths_FID = "QD_20380"> 
    <cfset CONST_BQ_InsurerDOB_FID = "CB_DOB"> <!--- this used to be cover bound field --->
    <cfset CONST_BQ_OriginalRegoDate_FID = "QD_OriginalRegoDate">
    <cfset CONST_BQ_StoragePostcode_FID = "QD_StoragePostcode">
    <cfset CONST_BQ_StorageMethod_FID = "QD_StorageMethod">
    <cfset CONST_BQ_StateArea_FID = "QD_RegionArea">
    <cfset CONST_BQ_NCB_FID = "QD_NCB">
    <cfset CONST_BQ_TotLoanValue_FID = "QD_TotLoanValue">
    
    
    <!--- CHOOSE QUOTE STAGE FIELDs --->
	<cfset CONST_BQ_quoteComp_FID = "CQ_20686|number3">
    <cfset CONST_BQ_quoteOffRoad_FID = "CQ_20688|number4">
    <cfset CONST_BQ_quoteTPD_FID = "CQ_20690|number5">
    <cfset CONST_BQ_quoteTPO_FID = "CQ_20720|number6">
	<cfset CONST_BQ_quoteGapCover_FID = "CQ_quoteGapCover">
    <cfset CONST_BQ_gapCoverTerm_FID = "CQ_gapCoverTerm">
    <cfset CONST_BQ_quoteTyreRim_FID = "CQ_quoteTyreRim">
    <cfset CONST_BQ_quoteLoanProtect_FID = "CQ_quoteLoanProtect">
    <cfset CONST_BQ_loanProtectTerm_FID = "CQ_loanProtectTerm">
    <cfset CONST_BQ_loanProtectDetails_FID = "CQ_loanProtectDetails">
	<cfset CONST_BQ_extraSelected_FID = "CQ_20694|text4"> 
     <cfset CONST_BQ_quoteSelected_FID = "CQ_quoteSelected"> <!--- multi list --->
    <cfset CONST_BQ_quoteDetails_FID = "CQ_quoteDetails">
    <cfset CONST_BQ_quoteAdminFee_FID = "CQ_adminFeeTotal">
    <cfset CONST_BQ_quoteFSLFee_FID = "CQ_fslFee">
    <cfset CONST_BQ_ignoreCompl_FID = "CQ_ignoreCompl">
    <cfset CONST_BQ_ignoreComplReason_FID = "CQ_ignoreComplReason">
    <cfset CONST_BQ_manualEditReason_FID = "CQ_manualEditReason">
    <cfset CONST_BQ_manualEditor_FID = "CQ_manualEditor">
    
    <!--- <cfset CONST_BQ_quoteSelected_FID = "CQ_20722|newlist3"> 
    <cfset CONST_BQ_quoteDetails_FID = "CQ_quoteDetails|text3"> --->
    
    
    <!--- BOUND COVER STAGE FIELDs --->
    <cfset CONST_BQ_CoverBoundTitle_FID ="CB_Title">
    <cfset CONST_BQ_CoverCommDate_FID ="CB_CoverCommDate">
    <cfset CONST_BQ_InsuredAddStreet_FID = "CB_Address_Street">
    <cfset CONST_BQ_InsuredAddPost_FID = "CB_Address_Postcode">
    <cfset CONST_BQ_Homephone_FID = "CB_Homephone">
    <cfset CONST_BQ_MobilePhone_FID = "CB_Mobilephone">
    <cfset CONST_BQ_Email_FID = "CB_Email">
    <cfset CONST_BQ_Occupation_FID = "CB_Occupation">
    <cfset CONST_BQ_InterestedParties_FID = "CB_InterestedParties">
    <cfset CONST_BQ_RegoNo_FID ="CB_Rego_No">
    <cfset CONST_BQ_VinNo_FID = "CB_VIN_No">
    <cfset CONST_BQ_PurchasedDate_FID = "CB_PurchasedDate">
    <cfset CONST_BQ_StorageAddress_FID = "CB_StorageAddress">
    <cfset CONST_BQ_IsModified_FID = "CB_IsModified">
    <cfset CONST_BQ_ModifiedDesc_FID = "CB_ModifiedDesc">
    <cfset CONST_BQ_IsUsable_FID = "CB_IsUsable">
    <cfset CONST_BQ_UsableDesc_FID = "CB_UsableDesc">
    <cfset CONST_BQ_PurchasePrice_FID = "CB_PurchasePrice">
    <cfset CONST_BQ_PaymentType_FID = "CB_PaymentType"> <!--- CURRENTLY NOT USED  --->
    <cfset CONST_BQ_NewMotorcycle_FID ="CB_NewMotorcycle">
   
    <!--- LIST VALUES --->
    <cfset CONST_BQ_QuoteComp_ListItemID = "7152">
    <cfset CONST_BQ_QuoteOffRoad_ListItemID = "7153">
    <cfset CONST_BQ_QuoteTPD_ListItemID = "7154">
    <cfset CONST_BQ_QuoteTPO_ListItemID = "7155">
    <cfset CONST_BQ_QuoteGapCover_ListItemID = "10594">
    <cfset CONST_BQ_QuoteTyreRim_ListItemID= "0">
    <cfset CONST_BQ_QuoteLoanProtect_ListItemID= "0">
    <cfset CONST_BQ_DefaultTerm_ListItemID= "9503"> <!--- default is 12 months --->
	
    <cfset CONST_BQ_LayupMth_ListID = 746>
    <!--- <cfset CONST_BQ_State_ListID = 745> --->
    <cfset CONST_BQ_State_ListID = 1041>
    <cfset CONST_BQ_AppStatus_ListID = 804>    
    
    <cfset CONST_BQ_StateArea_ListID = 1040>
    <cfset CONST_BQ_gender_ListID = 826>
    <cfset CONST_BQ_excess_ListID = 744>
    <cfset CONST_BQ_NCB_ListID = 1038>
    <cfset CONST_BQ_StorageMethod_ListID = 916>
    <cfset CONST_BQ_BikeStyle_ListID = 917>
    <cfset CONST_BQ_LoanTerm_ListID = 918>
    <cfset CONST_BQ_paymentType_ListID = 829>
    
    <cfset CONST_BQ_StateAreaMetro_LID = 10606>  
    <cfset CONST_BQ_StateAreaCountry_LID = 10607>
    <cfset CONST_BQ_paymentType_Cheque_LID = 7730>
    <cfset CONST_BQ_paymentType_Mastercard_LID = 7731>
    <cfset CONST_BQ_paymentType_Visa_LID = 7732>
    <cfset CONST_BQ_paymentType_FinancedYMF_LID = 7733>
    <cfset CONST_BQ_paymentType_FinancedOther_LID = 7734>
	
	<cfset CONS_ID_Street_Parked_StorageMethod = 9472>
    

<!--- CALCULATOR ITEMS --->
    <cfset CONST_ID_GST = 93>
    <cfset CONST_ID_Admin_Fee = 94>
    <cfset CONST_ID_Min_Premium_Cost = 95>
    <cfset CONST_ID_Base_Rates = 96>
    <cfset CONST_ID_Age_Loadings = 97>
    <cfset CONST_ID_Layup_Discount = 98>
    <cfset CONST_ID_State = 99>
    <cfset CONST_ID_StateMetro = 121>
    <cfset CONST_ID_StateCountry = 122>
    <cfset CONST_ID_TPO_Price = 100>
    <cfset CONST_ID_Excess_Discount = 101>
    <cfset CONST_ID_Excess_Discount_OffRoad = 155>
    <cfset CONST_ID_NCB = 102>
    <cfset CONST_ID_LicenseYr = 103>
    <cfset CONST_ID_BikeYr = 104>
    <cfset CONST_ID_YMIDealerRate = 105> 
    <cfset CONST_ID_BikeType = 106>
    <cfset CONST_ID_StorageMethod = 107>
    <cfset CONST_ID_LiabilityAmountBase = 108>
    <cfset CONST_ID_GapExtraCover = 109>
    <cfset CONST_ID_TyreRimBase = 110>
    <cfset CONST_ID_TyreRimMaxBase = 111>
    <cfset CONST_ID_PayByMonthCharge = 112>
    <cfset CONST_ID_PayByMonthCharge_CCExtra = 113>
    <cfset CONST_ID_LP_LifeTerm = 114>
    <cfset CONST_ID_LP_DisableTerm = 115>
    <cfset CONST_ID_LP_UnempTerm = 116>
    <cfset CONST_ID_LP_CashAssTerm = 117>
    <cfset CONST_ID_BikeAgeLimit = 118>
    <!--- <cfset CONST_ID_FSL_Rate = 119>  --->    
    <cfset CONST_ID_FSL_fee = 119>
    <cfset CONST_ID_MaxDisc = 120>
     <cfset CONST_ID_SpecialProdPrice = 154> 