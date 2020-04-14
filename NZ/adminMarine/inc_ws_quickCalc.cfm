<!--- 
sample:
========
<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Marine</clientType>
</header>
<request type="QUICKCALC">
    <id>
        <extRefId provider="YMSI">Y9IA801279</extRefId>
        <extDealer id="YMINZ001">Auckland Test Marine</extDealer>
        <extUser id="987564">John.Citizen</extUser>
    </id>    
    <marine>
        <boatDetails>
            <type>RUN</type> 
            <year>2013</year>
            <construction>ALMUNIUM</construction>
            <inProd>true</inProd>
            <length>5</length>
        </boatDetails> 
        <motorDetails>
            <year>2014</year>
            <type>JET</type>
            <fuelType>PETROL</fuelType> 
            <hp>100</hp> 
            <speedMax>21</speedMax> <!--- in km/h --->
        </motorDetails>
        <marketPrice>5000.00</marketPrice> <!--- Insured Value:  --->
        <liability>5000000.00</liability> <!--- Liability Limit:  --->
        <excess>500</excess> <!--- Excess --->
        <isSkiers>true</isSkiers>
        <layUpMths></layUpMths> <!--- Lay Up Months:  ---> <!--- optional --->
    </marine>
    <client>
        <dob>1980-08-25Z</dob>
        <gender>M</gender>
        <storageMethod>TRAILER_PRIVATE</storageMethod>
        <storagePostcode>2035</storagePostcode>
        <storageState>AUCKLAND</storageState>
        <storageStateArea>METRO</storageStateArea>
        <streetPark>true</streetPark>
        <boatingExp>2</boatingExp> <!--- Boating experience --->
        <boatingCourse>true</boatingCourse> <!---  Boating Courses:  --->
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
        
        
    <cfset BoatQuoteStruct = StructNew()>
    <cftry>
        <cfset tempXML = theCurrentXml.NMPackage.request.marine>
        <cfif not IsDefined("tempXML.boatDetails")
            or not IsDefined("tempXML.motorDetails")>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE")>
        <cfelse>
            <cfset list_boatType = trim(tempXML.boatDetails.type.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_BoatType_ListID#
            and list_item_image like '#list_boatType#'
            </cfquery>  
            <cfset data_boatType = getListItem.list_item_id>
            
            <cfset data_boatMake = "">
            <cfif StructKeyExists(tempXML.boatDetails,"make") and trim(tempXML.boatDetails.make.XmlText) neq "">
                <cfset data_boatMake = trim(tempXML.boatDetails.make.XmlText)>
            </cfif>
                        
            <cfset data_boatModel = "">
            <cfif StructKeyExists(tempXML.boatDetails,"model") and trim(tempXML.boatDetails.model.XmlText) neq "">
                <cfset data_boatModel = trim(tempXML.boatDetails.model.XmlText)>
            </cfif>
            
            <cfset data_boatYear = trim(tempXML.boatDetails.year.XmlText)>
            <cfset data_boatAge = year(now())-data_boatYear >
            <!--- <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_boatAge_ListID#
            and convert(int,list_item_image) >= #year(now())-data_boatYear# 
            order by convert(int,list_item_image)
            </cfquery>  
            <cfset data_boatAge = getListItem.list_item_id> --->
            <cfset data_boatIsProd = trim(tempXML.boatDetails.inProd.XmlText)>
            <cfset data_boatLength = "">
            <cfif StructKeyExists(tempXML.boatDetails,"length") and trim(tempXML.boatDetails.length.XmlText) neq "">
                <cfset data_boatLength = trim(tempXML.boatDetails.length.XmlText)>
            </cfif>
            <cfset list_boatConst = trim(tempXML.boatDetails.construction.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_Construct_ListID#
            and list_item_display like '#list_boatConst#'
            </cfquery>
            <cfset data_boatConst = getListItem.list_item_id>
            
            <cfset data_motorMake = "">
            <cfif StructKeyExists(tempXML.motorDetails,"make") and trim(tempXML.motorDetails.make.XmlText) neq "">
                <cfset data_motorMake = trim(tempXML.motorDetails.make.XmlText)>
            </cfif>
            <cfset data_motorYear = trim(tempXML.motorDetails.year.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_motorAge_ListID#
            and convert(int,list_item_image) >= #year(now())-data_motorYear# 
            order by convert(int,list_item_image)
            </cfquery>  
            <cfset data_motorAge = getListItem.list_item_id>
            
            <cfif StructKeyExists(tempXML.motorDetails,"type") >
                <cfset list_motorType = trim(tempXML.motorDetails.type.XmlText)>   
                <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                select list_item_id, list_item_display, list_item_image
                from thirdgen_list_item
                where list_id = #CONST_MQ_MotorType_ListID#
                and list_item_image like '#list_motorType#'
                </cfquery> 
                <cfset data_motorType = getListItem.list_item_id>
            <cfelse>
                <cfset list_motorType = "">
                <cfset data_motorType = "">
            </cfif>
            
            <cfset list_motorFuel  = trim(tempXML.motorDetails.fuelType.XmlText)>  
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_FuelType_ListID#
            and list_item_display like '#list_motorFuel#'
            </cfquery>  
            <cfset data_motorFuel = getListItem.list_item_id>
            <cfset data_motorHP = trim(tempXML.motorDetails.hp.XmlText)>   
            <cfset list_motorSpeed  = trim(tempXML.motorDetails.speedMax.XmlText)>
            <cfif not IsNumeric(list_motorSpeed)>
                <cfset list_motorSpeed = 0>
            </cfif>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_BoatSpeed_ListID#
            and convert(int,list_item_image) >= #list_motorSpeed#
            </cfquery>  
            <cfset data_motorSpeed = getListItem.list_item_id>
                        
            <cfif data_boatAge eq "" or data_boatConst eq "" or data_boatLength eq "" 
                or data_motorAge eq "" or data_motorFuel eq "" or data_motorSpeed eq ""
                or data_motorHP eq "" >
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE")>
            </cfif>
            
            <cfif data_boatType eq CONST_MQ_BoatTypePWC_LID>
                <cfif data_boatMake eq "">
                    <cfset allowQuoteEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE (PWC)")>
                </cfif>
                <cfif (data_boatYear neq data_motorYear)
                    or (data_motorMake neq "" and data_boatMake neq data_motorMake)>
                    <cfset allowQuoteEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid mandatory elements on MARINE (PWC)")>
                </cfif>
                
            <cfelse> <!--- RUNABOUT --->
                <cfif data_motorType eq "">
                    <cfset allowQuoteEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE (RUN)")>
                </cfif>
            </cfif>
        </cfif>
        
        <cfcatch type="Any">
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MARINE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>

    
    <cfif ArrayLen(outerErrorArray) eq 0>
        <cftry>
            <cfset tempXML = theCurrentXml.NMPackage.request.marine>
            <cfset data_marineValue = trim(tempXML.marketPrice.XmlText)>
            <cfif LSParseNumber(data_marineValue) lt 1>
                <cfset data_marineValue = "">
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid value on price field")>
            </cfif>
            
            <cfset data_liability = trim(tempXML.liability.XmlText)>
            <cfset data_liability = reReplaceNoCase(data_liability,"[$,]","")>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_LiabilityLimit_ListID#
            and convert(int,replace(list_item_display,',','')) = #data_liability#
            </cfquery>
            <cfset data_liability = getListItem.list_item_id>
            <cfset data_excessId = trim(tempXML.excess.XmlText)>
            <!--- <cfset data_excessId = reReplaceNoCase(data_excessId,"[$,]","")> --->
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_Excess_ListID#
            and convert(int,list_item_display) = #data_excessId#
            </cfquery>
            <cfset data_excessId = getListItem.list_item_id>
            <cfset data_isSkiers  = trim(tempXML.isSkiers.XmlText)>
            <cfif data_isSkiers>
                <cfset data_isSkiers = 1>
            <cfelse>
                <cfset data_isSkiers = 0>
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
                where list_id = #CONST_MQ_LayupMth_ListID#
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
            <cfset list_boatingExpYr = trim(tempXML.boatingExp.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_boatExp_ListID#
            and convert(int,list_item_image) >= #list_boatingExpYr# 
            order by convert(int,list_item_image)
            </cfquery> 
            <cfset data_boatingExpYr = getListItem.list_item_id>
            
            <cfset data_sailorDOB = trim(tempXML.dob.XmlText)> 
            <cfset data_sailorDOB = XMLToCF_dateTime(data_sailorDOB)>
            <!---  <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_motorAge_ListID#
            and convert(int,list_item_image) >= #DateDiff("yyyy",data_sailorDOB,now())# 
            order by convert(int,list_item_image)
            </cfquery>  
            <cfset data_sailorAge = getListItem.list_item_id> --->
            <cfset data_sailorAge = DateDiff("yyyy",data_sailorDOB,now())>
            
            <cfset data_gender = trim(tempXML.gender.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_gender_ListID#
            and list_item_image like '#data_gender#'
            </cfquery>
            <cfset data_gender = getListItem.list_item_id>
            
           
            <cfset data_stateId = trim(tempXML.storageState.XmlText)> 
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_State_ListID#
            and list_item_display like '#data_stateId#'
            </cfquery>
            <cfset data_stateId = getListItem.list_item_id>
            
            <cfset data_stateAreaID = trim(tempXML.storageStateArea.XmlText)> 
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_StateArea_ListID#
            and list_item_display like '#data_stateAreaID#'
            </cfquery>
            <cfset data_stateAreaID = getListItem.list_item_id>
            
            <cfset list_storageMethodID = trim(tempXML.storageMethod.XmlText)> 
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_MQ_StorageMethod_ListID#
            and list_item_image like '#list_storageMethodID#'
            </cfquery>
            <cfset data_storageMethodID = getListItem.list_item_id>
            <cfset data_streetPark  = trim(tempXML.streetPark.XmlText)>
            <cfif data_streetPark>
                <cfset data_streetPark = 1>
            <cfelse>
                <cfset data_streetPark = 0>
            </cfif>
            <cfset data_boatingCourse = trim(tempXML.boatingCourse.XmlText)>
            <cfif data_boatingCourse>
                <cfset data_boatingCourse = 1>
            <cfelse>
                <cfset data_boatingCourse = 0>
            </cfif>
            
            <cfif StructKeyExists(tempXML,"loanTermMth") and trim(tempXML.loanTermMth.XmlText) neq "" and trim(tempXML.loanTermMth.XmlText) neq "0">
                <cfset list_loanTermMth = trim(tempXML.loanTermMth.XmlText)>
                <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                select list_item_id, list_item_display, list_item_image
                from thirdgen_list_item
                where list_id = #CONST_MQ_LoanTerm_ListID#
                and list_item_image like '#list_loanTermMth#'
                </cfquery>
                <cfset data_loanTermMth = getListItem.list_item_id>
            <cfelse>
                <cfset list_loanTermMth = "">
                <cfset data_loanTermMth = "">
            </cfif>
            
            <cfif StructKeyExists(tempXML,"totalLoanVal") and trim(tempXML.totalLoanVal.XmlText) neq "" and trim(tempXML.totalLoanVal.XmlText) neq "0">
                <cfset data_totalLoanVal = trim(tempXML.totalLoanVal.XmlText)>
                <cfif data_totalLoanVal lte 0>
                    <cfset data_totalLoanVal = "">
                </cfif>
            <cfelse>
                <cfset data_totalLoanVal = "">
            </cfif>
            
            <cfif data_storageMethodID eq "">
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on CLIENT")>
            </cfif>
            
            <cfif data_totalLoanVal neq "" and data_loanTermMth eq ""> <!--- check if Loan Term Month is invalid when Loan Value exists --->
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid/missing value on loan fields")>
            </cfif>
            
            <cfcatch type="Any">
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MARINE/CLIENT", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>

    <cfif ArrayLen(outerErrorArray) eq 0>
        <!--- GET COVER OPTIONS (start) --->
        <cfset compStruct = StructNew()>
        <cfset motoronlyStruct = StructNew()>
        <cfset tpoStruct = StructNew()>
        <cfset coverOpts = StructNew()> <!--- APPLICABLE COVER OPTIONS --->
        
        <cftry>
            <cfmodule template="../adminMarine/mod_ratingMarine.cfm"
                boatMake="#data_boatMake#" <!--- only checking for PWC --->
                boatValue="#data_marineValue#"
                boatTypeID="#data_boatType#"
                boatSpeedID="#data_motorSpeed#"
                boatConstrID="#data_boatConst#"            
                boatExcessID="#data_excessId#"
                boatExpID="#data_boatingExpYr#"
                boatLiabilityID="#data_liability#"
                boatStorageID="#data_storageMethodID#"
                boatAge="#data_boatAge#"
                motorTypeID="#data_motorType#"
                motorAgeID="#data_motorAge#"
                sailorAge="#data_sailorAge#"
                isBoatingCourse="#data_boatingCourse#"
                isStreetParked="#data_streetPark#"
                isWaterSkiers="#data_isSkiers#"
                sailorState="#data_stateId#"
                sailorStateArea="#data_stateAreaId#"
            	layupMonths="#list_layUpMths#"
        	    output_comp="compStruct"
        	    output_motoronly="motoronlyStruct"
                output_tpo="tpoStruct">

            <cfmodule template="../adminMarine/mod_ratingMarine.cfm"
                otherProducts=true
                sailorState="#data_stateId#"
                loanValue="#data_totalLoanVal#"
                output_others="otherProdsStruct">
                
            <cfset adminFee = otherProdsStruct.calcParams.adminFee >
            <cfset gstRate = otherProdsStruct.calcParams.gstPer / 100 >
            <cfset fslRate = otherProdsStruct.calcParams.fslPer / 100 >
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

        <cfif data_boatType eq CONST_MQ_BoatTypeRA_LID> <!--- for RUNABOUT show MOTOR-ONLY product --->
            <cfset tmpStruct2 = motoronlyStruct>
            <cfif StructCount(motoronlyStruct) gt 0 and motoronlyStruct.calcResult eq "OK">
                <cfset tmpStruct = StructNew()>
                <cfset x = StructInsert(tmpStruct,"coverName","Motor Only Cover")>
                <cfset x = StructInsert(tmpStruct,"base",motoronlyStruct.basePremium)>
                <cfset x = StructInsert(tmpStruct,"GST",motoronlyStruct.gstAmount)>
                <cfset x = StructInsert(tmpStruct,"FSL",motoronlyStruct.fslAmount)>
                <cfset x = StructInsert(tmpStruct,"totalPremium",motoronlyStruct.totalPremium)>
                <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_MQ_MotorOnly_LID)>
                <cfset x = StructInsert(coverOpts,"MOTOR",tmpStruct)>
            </cfif>
        </cfif>

        <cfset tmpStruct2 = compStruct>
        <cfif StructCount(compStruct) gt 0 and compStruct.calcResult eq "OK">
            <cfset tmpStruct = StructNew()>
            <cfset x = StructInsert(tmpStruct,"coverName","Comprehensive Cover")>
            <cfset x = StructInsert(tmpStruct,"base",compStruct.basePremium)>
            <cfset x = StructInsert(tmpStruct,"GST",compStruct.gstAmount)>
            <cfset x = StructInsert(tmpStruct,"FSL",compStruct.fslAmount)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",compStruct.totalPremium)>
            <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_MQ_Comp_LID)>
            <cfset x = StructInsert(coverOpts,"COMP",tmpStruct)>
        </cfif>
        
        <cfif StructCount(tpoStruct) gt 0 and tpoStruct.calcResult eq "OK">
            <cfset tmpStruct = StructNew()>
            <cfset x = StructInsert(tmpStruct,"coverName","Third Party Only Cover")>
            <cfset x = StructInsert(tmpStruct,"base",tpoStruct.basePremium)>
            <cfset x = StructInsert(tmpStruct,"GST",tpoStruct.gstAmount)>
            <cfset x = StructInsert(tmpStruct,"FSL",tpoStruct.fslAmount)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tpoStruct.totalPremium)>
            <cfset x = StructInsert(tmpStruct,"termMth","12")> <!--- static value --->
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_MQ_TPO_LID)>
            <cfset x = StructInsert(coverOpts,"TPO",tmpStruct)>
        </cfif>
            
            
        <cfif StructCount(tmpStruct2) gt 0>
            <cfif tmpStruct2.calcResult neq "OK">
                <cfset errorStmt = "">
                <cfif CompareNoCase(tmpStruct2.calcResult,"OVERPRICE") eq 0>
                    <cfset errorStmt = "Market price is outside the limit for automatic-quote">
                <cfelseif CompareNoCase(tmpStruct2.calcResult,"NO_EXCESS") eq 0 >
                    <cfset errorStmt = "Excess option cannot be applied">
                <cfelseif CompareNoCase(tmpStruct2.calcResult,"STREETPARK") eq 0 >
                    <cfset errorStmt = "Cannot insure street-parked asset">
                <cfelseif CompareNoCase(tmpStruct2.calcResult,"BOATSPEED") eq 0 >
                    <cfset errorStmt = "Cannot insure the asset due to its speed-range">
                <cfelseif CompareNoCase(tmpStruct2.calcResult,"ENG_REARMOUNT") eq 0 >
                    <cfset errorStmt = "Cannot insure Rear Mount Engine">    
                <cfelseif CompareNoCase(tmpStruct2.calcResult,"STORAGEMTHD") eq 0 >
                    <cfset errorStmt = "Cannot insure the asset due to its storage method">
                <cfelseif CompareNoCase(tmpStruct2.calcResult,"BOATAGE") eq 0 >
                    <cfset errorStmt = "Cannot insure the asset due to its age">
                <cfelse>
                    <cfset errorStmt = "Error Code (" & tmpStruct2.calcResult &")">
                </cfif>
                
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Unable to generate quote : " & errorStmt)>
            </cfif>
        <cfelse>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Boat is not insurable")>
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
                <cfset x = StructInsert(tmpStruct,"termMth",12)>
                <cfset x = StructInsert(tmpStruct,"param","$"&anItem)>
                <cfset x = StructInsert(tmpStruct,"int_code",CONST_MQ_QuoteGapCover_LID)>
                <cfset x = StructInsert(tmpStruct,"parent_id","GAP")>
                <cfset x = StructInsert(coverOpts,"GAP-OPT"&i,tmpStruct)>
                <cfset i = i+1>
            </cfif>
        </cfloop>
        
        <cfif data_totalLoanVal neq "">
            <cfset LP_LifeTermStruct = otherProdsStruct.calcParams.LP_LifeTermCover>
            <cfset LP_DisableTermStruct = otherProdsStruct.calcParams.LP_DisableTermCover>
            <cfset LP_UnempTermStruct = otherProdsStruct.calcParams.LP_UnempTermCover>
            <cfset LP_CashAssistTermStruct = otherProdsStruct.calcParams.LP_CashAssistTermCover>
            
            <cfset LP_Life_price = 0>
            <cfif StructKeyExists(LP_LifeTermStruct,data_loanTermMth)>
                <cfset LP_Life_price = StructFind(LP_LifeTermStruct,data_loanTermMth)>
            </cfif>
            <cfset LP_Disable_price = 0>
            <cfif StructKeyExists(LP_DisableTermStruct,data_loanTermMth)>
                <<cfset LP_Disable_price = StructFind(LP_DisableTermStruct,data_loanTermMth)>
            </cfif>
            <cfset LP_Unemp_price = 0>
            <cfif StructKeyExists(LP_UnempTermStruct,data_loanTermMth)>
                <cfset LP_Unemp_price = StructFind(LP_UnempTermStruct,data_loanTermMth)>
            </cfif>
            <cfset LP_CashAssist_price = 0>
            <cfif StructKeyExists(LP_CashAssistTermStruct,data_loanTermMth)>
                <cfset LP_CashAssist_price = StructFind(LP_CashAssistTermStruct,data_loanTermMth)>
            </cfif>
            
            <cfset tmpStruct = StructNew()>               
            <cfset tmpPrem = LP_Life_price>
            <cfset x = StructInsert(tmpStruct,"coverName","Loan Protection - Life")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth",list_loanTermMth)>
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_MQ_QuoteLoanProtect_LID)>
            <cfset x = StructInsert(tmpStruct,"parent_id","LP")>
            <cfset x = StructInsert(coverOpts,"LP-LIFE",tmpStruct)>
            
            <cfset tmpStruct = StructNew()>               
            <cfset tmpPrem = LP_Disable_price>
            <cfset x = StructInsert(tmpStruct,"coverName","Loan Protection - Disablement")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth",list_loanTermMth)>
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_MQ_QuoteLoanProtect_LID)>
            <cfset x = StructInsert(tmpStruct,"parent_id","LP")>
            <cfset x = StructInsert(coverOpts,"LP-DISABLE",tmpStruct)>
            
            <cfset tmpStruct = StructNew()>               
            <cfset tmpPrem = LP_Unemp_price>
            <cfset x = StructInsert(tmpStruct,"coverName","Loan Protection - Unemployment")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth",list_loanTermMth)>
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_MQ_QuoteLoanProtect_LID)>
            <cfset x = StructInsert(tmpStruct,"parent_id","LP")>
            <cfset x = StructInsert(coverOpts,"LP-UNEMPLOY",tmpStruct)>
            
            <cfset tmpStruct = StructNew()>               
            <cfset tmpPrem = LP_CashAssist_price>
            <cfset x = StructInsert(tmpStruct,"coverName","Loan Protection - Cash Assist")>
            <cfset x = StructInsert(tmpStruct,"base",tmpPrem)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*tmpPrem,".99"))>
            <cfset x = StructInsert(tmpStruct,"FSL",0)>
            <cfset x = StructInsert(tmpStruct,"totalPremium",tmpStruct.base + tmpStruct.GST + tmpStruct.FSL)>
            <cfset x = StructInsert(tmpStruct,"termMth",list_loanTermMth)>
            <cfset x = StructInsert(tmpStruct,"int_code",CONST_MQ_QuoteLoanProtect_LID)>
            <cfset x = StructInsert(tmpStruct,"parent_id","LP")>
            <cfset x = StructInsert(coverOpts,"LP-CASH",tmpStruct)>

        </cfif>
        
        <!--- GET COVER OPTIONS (end) --->
    </cfif>   
        
    <cfif ArrayLen(outerErrorArray) eq 0>
        <cftry>
            <cfset BoatQuoteStruct = StructNew()>
            <!--- quote form fields (start) --->

            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatMake_FID,"|"), data_boatMake, true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatModel_FID,"|"), data_boatModel, true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatType_FID,"|"), data_boatType,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_HullYear_FID,"|"), data_boatYear,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatConst_FID,"|"), data_boatConst,true)>
            <cfif data_boatIsProd>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatProd_FID,"|"), CONST_MQ_BoatProd_Yes_LID,true)>
            <cfelse>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatProd_FID,"|"), CONST_MQ_BoatProd_No_LID,true)>
            </cfif>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_HullLength_FID,"|"), data_boatLength,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatAge_FID,"|"),  data_boatAge,true)>
            
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MotorMake_FID,"|"), data_motorMake, true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_Motor_Year_FID,"|"), data_motorYear,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MotorType_FID,"|"),  data_motorType,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatFuelType_FID,"|"),  data_motorFuel,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MotorHP_FID,"|"),  data_motorHP,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatSpeed_FID,"|"), data_motorSpeed,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MotorAge_FID,"|"),  data_motorAge,true)>

            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_InsuredValue_FID,"|"), data_marineValue,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_LiabiltyLmt_FID,"|"),  data_liability,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_ExcessOpt_FID,"|"), data_excessId,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_SkiersLiabilityOpt_FID,"|"),  data_isSkiers,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_layUpMths_FID,"|"), data_layUpMths,true)>
            
            
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_InsurerDOB_FID,"|"), DateFormat(data_sailorDOB,"DD/MM/YYYY"),true)>    
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_SailorAge_FID,"|"),  data_sailorAge,true)>        
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_StorageMethod_FID,"|"), data_storageMethodID,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatStoragePostcode_FID,"|"), data_storagePostCode,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_State_FID,"|"), data_stateId,true)>            
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_BQ_StateArea_FID,"|"), data_stateAreaID,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_StreetParked_FID,"|"), data_streetPark,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatExp_FID,"|"),  data_boatingExpYr,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatingCourseOpt_FID,"|"),  data_boatingCourse,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_loanTermMth_FID,"|"), data_loanTermMth,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_TotLoanValue_FID,"|"), data_totalLoanVal,true)>
                
            
            <cfif StructKeyExists(thirdgenDetailsStruct,"extDataProvider")>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|"), thirdgenDetailsStruct.extDataProvider,true)>
            </cfif>
            <cfif StructKeyExists(thirdgenDetailsStruct,"extDataID")>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_ExtId_FID,"|"), thirdgenDetailsStruct.extDataID,true)>
            </cfif>
            
            <!--- <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_BQ_gapCoverTerm_FID,"|"), data_loanTermMth,true)> --->
            <cfif StructKeyExists(coverOpts,"COMP")>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_quoteComp_FID,"|"), NumberFormat(coverOpts.COMP.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"TPO")>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_quoteTPO_FID,"|"), NumberFormat(coverOpts.TPO.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"MOTOR")>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_quoteMotorOnly_FID,"|"), NumberFormat(coverOpts.MOTOR.totalPremium,".99"),true)>
            </cfif>
            
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_extraSelected_FID,"|"), "",true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_quoteAdminFee_FID,"|"), NumberFormat(adminFeeTotal,".99"),true)>
            
        
            <!--- quote form fields (end) --->
    
            <cfset theFormDataId = 0>
            <cfcatch type="Any">
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot insert/update QUOTE", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfif ArrayLen(outerErrorArray) eq 0 and StructCount(BoatQuoteStruct) gt 1 >
        <!--- PRINT XML --->

        <cfsavecontent variable="theContent"><cfoutput>
        <marine>
            <boatDetails>
                <make>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_BoatMake_FID,"|"))#</make>
                <model>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_BoatModel_FID,"|"))#</model>
                <type>#list_boatType#</type>
                <year>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_HullYear_FID,"|"))#</year>
                <construction>#list_boatConst#</construction>
                <inProd>#data_boatIsProd#</inProd>
                <length>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_HullLength_FID,"|"))#</length> 
            </boatDetails>
            <motorDetails>
                <make>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_MotorMake_FID,"|"))#</make>
                <year>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_Motor_Year_FID,"|"))#</year>
                <type>#list_motorType#</type>
                <fuelType>#list_motorFuel#</fuelType>
                <hp>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_MotorHP_FID,"|"))#</hp> 
                <speedMax>#list_motorSpeed#</speedMax>
            </motorDetails>
        </marine>
        <client>
            <!---  DON'T NEED TO BE RETURNED AT THE MOMENT
            <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_loanTermMth_FID,"|"))>
                <loanTermMth>#list_loanTermMth#</loanTermMth>
            </cfif>  --->
            <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_TotLoanValue_FID,"|"))>
                <totalLoanVal>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_TotLoanValue_FID,"|"))#</totalLoanVal>
            </cfif>
        </client>
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


