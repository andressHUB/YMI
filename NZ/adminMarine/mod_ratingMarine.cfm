<cfinclude template="constants.cfm">
<cfparam name="attributes.boatValue" default="0">
<cfparam name="attributes.boatMake" default=""> <!--- could be numeric (list-item-id) or string --->
<cfparam name="attributes.boatTypeID" default="">
<cfparam name="attributes.boatSpeedID" default="">
<cfparam name="attributes.boatConstrID" default="">
<cfparam name="attributes.boatExcessID" default="">
<cfparam name="attributes.boatExpID" default="">
<cfparam name="attributes.boatLiabilityID" default="">
<cfparam name="attributes.boatStorageID" default="">
<cfparam name="attributes.boatAge" default="">
<cfparam name="attributes.motorTypeID" default="">
<cfparam name="attributes.motorAgeID" default="">
<cfparam name="attributes.sailorAge" default="">
<cfparam name="attributes.isBoatingCourse" default="">
<cfparam name="attributes.isStreetParked" default="">
<cfparam name="attributes.isWaterSkiers" default="">
<cfparam name="attributes.sailorState" default="">
<cfparam name="attributes.sailorStateArea" default=""> 
<cfparam name="attributes.layupMonths" default=""> <!--- string of layout months 0 or 1 flags --->
<cfparam name="attributes.quoteDate" default=""> <!--- the quoting date - on DD/MM/YYYY  --->
<cfparam name="attributes.loanValue" default="">
<cfparam name="attributes.isProd" default="">
<cfparam name="attributes.otherProducts" default=false>
<cfparam name="attributes.promoCode" default="">  <!--- Promo code Ticket 46175 --->

<cfparam name="attributes.output_comp" default="">
<cfparam name="attributes.output_motoronly"default="">
<cfparam name="attributes.output_tpo" default="">
<cfparam name="attributes.output_others" default="">

<cfset calcRatingStruct = structNew()>
<cfset compPremStruct = structNew()>
<cfset motorOnlyPremStruct = structNew()>
<cfset tpoPremStruct = structNew()>
<cfset errorFlag=ArrayNew(1)>

<cfif not isDefined("attributes.quoteDate") or attributes.quoteDate eq "">
	<cfset attributes.quoteDate = DateFormat(now(),"DD/MM/YYYY")>
</cfif>
<cfset compareDate = CreateDateTime(mid(attributes.quoteDate,7,4),  mid(attributes.quoteDate,4,2),  mid(attributes.quoteDate,1,2),  23,  59,  59)>

