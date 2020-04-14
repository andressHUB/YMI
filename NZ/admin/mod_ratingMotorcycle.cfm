<cfinclude template="constants.cfm">
<cfparam name="attributes.bikeValue" default="0">
<cfparam name="attributes.bikeModel" default=""> <!--- NVIC --->
<cfparam name="attributes.bikeYr_manual" default=""> <!--- only have value for not-yet-listed model - bikeModel = -1 --->
<cfparam name="attributes.bikeMake_manual" default=""> <!--- only have value for not-yet-listed model - bikeModel = -1 --->
<cfparam name="attributes.bikeStyle_manual" default=""> <!--- only have value for not-yet-listed model - bikeModel = -1 --->
<cfparam name="attributes.ncbRating" default="">
<cfparam name="attributes.riderDob" default="">
<cfparam name="attributes.licenseConsYr" default="">
<cfparam name="attributes.State" default="">
<cfparam name="attributes.StateArea" default="">
<cfparam name="attributes.StorageMethod" default="">
<cfparam name="attributes.excessId" default="">
<cfparam name="attributes.layupMonths" default=""> <!--- string of layout months 0 or 1 flags --->
<cfparam name="attributes.quoteDate" default=""> <!--- the quoting date - on DD/MM/YYYY  --->
<cfparam name="attributes.output_comp" default="">
<cfparam name="attributes.output_offroad" default="">
<cfparam name="attributes.output_tpd" default="">
<cfparam name="attributes.output_tpo" default="">
<cfparam name="attributes.otherProducts" default=false>
<cfparam name="attributes.loanValue" default=""> <!--- Loan Amount for LP product --->
<cfparam name="attributes.roadReg" default="1"> 

<cfparam name="attributes.promoCode" default="">  <!--- Promo code Ticket 46175 --->

<cfparam name="attributes.output_others" default="">



<cfif not isDefined("attributes.quoteDate") or attributes.quoteDate eq "">
	<cfset attributes.quoteDate = DateFormat(now(),"DD/MM/YYYY")>
</cfif>
<cfset compareDate = CreateDateTime(mid(attributes.quoteDate,7,4),  mid(attributes.quoteDate,4,2),  mid(attributes.quoteDate,1,2),  23,  59,  59)>

