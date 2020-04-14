<!--- 
sample:
========
<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Motorcycle</clientType>
</header>
<request type="QUICKCALC">
    <id>
        <extRefId provider="YMF">Y9IA801279</extRefId>
        <extDealer id="D999">Bailey Motorcycles Ltd</extDealer>
        <extUser id="9865">craig.bailey</extUser>
    </id>    
    <motorcycle>
        <customDetails>
            <make/>
            <model/>
            <year>2013</year>
            <type>SPORTS</type>
        </customDetails> 
        <marketPrice>5000.00</marketPrice> <!--- Market Value:  --->
        <isRoadReg>true</isRoadReg> <!--- Will this unit be road registered? --->
        <dateRego/> <!--- Date of original registration: --->   <!--- optional --->
        <excess>$500</excess> <!--- Excess --->
        <layUpMths></layUpMths> <!--- Lay Up Months:  ---> <!--- optional --->
    </motorcycle>
    <client>
        <dob>1980-08-25Z</dob>
        <gender>M</gender>
        <consYrsLicense>2</consYrsLicense> <!--- Consecutive years Motorcycle licence held:  --->
        <storageMethod>GARAGE</storageMethod>
        <storagePostcode>2035</storagePostcode>
        <storageState>AUCKLAND</storageState>
        <storageStateArea>METRO</storageStateArea>
        <isOtherRider25>false</isOtherRider25> <!--- Is there any other rider under 25 years of age?  --->
        <ncbCategory>4</ncbCategory> <!--- No-Claim-Benefit category:  --->
        <loanTermMth>12<loanTermMth>
    </client>
</request>
</NMPackage>

<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Motorcycle</clientType>
</header>
<request type="QUICKCALC">
    <id>
        <extRefId provider="YMF">Y9IA801279</extRefId>
        <extDealer id="D999">Bailey Motorcycles Ltd</extDealer>
        <extUser id="9865">craig.bailey</extUser>
    </id>    
    <motorcycle>
        <glassDetails>
            <make>HONDA</make>
            <nvic>2XL02E</nvic>
            <code>HON-50CH-2002XL2002E</code>
        </glassDetails>
        <marketPrice>5000.00</marketPrice> <!--- Market Value:  --->
        <isRoadReg>true</isRoadReg> <!--- Will this unit be road registered? --->
        <dateRego/> <!--- Date of original registration: --->   <!--- optional --->
        <excess>$500</excess> <!--- Excess --->
        <layUpMths></layUpMths> <!--- Lay Up Months:  ---> <!--- optional --->
    </motorcycle>
    <client>
        <dob>1980-08-25Z</dob>
        <gender>M</gender>
        <consYrsLicense>2</consYrsLicense> <!--- Consecutive years Motorcycle licence held:  --->
        <storageMethod>GARAGE</storageMethod>
        <storagePostcode>2035</storagePostcode>
        <storageState>AUCKLAND</storageState>
        <storageStateArea>METRO</storageStateArea>
        <isOtherRider25>false</isOtherRider25> <!--- Is there any other rider under 25 years of age?  --->
        <ncbCategory>4</ncbCategory> <!--- No-Claim-Benefit category:  --->
        <loanTermMth>12<loanTermMth>
        <totalLoanVal>6700.00</totalLoanVal>
    </client>
</request>
</NMPackage>
 --->
 
<cfset xmlWSDataId = ATTRIBUTES.xmlWSLogId> 
<cfset outerErrorArray = ArrayNew(1)>
<cfset sectionDetails = StructNew()>
<cfset thirdgenDetailsStruct = StructNew()>

<cfif IsDefined("ATTRIBUTES.theXmlContent")>
    <cfset theCurrentXml = ATTRIBUTES.theXmlContent>
<cfelse>
    <cfset theCurrentXml = StructNew()> <!--- ERROR --->
    <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Missing XML")>
</cfif>

<cfif IsDefined("ATTRIBUTES.thirdgenDetails")>
    <cfset thirdgenDetailsStruct = ATTRIBUTES.thirdgenDetails>
<cfelse>
    <cfset thirdgenDetailsStruct = StructNew()> <!--- ERROR --->
    <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Missing 3rdgen Details")>
</cfif>

<!--- CHECK IDENTIFICATIONS SET --->
<cfif ArrayLen(outerErrorArray) eq 0>
    <cfset tmpXML = theCurrentXml.NMPackage.request>
    <cfif not isDefined("tmpXML.XmlAttributes.type") OR CompareNoCase(tmpXML.XmlAttributes.type,"QUICKCALC") neq 0>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Invalid Request Content" )> 
    </cfif>
</cfif>