<!--- Get the active rates --->
<cfquery name="getExistingRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    select ymrd.*, ymrc.startAt, li.list_item_id, li.list_item_display, li.list_item_seq, li.list_item_image
    from (select top 1 * from ymi_marine_rateControl where startAt < #CreateODBCDateTime(now())# and marine_company_id = #CONST_MARINE_COMP_ID# order by startAt desc) ymrc
    inner join ymi_marine_rateData ymrd on ymrc.marine_rateControlID = ymrd.marine_rateControlID
    left outer join thirdgen_list_item li on isnumeric(ymrd.rateFor) = 1 and ymrd.rateFor = cast(li.list_item_id as varchar)
</cfquery>


<cfif attributes.otherProducts>
    <cfset otherProductsStruct = structNew()>
    
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where marine_rateCategoryID = #CONST_ID_Admin_Fee# order by marine_rate_item_id
    </cfquery>
    <cfif getSpecificRate.marine_rate_item_id neq "">
        <cfset x = StructInsert(calcRatingStruct,"adminFee",getSpecificRate.feedollar)> 
    <cfelse>
        <cfset x = StructInsert(calcRatingStruct,"adminFee",0)> 
    </cfif>
    
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where marine_rateCategoryID = #CONST_ID_GST# order by marine_rate_item_id
    </cfquery>
    <cfif getSpecificRate.marine_rate_item_id neq "">
        <cfset x = StructInsert(calcRatingStruct,"gstPer",getSpecificRate.loadingPercent)> 
    <cfelse>
        <cfset x = StructInsert(calcRatingStruct,"gstPer",0)> 
    </cfif>
    
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where marine_rateCategoryID = #CONST_ID_Fire_Service_Levy# order by marine_rate_item_id
    </cfquery>
    <cfif getSpecificRate.marine_rate_item_id neq "">
        <cfset x = StructInsert(calcRatingStruct,"fslPer",getSpecificRate.loadingPercent)> 
    <cfelse>
        <cfset x = StructInsert(calcRatingStruct,"fslPer",0)> 
    </cfif>
    
    <cfset GapExtraCoverStruct = structNew()>
    <cfset GapExtraCoverDspStruct = structNew()>
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where marine_rateCategoryID = #CONST_ID_GapExtraCover# order by marine_rate_item_id
    </cfquery>
    <cfif getSpecificRate.marine_rate_item_id neq "">
        <cfloop query="#getSpecificRate#">
            <cfset x = StructInsert(GapExtraCoverStruct,getSpecificRate.rateend,getSpecificRate.feedollar)> 
            <cfset tmpVal = (1 + (StructFind(calcRatingStruct,"gstPer") / 100)) * getSpecificRate.feedollar>
            <cfset x = StructInsert(GapExtraCoverDspStruct,getSpecificRate.rateend,tmpVal)> 
        </cfloop>
    </cfif>
    <cfset x = StructInsert(calcRatingStruct,"GapExtraCover",GapExtraCoverStruct)> 
    <cfset x = StructInsert(calcRatingStruct,"GapExtraCoverDisp",GapExtraCoverDspStruct)> 
    
    <cfif ATTRIBUTES.loanValue gt 0 and ATTRIBUTES.loanValue neq "">
        <cfset LPCoverStruct = structNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_LP_LifeTerm# order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfloop query="#getSpecificRate#">
                <cfset x = StructInsert(LPCoverStruct,getSpecificRate.ratefor,getSpecificRate.loadingPercent/100 * ATTRIBUTES.loanValue)> 
            </cfloop>
        </cfif>
        <cfset x = StructInsert(calcRatingStruct,"LP_LifeTermCover",LPCoverStruct)>  
        
        <cfset LPCoverStruct = structNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_LP_DisableTerm# order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfloop query="#getSpecificRate#">
                <cfset x = StructInsert(LPCoverStruct,getSpecificRate.ratefor,getSpecificRate.loadingPercent/100 * ATTRIBUTES.loanValue)> 
            </cfloop>
        </cfif>
        <cfset x = StructInsert(calcRatingStruct,"LP_DisableTermCover",LPCoverStruct)>  
        
        <cfset LPCoverStruct = structNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_LP_UnempTerm# order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfloop query="#getSpecificRate#">
                <cfset x = StructInsert(calcRatingStruct,getSpecificRate.ratefor,getSpecificRate.loadingPercent/100 * ATTRIBUTES.loanValue)> 
            </cfloop>
        </cfif>
        <cfset x = StructInsert(calcRatingStruct,"LP_UnempTermCover",LPCoverStruct)>  
        
        <cfset LPCoverStruct = structNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_LP_CashAssTerm# order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfloop query="#getSpecificRate#">
                <cfset x = StructInsert(LPCoverStruct,getSpecificRate.ratefor,getSpecificRate.loadingPercent/100 * ATTRIBUTES.loanValue)> 
            </cfloop>
        </cfif>
        <cfset x = StructInsert(calcRatingStruct,"LP_CashAssistTermCover",LPCoverStruct)>  
    </cfif>
    
    
    <cfset x = StructInsert(otherProductsStruct,"calcParams",calcRatingStruct)> 
    <cfset outputVar = "caller.#attributes.output_others#"> <cfset setVariable(outputVar,otherProductsStruct)>
    
<cfelse>
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where marine_rateCategoryID = #CONST_ID_MAX_BoatPrice#
    </cfquery>
    
     <!--- CHECKING INSURABLE (START) --->
    <!--- cannot insured street parked --->
    <cfif ATTRIBUTES.isStreetParked eq 1> 
        <cfset x = ArrayAppend(errorFlag,"STREETPARK")> 
    </cfif>
    <!--- cannot insured boat that run above 111 km/h --->
    <cfif ATTRIBUTES.boatSpeedID eq CONST_MQ_BoatSpeed_111_LID> 
        <cfset x = ArrayAppend(errorFlag,"BOATSPEED")> 
    </cfif>
    <!--- <!--- cannot insured boat that have inboard - rear mount engine --->
    <cfif ATTRIBUTES.motorTypeID eq CONST_MQ_MotorType_IRM_LID> 
        <cfset x = ArrayAppend(errorFlag,"ENG_REARMOUNT")> 
    </cfif>
    <!--- cannot insured boat that moored or have other option storage method --->
    <cfif ATTRIBUTES.boatStorageID eq CONST_MQ_StorageMethod_Other_LID OR ATTRIBUTES.boatStorageID eq CONST_MQ_StorageMethod_Moored_LID >
        <cfset x = ArrayAppend(errorFlag,"STORAGEMTHD")> 
    </cfif>
    <!--- cannot insured boat that in certain age --->
    <cfif ListFind(CONST_MQ_BoatAge_NotAllowed_LIDS,ATTRIBUTES.boatAgeID) gt 0>
        <cfset x = ArrayAppend(errorFlag,"BOATAGE")> 
    </cfif> --->
    <!--- cannot insured boat that no longer in prod --->
    <cfif ATTRIBUTES.isProd eq CONST_MQ_BoatProd_No_LID> 
        <cfset x = ArrayAppend(errorFlag,"NOT_PROD")> 
    </cfif>   
    <!--- cannot insured boat that above quoteable boat price --->
    <cfif ATTRIBUTES.boatValue gt getSpecificRate.feeDollar>
        <cfset x = ArrayAppend(errorFlag,"OVERPRICE")> 
    </cfif>
    <cfif attributes.boatTypeID neq "">
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where
        <cfif attributes.boatTypeID eq CONST_MQ_BoatTypePWC_LID>
        marine_rateCategoryID = #CONST_ID_PWC_Excess_Rating#
        <cfelse>
        marine_rateCategoryID = #CONST_ID_RA_Excess_Rating#
        </cfif>
        order by rateEnd asc
        </cfquery>
        <cfset xx = ListLast(valuelist(getSpecificRate.rateEnd))>
        <cfif ATTRIBUTES.boatValue gt LSParseNumber(xx)>
            <cfset x = ArrayAppend(errorFlag,"OVERPRICE")> 
        </cfif>
    </cfif>
    <!--- CHECKING INSURABLE (END) --->
    
    <cfif ArrayLen(errorFlag) eq 0>  
        <cfset rate_layup = 0>
        <cfset layups = StructNew()>
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_Layup_Discount# order by marine_rate_item_id
        </cfquery>
        
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"layupRate",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"layupRate",0)> 
        </cfif> 
        
        <cfset x = StructInsert(calcRatingStruct,"layupMthStr",attributes.layupMonths)> 
        
        <cfset x = StructInsert(calcRatingStruct,"ratesId",getExistingRates.marine_rateControlID)> 
        <cfset x = StructInsert(calcRatingStruct,"effectiveDate", getExistingRates.startAt)> 
        <cfset x = StructInsert(calcRatingStruct,"boatValue",attributes.boatValue)> 
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_GST# order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"gstPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"gstPer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_Fire_Service_Levy# order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"fslPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"fslPer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_Admin_Fee# order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"adminFee",getSpecificRate.feedollar)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"adminFee",0)> 
        </cfif>
        
        <!--- PWC / RA --->
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where 
        <cfif attributes.boatTypeID eq CONST_MQ_BoatTypePWC_LID>
        marine_rateCategoryID = #CONST_ID_PWC_Insured_Value_Bands# 
        <cfelse>
        marine_rateCategoryID = #CONST_ID_RA_Insured_Value_Bands#
        </cfif>
        and rateEnd >= #attributes.boatValue#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"InsuredValuePer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"InsuredValuePer",0)> 
        </cfif>
        
        <!--- PWC / RA --->
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where
        <cfif attributes.boatTypeID eq CONST_MQ_BoatTypePWC_LID>
        marine_rateCategoryID = #CONST_ID_PWC_Boat_Age#
        <cfelse>
        marine_rateCategoryID = #CONST_ID_RA_Boat_Age#
        </cfif>
        and rateEnd >= #attributes.boatAge#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"BoatAgePer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"BoatAgePer",0)> 
        </cfif>
        
        <cfif attributes.boatTypeID eq CONST_MQ_BoatTypeRA_LID>
            <cfquery name="getSpecificRate" dbtype="query">
            select * from getExistingRates 
            where  marine_rateCategoryID = #CONST_ID_RA_Motor_Type#
            and rateEnd >= #attributes.boatAge#
            and rateFor = '#attributes.motorTypeID#'
            order by rateEnd asc
            </cfquery>
            <cfif getSpecificRate.marine_rate_item_id neq "">
                <cfset x = StructInsert(calcRatingStruct,"MotorTypePer",getSpecificRate.loadingPercent)> 
            <cfelse>
                <cfset x = StructInsert(calcRatingStruct,"MotorTypePer",0)> 
            </cfif>
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"MotorTypePer",0)>
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_Boat_Construction#
        and rateFor = '#attributes.boatConstrID#'
        order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"BoatConstrPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"BoatConstrPer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_Boating_Course# 
        and rateFor = '#attributes.isBoatingCourse#'
        order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"BoatingCoursePer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"BoatingCoursePer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_Boating_Experience#
        and rateFor = '#attributes.boatExpID#'
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"BoatingExpPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"BoatingExpPer",0)> 
        </cfif>
        
        <!--- PWC / RA --->
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where
        <cfif attributes.boatTypeID eq CONST_MQ_BoatTypePWC_LID>
        marine_rateCategoryID = #CONST_ID_PWC_Excess_Rating#
        <cfelse>
        marine_rateCategoryID = #CONST_ID_RA_Excess_Rating#
        </cfif>
        and rateEnd >= #attributes.boatValue#
        and rateFor = '#attributes.boatExcessID#'
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"ExcessRtgPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"ExcessRtgPer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_Liability_Limit#
        and rateFor = '#attributes.boatLiabilityID#'
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"LiabilityDollar",getSpecificRate.feeDollar)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"LiabilityDollar",0)> 
        </cfif>
        
        <!--- PWC / RA --->
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where
        <cfif attributes.boatTypeID eq CONST_MQ_BoatTypePWC_LID>
        marine_rateCategoryID = #CONST_ID_PWC_Motor_Age#
        <cfelse>
        marine_rateCategoryID = #CONST_ID_RA_Motor_Age#
        </cfif>
        and rateFor = '#attributes.motorAgeID#'
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"MotorAgePer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"MotorAgePer",0)> 
        </cfif>
        
        <!--- PWC / RA --->
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where
        <cfif attributes.boatTypeID eq CONST_MQ_BoatTypePWC_LID>
        marine_rateCategoryID = #CONST_ID_PWC_Boat_Speed#
        <cfelse>
        marine_rateCategoryID = #CONST_ID_RA_Boat_Speed#
        </cfif>
        and rateFor = '#attributes.boatSpeedID#'
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"BoatSpeedPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"BoatSpeedPer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_Boat_Storage#
        and rateFor = '#attributes.boatStorageID#'
        order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"BoatStrgPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"BoatStrgPer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_Street_Parking#
        and rateFor = '#attributes.isStreetParked#'
        order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"StreetPrkPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"StreetPrkPer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_Water_Skiers#
        order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "" and attributes.isWaterSkiers>
            <cfset x = StructInsert(calcRatingStruct,"WaterSkiPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"WaterSkiPer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_Customer_Age#
        and rateEnd >= #attributes.sailorAge#
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"CustAgePer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"CustAgePer",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where marine_rateCategoryID = #CONST_ID_Motor_Only_Rate# order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"MotorOnlyPer",getSpecificRate.loadingPercent)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"MotorOnlyPer",0)> 
        </cfif>

        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_TPO_Amount#
        and rateFor = '#attributes.boatLiabilityID#'
        order by rateEnd asc
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"TPODollar",getSpecificRate.feeDollar)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"TPODollar",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_MIN_PremiumBase#
        order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"MinBasePrem",getSpecificRate.feeDollar)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"MinBasePrem",0)> 
        </cfif>
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates 
        where marine_rateCategoryID = #CONST_ID_PersonalAccidentCover#
        order by marine_rate_item_id
        </cfquery>
        <cfif getSpecificRate.marine_rate_item_id neq "">
            <cfset x = StructInsert(calcRatingStruct,"PersonalAccCover",getSpecificRate.feeDollar)> 
        <cfelse>
            <cfset x = StructInsert(calcRatingStruct,"PersonalAccCover",0)> 
        </cfif>
		
		<!--- START ASF Ticket 46175 - PromoCode --->
		<cfif attributes.promoCode neq "">			
	        <cfquery name="getPromoRate" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
	        select pc.percentage as loadingPercent 
			from scheme_promo_code_marine pc(nolock) 
			where pc.vessel_type_id = 0 
	        and pc.promo_code = '#attributes.promoCode#'
			and site_id = '#session.thirdgenas.siteid#'
			and isnull(pc.start_datetime,'2099-12-31') <= #CreateODBCDateTime(lsDateFormat(now(),'dd/mmm/yyyy'))#
			and isnull(pc.end_datetime,'2001-12-31') >= #CreateODBCDateTime(lsDateFormat(now(),'dd/mmm/yyyy'))# 
	        </cfquery>
				
	        <cfif getPromoRate.loadingPercent neq "">
	            <cfset x = StructInsert(calcRatingStruct,"PromoCodeDiscountRate",getPromoRate.loadingPercent)> 
	        <cfelse>
	            <cfset x = StructInsert(calcRatingStruct,"PromoCodeDiscountRate",0)> 
	        </cfif>
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug PROMO 1" type="HTML">
	<cfdump var="#getPromoRate#">
