<!--- 
SAMPLE:
========

<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Marine</clientType>
</header>
<request type="COVERBOUND">
    <id>
        <refId>82583<refId> <!--- this is mandatory for cover bound ! --->
        <extRefId provider="YMSI">Y9IA801279</extRefId>
        <extDealer id="YMINZ001">Auckland Test Marine</extDealer>
        <extUser id="987564">John.Citizen</extUser>
    </id>    
    <marine>
        <boatDetails>
            <serialNumbers>
                <serialNumber type="HIN">NHIJ-90912431444</serialNumber>
                <serialNumber type="REGONO">IP09189</serialNumber>
            </serialNumbers>
        </boatDetails>
        <motorDetails>
            <serialNumbers>
                <serialNumber type="ENGINENO">0123457001</serialNumber>
                <serialNumber type="ENGINENO">0123457002</serialNumber>
            </serialNumbers>
        </motorDetails>
        <trailerDetails>
            <make>HONDA</make>
            <year>2010</year>
            <serialNumbers>
                <serialNumber type="REGONO">IP09189</serialNumber>
            </serialNumbers>
        </trailerDetails>
        <isYamahaDNA>false</isYamahaDNA>
        <isTransitRisk>false</isTransitRisk>
        <mooringType></mooringType>
        <datePurchased>2014-09-04Z</datePurchased>
        <purchasedPrice>5100.00</purchasedPrice> <!--- Purchase Price:  --->
        <dateSurveyed>2014-09-03Z</dateSurveyed>
    </marine>
    <client>
        <firstname>John</firstname>
        <lastname>Citizen</lastname>
        <email>j.citizen@gmail.com</email>
        
        <coverStartDate>2013-09-05Z</coverStartDate> <!--- Cover Commencement Date:  --->
        <address>258 Woop Street</address>
        <addressPostcode>2035</addressPostcode>
        <storageAddress></storageAddress>
        <homephone>987654321</homephone>
        <mobilephone>0401234567</mobilephone>
        <fax>98765000</fax>
        <occupation>Truckies</occupation>
        <driverLicNo>1286786</driverLicNo>
        <driverLicExpDate>2018-03-05Z</driverLicExpDate>
        <boatLicNo>AB09017823-90</boatLicNo>
        <boatLicExpDate>2017-09-15Z</boatLicExpDate>
        <financier>YMF Australia</financier>
        <isRegGST>false</isRegGST>
        <ABN>89 0019 2450</ABN>
        <bussName>ABC Pty Ltd</bussName>
        <inputTaxCredit>0</inputTaxCredit>
    </client>
    <cover>
        <product id="COMP"/>
        <product id="GAP">
            <subProduct id="GAP-OPT1"/>
        </product>
    </cover>
</request>
</NMPackage>
--->

