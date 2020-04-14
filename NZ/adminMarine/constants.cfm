<cfset admin="../html/adminMarine.cfm?act=">
<cfset NewLineChars = Chr(13) & Chr(10)>

<cfset CONST_stateTreeNodeId = 800> <!--- the tree node id of "NZ DEALERS" --->
<cfset ADMIN_USERIDS = "1,3,131">

<cfset CONST_QUOTE_VALIDITY = 30 > <!--- in DAYS --->
<cfset CONST_BDM_Email = "NZYMI@ymi.co.nz">

<cfset CONST_USER_FIRST_NAME_FID = "20483">
<cfset CONST_USER_LAST_NAME_FID = "20484">

<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->	
	

<cfset CONST_START_AGREED_MARKET_VALUE = CreateDateTime(2020,  2,  12,  0,  0,  0)>  
<cfset CONST_nonYamahaAgreedMonths = 24> 
<cfset CONST_YamahaAgreedMonths    = 36> 	
	
<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->		

<cfset CONS_YMI_Marine_Promo_ID = 0>  <!--- Ticket 46175 - PromoCode --->

<cfset CONST_MARINE_COMP_ID = 1> <!--- YMI NZ Marine --->
<cfset CONST_MARINE_ROLEID = 20> <!--- ymiMarineDealer --->

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
    