</cfmail> --->			
									
		</cfif>
		<!--- END ASF Ticket 46175 - PromoCode --->
		
		
    </cfif>
    
    <cfif ArrayLen(errorFlag) gt 0>
        <cfset x = StructInsert(motorOnlyPremStruct,"calcResult",errorFlag[1],true)> 
        <cfset x = StructInsert(compPremStruct,"calcResult",errorFlag[1],true)> 
        <cfset x = StructInsert(tpoPremStruct,"calcResult",errorFlag[1],true)> 
    <cfelse>
        <cfset x = StructInsert(motorOnlyPremStruct,"calcResult","NA")>
        <cfset x = StructInsert(compPremStruct,"calcResult","NA")>
        <cfset x = StructInsert(tpoPremStruct,"calcResult","NA")>
        
        <cfif attributes.boatTypeID eq CONST_MQ_BoatTypeRAM_LID>
            <cfset motorOnlyPremStruct = calcRating(calcRatingStruct,"MOTOR")>
        <cfelse>
            <cfset motorOnlyPremStruct = calcRating(calcRatingStruct,"MOTOR")>
            <cfset compPremStruct = calcRating(calcRatingStruct,"COMP")>
            <cfset tpoPremStruct = calcRating(calcRatingStruct,"TPO")>
        </cfif>
    </cfif>
    
    <cfset outputVar = "caller.#attributes.output_comp#"> <cfset setVariable(outputVar,compPremStruct)>
    <cfset outputVar = "caller.#attributes.output_motoronly#"> <cfset setVariable(outputVar,motorOnlyPremStruct)>
    <cfset outputVar = "caller.#attributes.output_tpo#"> <cfset setVariable(outputVar,tpoPremStruct)>