<!--- PROCESS XML --->
<cfif ArrayLen(outerErrorArray) eq 0>
    <cfset innerErrorArray = ArrayNew(1)>
    <cfset tmpXML = theCurrentXml.NMPackage.request>
    <cfset xmlRequestId = updateWebServiceRequestLog( ws_request_id=xmlWSDataId
        ,external_id=thirdgenDetailsStruct.extDataID
        ,requester_id=thirdgenDetailsStruct.extDataProvider
        ,dealership_id=thirdgenDetailsStruct.extDealerID
        ,dealership_name=thirdgenDetailsStruct.extDealerName
        ,req_type=tmpXML.XmlAttributes.type
        ,requestXML=theCurrentXml
        )>
        
    <cfset BikeQuoteStruct = StructNew()>
       
    <cfset bikeModelOK = true>
    <cfset data_bikeFormDataId = 0>
    <cftry>
        <cfset tempXML = theCurrentXml.NMPackage.request.motorcycle>
        <cfif IsDefined("tempXML.glassDetails")>
            <cfset data_bikeModel = trim(tempXML.glassDetails.NVIC.XmlText)>
            <cfset data_bikeCustomMake = "">
            <cfset data_bikeCustomStyle = "">
            <cfset data_bikeCustomYear = "">
            <cfset data_bikeCustomDetail = "">
            <cfset list_bikeCustomStyle = "">
            <cfquery name="getBikeData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select fd.form_data_id, fd.xml_data
            from thirdgen_form_data fd with (nolock)
            inner join thirdgen_form_header_data fhd with (nolock) on fd.form_data_id = fhd.form_data_id 
                and fd.form_def_id = #CONST_bikeDataFormDefId# and fhd.text1 = '#data_bikeModel#'
            </cfquery>
            <cfif getBikeData.xml_data neq "">
                <cfset data_bikeFormDataId = getBikeData.form_data_id>
                <cfwddx action="WDDX2CFML" input="#getBikeData.xml_data#" output="bikeDataStruct">	
                <cfset data_bikeIsInsurable = StructFind(bikeDataStruct,CONST_BD_IsInsurable_FID)>
                <cfif data_bikeIsInsurable eq "0" or data_bikeIsInsurable eq "" >
                    <cfset bikeModelOK = false>
                </cfif>
            <cfelse>
                <cfset bikeModelOK = false>
            </cfif>
        <cfelse>
            <cfset data_bikeModel = -1>
            <cfset data_bikeCustomMake = trim(tempXML.customDetails.make.XmlText)>
            <cfset data_bikeCustomYear = trim(tempXML.customDetails.year.XmlText)>
            <cfset data_bikeCustomDetail = trim(tempXML.customDetails.model.XmlText)>
            <cfset list_bikeCustomStyle = trim(tempXML.customDetails.type.XmlText)>
            
            <cfif list_bikeCustomStyle neq "" and len(replace(list_bikeCustomStyle," ","")) gte 3
                and data_bikeCustomYear neq "" >
                <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                select list_item_id, list_item_display, list_item_image
                from thirdgen_list_item
                where list_id = #CONST_BQ_BikeStyle_ListID#
                and list_item_display like '#list_bikeCustomStyle#'
                </cfquery>
                <cfset data_bikeCustomStyle = getListItem.list_item_id>
                <cfset list_bikeCustomStyle = getListItem.list_item_display>
                <cfset bikeModelOK = true>
            <cfelse>
                <cfset data_bikeCustomStyle = 0>
                <cfset list_bikeCustomStyle = "">
                <cfset bikeModelOK = false>
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MOTORYCLE")>
            </cfif>
            <cfset data_bikeFormDataId = data_bikeModel>
        </cfif>

        <cfcatch type="Any">
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MOTORYCLE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>
    
    <cfif ArrayLen(outerErrorArray) eq 0>
        <cftry>
            <cfset tempXML = theCurrentXml.NMPackage.request.motorcycle>
            <cfset data_bikeValue = trim(tempXML.marketPrice.XmlText)>
            <cfif LSParseNumber(data_bikeValue) lt 1>
                <cfset data_bikeValue = "">
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid value on price field")>
            </cfif>
            
            <cfset data_excessId = trim(tempXML.excess.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_BQ_excess_ListID#
            and list_item_display like '#data_excessId#'
            </cfquery>
            <cfset data_excessId = getListItem.list_item_id>
            <cfset data_RTC = 0>
            <cfif StructKeyExists(tempXML,"isRTC") and trim(tempXML.isRTC.XmlText) neq "">
                <cfset data_RTC  = trim(tempXML.isRTC.XmlText)>
                <cfif data_RTC>
                    <cfset data_RTC = 1>
                <cfelse>
                    <cfset data_RTC = 0>
                </cfif>
            </cfif>
            <cfset data_isRoadReg  = trim(tempXML.isRoadReg.XmlText)>
            <cfif data_isRoadReg>
                <cfset data_isRoadReg = 1>
            <cfelse>
                <cfset data_isRoadReg = 0>
            </cfif>
            <cfset data_dateRego = "">
            <cfif StructKeyExists(tempXML,"dateRego") and trim(tempXML.dateRego.XmlText) neq "">
                <cfset data_dateRego = trim(tempXML.dateRego.XmlText)> 
                <cfset data_dateRego = XMLToCF_dateTime(data_dateRego)>
            </cfif>
    
            
            <cfset data_layUpMths = trim(tempXML.layUpMths.XmlText)> 
            <cfset data_layUpMths_numbers = "">
            <cfif data_layUpMths neq "">
                <cfset tmpStr = "">
                <cfloop list="#data_layUpMths#" index="anIndex">
                    <cfset tmpStr = ListAppend(tmpStr,"'"&getMthAsNum(anIndex)&"'")>
                </cfloop>
                <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                select list_item_id, list_item_display, list_item_image
                from thirdgen_list_item
                where list_id = #CONST_BQ_LayupMth_ListID#
                and list_item_image in (#PreserveSingleQuotes(tmpStr)#)
                </cfquery>
                <cfset data_layUpMths = ValueList(getListItem.list_item_id)>
                <cfset data_layUpMths_numbers = ValueList(getListItem.list_item_image)>
            </cfif>
            <cfset list_layUpMths = "">
            <cfloop from="1" to="12" step="1" index="aMonth">
                <cfif ListFind(data_layUpMths_numbers,aMonth) gt 0>
                    <cfset list_layUpMths = ListAppend(list_layUpMths,1)>
                <cfelse>
                    <cfset list_layUpMths = ListAppend(list_layUpMths,0)>
                </cfif>	
            </cfloop>
    
            <cfset tempXML = theCurrentXml.NMPackage.request.client>
            <cfset data_storagePostCode = trim(tempXML.storagePostcode.XmlText)>
            <cfset data_licenseConsYr = trim(tempXML.consYrsLicense.XmlText)>
            
            <cfset data_riderDOB = trim(tempXML.dob.XmlText)> 
            <cfset data_riderDOB = XMLToCF_dateTime(data_riderDOB)>
                
            <cfset data_gender = trim(tempXML.gender.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_BQ_gender_ListID#
            and list_item_image like '#data_gender#'
            </cfquery>
            <cfset data_gender = getListItem.list_item_id>
            
            <cfset data_loanTermMth = trim(tempXML.loanTermMth.XmlText)>
            <cfset data_loanTermMth_disp = trim(tempXML.loanTermMth.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_BQ_LoanTerm_ListID#
            and list_item_image like '#data_loanTermMth#'
            </cfquery>
            <cfset data_loanTermMth = getListItem.list_item_id>
            
            <cfset data_stateId = trim(tempXML.storageState.XmlText)> 
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_BQ_State_ListID#
            and list_item_display like '#data_stateId#'
            </cfquery>
            <cfset data_stateId = getListItem.list_item_id>
            
            <cfset data_stateRegionID = trim(tempXML.storageStateArea.XmlText)> 
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_BQ_StateArea_ListID#
            and list_item_display like '#data_stateRegionID#'
            </cfquery>
            <cfset data_stateRegionID = getListItem.list_item_id>
            
            <cfset data_storageMethodID = trim(tempXML.storageMethod.XmlText)> 
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_BQ_StorageMethod_ListID#
            and (list_item_display like '#data_storageMethodID#' or list_item_image like '#data_storageMethodID#')
            </cfquery>
            <cfset data_storageMethodID = getListItem.list_item_id>
            
            <cfset data_ncbratingID = trim(tempXML.ncbCategory.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_BQ_NCB_ListID#
            and list_item_image like '#data_ncbratingID#'
            </cfquery>
            <cfset data_ncbratingID = getListItem.list_item_id>
            
            <cfset data_under25Restr = trim(tempXML.isOtherRider25.XmlText)>
            <cfif data_under25Restr>
                <cfset data_under25Restr = 1>
            <cfelse>
                <cfset data_under25Restr = 0>
            </cfif>
            
            <cfif StructKeyExists(tempXML,"totalLoanVal") and trim(tempXML.totalLoanVal.XmlText) neq "" and  trim(tempXML.totalLoanVal.XmlText) neq "0">
                <cfset data_totalLoanVal = trim(tempXML.totalLoanVal.XmlText)>
            <cfelse>
                <cfset data_totalLoanVal = "">
            </cfif>
            
            <cfif data_totalLoanVal neq "" and data_loanTermMth eq ""> <!--- check if Loan Term Month is invalid when Loan Value exists --->
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid/missing value on loan fields")>
            </cfif>
            
            <cfcatch type="Any">
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MOTORYCLE/CLIENT", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>

    <cfif ArrayLen(outerErrorArray) eq 0>
        <!--- GET COVER OPTIONS (start) --->
        <cfset compStruct = StructNew()>
        <cfset offroadStruct = StructNew()>
        <cfset tpdStruct = StructNew()>
        <cfset tpoStruct = StructNew()>
        <cfset coverOpts = StructNew()> <!--- APPLICABLE COVER OPTIONS --->
        
        <cftry>
            <cfif bikeModelOK>
                <cfif data_bikeModel eq -1>
                    <cfmodule template="../admin/mod_ratingMotorcycle.cfm"
                        bikeValue="#data_bikeValue#"
                        bikeModel="#data_bikeModel#"
                        bikeYr_manual="#data_bikeCustomYear#"
                        bikeMake_manual="YAMAHA" <!--- only for quick calc --->
                        bikeStyle_manual="#list_bikeCustomStyle#"
                        ncbRating="#data_ncbratingID#"
                        riderDob="#data_riderDOB#"
                        licenseConsYr="#data_licenseConsYr#"
                        under25Restr="#data_under25Restr#"
                        state="#data_stateID#"
                        stateRegion="#data_stateRegionID#"
                        storageMethod="#data_storageMethodID#"
                        excessId = "#data_excessId#"
                        isRTC = "#data_RTC#"
                        layupMonths="#list_layUpMths#"
                        roadReg="#data_isRoadReg#"
                        output_comp="compStruct"
                        output_offroad="offroadStruct"
                        output_tpd="tpdStruct"
                        output_tpo="tpoStruct">
                <cfelse>
                    <cfmodule template="../admin/mod_ratingMotorcycle.cfm"
                        bikeValue="#data_bikeValue#"
                        bikeModel="#data_bikeModel#"
                        ncbRating="#data_ncbratingID#"
                        riderDob="#data_riderDOB#"
                        licenseConsYr="#data_licenseConsYr#"
                        under25Restr="#data_under25Restr#"
                        state="#data_stateID#"
                        stateRegion="#data_stateRegionID#"
                        storageMethod="#data_storageMethodID#"
                        excessId = "#data_excessId#"
                        isRTC = "#data_RTC#"
                        layupMonths="#list_layUpMths#"
                        roadReg="#data_isRoadReg#"
                        output_comp="compStruct"
                        output_offroad="offroadStruct"
                        output_tpd="tpdStruct"
                        output_tpo="tpoStruct">
                </cfif>
            </cfif>
    
            <cfmodule template="../admin/mod_ratingMotorcycle.cfm"
                otherProducts=true
                state="#data_stateID#"
                loanValue="#data_totalLoanVal#"
                output_others="otherProdsStruct">
                
            <cfset adminFee = otherProdsStruct.calcParams.adminCost >
            <cfset gstRate = otherProdsStruct.calcParams.gstRate / 100 >
            <!--- <cfset fslRate = otherProdsStruct.calcParams.fslRate / 100 > --->
            <cfset fslFee = otherProdsStruct.calcParams.fslFee / 100 >
            <cfset adminFeeTotal = adminFee + gstRate*adminFee>
            
            <cfset tmpStruct = StructNew()>
            <cfset x = StructInsert(tmpStruct,"base",adminFee)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*adminFee,".99"))>
            <cfset x = StructInsert(tmpStruct,"total",tmpStruct.base + tmpStruct.GST)>
            <cfset x = StructInsert(coverOpts,"FEE_ADMIN",tmpStruct)>
            
            <cfcatch type="Any">
                <!--- can't get quote --->
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot get quote", cfcatch.message)>
            </cfcatch>
        </cftry>
    
        <cfif data_isRoadReg eq 1>
            <cfif StructCount(compStruct) gt 0 and compStruct.calcResult eq "OK">
                <cfset tmpStruct = StructNew()>
                <cfset x = StructInsert(tmpStruct,"coverName","Comprehensive Cover")>
                <cfset x = StructInsert(tmpStruct,"base",compStruct.subTotPremium)>
                <cfset x = StructInsert(tmpStruct,"GST",compStruct.GST)>
                <cfset x = StructInsert(tmpStruct,"FSL",compStruct.FSL)>
                <cfset x = StructInsert(tmpStruct,"totalPremium",compStruct.totalPremium)>
                <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteComp_ListItemID)>
                <cfset x = StructInsert(coverOpts,"COMP",tmpStruct)>
            </cfif>
            
            <cfif StructCount(tpoStruct) gt 0 and tpoStruct.calcResult eq "OK">
                <cfset tmpStruct = StructNew()>
                <cfset x = StructInsert(tmpStruct,"coverName","Third Party Only cover")>
                <cfset x = StructInsert(tmpStruct,"base",tpoStruct.subTotPremium)>
                <cfset x = StructInsert(tmpStruct,"GST",tpoStruct.GST)>
                <cfset x = StructInsert(tmpStruct,"FSL",tpoStruct.FSL)>
                <cfset x = StructInsert(tmpStruct,"totalPremium",tpoStruct.totalPremium)>
                <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteTPO_ListItemID)>
                <cfset x = StructInsert(coverOpts,"TPO",tmpStruct)>
            </cfif>
            
            <!--- CURRENTLY NOT INCLUDING THIS - SINCE IT MAY CONFUSE YWAIT  --->
            <!--- <cfif StructCount(tpdStruct) gt 0 and tpdStruct.calcResult eq "OK">
                <cfset tmpStruct = StructNew()>
                <cfset x = StructInsert(tmpStruct,"coverName","Third Party, Fire, Theft and Transit Cover")>
                <cfset x = StructInsert(tmpStruct,"base",tpdStruct.subTotPremium)>
                <cfset x = StructInsert(tmpStruct,"GST",tpdStruct.GST)>
                <cfset x = StructInsert(tmpStruct,"FSL",tpdStruct.FSL)>
                <cfset x = StructInsert(tmpStruct,"totalPremium",tpdStruct.totalPremium)>
                <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteTPD_ListItemID)>
                <cfset x = StructInsert(coverOpts,"TPD",tmpStruct)>
            </cfif> --->
            
            
            <!--- yWait are not using this. Returns the Max amount for now --->
            <cfset tmpStruct = StructNew()>
            <cfset tmpPrem = otherProdsStruct.calcParams.TyreRimCover.BaseCostMax>
            <cfset x = StructInsert(tmpStruct,"coverName","Tyre & Rim Cover")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteTyreRim_ListItemID)>
            <cfset x = StructInsert(coverOpts,"TR",tmpStruct)>
            
    
        <cfelse>
            <cfif StructCount(offroadStruct) gt 0 and offroadStruct.calcResult eq "OK">
                <cfset tmpStruct = StructNew()>
                <cfset x = StructInsert(tmpStruct,"coverName","Off Road Cover")>
                <cfset x = StructInsert(tmpStruct,"base",offroadStruct.subTotPremium)>
                <cfset x = StructInsert(tmpStruct,"GST",offroadStruct.GST)>
                <cfset x = StructInsert(tmpStruct,"FSL",offroadStruct.FSL)>
                <cfset x = StructInsert(tmpStruct,"totalPremium",offroadStruct.totalPremium)>
                <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteOffRoad_ListItemID)>
                <cfset x = StructInsert(coverOpts,"OFFROAD",tmpStruct)>
            </cfif>
            
            <cfif StructCount(tpoStruct) gt 0 and tpoStruct.calcResult eq "OK">
                <cfset tmpStruct = StructNew()>
                <cfset x = StructInsert(tmpStruct,"coverName","Third Party Only cover")>
                <cfset x = StructInsert(tmpStruct,"base",tpoStruct.subTotPremium)>
                <cfset x = StructInsert(tmpStruct,"GST",tpoStruct.GST)>
                <cfset x = StructInsert(tmpStruct,"FSL",tpoStruct.FSL)>
                <cfset x = StructInsert(tmpStruct,"totalPremium",tpoStruct.totalPremium)>
                <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteTPO_ListItemID)>
                <cfset x = StructInsert(coverOpts,"TPO",tmpStruct)>
            </cfif>
            
            <cfif StructCount(tpdStruct) gt 0 and tpdStruct.calcResult eq "OK">
                <cfset tmpStruct = StructNew()>
                <cfset x = StructInsert(tmpStruct,"coverName","Third Party, Fire, Theft and Transit Cover")>
                <cfset x = StructInsert(tmpStruct,"base",tpdStruct.subTotPremium)>
                <cfset x = StructInsert(tmpStruct,"GST",tpdStruct.GST)>
                <cfset x = StructInsert(tmpStruct,"FSL",tpdStruct.FSL)>
                <cfset x = StructInsert(tmpStruct,"totalPremium",tpdStruct.totalPremium)>
                <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteTPD_ListItemID)>
                <cfset x = StructInsert(coverOpts,"TPD",tmpStruct)>
            </cfif>
            
        </cfif>
            
        <!--- MUST always have TPO options - UNLESS parameters gone missing OR cannot be found --->
        <cfif StructCount(tpoStruct) gt 0>
            <cfif tpoStruct.calcResult neq "OK">
                <cfset errorStmt = "">
                <cfif CompareNoCase(tpoStruct.calcResult,"NO_RATE_COMP") eq 0
                    or  CompareNoCase(tpoStruct.calcResult,"NO_RATE_OFFROAD") eq 0
                    or  CompareNoCase(tpoStruct.calcResult,"NO_RATE_TPD") eq 0 >
                    <cfset errorStmt = "Market price is outside the limit for automatic-quote">
                <cfelseif CompareNoCase(tpoStruct.calcResult,"NO_EXCESS") eq 0 >
                    <cfset errorStmt = "Excess option cannot be applied">
                <cfelse>
                    <cfset errorStmt = "Error Code (" & tpoStruct.calcResult &")">
                </cfif>
                
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Unable to generate quote : " & errorStmt)>
                
            </cfif>
        <cfelse>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Bike model is not insurable")>
        </cfif>
            
        
        <cfif data_totalLoanVal neq "">
            <cfset LP_LifeTermStruct = otherProdsStruct.calcParams.LP_LifeTermCover>
            <cfset LP_DisableTermStruct = otherProdsStruct.calcParams.LP_DisableTermCover>
            <cfset LP_UnempTermStruct = otherProdsStruct.calcParams.LP_UnempTermCover>
            <cfset LP_CashAssistTermStruct = otherProdsStruct.calcParams.LP_CashAssistTermCover>
            
            <!--- <cfset LP_Life_price = StructFind(LP_LifeTermStruct,"BaseCost")>
            <cfset LP_Life_price = LP_Life_price + StructFind(LP_LifeTermStruct,data_loanTermMth)>
            <cfset LP_Disable_price = StructFind(LP_DisableTermStruct,"BaseCost")>
            <cfset LP_Disable_price = LP_Disable_price + StructFind(LP_DisableTermStruct,data_loanTermMth)>
            <cfset LP_Unemp_price = StructFind(LP_UnempTermStruct,"BaseCost")>
            <cfset LP_Unemp_price = LP_Unemp_price + StructFind(LP_UnempTermStruct,data_loanTermMth)>
            <cfset LP_CashAssist_price = StructFind(LP_CashAssistTermStruct,"BaseCost")>
            <cfset LP_CashAssist_price = LP_CashAssist_price + StructFind(LP_CashAssistTermStruct,data_loanTermMth)> --->
            
            <cfset LP_Life_price = StructFind(LP_LifeTermStruct,data_loanTermMth)>
            <cfset LP_Disable_price = StructFind(LP_DisableTermStruct,data_loanTermMth)>
            <cfset LP_Unemp_price = StructFind(LP_UnempTermStruct,data_loanTermMth)>
            <cfset LP_CashAssist_price = StructFind(LP_CashAssistTermStruct,data_loanTermMth)>
            
            <cfset tmpStruct = StructNew()>               
            <cfset tmpPrem = LP_Life_price>
            <cfset x = StructInsert(tmpStruct,"coverName","Loan Protection - Life")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth",data_loanTermMth_disp)>
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteLoanProtect_ListItemID)>
            <cfset x = StructInsert(tmpStruct,"parent_id","LP")>
            <cfset x = StructInsert(coverOpts,"LP-LIFE",tmpStruct)>
            
            <cfset tmpStruct = StructNew()>               
            <cfset tmpPrem = LP_Disable_price>
            <cfset x = StructInsert(tmpStruct,"coverName","Loan Protection - Disablement")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth",data_loanTermMth_disp)>
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteLoanProtect_ListItemID)>
            <cfset x = StructInsert(tmpStruct,"parent_id","LP")>
            <cfset x = StructInsert(coverOpts,"LP-DISABLE",tmpStruct)>
            
            <cfset tmpStruct = StructNew()>               
            <cfset tmpPrem = LP_Unemp_price>
            <cfset x = StructInsert(tmpStruct,"coverName","Loan Protection - Unemployment")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth",data_loanTermMth_disp)>
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteLoanProtect_ListItemID)>
            <cfset x = StructInsert(tmpStruct,"parent_id","LP")>
            <cfset x = StructInsert(coverOpts,"LP-UNEMPLOY",tmpStruct)>
            
            <cfset tmpStruct = StructNew()>               
            <cfset tmpPrem = LP_CashAssist_price>
            <cfset x = StructInsert(tmpStruct,"coverName","Loan Protection - Cash Assist")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth",data_loanTermMth_disp)>
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteLoanProtect_ListItemID)>
            <cfset x = StructInsert(tmpStruct,"parent_id","LP")>
            <cfset x = StructInsert(coverOpts,"LP-CASH",tmpStruct)>

        </cfif>
    
        <cfset tmpStruct2 = otherProdsStruct.calcParams.GapExtraCover>
        <cfset optionKeys = StructSort( tmpStruct2, "numeric", "ASC" )>
        <cfset i = 1>
        <cfloop array="#optionKeys#" index="anItem">
            <cfset tmpPrem = StructFind(tmpStruct2,anItem)>
            <cfif val(tmpPrem) gt 0>
                <cfset tmpStruct = StructNew()>
                <cfset x = StructInsert(tmpStruct,"coverName","Gap Cover - Sum Insured  $" & anItem)>
                <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
                <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
                <cfset x = StructInsert(tmpStruct,"FSL",0)>
                <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
                <cfset x = StructInsert(tmpStruct,"termMth",data_loanTermMth_disp)>
                <cfset x = StructInsert(tmpStruct,"param","$"&anItem)>
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_BQ_QuoteGapCover_ListItemID)>
                <cfset x = StructInsert(tmpStruct,"parent_id","GAP")>
                <cfset x = StructInsert(coverOpts,"GAP-OPT"&i,tmpStruct)>
                <cfset i = i+1>
            </cfif>
        </cfloop>
        
        <!--- GET COVER OPTIONS (end) --->
    </cfif>   
        
    <cfif ArrayLen(outerErrorArray) eq 0>
        <cftry>
            <cfset BikeQuoteStruct = StructNew()>
            <!--- quote form fields (start) --->
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_BikeModel_FID,"|"), data_bikeFormDataId,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_customBikeMake,"|"), data_bikeCustomMake,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_customBikeStyle,"|"), data_bikeCustomStyle,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_customBikeYear,"|"), data_bikeCustomYear,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_customBikeDetail1,"|"), data_bikeCustomDetail,true)>
            
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_InsuredValue_FID,"|"), data_bikeValue,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_RoadReg_FID,"|"), data_isRoadReg,true)>
            <cfif data_dateRego neq "">
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_OriginalRegoDate_FID,"|"), DateFormat(data_dateRego,"DD/MM/YYYY"),true)>
            </cfif>
            <!--- <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_RiderTotalCare_FID,"|"), data_RTC,true)> --->
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_Excess_FID,"|"), data_excessId,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_layUpMths_FID,"|"), data_layUpMths,true)>
            
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_InsurerDOB_FID,"|"), DateFormat(data_riderDOB,"DD/MM/YYYY"),true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_InsurerSex_FID,"|"), data_gender,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_RidingExp_FID,"|"), data_licenseConsYr,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_StorageMethod_FID,"|"), data_storageMethodID,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_StoragePostcode_FID,"|"), data_storagePostCode,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_State_FID,"|"), data_stateId,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_StateArea_FID,"|"), data_stateRegionID,true)>
            <!--- <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_OtherRiderUnder25_FID,"|"), data_under25Restr,true)> --->
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_NCB_FID,"|"), data_ncbratingID,true)>
            <cfif StructKeyExists(thirdgenDetailsStruct,"extDataProvider")>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_ExtProvider_FID,"|"), thirdgenDetailsStruct.extDataProvider,true)>
            </cfif>
            <cfif StructKeyExists(thirdgenDetailsStruct,"extDataID")>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_ExtId_FID,"|"), thirdgenDetailsStruct.extDataID,true)>
            </cfif>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_loanProtectTerm_FID,"|"), data_loanTermMth,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_gapCoverTerm_FID,"|"), data_loanTermMth,true)>
            <cfif StructKeyExists(coverOpts,"COMP")>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteComp_FID,"|"), NumberFormat(coverOpts.COMP.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"OFFROAD")>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteOffRoad_FID,"|"), NumberFormat(coverOpts.OFFROAD.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"TPD")>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteTPD_FID,"|"), NumberFormat(coverOpts.TPD.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"TPO")>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteTPO_FID,"|"), NumberFormat(coverOpts.TPO.totalPremium,".99"),true)>
            </cfif>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteGapCover_FID,"|"), NumberFormat(0,".99"),true)>
            <cfif StructKeyExists(coverOpts,"TR")>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteTyreRim_FID,"|"), NumberFormat(coverOpts.TR.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"LP")>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteLoanProtect_FID,"|"), NumberFormat(coverOpts.LP.totalPremium,".99"),true)>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_loanProtectDetails_FID,"|"), coverOpts.LP.details,true)>
            </cfif>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteAdminFee_FID,"|"), NumberFormat(adminFeeTotal,".99"),true)>
            <!--- <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteFSLFee_FID,"|"), NumberFormat(fslRate*data_bikeValue,".99"),true)> --->
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteFSLFee_FID,"|"), NumberFormat(fslFee,".99"),true)>
            
            <!--- <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_QuoteStatus_FID,"|"), CONST_BQ_QuoteStatus_stage1_LID,true)> --->
        
            <!--- quote form fields (end) --->
    
            <cfset theFormDataId = 0>
            <cfcatch type="Any">
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot insert/update QUOTE", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfif ArrayLen(outerErrorArray) eq 0>
        <!--- PRINT XML --->

        <cfsavecontent variable="theContent"><cfoutput>
        <motorcycle>    
            <cfif data_bikeModel eq -1>
            <customDetails>
                <make>#data_bikeCustomMake#</make>
                <model>#data_bikeCustomDetail#</model>
                <year>#data_bikeCustomYear#</year>
                <type>#list_bikeCustomStyle#</type>
            </customDetails>
            <cfelse>
            <glassDetails>
                <nvic>#data_bikeModel#</nvic>
                <cfif IsDefined("bikeDataStruct")>
                <make>#StructFind(bikeDataStruct,ListFirst(CONST_BD_Make_FID,"|"))#</make>
                <code>#StructFind(bikeDataStruct,ListFirst(CONST_BD_Code_FID,"|"))#</code>
                <year>#StructFind(bikeDataStruct,ListFirst(CONST_BD_Year_FID,"|"))#</year>
                <type>#StructFind(bikeDataStruct,ListFirst(CONST_BD_Style_FID,"|"))#</type>
                <family>#StructFind(bikeDataStruct,ListFirst(CONST_BD_Family_FID,"|"))#</family>
                <variant>#StructFind(bikeDataStruct,ListFirst(CONST_BD_Variant_FID,"|"))#</variant>
                </cfif>
            </glassDetails>
            </cfif>
            <otherDetails></otherDetails>
        </motorcycle>
        <client></client>
        <options>
            <cfset aCover = StructFind(coverOpts,"FEE_ADMIN")>
            <adminFee>
                <total>#NumberFormat(aCover.total,",.99")#</total>
                <base>#NumberFormat(aCover.base,",.99")#</base>
                <gst>#NumberFormat(aCover.GST,",.99")#</gst>
            </adminFee>
            <cfset tmpSubProds = "">
            <cfset subProdStruct = StructNew()>
            <cfset optionKeys = StructKeyArray(coverOpts)>
            <cfset x = ArraySort( optionKeys, "textnocase", "ASC" )>
            <!--- <cfset optionKeys = StructSort( coverOpts, "textnocase", "ASC" )> --->
            <cfloop array="#optionKeys#" index="anItem">
                <cfset aCover = StructFind(coverOpts,anItem)>
                <cfif StructKeyExists(aCover,"totalPremium") and StructKeyExists(aCover,"int_code")>
                    <cfif not StructKeyExists(aCover,"parent_id") or StructFind(aCover,"parent_id") eq "">
                        <product id="#anItem#">
                            <name>#XmlFormat(aCover.coverName)#</name>
                            <price>
                                <total>#NumberFormat(aCover.totalPremium,",.99")#</total>
                                <base>#NumberFormat(aCover.base,",.99")#</base>
                                <gst>#NumberFormat(aCover.GST,",.99")#</gst>
                                <fsl>#NumberFormat(aCover.FSL,",.99")#</fsl>
                            </price>
                            <termMth>#aCover.termMth#</termMth>
                            <cfif IsDefined("aCover.param")>
                            <param>#XmlFormat(aCover.param)#</param>
                            </cfif>
                        </product>
                    <cfelse>
                        <cfif StructKeyExists(subProdStruct,StructFind(aCover,"parent_id"))>
                            <cfset tmpSubProds = StructFind(subProdStruct,StructFind(aCover,"parent_id"))>
                        <cfelse>
                            <cfset tmpSubProds = "">
                        </cfif>
                        <cfsavecontent variable="tmpStr">
                        <subProduct id="#anItem#">
                            <name>#XmlFormat(aCover.coverName)#</name>
                            <price>
                                <total>#NumberFormat(aCover.totalPremium,",.99")#</total>
                                <base>#NumberFormat(aCover.base,",.99")#</base>
                                <gst>#NumberFormat(aCover.GST,",.99")#</gst>
                                <fsl>#NumberFormat(aCover.FSL,",.99")#</fsl>
                            </price>
                            <termMth>#aCover.termMth#</termMth>
                            <cfif IsDefined("aCover.param")>
                            <param>#XmlFormat(aCover.param)#</param>
                            </cfif>
                        </subProduct>
                        </cfsavecontent>
                        <cfset tmpSubProds = tmpSubProds & trim(replace(tmpStr, "  "," ","ALL"))>
                        <cfset x = StructInsert(subProdStruct,StructFind(aCover,"parent_id"),tmpSubProds,true)>
                    </cfif>
                </cfif>
            </cfloop>
            
            <cfloop collection="#subProdStruct#" item="aSubProdParent">
            <product id="#aSubProdParent#">
            #StructFind(subProdStruct,aSubProdParent)#
            </product>
            </cfloop>
        </options>
        </cfoutput></cfsavecontent>
    
        <cfset xmlResponse = createXMLPackage(xmlContent="#theContent#",responseType="QUICKCALC",idStruct=thirdgenDetailsStruct)>
        
       
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=0
            ,responseXML=XmlParse(xmlResponse)
            ,note="Quick Calculation"
            )>

        <cfoutput>#xmlResponse#</cfoutput>
    </cfif>
    
    
</cfif>

<cfif ArrayLen(outerErrorArray) gt 0>
    <cfset xmlResponse = createXMLPackage(errorMsg=outerErrorArray[1],responseType="QUICKCALC",idStruct=thirdgenDetailsStruct)>
    <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
        ,responseXML=XmlParse(xmlResponse)
        ,note="Error - Quick Calculation"
        )>
    <cfoutput>#xmlResponse#</cfoutput>
</cfif>