<cfset CONST_marineQuoteFormDefId = 974>
    <cfset CONST_MQ_QuoteStatus_FID = "GLOBAL_quoteStatus">
    <cfset CONST_MQ_QuoteStatus_stage1_LID = "7542">
    <cfset CONST_MQ_QuoteStatus_stage2_LID = "7543">
    <cfset CONST_MQ_QuoteStatus_stage3_LID = "7544">
    <cfset CONST_MQ_QuoteStatus_stage4_LID = "7545">

    <!--- QUOTE DETAILS STAGE FIELDs --->
    <cfset CONST_MQ_FirstName_FID = "QD_FirstName|text1">
    <cfset CONST_MQ_Surname_FID = "QD_surname|text2">
    <cfset CONST_MQ_InsuredValue_FID = "QD_insvalue|number1">
    <cfset CONST_MQ_BoatType_FID = "QD_boattype|newlist2">   
    <cfset CONST_MQ_BoatSpeed_FID = "QD_boatspeed|newlist3">
    <cfset CONST_MQ_BoatConst_FID = "QD_boatconstruction|newlist5">
    <cfset CONST_MQ_StorageMethod_FID = "QD_storagemethod|newlist7">
    <cfset CONST_MQ_LiabiltyLmt_FID = "QD_liablimitoption|newlist4">
    <cfset CONST_MQ_ExcessOpt_FID = "QD_excessoption|newlist1">
    <cfset CONST_MQ_BoatExp_FID = "QD_boatingexp|newlist6">
    <cfset CONST_MQ_BoatMake_FID = "QD_20886|text3">
    <cfset CONST_MQ_State_FID = "QD_State|newlist9">
    <cfset CONST_MQ_SailorAge_FID = "QD_ageinsured|number2">
    
    <cfset CONST_MQ_hadInsuranceRefused_FID = "QD_insrefused|yesno1">
    <cfset CONST_MQ_hadClaims_FID = "QD_insclaims|yesno2">
    <cfset CONST_MQ_hadChargedWithOffence_FID = "QD_insoffence|yesno3">
    <cfset CONST_MQ_ExtProvider_FID = "QD_extProv|text5">
    <cfset CONST_MQ_ExtId_FID = "QD_extId|text6">
    
    <cfset CONST_MQ_BoatMakeBrand_FID = "QD_BoatMakeBrand">
    <cfset CONST_MQ_BoatModel_FID = "QD_BoatModel">
    <cfset CONST_MQ_BoatStoragePostcode_FID = "QD_StoragePostcode">
    <cfset CONST_BQ_StateArea_FID = "QD_RegionArea">
    <cfset CONST_MQ_StreetParked_FID = "QD_streetparked">
    <cfset CONST_MQ_BoatProd_FID = "QD_production">
    <cfset CONST_MQ_BoatAge_FID = "QD_boatage">
    <cfset CONST_MQ_BoatFuelType_FID ="QD_fueltype">
    <cfset CONST_MQ_MotorType_FID = "QD_motortype">
    <cfset CONST_MQ_MotorAge_FID = "QD_motorage">
    <cfset CONST_MQ_layUpMths_FID = "QD_layupmonths"> 
    <cfset CONST_MQ_BoatingCourseOpt_FID = "QD_boatingcourseopt">
    <cfset CONST_MQ_SkiersLiabilityOpt_FID = "QD_skiliabopt">
    <cfset CONST_MQ_TotLoanValue_FID = "QD_TotLoanValue">
    <cfset CONST_MQ_loanTermMth_FID = "QD_loanTermMth">
    
    <!--- CHOOSE QUOTE STAGE FIELDs --->
    <cfset CONST_MQ_quoteComp_FID = "CQ_20888|number3">
    <cfset CONST_MQ_quoteMotorOnly_FID = "CQ_20898|number4">
    <cfset CONST_MQ_quoteTPO_FID = "CQ_20892|number5">
    <cfset CONST_MQ_quoteGapCover_FID = "CQ_quoteGapCover">
   
    <!--- <cfset CONST_MQ_quoteSelected_FID = "CQ_20894|newlist9"> 
    <cfset CONST_MQ_quoteDetails_FID = "CQ_quoteDetails|text5"> --->
    
    <cfset CONST_MQ_quoteSelected_FID = "CQ_quoteSelected"> <!--- multi list --->
    <cfset CONST_MQ_extraSelected_FID = "CQ_20896|text4"> 
    <cfset CONST_MQ_quoteDetails_FID = "CQ_quoteDetails"> <!--- long text --->
    <cfset CONST_MQ_quoteAdminFee_FID = "CQ_adminFeeTotal">
    <cfset CONST_MQ_quoteFSLFee_FID = "CQ_fslFee">
    <cfset CONST_MQ_ignoreCompl_FID = "CQ_ignoreCompl">
    <cfset CONST_MQ_ignoreComplReason_FID = "CQ_ignoreComplReason">
    <cfset CONST_MQ_manualEditReason_FID = "CQ_manualEditReason">
    <cfset CONST_MQ_manualEditor_FID = "CQ_manualEditor">
    
    <!--- BOUND COVER STAGE FIELDs --->
    <cfset CONST_MQ_CoverBoundTitle_FID ="CB_Title">
    <cfset CONST_MQ_CoverCommDate_FID ="CB_CoverCommDate">
    <cfset CONST_MQ_InsurerDOB_FID = "CB_DOB">
    <cfset CONST_MQ_InsuredAddStreet_FID = "CB_Address_Street">
    <cfset CONST_MQ_InsuredAddPost_FID = "CB_Address_Postcode">
    <cfset CONST_MQ_Homephone_FID = "CB_Homephone">
    <cfset CONST_MQ_MobilePhone_FID = "CB_Mobilephone">
    <cfset CONST_MQ_Email_FID = "CB_Email">
    <cfset CONST_MQ_Occupation_FID = "CB_Occupation">
    <cfset CONST_MQ_DriverLicense_No_FID = "CB_DriverLicense_No">
    <cfset CONST_MQ_DriverLicense_Expiry_FID = "CB_DriverLicense_ExpiryDate">
    <cfset CONST_MQ_InterestedParties_FID = "CB_InterestedParties">
    <cfset CONST_MQ_HINNo_FID ="CB_HULL_HIN_No">
    <cfset CONST_MQ_RegoNo_FID ="CB_HULL_Rego_No">
    <cfset CONST_MQ_HullYear_FID = "CB_HULL_Year">
    <cfset CONST_MQ_HullLength_FID = "CB_HULL_Length">
    <cfset CONST_MQ_MotorMake_FID ="CB_Motor_Make">
    <cfset CONST_MQ_MotorHP_FID ="CB_Motor_HP">
    <cfset CONST_MQ_Motor_Year_FID = "CB_Motor_Year">
    <cfset CONST_MQ_MotorSerialNo_FID ="CB_Motor_Serial_No">
    <cfset CONST_MQ_TrailerMake_FID ="CB_Trailer_Make">
    <cfset CONST_MQ_TrailerRego_FID ="CB_Trailer_Rego">
    <cfset CONST_MQ_TrailerYear_FID = "CB_Trailer_Year">
    <cfset CONST_MQ_PurchasedDate_FID = "CB_PurchasedDate">
    <cfset CONST_MQ_PurchasedPrice_FID = "CB_PurchasedPrice">
    <cfset CONST_MQ_PaymentType_FID = "CB_PaymentType"> <!--- CURRENTLY NOT USED  --->
    <cfset CONST_MQ_Fax_FID = "CB_Fax">
    <cfset CONST_MQ_BoatLicense_No_FID = "CB_BoatLicense_No">
    <cfset CONST_MQ_BoatLicense_Expiry_FID = "CB_BoatLicense_ExpiryDate">
    <cfset CONST_MQ_GSTRegistered_FID = "CB_GSTRegistered">
    <cfset CONST_MQ_BusinessABN_FID = "CB_BusinessABN">
    <cfset CONST_MQ_BusinessName_FID = "CB_BusinessName">
    <cfset CONST_MQ_ITC_Claim_FID = "CB_ITC_Claim">
    <cfset CONST_MQ_IsYamahaDNA_FID = "CB_IsYamahaDNA">
    <cfset CONST_MQ_LayupAddress_FID = "CB_LayupAddress">
    <cfset CONST_MQ_IsTransitRisk_FID = "CB_IsTransitRisk">
    <cfset CONST_MQ_IsBoatMoored_FID = "CB_IsBoatMoored">
    <cfset CONST_MQ_MooredType_FID = "CB_MooredType">
    <cfset CONST_MQ_SurveyedDate_FID = "CB_SurveyedDate">
    
    <!--- LIST VALUES --->
    <cfset CONST_MQ_Comp_LID = "7330">
    <cfset CONST_MQ_MotorOnly_LID = "7331">
    <cfset CONST_MQ_TPO_LID = "7332">
    <cfset CONST_MQ_QuoteGapCover_LID = "11209">
    <cfset CONST_MQ_QuoteLoanProtect_LID= "0">
    
    <cfset CONST_MQ_BoatTypePWC_LID = "7213">
    <cfset CONST_MQ_BoatTypeRA_LID = "7212">
    <cfset CONST_MQ_BoatTypeRAM_LID= "7329">
    
    <cfset CONST_MQ_MotorType_IMM_LID = "7227">
    <cfset CONST_MQ_MotorType_IRM_LID = "7333">
    <cfset CONST_MQ_StorageMethod_Other_LID = "7244">
    <cfset CONST_MQ_StorageMethod_Moored_LID = "7525">
    
    <cfset CONST_MQ_Construct_Fibre_LID = "7219">
    <cfset CONST_MQ_Construct_Alum_LID = "7220">
    <cfset CONST_MQ_Construct_Rubber_LID = "7221">
    <cfset CONST_MQ_Construct_Plastic_LID = "7222">
    
    <!--- <cfset CONST_MQ_BoatExp_0_1_LID = "7237">
    <cfset CONST_MQ_BoatExp_2_5_LID = "7238">
    <cfset CONST_MQ_BoatExp_6_10_LID = "7239">
    <cfset CONST_MQ_BoatExp_11_15_LID = "7240">
    <cfset CONST_MQ_BoatExp_16_LID = "7241">
    
    <cfset CONST_MQ_Liabilty_1mil_LID = "7217">
    <cfset CONST_MQ_Liabilty_2mil_LID = "7218">
    <cfset CONST_MQ_Liabilty_5mil_LID = "7334">
    
    <cfset CONST_MQ_MotorAge_0_5_LID = "7232">
    <cfset CONST_MQ_MotorAge_6_10_LID = "7233">
    <cfset CONST_MQ_MotorAge_11_15_LID = "7234">
    <cfset CONST_MQ_MotorAge_16_20_LID = "7235">
    <cfset CONST_MQ_MotorAge_21_25_LID = "7236">
    <cfset CONST_MQ_MotorAge_26_LID = "7335"> 
    --->
    
    <cfset CONST_MQ_BoatSpeed_1_35_LID = "7214">
    <cfset CONST_MQ_BoatSpeed_36_110_LID = "7215">
    <cfset CONST_MQ_BoatSpeed_111_LID = "7216">
    <cfset CONST_MQ_BoatProd_Yes_LID = "7223">
    <cfset CONST_MQ_BoatProd_No_LID = "7224">   
    
    <cfset CONST_MQ_paymentType_ListID = 829>
    <cfset CONST_MQ_paymentType_Cheque_LID = 7730>
    <cfset CONST_MQ_paymentType_Mastercard_LID = 7731>
    <cfset CONST_MQ_paymentType_Visa_LID = 7732>
    <cfset CONST_MQ_paymentType_FinancedYMF_LID = 7733>
    <cfset CONST_MQ_paymentType_FinancedOther_LID = 7734>
    
    <cfset CONST_MQ_MotorType_ListID = 760>
    <cfset CONST_MQ_FuelType_ListID = 761>
    <cfset CONST_MQ_Excess_ListID = 754>
    <cfset CONST_MQ_BoatType_ListID = 755> 
    <cfset CONST_MQ_Construct_ListID = 758>
    <cfset CONST_MQ_LayupMth_ListID = 746>
    <cfset CONST_MQ_State_ListID = 1041>
    <cfset CONST_MQ_StateArea_ListID = 1040>
    <cfset CONST_MQ_LoanTerm_ListID = 918>
    <cfset CONST_MQ_gender_ListID = 826>
    <cfset CONST_MQ_StorageMethod_ListID = 764>
    <cfset CONST_MQ_LiabilityLimit_ListID = 757>
    <cfset CONST_MQ_BoatSpeed_ListID = 756>
    <cfset CONST_MQ_paymentType_ListID = 829>
    <cfset CONST_MQ_boatAge_ListID = 799>
    <cfset CONST_MQ_motorAge_ListID = 762>
    <cfset CONST_MQ_personAge_ListID = 800>
    <cfset CONST_MQ_boatExp_ListID = 763>
    <cfset CONST_MQ_insurablePWCMaker_ListID = 787>   
    <cfset CONST_MQ_BoatMake_ListID = 847>
	
	<cfset CONST_BQ_QD_promoCode = "QD_promoCode">	<!--- Ticket 46175 - PromoCode --->
    