</cfif>



<!--- 
AVAILABLE PARAM on calcParams:
=============================
layupRate
layupMthStr
boatValue
gstPer
fslPer
adminFee
InsuredValuePer
BoatAgePer
MotorTypePer
BoatConstrPer
BoatingCoursePer
BoatingExpPer
ExcessRtgPer
LiabilityDollar
MotorAgePer
BoatSpeedPer
BoatStrgPer
StreetPrkPer
WaterSkiPer
CustAgePer
MotorOnlyPer
TPODollar
MinBasePrem
PersonalAccCover
--->

<cffunction name="calcRating" returntype="struct">
    <cfargument name="calcParams" required="Yes" type="struct">
    <cfargument name="coverType" required="No" type="string" default="">
    
    <cfset premiumStruct = StructNew()>
    <cfset x = StructInsert(premiumStruct,"ratesId",ARGUMENTS.calcParams.ratesId)> 
    <cfset x = StructInsert(premiumStruct,"calcParams",ARGUMENTS.calcParams)> 
    
    <cfset calcResult = "OK">
    <cfif ARGUMENTS.coverType eq "COMP"> <!--- comprehensive --->
        <cfset baseValue = (ARGUMENTS.calcParams.boatValue * ARGUMENTS.calcParams.InsuredValuePer / 100)>

        <cfset basePremium = baseValue>
		
		<!--- START ASF Ticket 46175 - PromoCode --->
		<cfif attributes.promoCode neq "" and StructFind(ARGUMENTS.calcParams,"PromoCodeDiscountRate") gt 0>
                  <cfset promoCodeDisc = baseValue * (arguments.calcParams.promoCodeDiscountRate / 100)>    <!--- Apply discount promocode discount --->
                  <cfset baseValue = baseValue - promoCodeDisc>  
				  
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug PROMO 3" type="HTML">
	baseValue <cfdump var="#baseValue#"><br>
	promoCodeDisc <cfdump var="#promoCodeDisc#">