<!--- 
LP rules: UNEMPLOYMENT and CASH-ASSIST Cover must be chosen with either LIFE or DISABLEMENT Cover
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
    <cfif not isDefined("tmpXML.XmlAttributes.type") OR CompareNoCase(tmpXML.XmlAttributes.type,"COVERBOUND") neq 0>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"FORMAT","Invalid Request Content" )>
    <cfelse>
        <cfif isDefined("tmpXML.XmlAttributes.action")>
            <cfset requestAction = tmpXML.XmlAttributes.action>
        </cfif>
        
        <cfif StructCount(thirdgenDetailsStruct) neq 0 >
            <cfif not StructKeyExists(thirdgenDetailsStruct,"intDataID")>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Internal ID is required")>
            </cfif>
        </cfif>   
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
    
    <cfset allowCoverBoundEdit = true>
    <cfset BoatQuoteStruct = StructNew()>
    
    <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_def_id, fd.form_data_id, fd.xml_data, fd.last_updated
    from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
    </cfquery>
    <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BoatQuoteStruct">
    <cfif StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|")) eq CONST_MQ_QuoteStatus_stage3_LID
        or StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|")) eq CONST_MQ_QuoteStatus_stage4_LID>
        <cfset allowCoverBoundEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Quote has already been bound")> 
    </cfif>
    <cfif StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_ignoreCompl_FID,"|")) neq 1
        and
        (
            StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_hadInsuranceRefused_FID,"|")) eq 1
            or StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_hadClaims_FID,"|")) eq 1
            or StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_hadChargedWithOffence_FID,"|")) eq 1
        )
        >
        <cfset allowCoverBoundEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cover bound is not allowed - compliance issue")>
    </cfif>
    
    <!--- can't edit if it has been manually adjusted internally --->
    <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_manualEditor_FID,"|"))
        and StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_manualEditor_FID,"|")) neq ""> 
        <cfset allowCoverBoundEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cover bound is not allowed - manual-edit has been applied")> 
    </cfif>
    
    <cfif DateDiff("d",getformData.last_updated ,now()) gt CONST_QUOTE_VALIDITY>
        <cfset allowCoverBoundEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Outside #CONST_QUOTE_VALIDITY# days quote validity period")>
    </cfif>
    
    <cftry>
        <cfset tempXML = theCurrentXml.NMPackage.request.marine>
        <cfif not IsDefined("tempXML.boatDetails")
            or not IsDefined("tempXML.motorDetails")
            or not IsDefined("tempXML.trailerDetails") >
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE")>
        <cfelse>
            <cfloop index="aSerialNo" array="#xmlsearch(tempXML.boatDetails.serialNumbers,'serialNumber')#">
                <cfif IsDefined("data_boat_"&aSerialNo.XmlAttributes.type)>
                    <cfset x = evaluate("data_boat_"&aSerialNo.XmlAttributes.type&" = ListAppend(data_boat_"&aSerialNo.XmlAttributes.type&","""& aSerialNo.XmlText & """,""|"")")>
                <cfelse>
                    <cfset x = evaluate("data_boat_"&aSerialNo.XmlAttributes.type&" = """& aSerialNo.XmlText & """")> <!--- HIN | REGONO | ENGINENO  --->
                </cfif>
            </cfloop>
        
            <cfloop index="aSerialNo" array="#xmlsearch(tempXML.motorDetails.serialNumbers,'serialNumber')#">
                <cfif IsDefined("data_motor_"&aSerialNo.XmlAttributes.type)>
                    <cfset x = evaluate("data_motor_"&aSerialNo.XmlAttributes.type&" = ListAppend(data_motor_"&aSerialNo.XmlAttributes.type&","""& aSerialNo.XmlText & """,""|"")")>
                <cfelse>
                    <cfset x = evaluate("data_motor_"&aSerialNo.XmlAttributes.type&" = """& aSerialNo.XmlText & """")> <!--- HIN | REGONO | ENGINENO  --->
                </cfif>
            </cfloop>
            
            <cfloop index="aSerialNo" array="#xmlsearch(tempXML.trailerDetails.serialNumbers,'serialNumber')#">
                <cfif IsDefined("data_trailer_"&aSerialNo.XmlAttributes.type)>
                    <cfset x = evaluate("data_trailer_"&aSerialNo.XmlAttributes.type&" = ListAppend(data_trailer_"&aSerialNo.XmlAttributes.type&","""& aSerialNo.XmlText & """,""|"")")>
                <cfelse>
                    <cfset x = evaluate("data_trailer_"&aSerialNo.XmlAttributes.type&" = """& aSerialNo.XmlText & """")> <!--- HIN | REGONO | ENGINENO  --->
                </cfif>
            </cfloop>

            <cfset data_trailerMake = "">
            <cfif StructKeyExists(tempXML.trailerDetails,"make") and trim(tempXML.trailerDetails.make.XmlText) neq "">
                <cfset data_trailerMake = trim(tempXML.trailerDetails.make.XmlText)>
            </cfif>
            <cfset data_trailerYear = "">
            <cfif StructKeyExists(tempXML.trailerDetails,"year") and trim(tempXML.trailerDetails.year.XmlText) neq "">
                <cfset data_trailerYear = trim(tempXML.trailerDetails.year.XmlText)>
            </cfif>
            
            <cfset data_isYamahaDNA = trim(tempXML.isYamahaDNA.XmlText)>
            <cfif data_isYamahaDNA>
                <cfset data_isYamahaDNA = 1>
            <cfelse>
                <cfset data_isYamahaDNA = 0>
            </cfif>
            
            <cfset data_isTransitRisk = trim(tempXML.isTransitRisk.XmlText)>
            <cfif data_isTransitRisk>
                <cfset data_isTransitRisk = 1>
            <cfelse>
                <cfset data_isTransitRisk = 0>
            </cfif>
            
            <cfset data_mooringType = "">
            <cfif StructKeyExists(tempXML,"mooringType") and trim(tempXML.mooringType.XmlText) neq "">
                <cfset data_mooringType = trim(tempXML.mooringType.XmlText)>
            </cfif>
            
            <cfset data_datePurchased = "">
			
			<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value)  datePurchased was moved to getQuote--->
            <!--- <cfif StructKeyExists(tempXML,"datePurchased") and trim(tempXML.datePurchased.XmlText) neq "">
                <cfset data_datePurchased = trim(tempXML.datePurchased.XmlText)> 
                <cfset data_datePurchased = XMLToCF_dateTime(data_datePurchased)>
            </cfif> --->
			<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value)  datePurchased was moved to getQuote--->
            
            <cfset data_dateSurveyed = "">
            <cfif StructKeyExists(tempXML,"dateSurveyed") and trim(tempXML.dateSurveyed.XmlText) neq "">
                <cfset data_dateSurveyed = trim(tempXML.dateSurveyed.XmlText)> 
                <cfset data_dateSurveyed = XMLToCF_dateTime(data_dateSurveyed)>
            </cfif>
            
            <cfset data_purchasedPrice = trim(tempXML.purchasedPrice.XmlText)>
            <cfif LSParseNumber(data_purchasedPrice) lt 1>
                <cfset data_purchasedPrice = "">
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid value on price field")>
            </cfif>
            
            <cfif data_datePurchased neq ""> <!--- OPTIONAL --->
                <cfif DateDiff("d",now(),data_datePurchased) gt 0> <!--- CANNOT BE FUTURE --->
                    <cfset allowCoverBoundEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid Date Purchased")>
                </cfif>
                
                <!--- <cfif data_dateSurveyed neq "" and DateDiff("d",data_datePurchased,data_dateSurveyed) lt 0> <!--- CANNOT BE BEFORE DATE-PURCHASED --->
                    <cfset allowCoverBoundEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid Date Surveyed")>
                </cfif> --->
            </cfif>        
                
        </cfif>
        
        <cfcatch type="Any">
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MARINE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>
    
    <cftry>
        <cfset tempXML = theCurrentXml.NMPackage.request.client>
        <cfset data_firstname = trim(tempXML.firstname.XmlText)>
        <cfset data_lastname = trim(tempXML.lastname.XmlText)>
        <cfset data_email = trim(tempXML.email.XmlText)>
        
        <cfset data_coverStartDate = trim(tempXML.coverStartDate.XmlText)> 
        <cfset data_coverStartDate = XMLToCF_dateTime(data_coverStartDate)>
        
        <cfset data_address = trim(tempXML.address.XmlText)>
        <cfset data_addressPostcode = trim(tempXML.addressPostcode.XmlText)>
        <cfset data_storageAddress = trim(tempXML.storageAddress.XmlText)>
        <cfset data_homephone = trim(tempXML.homephone.XmlText)>
        <cfset data_mobilephone = "">
        <cfif StructKeyExists(tempXML,"mobilephone") and trim(tempXML.mobilephone.XmlText) neq "">
            <cfset data_mobilephone = trim(tempXML.mobilephone.XmlText)>
        </cfif>
        <cfset data_fax = "">
        <cfif StructKeyExists(tempXML,"fax") and trim(tempXML.fax.XmlText) neq "">
            <cfset data_fax = trim(tempXML.fax.XmlText)>
        </cfif>
        <cfset data_occupation = trim(tempXML.occupation.XmlText)>
        <cfset data_financier = trim(tempXML.financier.XmlText)>
        
        <cfset data_driverLicNo = "">
        <cfset data_driverLicExpDate = "">
        <cfif StructKeyExists(tempXML,"driverLicNo") and trim(tempXML.driverLicNo.XmlText) neq "">
            <cfset data_driverLicNo = trim(tempXML.driverLicNo.XmlText)>
            <cfset data_driverLicExpDate = trim(tempXML.driverLicExpDate.XmlText)> 
            <cfset data_driverLicExpDate = XMLToCF_dateTime(data_driverLicExpDate)>
        </cfif>

        <cfset data_boatLicNo = "">
        <cfset data_boatLicExpDate = "">
        <cfif StructKeyExists(tempXML,"boatLicNo") and trim(tempXML.boatLicNo.XmlText) neq "">
            <cfset data_boatLicNo = trim(tempXML.boatLicNo.XmlText)>  
            <cfset data_boatLicExpDate = trim(tempXML.boatLicExpDate.XmlText)> 
            <cfset data_boatLicExpDate = XMLToCF_dateTime(data_boatLicExpDate)>
        </cfif>
        
        <cfset data_isRegGST = trim(tempXML.isRegGST.XmlText)>
        <cfif data_isRegGST>
            <cfset data_isRegGST = 1>
        <cfelse>
            <cfset data_isRegGST = 0>
        </cfif>
        
        <cfset data_ABN = "">
        <cfif StructKeyExists(tempXML,"ABN") and trim(tempXML.ABN.XmlText) neq "">
            <cfset data_ABN = trim(tempXML.ABN.XmlText)>
        </cfif>
        
        <cfset data_bussName = "">
        <cfif StructKeyExists(tempXML,"bussName") and trim(tempXML.bussName.XmlText) neq "">
            <cfset data_bussName = trim(tempXML.bussName.XmlText)>
        </cfif>
        
        <cfset data_inputTaxCredit = "">
        <cfif StructKeyExists(tempXML,"inputTaxCredit") and trim(tempXML.inputTaxCredit.XmlText) neq "">
            <cfset data_inputTaxCredit = trim(tempXML.inputTaxCredit.XmlText)>
        </cfif>
        
        <cfif data_firstname eq "" or data_lastname eq "" or data_email eq ""
            > <!--- or data_driverLicNo eq "" or data_boatLicNo eq "" --->
            <cfset allowCoverBoundEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE")>
        </cfif>
        
        <cfif DateDiff("d",now(),data_coverStartDate) lt 0>
            <cfset allowCoverBoundEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Invalid Cover start date", "")>
        </cfif>
        
        <cfif data_boatLicExpDate neq "" and DateDiff("d",now(),data_boatLicExpDate) lt 0>
            <cfset allowCoverBoundEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Invalid Boat License Expiry Date", "")>
        </cfif>
        
        <cfif data_driverLicExpDate neq "" and DateDiff("d",now(),data_driverLicExpDate) lt 0>
            <cfset allowCoverBoundEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Invalid Driver License Expiry Date", "")>
        </cfif>

        <cfcatch type="Any">
            <cfset allowCoverBoundEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MARINE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>
    
    <cfif allowCoverBoundEdit>
        <cftry>
            <cfset coverSelection = ArrayNew(1)>
            <cfset tempXML = theCurrentXml.NMPackage.request.cover>
            
            <!--- What if they remove all selected products? --->
            <cfloop index="aProd" array="#xmlsearch(tempXML,'product')#">
                <cfif StructKeyExists(aProd,"subproduct")> <!--- this is CASE-INSENSITIVE search! --->
                    <cfloop index="aSubProd" array="#xmlsearch(aProd,'subProduct')#">
                        <cfset x = ArrayAppend(coverSelection,aProd.XmlAttributes.id&"|"&aSubProd.XmlAttributes.id)>
                    </cfloop>
                <cfelse>
                    <cfset x = ArrayAppend(coverSelection,aProd.XmlAttributes.id)>
                </cfif>
            </cfloop>
            
            <!--- UNEMPLOYMENT and CASH-ASSIST Cover must be chosen with either LIFE or DISABLEMENT Cover (Done based on product rules, instead ) --->
            <!--- <cfif ArrayFindNoCase(coverSelection,"LP|LP-UNEMPLOY") gt 0 or ArrayFindNoCase(coverSelection,"LP|LP-CASH") gt 0>
                <cfif ArrayFindNoCase(coverSelection,"LP|LP-LIFE") eq 0 and ArrayFindNoCase(coverSelection,"LP|LP-DISABLE") eq 0>
                    <cfset x = ArrayClear(coverSelection)>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid Loan Protection cover combination", "")>
                </cfif>
            </cfif> --->
            
            <cfif ArrayLen(coverSelection) eq 0>
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - No cover products selected", "")>
            </cfif>
            
            <cfcatch type="Any">
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MARINE/CLIENT", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfif allowCoverBoundEdit>
        <cftry>
            <!--- quote form fields (start) --->          
            <cfif data_datePurchased neq "">
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_PurchasedDate_FID,"|"), DateFormat(data_datePurchased,"DD/MM/YYYY"),true)>
            </cfif> 
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_PurchasedPrice_FID,"|"), data_purchasedPrice,true)>
            <cfif data_dateSurveyed neq "">
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_SurveyedDate_FID,"|"), DateFormat(data_dateSurveyed,"DD/MM/YYYY"),true)>
            </cfif>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_IsYamahaDNA_FID,"|"), data_isYamahaDNA,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_IsTransitRisk_FID,"|"), data_isTransitRisk,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_TrailerMake_FID,"|"), data_trailerMake,true)>            
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_TrailerYear_FID,"|"), data_trailerYear,true)>
     
            <cfif (IsDefined("data_mooringType") and data_mooringType neq "") 
                or StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_StorageMethod_FID,"|")) eq CONST_MQ_StorageMethod_Moored_LID>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_IsBoatMoored_FID,"|"), 1,true)>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MooredType_FID,"|"), data_mooringType,true)>
            <cfelse>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_IsBoatMoored_FID,"|"), 0,true)>
            </cfif>
            
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_CoverCommDate_FID,"|"), DateFormat(data_coverStartDate,"DD/MM/YYYY"),true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_InsuredAddStreet_FID,"|"), data_address,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_InsuredAddPost_FID,"|"), data_addressPostcode,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_LayupAddress_FID,"|"), data_storageAddress,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_Homephone_FID,"|"), data_homephone,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_Occupation_FID,"|"), data_occupation,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_InterestedParties_FID,"|"), data_financier,true)>
            
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MobilePhone_FID,"|"), data_mobilephone,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_Fax_FID,"|"), data_fax,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_DriverLicense_No_FID,"|"), data_driverLicNo,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatLicense_No_FID,"|"), data_boatLicNo,true)>
            <cfif data_driverLicExpDate neq "">
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_DriverLicense_Expiry_FID,"|"), DateFormat(data_driverLicExpDate,"DD/MM/YYYY"),true)>
            </cfif>
            <cfif data_boatLicExpDate neq "">
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatLicense_Expiry_FID,"|"), DateFormat(data_boatLicExpDate,"DD/MM/YYYY"),true)>
            </cfif>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_GSTRegistered_FID,"|"), data_isRegGST,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BusinessABN_FID,"|"), data_ABN,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BusinessName_FID,"|"), data_bussName,true)>
            <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_ITC_Claim_FID,"|"), data_inputTaxCredit,true)>
            
            
            <cfif IsDefined("data_boat_REGONO") and data_boat_REGONO neq "">
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_RegoNo_FID,"|"), data_boat_REGONO,true)>
            </cfif>
            <cfif IsDefined("data_boat_HIN") and data_boat_HIN neq "">
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_HINNo_FID,"|"), data_boat_HIN,true)>
            </cfif>
            <cfif IsDefined("data_trailer_REGONO") and data_trailer_REGONO neq "">
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_TrailerRego_FID,"|"), data_trailer_REGONO,true)>
            </cfif>
            <cfif IsDefined("data_motor_ENGINENO") and data_motor_ENGINENO neq "">
                <!--- <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MotorSerialNo1_FID,"|"), ListFirst(data_motor_ENGINENO,"|"),true)>
                <cfif ListLen(data_motor_ENGINENO,"|") gt 1>
                    <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MotorSerialNo2_FID,"|"), ListGetAt(data_motor_ENGINENO,2,"|"),true)>
                </cfif>
                <cfif ListLen(data_motor_ENGINENO,"|") gt 2>
                    <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MotorSerialNo3_FID,"|"), ListGetAt(data_motor_ENGINENO,3,"|"),true)>
                </cfif> --->
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_MotorSerialNo_FID,"|"), ReplaceNoCase(data_motor_ENGINENO,"|",",","ALL"),true)>
            </cfif>
            
            <cfset tmpStr = getWebServiceTempData(form_data_id=thirdgenDetailsStruct.intDataID
                ,data_type="COVER_OPTIONS"
                ,requester_id=thirdgenDetailsStruct.extDataProvider
                ,external_id=thirdgenDetailsStruct.extDataID
                )> 
            <cfif trim(tmpStr) eq "">
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot find cover options for (Ext-Ref:"&thirdgenDetailsStruct.extDataID&") and (Int-Ref:" & thirdgenDetailsStruct.intDataID & ")")>
            <cfelse>
                <cfwddx action="WDDX2CFML" input="#tmpStr#" output="coverOpts">
            </cfif>
            
            <!--- check the product rules --->
            <cfif ArrayLen(outerErrorArray) eq 0>
                <cfloop array="#coverSelection#" index="aCover">
                    <cfif ListLen(aCover,"|") gt 1>
                        <cfset theCover = ListLast(aCover,"|")>
                    <cfelse>
                        <cfset theCover = aCover>
                    </cfif>
                    
                    <cfif StructKeyExists(coverOpts,theCover)>
                        <cfset tmpStruct = StructFind(coverOpts,theCover)>
                        
                        <cfif StructKeyExists(tmpStruct,"prodOpt")>
                            <cfset productOpt = StructFind(tmpStruct,"prodOpt")>
                            <cfset parentId = "">
                            <cfif StructKeyExists(tmpStruct,"parent_id")>
                                <cfset parentId = StructFind(tmpStruct,"parent_id")>
                            </cfif>
                            <cfset x = ListFirst(productOpt,"|")>
                            
                            <cfif CompareNoCase(x,"UNIQUE") eq 0>
                                <cfset theParam = ListLast(productOpt,"|")>
                                <cfset prodQty = 0>
                                <cfloop list="#theParam#" index="anItem">
                                    <cfif ArrayContains(coverSelection,anItem)>
                                        <cfset prodQty = prodQty + 1>
                                    </cfif>
                                </cfloop>
                                
                                <cfif prodQty gt 1> <!--- not unique - invalid --->
                                    <cfset allowCoverBoundEdit = false>
                                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Multiple Unique products", "")>
                                </cfif>
                                
                            <cfelseif CompareNoCase(x,"REQ_OR") eq 0>
                                <cfset theParam = ListLast(productOpt,"|")>
                                
                                <cfset isFound = false>
                                <cfloop list="#theParam#" index="anItem">
                                    <cfset tmpItem = anItem>
                                    <cfif parentId neq "">
                                        <cfset tmpItem = parentId & "|" & tmpItem>
                                    </cfif>
                                    <cfif ArrayContains(coverSelection,tmpItem)>
                                        <cfset isFound = true>
                                    </cfif>
                                </cfloop>
                                
                                <cfif not isFound> <!--- cannot find the required products --->
                                    <cfset allowCoverBoundEdit = false>
                                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Cover Combination(s) for #StructFind(tmpStruct,'coverName')#", "")>
                                </cfif>
                            </cfif>
                        </cfif>
                    </cfif>
                </cfloop>
            </cfif>
    
            <cfset fslFee = 0>
            <cfif ArrayLen(outerErrorArray) eq 0>
                <cfset allCovers = "">
                <cfset allCoversStruct = StructNew()>
                <cfset allCoversDetails = "">
                                
                <cfset LP_totalBase = 0>
                <cfset LP_totalGST = 0>
                <cfset LP_totalStamp = 0>
                <cfset LP_detailsPrem = "">
                <cfset LP_int_code = "">
                
                <cfloop array="#coverSelection#" index="aCover">
                    <cfif ListLen(aCover,"|") gt 1>
                        <cfset theCover = ListLast(aCover,"|")>
                    <cfelse>
                        <cfset theCover = aCover>
                    </cfif>
                    
                    <cfif StructKeyExists(coverOpts,theCover)>
                        <cfset tmpStruct = StructFind(coverOpts,theCover)>
                        <cfif tmpStruct.base gt 0>
                            <cfset x = StructInsert(allCoversStruct,theCover,tmpStruct)>
                            <cfset theCoverID = ListFirst(StructFind(tmpStruct,"int_code"),"|")> <!--- some of the product has multiple LID's --->
                            
                            <cfif CompareNoCase(ListFirst(aCover,"|"),"LP") eq 0> <!--- LP is a combination of sub-products --->
                                <cfset LP_int_code = theCoverID>
                                <cfset LP_totalBase = LP_totalBase + tmpStruct.base>
                                <cfset LP_totalGST = LP_totalGST + tmpStruct.gst>
                                <cfset LP_totalStamp = LP_totalStamp + tmpStruct.stampduty>
                                
                                <cfif theCover eq "LP-LIFE">
                                    <cfset LP_detailsPrem = ListAppend(LP_detailsPrem, "L:$#tmpStruct.base#", ";")>
                                <cfelseif theCover eq "LP-DISABLE">
                                    <cfset LP_detailsPrem = ListAppend(LP_detailsPrem, "D:$#tmpStruct.base#", ";")>
                                <cfelseif theCover eq "LP-UNEMPLOY">
                                    <cfset LP_detailsPrem = ListAppend(LP_detailsPrem, "U:$#tmpStruct.base#", ";")>
                                <cfelseif theCover eq "LP-CASH">
                                    <cfset LP_detailsPrem = ListAppend(LP_detailsPrem, "C:$#tmpStruct.base#", ";")>
                                </cfif>
                                
                            <cfelse>  
                                <cfset allCovers = ListAppend(allCovers, theCoverID)>
                                <cfsavecontent variable="tmpStr"><cfoutput>
                                ^ #tmpStruct.coverName# <cfif StructKeyExists(tmpStruct,"details")>(#StructFind(tmpStruct,"details")#)</cfif> - 
                                Base: $#tmpStruct.base#;
                                GST: $#tmpStruct.gst#;<br/>
                                </cfoutput></cfsavecontent>
                                <cfset allCoversDetails = allCoversDetails & APPLICATION.NEWLINE & trim(Replace(tmpStr, "  "," ","ALL"))>
                            
                                <cfif CompareNoCase(ListFirst(aCover,"|"),"GAP") eq 0>
                                    <cfset selectExtra = "Sum Insured #tmpStruct.param#">
                                    <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_extraSelected_FID,"|"), selectExtra,true)>
                                    <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_quoteGapCover_FID,"|"), tmpStruct.totalPremium,true)>
                                </cfif>
                            </cfif>
                            
                            <cfset fslFee = fslFee + tmpStruct.fsl>
                        </cfif>
                    </cfif>
                </cfloop>
                
                <cfif LP_totalBase gt 1> <!--- if Loan Protection product was chosen - currently NA --->
                    <cfset allCovers = ListAppend(allCovers, LP_int_code)>
                    <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_quoteLoanProtect_FID,"|"), NumberFormat(LP_totalBase + LP_totalGST + LP_totalStamp,".99"),true)>
                    <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_loanProtectDetails_FID,"|"), LP_detailsPrem, true)>
                    <cfsavecontent variable="tmpStr"><cfoutput>
                    ^ Loan Protection (#LP_detailsPrem#) - 
                    Base: $#LP_totalBase#;
                    GST: $#LP_totalGST#;<br/>
                    </cfoutput></cfsavecontent>
                    <cfset allCoversDetails = allCoversDetails & APPLICATION.NEWLINE & trim(Replace(tmpStr, "  "," ","ALL"))> 
                </cfif>
                
                <!--- if RUNABOUT, and chose MOTOR-ONLY product --->
                <cfif ListFindNoCase(allCovers,CONST_MQ_MotorOnly_LID) gt 0 and StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_BoatType_FID,"|")) eq CONST_MQ_BoatTypeRA_LID>
                    <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_BoatType_FID,"|"), CONST_MQ_BoatTypeRAM_LID,true)>
                </cfif>
                
                <!--- add ADMIN FEES details (start) --->
                <cfset tmpStruct = StructFind(coverOpts,"FEE_ADMIN")>
                <cfsavecontent variable="tmpStr"><cfoutput>
                ^ Admin Fee (inc. GST): $#NumberFormat(tmpStruct.total,".99")#<br/>
                <cfif fslFee gt 0>
                    ^ FSL: $#NumberFormat(fslFee,".99")#<br/>
                </cfif>
                </cfoutput></cfsavecontent>
                <cfset allCoversDetails = allCoversDetails & APPLICATION.NEWLINE & trim(Replace(tmpStr, "  "," ","ALL"))>
                <!--- add ADMIN FEES details (end) --->
                
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_quoteSelected_FID,"|"), allCovers,true)>
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_quoteDetails_FID,"|"), allCoversDetails,true)>
                
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|"), CONST_MQ_QuoteStatus_stage3_LID,true)>
            </cfif>        

            <!--- quote form fields (end) --->
    
            <cfif ArrayLen(outerErrorArray) eq 0>
                <cfwddx action="CFML2WDDX" input="#BoatQuoteStruct#" output="BoatQuoteStructWDDX">
                
                <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        	    update thirdgen_form_data
        	    set xml_data = '#BoatQuoteStructWDDX#', last_updated = #CreateODBCDateTime(now())#
        	    where form_data_id = #thirdgenDetailsStruct.intDataID#
                
                update thirdgen_form_header_data
                set form_def_id = form_def_id
                <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_extraSelected_FID,"|"))>
                , #ListLast(CONST_MQ_extraSelected_FID,"|")# = '#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_extraSelected_FID,"|"))#'
                </cfif>
                where form_data_id = #thirdgenDetailsStruct.intDataID#
                </cfquery>
                
                <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#CONST_marineQuoteFormDefId#" formDataID="#thirdgenDetailsStruct.intDataID#">
            
                <!--- RE-QUERY QUOTE DATA STRUCT! --->
                <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
                select fd.form_def_id, fd.form_data_id, fd.xml_data
                from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
                </cfquery>
                <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BoatQuoteStruct">
                
            </cfif> 
            
            <cfcatch type="Any">
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot insert/update COVER BOUND", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfif ArrayLen(outerErrorArray) eq 0>
        <!--- PRINT XML --->
        <!--- show the list-item 'real' value - only use this when necessary --->
        <cfmodule template="../thirdgen/form/mod_get_form_data.cfm"
            formDefID = "#CONST_marineQuoteFormDefId#"
            formDataId = "#getFormData.form_data_id#"
            output="theData">
        
        <cfquery name="getFormDataList" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select fdlv.key_name, fdlv.field_value, li.list_id, li.list_item_id, li.list_item_display, li.list_item_image
        from thirdgen_form_data_list_values fdlv
        inner join thirdgen_list_item li on fdlv.field_value = li.list_item_id
        	and fdlv.list_type = 'L'
        where form_Data_id = #getFormData.form_data_id#
        </cfquery>
        
        <cfquery name="getFormDataListSpec" dbtype="query">
        select * from getFormDataList where key_name = '#ListFirst(CONST_MQ_BoatType_FID,"|")#'
        </cfquery>
        <cfset list_boatType = getFormDataListSpec.list_item_image>
    
        <cfquery name="getFormDataListSpec" dbtype="query">
        select * from getFormDataList where key_name = '#ListFirst(CONST_MQ_BoatConst_FID,"|")#'
        </cfquery>
        <cfset list_boatConst = UCase(getFormDataListSpec.list_item_display)>
        
        <cfquery name="getFormDataListSpec" dbtype="query">
        select * from getFormDataList where key_name = '#ListFirst(CONST_MQ_BoatProd_FID,"|")#'
        </cfquery>
        <cfif getFormDataListSpec.list_item_id eq CONST_MQ_BoatProd_Yes_LID>
            <cfset data_boatIsProd = "true">
        <cfelse>
            <cfset data_boatIsProd = "false">
        </cfif>
        
        <cfquery name="getFormDataListSpec" dbtype="query">
        select * from getFormDataList where key_name = '#ListFirst(CONST_MQ_MotorType_FID,"|")#'
        </cfquery>
        <cfset list_motorType = getFormDataListSpec.list_item_image>
        
        <cfquery name="getFormDataListSpec" dbtype="query">
        select * from getFormDataList where key_name = '#ListFirst(CONST_MQ_BoatFuelType_FID,"|")#'
        </cfquery>
        <cfset list_motorFuel = getFormDataListSpec.list_item_display>
        
        <cfquery name="getFormDataListSpec" dbtype="query">
        select * from getFormDataList where key_name = '#ListFirst(CONST_MQ_BoatSpeed_FID,"|")#'
        </cfquery>
        <cfset list_motorSpeed = getFormDataListSpec.list_item_image>
        
        
        <cfset tmpStruct = StructNew()>
        <cfset tmpArray = StructFindKey(allCoversStruct,"parent_id","ALL")>
        <cfloop array="#tmpArray#" index="anIndex">
            <cfset aCover = anIndex.owner>
            <cfset anItem = ListGetAt(anIndex.path,2,".",true)>
            <cfsavecontent variable="tmpStr"><cfoutput>
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
            </cfoutput></cfsavecontent>
            
            <cfif StructKeyExists(tmpStruct,anIndex.value)>
                <cfset x = StructInsert(tmpStruct,anIndex.value,StructFind(tmpStruct,anIndex.value)&trim(tmpStr),true)>
            <cfelse>
                <cfset x = StructInsert(tmpStruct,anIndex.value,trim(tmpStr),true)>
            </cfif>
        </cfloop>

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
            <trailerDetails>
                <make>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_TrailerMake_FID,"|"))#</make>
                <year>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_TrailerYear_FID,"|"))#</year>
            </trailerDetails>
        </marine>
        <client>
            <firstname>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_FirstName_FID,"|"))#</firstname>
            <lastname>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_Surname_FID,"|"))#</lastname>
            <email>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_Email_FID,"|"))#</email>
            <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_TotLoanValue_FID,"|"))>
            <totalLoanVal>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_TotLoanValue_FID,"|"))#</totalLoanVal>
            </cfif>
        </client>
        <cover>
            <excess>#StructFind(theData,ListFirst(CONST_MQ_ExcessOpt_FID,"|"))#</excess>
            <cfset aCover = StructFind(coverOpts,"FEE_ADMIN")>
            <cfset totalPremium = aCover.total>
            <adminFee>
                <total>#NumberFormat(aCover.total,",.99")#</total>
                <base>#NumberFormat(aCover.base,",.99")#</base>
                <gst>#NumberFormat(aCover.GST,",.99")#</gst>
            </adminFee>
            
            <cfset printedCover = "">
            <cfloop collection="#allCoversStruct#" item="anItem">
                <cfset aCover = StructFind(allCoversStruct,anItem)>
                <cfif not StructKeyExists(aCover,"parent_id") or StructFind(aCover,"parent_id") eq "">
                    <cfset totalPremium = totalPremium + aCover.totalPremium>
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
                    <cfset printedCover = ListAppend(printedCover,anItem)>
                <cfelse>
                    <cfset totalPremium = totalPremium + aCover.totalPremium>
                    <cfif ListFindNoCase(printedCover,aCover.parent_id) eq 0>
                        <product id="#aCover.parent_id#">
                            #StructFind(tmpStruct,aCover.parent_id)#
                        </product>
                        <cfset printedCover = ListAppend(printedCover,aCover.parent_id)>
                    </cfif>
                </cfif>
            </cfloop>
            <totalPremium>#totalPremium#</totalPremium>
        </cover>
        </cfoutput></cfsavecontent>
        
        <cfset xmlResponse = createXMLPackage(xmlContent="#theContent#",responseType="COVERBOUND",idStruct=thirdgenDetailsStruct)>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=thirdgenDetailsStruct.intDataID
            ,responseXML=XmlParse(xmlResponse)
            ,note="Cover Bound"
            )>

        <cfoutput>#xmlResponse#</cfoutput>
        <cftry>
            <cfset attributes.fdid = getFormData.form_data_id>
            <cfset attributes.format = "pdfEmail">
            <cfset attributes.redir = "">
            <!--- <cfset attributes.debugEmail = "david@3rdmill.com.au"> --->
            <cfinclude template="inc_admin_printCoverBound.cfm">
            <cfcatch type="any">
       
            </cfcatch>
        </cftry>
    </cfif>
</cfif>

<cfif ArrayLen(outerErrorArray) gt 0>
    <cfset xmlResponse = createXMLPackage(errorMsg=outerErrorArray[1],responseType="COVERBOUND",idStruct=thirdgenDetailsStruct)>
    <cfif IsDefined("thirdgenDetailsStruct.intDataID")>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=thirdgenDetailsStruct.intDataID
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Cover Bound"
            )>
    <cfelse>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Cover Bound"
            )>
    </cfif>
   
    <cfoutput>#xmlResponse#</cfoutput>
</cfif>