<!--- CALCULATOR ITEMS --->
<cfset CONST_ID_PWC_Insured_Value_Bands=1>
<cfset CONST_ID_RA_Insured_Value_Bands=2>
<cfset CONST_ID_PWC_Boat_Age=3>
<cfset CONST_ID_RA_Boat_Age=4>
<cfset CONST_ID_RA_Motor_Type=5>
<cfset CONST_ID_Boat_Construction=6>
<cfset CONST_ID_Boating_Course=7>
<cfset CONST_ID_Boating_Experience=8>
<cfset CONST_ID_PWC_Excess_Rating=9>
<cfset CONST_ID_RA_Excess_Rating=10>
<cfset CONST_ID_Layup_Discount=11>
<cfset CONST_ID_Liability_Limit=12>
<cfset CONST_ID_PWC_Motor_Age=13>
<cfset CONST_ID_RA_Motor_Age=14>
<cfset CONST_ID_PWC_Boat_Speed=15>
<cfset CONST_ID_RA_Boat_Speed=16>
<cfset CONST_ID_Boat_Storage=17>
<cfset CONST_ID_Street_Parking=18>
<cfset CONST_ID_Water_Skiers=19>
<cfset CONST_ID_Customer_Age=20>
<cfset CONST_ID_Admin_Fee=21>
<cfset CONST_ID_Fire_Service_Levy=22>
<cfset CONST_ID_GST=23>
<cfset CONST_ID_Motor_Only_Rate=24>
<cfset CONST_ID_TPO_Amount=25>
<cfset CONST_ID_MIN_PremiumBase=26>
<cfset CONST_ID_MAX_BoatPrice=27>
<cfset CONST_ID_PersonalAccidentCover=133>

<cfset CONST_ID_PayByMonthCharge = 147>
<cfset CONST_ID_PayByMonthCharge_CCExtra = 148>
<cfset CONST_ID_GapExtraCover = 149>
<cfset CONST_ID_LP_LifeTerm = 0>
<cfset CONST_ID_LP_DisableTerm = 0>
<cfset CONST_ID_LP_UnempTerm = 0>
<cfset CONST_ID_LP_CashAssTerm = 0>