<!--- Get the active rates --->
<cfquery name="getExistingRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    select ymrd.*, ymrc.startAt, li.list_item_display, li.list_item_seq
    from (select top 1 * from ymi_motorcycle_rateControl where startAt < #CreateODBCDateTime(now())# and motorcycle_company_id = #CONST_MOTORCYCLE_COMP_ID# order by startAt desc) ymrc
    inner join ymi_motorcycle_rateData ymrd on ymrc.motorcycle_rateControlID = ymrd.motorcycle_rateControlID
    left outer join thirdgen_list_item li on isnumeric(ymrd.rateFor) = 1 and ymrd.rateFor = cast(li.list_item_id as varchar)
</cfquery>

<cfif attributes.otherProducts> <!--- REQ: attributes.State, attributes.loanValue --->
    <cfset otherProductsStruct = structNew()>
    <cfset premiumCalcStruct = structNew()>
    
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_Admin_Fee# order by motorcycle_rate_item_id
    </cfquery>
    <cfif getSpecificRate.motorcycle_rate_item_id neq "">
        <cfset x = StructInsert(premiumCalcStruct,"adminCost",getSpecificRate.feeDollar)> 
    <cfelse>
        <cfset x = StructInsert(premiumCalcStruct,"adminCost",0)> 
    </cfif>
    
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_GST# order by motorcycle_rate_item_id
    </cfquery>
    <cfif getSpecificRate.motorcycle_rate_item_id neq "">
        <cfset x = StructInsert(premiumCalcStruct,"gstRate",getSpecificRate.loadingPercent)> 
    <cfelse>
        <cfset x = StructInsert(premiumCalcStruct,"gstRate",0)> 
    </cfif>
    
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_FSL_fee# order by motorcycle_rate_item_id
    </cfquery>
    <cfif getSpecificRate.motorcycle_rate_item_id neq "">
        <cfset x = StructInsert(premiumCalcStruct,"fslFee",getSpecificRate.feedollar)> 
    <cfelse>
        <cfset x = StructInsert(premiumCalcStruct,"fslFee",0)> 
    </cfif>
  
    <!--- 
    <cfif getSpecificRate.motorcycle_rate_item_id neq "">
        <cfloop query="#getSpecificRate#">
            <cfset x = StructInsert(GapExtraCoverStruct,getSpecificRate.rateend,getSpecificRate.feedollar)> 
            <cfset tmpVal = (1 + (StructFind(premiumCalcStruct,"stampDutyRate_GAP") / 100)) * ((1 + (StructFind(premiumCalcStruct,"gstRate") / 100)) * getSpecificRate.feedollar) >
            <cfset x = StructInsert(GapExtraCoverDspStruct,getSpecificRate.rateend,tmpVal)> 
        </cfloop>
    </cfif>
     --->
     
    <cfset TyreRimCoverStruct = structNew()>
    <cfset TyreRimCoverDspStruct = structNew()>
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_TyreRimBase# order by motorcycle_rate_item_id
    </cfquery>
    <cfif getSpecificRate.motorcycle_rate_item_id neq "">
        <cfset x = StructInsert(TyreRimCoverStruct,"BaseCost",getSpecificRate.feedollar)> 
        <cfset tmpVal = (1 + (StructFind(premiumCalcStruct,"gstRate") / 100)) * getSpecificRate.feedollar >
        <cfset x = StructInsert(TyreRimCoverDspStruct,"BaseCost",tmpVal)> 
    <cfelse>
        <cfset x = StructInsert(TyreRimCoverStruct,"BaseCost",0)> 
        <cfset x = StructInsert(TyreRimCoverDspStruct,"BaseCost","")> 
    </cfif>
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_TyreRimMaxBase# order by motorcycle_rate_item_id
    </cfquery>
    <cfif getSpecificRate.motorcycle_rate_item_id neq "">
        <cfset x = StructInsert(TyreRimCoverStruct,"BaseCostMax",getSpecificRate.feedollar)> 
        <cfset tmpVal = (1 + (StructFind(premiumCalcStruct,"gstRate") / 100)) * getSpecificRate.feedollar >
        <cfset x = StructInsert(TyreRimCoverDspStruct,"BaseCostMax",tmpVal)> 
    <cfelse>
        <cfset x = StructInsert(TyreRimCoverStruct,"BaseCostMax",0)> 
        <cfset x = StructInsert(TyreRimCoverDspStruct,"BaseCostMax","")> 
    </cfif>
    <cfset x = StructInsert(premiumCalcStruct,"TyreRimCover",TyreRimCoverStruct)> 
    <cfset x = StructInsert(premiumCalcStruct,"TyreRimCoverDisp",TyreRimCoverDspStruct)> 
    
    
    <cfset GapExtraCoverStruct = structNew()>
    <cfset GapExtraCoverDspStruct = structNew()>
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_GapExtraCover# order by motorcycle_rate_item_id
    </cfquery>
    <cfif getSpecificRate.motorcycle_rate_item_id neq "">
        <cfloop query="#getSpecificRate#">
            <cfset x = StructInsert(GapExtraCoverStruct,getSpecificRate.rateend,getSpecificRate.feedollar)> 
            <cfset tmpVal = (1 + (StructFind(premiumCalcStruct,"gstRate") / 100)) * getSpecificRate.feedollar>
            <cfset x = StructInsert(GapExtraCoverDspStruct,getSpecificRate.rateend,tmpVal)> 
        </cfloop>
    </cfif>
    <cfset x = StructInsert(premiumCalcStruct,"GapExtraCover",GapExtraCoverStruct)> 
    <cfset x = StructInsert(premiumCalcStruct,"GapExtraCoverDisp",GapExtraCoverDspStruct)> 
    
    <cfif ATTRIBUTES.loanValue gt 0 and ATTRIBUTES.loanValue neq "">
        <cfset LPCoverStruct = structNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_LP_LifeTerm# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfloop query="#getSpecificRate#">
                <cfset x = StructInsert(LPCoverStruct,getSpecificRate.ratefor,NumberFormat(getSpecificRate.loadingPercent/100 * ATTRIBUTES.loanValue,".99"))> 
            </cfloop>
        </cfif>
        <cfset x = StructInsert(premiumCalcStruct,"LP_LifeTermCover",LPCoverStruct)>  
        
        <cfset LPCoverStruct = structNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_LP_DisableTerm# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfloop query="#getSpecificRate#">
                <cfset x = StructInsert(LPCoverStruct,getSpecificRate.ratefor,NumberFormat(getSpecificRate.loadingPercent/100 * ATTRIBUTES.loanValue,".99"))> 
            </cfloop>
        </cfif>
        <cfset x = StructInsert(premiumCalcStruct,"LP_DisableTermCover",LPCoverStruct)>  
        
        <cfset LPCoverStruct = structNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_LP_UnempTerm# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfloop query="#getSpecificRate#">
                <cfset x = StructInsert(LPCoverStruct,getSpecificRate.ratefor,NumberFormat(getSpecificRate.loadingPercent/100 * ATTRIBUTES.loanValue,".99"))> 
            </cfloop>
        </cfif>
        <cfset x = StructInsert(premiumCalcStruct,"LP_UnempTermCover",LPCoverStruct)>  
        
        <cfset LPCoverStruct = structNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_LP_CashAssTerm# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfloop query="#getSpecificRate#">
                <cfset x = StructInsert(LPCoverStruct,getSpecificRate.ratefor,NumberFormat(getSpecificRate.loadingPercent/100 * ATTRIBUTES.loanValue,".99"))> 
            </cfloop>
        </cfif>
        <cfset x = StructInsert(premiumCalcStruct,"LP_CashAssistTermCover",LPCoverStruct)>  
    </cfif>
    
    <cfset x = StructInsert(otherProductsStruct,"ratesId",getExistingRates.motorcycle_rateControlID)> 
    <cfset x = StructInsert(otherProductsStruct,"calcParams",premiumCalcStruct)> 
    
    <cfset outputVar = "caller.#attributes.output_others#"> <cfset setVariable(outputVar,otherProductsStruct)>

<cfelse>

    <cfset compPremStruct = structNew()>
    <cfset offRoadPremStruct = structNew()>
    <cfset tpdPremStruct = structNew()>
    <cfset tpoPremStruct = structNew()>
    <cfset premiumCalcStruct = structNew()>
    <cfset errorFlag=ArrayNew(1)>
    
    <cfset bikeModelOK = true> <!--- SHOULD've already checked by the calling page, but in case ... --->
    <cfset local_bikeAge = "">
    <cfset local_bikeMake = "">
    <cfset local_bikeStyle = "">
   
    <cfif attributes.bikeModel eq -1> <!--- DISREGARD IF It's a NEW MODEL NOT YET LISTED --->
        <cfset bikeModelOK = true>
        <cfset local_bikeMake = attributes.bikeMake_manual>
        <cfset local_bikeStyle = attributes.bikeStyle_manual>
        <cfset local_bikeAge = year(now()) - attributes.bikeYr_manual>
    <cfelse>
        <cfquery name="getBikeData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
        select fd.xml_data
        from thirdgen_form_data fd with (nolock)
        inner join thirdgen_form_header_data fhd with (nolock) on fd.form_data_id = fhd.form_data_id 
            and fd.form_def_id = #CONST_bikeDataFormDefId# and fhd.text1 = '#attributes.bikeModel#'
        </cfquery>
        <cfif getBikeData.xml_data neq "">
            <cfwddx action="WDDX2CFML" input="#getBikeData.xml_data#" output="bikeDataStruct">	
            <cfset data_bikeIsInsurable = StructFind(bikeDataStruct,CONST_BD_IsInsurable_FID)>
            <cfif data_bikeIsInsurable eq "0" or data_bikeIsInsurable eq "" >
                <cfset bikeModelOK = false>
            </cfif>
            <cfset local_bikeAge = StructFind(bikeDataStruct,CONST_BD_Year_FID)>
            <cfset local_bikeAge = year(now()) - local_bikeAge>
            <cfset local_bikeMake = StructFind(bikeDataStruct,CONST_BD_Make_FID)>
            <cfset local_bikeStyle = StructFind(bikeDataStruct,CONST_BD_Style_FID)>
        <cfelse>
            <cfset bikeModelOK = false>
        </cfif>
    </cfif>
 
    <cfif bikeModelOK>
        <cfif attributes.roadReg eq 1>
            <cfquery name="getSpecificRate" dbtype="query">
            select * from getExistingRates 
            where motorcycle_rateCategoryID = #CONST_ID_BikeAgeLimit# 
            and rateFor = '#CONST_BQ_QuoteComp_ListItemID#'
            order by rateEnd asc
            </cfquery>
        <cfelse>
            <cfquery name="getSpecificRate" dbtype="query">
            select * from getExistingRates 
            where motorcycle_rateCategoryID = #CONST_ID_BikeAgeLimit# 
            and rateFor = '#CONST_BQ_QuoteOffRoad_ListItemID#'
            order by rateEnd asc
            </cfquery>
        </cfif>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "" and LSParseNumber(getSpecificRate.feeDollar) gt 0>
            <cfif local_bikeAge gt LSParseNumber(getSpecificRate.feeDollar)>
                <cfset x = ArrayAppend(errorFlag,"EXCEED_MAXBIKEAGE")>
                <cfset bikeModelOK = false>
            </cfif>
        </cfif>
        
    </cfif>
 
    <cfif bikeModelOK> <!--- Bike is insurable --->
        
        <cfset rate_layup = 0>
        <cfset layups = StructNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_Layup_Discount# order by motorcycle_rate_item_id
        </cfquery>
        
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"layupRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"layupRate",0)> 
        </cfif> 
    
        <cfset x = StructInsert(premiumCalcStruct,"layupMthStr",attributes.layupMonths)> 
        
        <cfset x = StructInsert(premiumCalcStruct,"ratesId",getExistingRates.motorcycle_rateControlID)> 
        <cfset x = StructInsert(premiumCalcStruct,"effectiveDate", getExistingRates.startAt)> 
        <cfset x = StructInsert(premiumCalcStruct,"bikeValue",attributes.bikeValue)> 
        
        <!--- CHECK BASE RATES (start) --->
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_Base_Rates# 
        and rateFor = '#CONST_BQ_QuoteComp_ListItemID#'
        and rateEnd >= #attributes.bikeValue#
        order by rateEnd asc
        </cfquery>

        <cfif getSpecificRate.motorcycle_rate_item_id neq "" and LSParseNumber(getSpecificRate.loadingPercent) gt 0>
            <cfset x = StructInsert(premiumCalcStruct,"baseRate_comp",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"baseRate_comp",0)> 
            <!--- <cfset x = ArrayAppend(errorFlag,"NO_RATE_COMP")> --->
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_Base_Rates# 
        and rateFor = '#CONST_BQ_QuoteOffRoad_ListItemID#'
        and rateEnd >= #attributes.bikeValue#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "" and LSParseNumber(getSpecificRate.loadingPercent) gt 0>
            <cfset x = StructInsert(premiumCalcStruct,"baseRate_offroad",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"baseRate_offroad",0)> 
            <!--- <cfset x = ArrayAppend(errorFlag,"NO_RATE_OFFROAD")> --->
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_Base_Rates# 
        and rateFor = '#CONST_BQ_QuoteTPD_ListItemID#'
        and rateEnd >= #attributes.bikeValue#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "" and LSParseNumber(getSpecificRate.loadingPercent) gt 0>
            <cfset x = StructInsert(premiumCalcStruct,"baseRate_tpd",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"baseRate_tpd",0)>
            <!--- <cfset x = ArrayAppend(errorFlag,"NO_RATE_TPD")> --->
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_TPO_Price# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "" and LSParseNumber(getSpecificRate.feeDollar) gt 0>
            <cfset x = StructInsert(premiumCalcStruct,"baseCost_tpo",getSpecificRate.feeDollar)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"baseCost_tpo",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_RATE_TPO")>
        </cfif>    
        <!--- CHECK BASE RATES (end) --->
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_GST# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"gstRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"gstRate",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_FSL_fee# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"fslFee",getSpecificRate.feedollar)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"fslFee",0)> 
        </cfif>
    
	
		<!--- START ASF Ticket 46175 - PromoCode --->
		<cfif attributes.promoCode neq "">			
	        <cfquery name="getPromoRate" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
	        select pc.percentage as loadingPercent 
			from scheme_promo_code pc(nolock) 
			where pc.vessel_type_id = 0 
	        and pc.promo_code = '#attributes.promoCode#'
			and site_id = '#session.thirdgenas.siteid#'
			and isnull(pc.start_datetime,'2099-12-31') <= #CreateODBCDateTime(lsDateFormat(now(),'dd/mmm/yyyy'))#
			and isnull(pc.end_datetime,'2001-12-31') >= #CreateODBCDateTime(lsDateFormat(now(),'dd/mmm/yyyy'))# 
	        </cfquery>
	        <cfif getPromoRate.loadingPercent neq "">
	            <cfset x = StructInsert(premiumCalcStruct,"PromoCodeDiscountRate",getPromoRate.loadingPercent)> 
	        <cfelse>
	            <cfset x = StructInsert(premiumCalcStruct,"PromoCodeDiscountRate",0)> 
	        </cfif>

<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug YMI NZ MC DEV getPromoRate" type="HTML">
	<cfdump var="#getPromoRate#">
</cfmail> --->				
			
		</cfif>

<!--- <cfdump var="#getPromoRate#">
<cfabort> --->
		
		<!--- END ASF Ticket 46175 - PromoCode --->
	
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_Admin_Fee# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"adminCost",getSpecificRate.feeDollar)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"adminCost",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_Min_Premium_Cost# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"minPremCost",getSpecificRate.feeDollar)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"minPremCost",0)> 
        </cfif>       
                
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_LiabilityAmountBase# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"liabilityBaseCost",getSpecificRate.feeDollar)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"liabilityBaseCost",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_LIABILITYBASE")>
        </cfif>   
        
    
        <cfset local_riderAge = DateDiff("yyyy",attributes.riderDOB, now())>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_Age_Loadings# 
        and rateFor = '#CONST_BQ_QuoteComp_ListItemID#'
        and rateEnd >= #local_riderAge#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"riderAgeRate_comp",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"riderAgeRate_comp",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_RIDERAGE")>
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_Age_Loadings# 
        and rateFor = '#CONST_BQ_QuoteOffRoad_ListItemID#'
        and rateEnd >= #local_riderAge#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"riderAgeRate_offroad",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"riderAgeRate_offroad",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_RIDERAGE")>
        </cfif>
    
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_Age_Loadings# 
        and rateFor = '#CONST_BQ_QuoteTPD_ListItemID#'
        and rateEnd >= #local_riderAge#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"riderAgeRate_tpd",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"riderAgeRate_tpd",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_RIDERAGE")>
        </cfif>
    
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_LicenseYr# 
        and rateEnd >= #attributes.licenseConsYr#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"licenseYrRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"licenseYrRate",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_LICENSEYR")>
        </cfif>
               
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_NCB# 
        and rateFor = '#attributes.ncbRating#'
        order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"ncbRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"ncbRate",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_NCB")>
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_State# 
        and rateFor = '#attributes.State#'
        order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"stateRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"stateRate",0)>
            <cfset x = ArrayAppend(errorFlag,"NO_STATE")> 
        </cfif>
        
        <!---
        <!--- Metro / Country --->
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        <cfif attributes.StateArea eq CONST_BQ_StateAreaCountry_LID>
        where motorcycle_rateCategoryID = #CONST_ID_StateCountry#
        <cfelse>
        where motorcycle_rateCategoryID = #CONST_ID_StateMetro#
        </cfif>
        and rateFor = '#attributes.State#'
        order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"stateAreaRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"stateAreaRate",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_STATEAREA")> 
        </cfif> 
        --->
    
        <!--- Service Ticket #26533 - NZ Motorcycle calculator changes --->
        <cfquery name="getTempRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = <cfif attributes.roadReg eq 1>#CONST_ID_Excess_Discount#<cfelse>#CONST_ID_Excess_Discount_OffRoad#</cfif>  
        and rateEnd >= #attributes.bikeValue#
        order by rateEnd asc, list_item_seq asc
        </cfquery>
        <cfset getTempRate.RemoveRows(4,(getTempRate.RecordCount - 4 )) /> <!--- GET TOP 4 results from QoQ because there are only 4 options per price range --->

        <cfquery name="getSpecificRate" dbtype="query">
        select * from getTempRate
        where rateFor = '#attributes.excessID#'
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"excessRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"excessRate",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_EXCESS")> 
        </cfif>

        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_StorageMethod# 
        and rateFor = '#attributes.StorageMethod#'
        order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"storageMethodRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"storageMethodRate",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_STORAGEMETHOD")> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_BikeYr# 
        and rateEnd >= #local_bikeAge#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"bikeAgeRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"bikeAgeRate",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_BIKEAGE")> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where motorcycle_rateCategoryID = #CONST_ID_BikeType# 
        and upper(list_item_display) = upper('#local_bikeStyle#')
        order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "">
            <cfset x = StructInsert(premiumCalcStruct,"bikeStyleRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"bikeStyleRate",0)> 
            <cfset x = ArrayAppend(errorFlag,"NO_BIKESTYLE")> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_YMIDealerRate# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "" > <!--- and CompareNoCase(local_bikeMake,"YAMAHA") eq 0 ---> <!--- It's applicable to everyone now - 12/03/2014 --->
            <cfset x = StructInsert(premiumCalcStruct,"ymiDiscRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"ymiDiscRate",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_MaxDisc# order by motorcycle_rate_item_id
        </cfquery>
        <cfif getSpecificRate.motorcycle_rate_item_id neq "" >
            <cfset x = StructInsert(premiumCalcStruct,"maxDiscRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(premiumCalcStruct,"maxDiscRate",0)> 
        </cfif>
        
    
        <cfif ArrayLen(errorFlag) gt 0>            
            <cfset x = StructInsert(compPremStruct,"calcResult",errorFlag[1],true)> 
            <cfset x = StructInsert(offroadPremStruct,"calcResult",errorFlag[1],true)> 
            <cfset x = StructInsert(tpdPremStruct,"calcResult",errorFlag[1],true)> 
            <cfset x = StructInsert(tpoPremStruct,"calcResult",errorFlag[1],true)> 
        <cfelse>
            <cfif StructFind(premiumCalcStruct,"baseRate_comp") gt 0>
                <cfset compPremStruct = calcRating(premiumCalcStruct,"COMP")>
            <cfelse>
                <cfset x = StructInsert(compPremStruct,"calcResult","NO_RATE_COMP",true)> 
            </cfif>
            <cfif StructFind(premiumCalcStruct,"baseRate_offroad") gt 0>
                <cfset offroadPremStruct = calcRating(premiumCalcStruct,"OFFROAD")>
             <cfelse>
                <cfset x = StructInsert(offroadPremStruct,"calcResult","NO_RATE_OFFROAD",true)> 
            </cfif>
            <cfif StructFind(premiumCalcStruct,"baseRate_tpd") gt 0>
                <cfset tpdPremStruct = calcRating(premiumCalcStruct,"TPD")>
            <cfelse>
                <cfset x = StructInsert(tpdPremStruct,"calcResult","NO_RATE_TPD",true)> 
            </cfif>
            <cfset tpoPremStruct = calcRating(premiumCalcStruct,"TPO")>
        </cfif>
    
    <cfelse>
        <!--- Bike not insurable --->
        <cfset x = ArrayAppend(errorFlag,"NOT_INSURABLE")>
        <cfset x = StructInsert(compPremStruct,"calcResult",errorFlag[1],true)> 
        <cfset x = StructInsert(offroadPremStruct,"calcResult",errorFlag[1],true)> 
        <cfset x = StructInsert(tpdPremStruct,"calcResult",errorFlag[1],true)> 
        <cfset x = StructInsert(tpoPremStruct,"calcResult",errorFlag[1],true)> 
    </cfif>
    

    
    <cfset outputVar = "caller.#attributes.output_comp#"> <cfset setVariable(outputVar,compPremStruct)>
    <cfset outputVar = "caller.#attributes.output_offroad#"> <cfset setVariable(outputVar,offroadPremStruct)>
    <cfset outputVar = "caller.#attributes.output_tpd#"> <cfset setVariable(outputVar,tpdPremStruct)>
    <cfset outputVar = "caller.#attributes.output_tpo#"> <cfset setVariable(outputVar,tpoPremStruct)>

</cfif>

<!--- User Defined Functions --->

<cffunction name="calcRating" returntype="struct">
    <cfargument name="calcParams" required="Yes" type="struct">
    <cfargument name="coverType" required="No" type="string" default="">
    
    <!--- 
    AVAILABLE PARAM on calcParams:
    =============================
    layupRate
    layupMthStr
    ratesId
    effectiveDate
    bikeValue
    baseRate_comp
    baseRate_offroad
    baseRate_tpd
    baseCost_tpo
    gstRate
    fslFee
    adminCost
    minPremCost
    riderAgeRate_comp
    riderAgeRate_offroad
    riderAgeRate_tpd
    stateRate
    stateAreaRate
    excessRate
    bikeAgeRate
    bikeStyleRate
    ymiDiscRate
    ncbRate
    licenseYrRate
    storageMethodRate
    LiabBaseCost
    --->
    
    <cfset premiumStruct = StructNew()>     
    <cfset x = StructInsert(premiumStruct,"ratesId",arguments.calcParams.ratesId)> 
    <cfset x = StructInsert(premiumStruct,"calcParams",arguments.calcParams)> 
    
    
    <cfset baseValue = 0>
    <cfset subTotPrem = 0>
    <cfset totPrem = 0>
    <cfset totDiscLoading = 0>
    <cfset totGst = 0>
    <cfset totFSL = 0> 
    <cfset totLayup = 0>
    <cfset layupRate = 0>
    <cfset calcResult="NO_RATE">

    
    <!--- Get layup discount --->
    <cfloop from="1" to="12" index="m">
        <cfset monthFlag = ListGetAt(arguments.calcParams.layupMthStr,m)>
        <cfif monthFlag eq "1">
            <cfset layupRate = layupRate + arguments.calcParams.layupRate>
        </cfif>
    </cfloop>
    
    <cfif CompareNoCase(arguments.coverType,"TPO") eq 0> <!--- TPO --->
        <cfset baseValue = arguments.calcParams.baseCost_tpo>
        <cfset baseValue = NumberFormat(baseValue,".99")>
        <cfset totDiscLoading = 0 >
        <!--- <cfset totLayup = 0> --->
        <cfset totLayup = (layupRate/100) * baseValue>
        <cfset subTotPrem = baseValue + totDiscLoading + totLayup>
        <cfif subTotPrem lt arguments.calcParams.minPremCost>
            <cfset subTotPrem = arguments.calcParams.minPremCost>
        </cfif>
        
        <cfset totGst = ((arguments.calcParams.gstRate/100) * subTotPrem) >
        <!--- <cfset totGst = totGst + ((arguments.calcParams.gstRate/100) * arguments.calcParams.adminCost) > --->
        <cfset totFSL = 0> 
        <cfset totGst = NumberFormat(totGst,".99")>
        <cfset totPrem = subTotPrem + totGst + totFSL>
        <cfset calcResult="OK">
        
    <cfelse>

        <cfif CompareNoCase(arguments.coverType,"COMP") eq 0> <!--- COMP --->
            <cfset baseValue = (arguments.calcParams.baseRate_comp/100) * arguments.calcParams.bikeValue>
            <cfset baseValue = NumberFormat(baseValue,".99")>
			
			<cfset compBaseValue = baseValue>			<!--- ASF Ticket 46175 - PromoCode --->
			
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au" type="html" subject="Debug COMP DISCOUNT 1 YMI NZ MC DEV">
	<cfdump var="#baseValue#">
</cfmail> --->			
			
			<!--- START ASF Ticket 46175 - PromoCode --->
				<cfif attributes.promoCode neq "" and StructFind(premiumCalcStruct,"PromoCodeDiscountRate") gt 0>
                    <cfset promoCodeDisc = baseValue * (arguments.calcParams.promoCodeDiscountRate / 100)>    <!--- Apply discount promocode discount --->
                    <cfset baseValue = baseValue - promoCodeDisc>
					
					
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug COMP DISCOUNT 2 YMI NZ MC DEV" type="HTML">
	attributes.promoCode <cfdump var="#attributes.promoCode#"><br>
	arguments.calcParams.promoCodeDiscountRate <cfdump var="#arguments.calcParams.promoCodeDiscountRate#"><br>
	Comp base value <cfdump var="#baseValue#"><br>
	promoCodeDisc <cfdump var="#promoCodeDisc#"><br>
</cfmail> --->
					
					<!--- <cfif debugMode>    
						baseValue after Promo Code 2 <cfdump var="#baseValue#"><br></span>
					</cfif> --->
                    
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au" type="html" subject="Debug COMP after DISC base value">
	<cfdump var="#baseValue#">
</cfmail> --->


<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au" type="html" subject="Debug COMP DISCOUNT 3 YMI NZ MC DEV">
	<cfdump var="#baseValue#">
</cfmail> --->
                    
                </cfif>
				<!--- END ASF Ticket 46175 - PromoCode --->
			
            <cfset totLayup = (layupRate/100) * baseValue>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.stateRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.excessRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.ncbRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.riderAgeRate_comp / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.licenseYrRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.bikeAgeRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.bikeStyleRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.ymiDiscRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.storageMethodRate / 100 * baseValue)>

            <cfset subTotPrem = baseValue + totDiscLoading + totLayup >
            <cfif subTotPrem lt arguments.calcParams.minPremCost>
                <cfset subTotPrem = arguments.calcParams.minPremCost>
            </cfif>
			
			
			<!--- START ASF Ticket 46175 - PromoCode 
				<cfif subTotPrem lt arguments.calcParams.minPremCost>									
						<cfset subTotPrem = arguments.calcParams.minPremCost>
				</cfif>--->
				
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug COMP DISCOUNT 4" type="HTML">
	subTotPrem <cfdump var="#subTotPrem#"><br>
	compBaseValue <cfdump var="#compBaseValue#"><br>	
</cfmail> --->				
				<!--- END ASF Ticket 46175 - PromoCode --->
            
            <!--- 
            <cfset totLiabilityCost = arguments.calcParams.liabilityBaseCost>
            <cfset totLiabilityCost = totLiabilityCost + ((layupRate/100) * totLiabilityCost) + (arguments.calcParams.ncbRate / 100 * totLiabilityCost) + (arguments.calcParams.ymiDiscRate / 100 * totLiabilityCost)>
            
            <cfset subTotPrem = subTotPrem + totLiabilityCost> 
            --->
            
        <cfelseif CompareNoCase(arguments.coverType,"TPD") eq 0> <!--- TP-FTT --->
            <cfset baseValue = (arguments.calcParams.baseRate_tpd/100) * arguments.calcParams.bikeValue>
            <cfset baseValue = NumberFormat(baseValue,".99")>
            <cfset totLayup = (layupRate/100) * baseValue>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.stateRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.excessRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.ncbRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.riderAgeRate_tpd / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.licenseYrRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.bikeAgeRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.bikeStyleRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.ymiDiscRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.storageMethodRate / 100 * baseValue)>
            
            <cfset subTotPrem = baseValue + totDiscLoading + totLayup>
            <cfif subTotPrem lt arguments.calcParams.minPremCost>
                <cfset subTotPrem = arguments.calcParams.minPremCost>
            </cfif>
            
            <!--- 
            <cfset totLiabilityCost = arguments.calcParams.liabilityBaseCost>
            <cfset totLiabilityCost = totLiabilityCost + ((layupRate/100) * totLiabilityCost) + (arguments.calcParams.ncbRate / 100 * totLiabilityCost) + (arguments.calcParams.ymiDiscRate / 100 * totLiabilityCost) >
            
            <cfset subTotPrem = subTotPrem + totLiabilityCost> 
            --->

         <cfelseif CompareNoCase(arguments.coverType,"OFFROAD") eq 0> <!--- OFF ROAD --->
            <cfset baseValue = (arguments.calcParams.baseRate_offroad/100) * arguments.calcParams.bikeValue>
            <cfset baseValue = NumberFormat(baseValue,".99")>
			
			<!--- START ASF Ticket 46175 - PromoCode --->
			<cfset OffRoadBaseValue = baseValue>
			
			<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug OFF ROAD DISCOUNT 1" type="HTML">
						attributes.promoCode <cfdump var="#attributes.promoCode#"><br>
						premiumCalcStruct.PromoCodeDiscountRate <cfdump var="#premiumCalcStruct.PromoCodeDiscountRate#"><br>
						OFFROAD base value <cfdump var="#baseValue#"><br>
	</cfmail> --->
				
				
				
				<cfif attributes.promoCode neq "" and StructFind(premiumCalcStruct,"PromoCodeDiscountRate") gt 0>
                    <cfset promoCodeDisc = baseValue * (arguments.calcParams.promoCodeDiscountRate / 100)>    <!--- Apply discount promocode discount --->
                    <cfset baseValue = baseValue - promoCodeDisc>
					
													
					
	 <!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug OFF ROAD DISCOUNT 2" type="HTML">
		attributes.promoCode <cfdump var="#attributes.promoCode#"><br>
		premiumCalcStruct.PromoCodeDiscountRate <cfdump var="#premiumCalcStruct.PromoCodeDiscountRate#"><br>
		OFFROAD base value <cfdump var="#baseValue#"><br>
		promoCodeDisc <cfdump var="#promoCodeDisc#"><br>
	</cfmail> --->
					
								              
                </cfif>
				<!--- END ASF Ticket 46175 - PromoCode --->
			
            <cfset totLayup = 0>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.stateRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.excessRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.ncbRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.riderAgeRate_offroad / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.licenseYrRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.bikeAgeRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.bikeStyleRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.ymiDiscRate / 100 * baseValue)>
            <cfset totDiscLoading = totDiscLoading + (arguments.calcParams.storageMethodRate / 100 * baseValue)>
            
            <cfset subTotPrem = baseValue + totDiscLoading + totLayup>
            <cfif subTotPrem lt arguments.calcParams.minPremCost>
                <cfset subTotPrem = arguments.calcParams.minPremCost>
            </cfif>
			
			<!--- START ASF Ticket 46175 - PromoCode 
			<cfif subTotPrem lt OffRoadBaseValue>									
					<cfset subTotPrem = OffRoadBaseValue>
			</cfif>--->
			<!--- END ASF Ticket 46175 - PromoCode --->
            
        </cfif>
        
        <cfset subTotPrem = NumberFormat(subTotPrem,".99")>
        <!--- 
        <cfset totFSL = ((arguments.calcParams.fslRate/100) * arguments.calcParams.bikeValue) > 
        <cfset totFSL = NumberFormat(totFSL,".99")> 
        --->
        <cfset totFSL = NumberFormat(arguments.calcParams.fslFee,".99")> <!--- FSL is CONSTANT DOLLAR AMOUNT --->
        <cfset totGst = ((arguments.calcParams.gstRate/100) * subTotPrem) + ((arguments.calcParams.gstRate/100) * totFSL) >
        <!--- <cfset totGst = totGst + ((arguments.calcParams.gstRate/100) * arguments.calcParams.adminCost) > --->
        <cfset totGst = NumberFormat(totGst,".99")>
        <cfset totPrem = subTotPrem + totGst + totFSL>
        
        <cfset calcResult="OK">
        
    </cfif>
    
    
    <cfset x = StructInsert(premiumStruct,"baseValue",baseValue)> 
    <cfset x = StructInsert(premiumStruct,"totalDiscountLoading",totDiscLoading)> 
    <cfset x = StructInsert(premiumStruct,"subTotPremium",subTotPrem)> 
    <cfset x = StructInsert(premiumStruct,"totalPremium",totPrem)> 
    <cfset x = StructInsert(premiumStruct,"GST",totGst)> 
    <cfset x = StructInsert(premiumStruct,"FSL",totFSL)> 
    <cfset x = StructInsert(premiumStruct,"totalLayupDisc",-1 * totLayup)> 
    <cfset x = StructInsert(premiumStruct,"calcResult",calcResult,true)> 
   
    <cfreturn premiumStruct>
</cffunction>