</cfmail> --->
				                  
        </cfif>
		
 	
		
		<!--- END ASF Ticket 46175 - PromoCode --->
		
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.BoatAgePer / 100 * baseValue)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.BoatConstrPer / 100 * baseValue)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.BoatingCoursePer / 100 * baseValue)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.BoatingExpPer / 100 * baseValue)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.MotorTypePer / 100 * baseValue)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.MotorAgePer / 100 * baseValue)> 
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.BoatSpeedPer / 100 * baseValue)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.BoatStrgPer / 100 * baseValue)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.StreetPrkPer /100 * baseValue)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.CustAgePer / 100* baseValue)>
        
        <cfif basePremium lt ARGUMENTS.calcParams.MinBasePrem>
            <cfset basePremium = ARGUMENTS.calcParams.MinBasePrem>
        </cfif>
        
        <cfset liabilityTotal = ARGUMENTS.calcParams.LiabilityDollar + ((ARGUMENTS.calcParams.WaterSkiPer / 100) * ARGUMENTS.calcParams.LiabilityDollar)>
        
        <cfset basePremium = basePremium + liabilityTotal + ARGUMENTS.calcParams.PersonalAccCover>
        
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.ExcessRtgPer / 100 * basePremium)>
        
        <cfset layupRate = 0>
        <cfloop from="1" to="12" index="m">
            <cfset monthFlag = ListGetAt(ARGUMENTS.calcParams.layupMthStr,m)>
            <cfif monthFlag eq "1">
                <cfset layupRate = layupRate + ARGUMENTS.calcParams.layupRate>
            </cfif>
        </cfloop>
        <cfset basePremium = basePremium + (layupRate / 100 * basePremium)>
        <cfset fslAmount = (ARGUMENTS.calcParams.fslPer / 100 * ARGUMENTS.calcParams.boatValue)>
        
    <cfelseif ARGUMENTS.coverType eq "TPO"> <!--- TPO --->
        <cfset baseValue = 0>
        <cfset basePremium = ARGUMENTS.calcParams.TPODollar + ((ARGUMENTS.calcParams.WaterSkiPer / 100) * ARGUMENTS.calcParams.LiabilityDollar)>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.ExcessRtgPer / 100 * basePremium)>
        <cfset sumLayupDiscount = 0>
        <cfset fslAmount = 0>
        
    <cfelseif ARGUMENTS.coverType eq "MOTOR"> <!--- Motor Only --->
        <cfset baseValue = (ARGUMENTS.calcParams.MotorOnlyPer / 100) * ARGUMENTS.calcParams.boatValue >
        <cfset basePremium = baseValue>
        <cfset basePremium = basePremium + (ARGUMENTS.calcParams.ExcessRtgPer / 100 * basePremium)>
        <cfset sumLayupDiscount = 0>
        <cfif basePremium lt ARGUMENTS.calcParams.MinBasePrem>
            <cfset basePremium = ARGUMENTS.calcParams.MinBasePrem>
        </cfif>
        <cfset fslAmount = (ARGUMENTS.calcParams.fslPer / 100 * ARGUMENTS.calcParams.boatValue)>
    
    </cfif>
    
    <cfset basePremium = NumberFormat(basePremium,".99")>
    
    <!---  <cfset gstAmount = (ARGUMENTS.calcParams.gstPer / 100 * basePremium) + (ARGUMENTS.calcParams.gstPer / 100 * ARGUMENTS.calcParams.adminFee) + (ARGUMENTS.calcParams.gstPer / 100 * fslAmount) >
    <cfset gstAmount = NumberFormat(gstAmount,".99")>
    <cfset totPremium = basePremium + ARGUMENTS.calcParams.adminFee + fslAmount>  --->
    
    <cfset gstAmount = (ARGUMENTS.calcParams.gstPer / 100 * basePremium) + ((ARGUMENTS.calcParams.gstPer/100) * fslAmount) >
    <cfset gstAmount = NumberFormat(gstAmount,".99")>
    
    <cfset totalPremium = basePremium + gstAmount + fslAmount>


    <cfset x = StructInsert(premiumStruct,"adminFeeExGst",ARGUMENTS.calcParams.adminFee)> <!--- adminFeeExGst --->
    <cfset x = StructInsert(premiumStruct,"baseValue",baseValue)>
    <cfset x = StructInsert(premiumStruct,"basePremium",basePremium)>
    <cfset x = StructInsert(premiumStruct,"gstAmount",gstAmount)>
    <cfset x = StructInsert(premiumStruct,"fslAmount",fslAmount)>
    <cfset x = StructInsert(premiumStruct,"totalPremium",totalPremium)>
    <cfset x = StructInsert(premiumStruct,"calcResult",calcResult,true)>
    <cfset x = StructInsert(premiumStruct,"gstPer",ARGUMENTS.calcParams.gstPer)>
    
    <cfreturn premiumStruct>
</cffunction>
