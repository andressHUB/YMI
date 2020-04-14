<!--- 
SAMPLE:
========
<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Motorcycle</clientType>
</header>
<request type="COVERBOUND">
    <id>
        <refId>82583<refId> <!--- this is mandatory for compliance ! --->
        <extRefId provider="YMF">Y9IA801279<extRefId>
        <extDealer id="D999">Bailey Motorcycles Ltd</extDealer>
        <extUser id="9865">craig.bailey</extUser>
    </id>    
    <motorcycle>
        <glassDetails>
            <make>HONDA</make>
            <nvic>2XL02E</nvic>
            <code>HON-50CH-2002XL2002E</code>
        </glassDetails>
        <otherDetails></otherDetails>
        
        <serialNumbers>
            <serialNumber type="VIN">NHIJ-90912431444</serialNumber>
            <serialNumber type="ENGINENO">9018912389XX</serialNumber>
        </serialNumbers>
        <datePurchased>2013-09-04Z</datePurchased>
        <isMod>false</isMod> <!--- Has the motorcycle been modified in any way from the manufacturers original specifications --->
        <isModDetails></isModDetails> <!--- Modification details:  --->
        <isSuitableCond>true</isSuitableCond> <!--- Is the motorcycle fit for purpose?  --->
        <isSuitableCondDetails></isSuitableCondDetails> <!--- Non-fit details: --->
        <purchasedPrice>5100.00</purchasedPrice> <!--- Purchase Price:  --->
        <isNew>true</isNew> <!--- Is this a new motorcycle (first time purchased)?  --->
    </motorcycle>
    <client>
        <firstname>John</firstname>
        <lastname>Citizen</lastname>
        <email>j.citizen@gmail.com</email>
        
        <coverStartDate>2013-09-05Z</coverStartDate> <!--- Cover Commencement Date:  --->
        <address>258 Woop Street</address>
        <addressPostcode>2035</addressPostcode>
        <storageAddress></storageAddress>
        <homephone>987654321</homephone>
        <occupation>Truckies</occupation>
        <financier>YMF Australia</financier>
    </client>
    <cover>
        <product id="COMP"/>
        <product id="GAP">
            <subProduct id="GAP-OPT1"/>
        </product>
        <product id="LP">
            <subProduct id="LP-UNEMPLOY"/>
            <subProduct id="LP-LIFE"/>
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
    <cfset BikeQuoteStruct = StructNew()>
    
    <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_def_id, fd.form_data_id, fd.xml_data, fd.last_updated
    from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
    </cfquery>
    <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BikeQuoteStruct">
    <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_QuoteStatus_FID,"|")) eq CONST_BQ_QuoteStatus_stage3_LID
        or StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_QuoteStatus_FID,"|")) eq CONST_BQ_QuoteStatus_stage4_LID>
        <cfset allowCoverBoundEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Quote has already been bound")> 
    </cfif>
    <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_ignoreCompl_FID,"|")) neq 1
        and
        (
            StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_InsRefCan_FID,"|")) eq 1
            or StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Claims_FID,"|")) eq 1
            or StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Charged_FID,"|")) eq 1
            or StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Suspended_FID,"|")) eq 1
            or (IsDefined("BikeQuoteStruct.QD_Is_BusinessUse") and BikeQuoteStruct.QD_Is_BusinessUse eq 1)
        )
        >
        <cfset allowCoverBoundEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cover bound is not allowed - compliance issue")>
    </cfif>
    
    <!--- can't edit if it has been manually adjusted internally --->
    <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_manualEditor_FID,"|"))
        and StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_manualEditor_FID,"|")) neq ""> 
        <cfset allowCoverBoundEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cover bound is not allowed - manual-edit has been applied")> 
    </cfif>
    
    <cfif DateDiff("d",getformData.last_updated ,now()) gt CONST_QUOTE_VALIDITY>
        <cfset allowCoverBoundEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Outside #CONST_QUOTE_VALIDITY# days quote validity period")>
    </cfif>
    
    <cftry>
        <cfset tempXML = theCurrentXml.NMPackage.request.motorcycle>
        <cfif IsDefined("tempXML.glassDetails")>
            <cfset data_bikeModel = trim(tempXML.glassDetails.NVIC.XmlText)>
            <cfset data_bikeCustomMake = "">
            <cfset data_bikeCustomStyle = "">
            <cfset data_bikeCustomYear = "">
            <cfset data_bikeCustomDetail = "">
            <cfquery name="getBikeData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
            select fd.form_data_id, fd.xml_data
            from thirdgen_form_data fd with (nolock)
            inner join thirdgen_form_header_data fhd with (nolock) on fd.form_data_id = fhd.form_data_id 
                and fd.form_def_id = #CONST_bikeDataFormDefId# and fhd.text1 = '#data_bikeModel#'
            </cfquery>
            <cfif getBikeData.xml_data neq "">
                <cfwddx action="WDDX2CFML" input="#getBikeData.xml_data#" output="bikeDataStruct">	
            </cfif>
        <cfelse>
            <cfset data_bikeModel = -1>
            <cfset data_bikeCustomMake = trim(tempXML.customDetails.make.XmlText)>
            <cfset data_bikeCustomYear = trim(tempXML.customDetails.year.XmlText)>
            <cfset data_bikeCustomDetail = trim(tempXML.customDetails.model.XmlText)>
            <cfset data_bikeCustomStyle = trim(tempXML.customDetails.type.XmlText)>
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_id, list_item_display, list_item_image
            from thirdgen_list_item
            where list_id = #CONST_BQ_BikeStyle_ListID#
            and list_item_display like '#data_bikeCustomStyle#'
            </cfquery>
            <cfset data_bikeCustomStyle = getListItem.list_item_id>
        </cfif>
        
        <cfset tempXML = theCurrentXml.NMPackage.request.client>
        <cfset data_firstname = trim(tempXML.firstname.XmlText)>
        <cfset data_lastname = trim(tempXML.lastname.XmlText)>
        <cfset data_email = trim(tempXML.email.XmlText)>
        
        <cfif data_firstname eq "" or data_lastname eq "" or data_email eq "">
            <cfset allowCoverBoundEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MOTORYCLE")>
        </cfif>

        <cfcatch type="Any">
            <cfset allowCoverBoundEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MOTORYCLE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>
    
    <cfif allowCoverBoundEdit>
        <cftry>
            <cfset tempXML = theCurrentXml.NMPackage.request.motorcycle>
            <cfset data_REGONO=""> <!--- Regno may not be provided for off-road only --->
            <cfloop index="aSerialNo" array="#xmlsearch(tempXML.serialNumbers,'serialNumber')#">
                <cfset x = evaluate("data_"&aSerialNo.XmlAttributes.type&" = """& aSerialNo.XmlText & """")> <!--- VIN | REGONO | ENGINENO  --->
            </cfloop>
            
			
			<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value)  datePurchased was moved to getQuote--->
			<cfset data_datePurchased = "">
            <!--- <cfset data_datePurchased = trim(tempXML.datePurchased.XmlText)> 
            <cfset data_datePurchased = XMLToCF_dateTime(data_datePurchased)> --->
			<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value)  datePurchased was moved to getQuote--->
			
			
            <cfset data_isMod  = trim(tempXML.isMod.XmlText)>
            <cfif data_isMod>
                <cfset data_isMod = 1>
            <cfelse>
                <cfset data_isMod = 0>
            </cfif>
            <cfset data_isModDetails  = trim(tempXML.isModDetails.XmlText)>
            <cfset data_isSuitableCond  = trim(tempXML.isSuitableCond.XmlText)>
            <cfif data_isSuitableCond>
                <cfset data_isSuitableCond = 1>
            <cfelse>
                <cfset data_isSuitableCond = 0>
            </cfif>
            <cfset data_isSuitableCondDetails = "">
            <cfif StructKeyExists(tempXML,"isSuitableCondDetails") and trim(tempXML.isSuitableCondDetails.XmlText) neq "">
                <cfset data_isSuitableCondDetails  = trim(tempXML.isSuitableCondDetails.XmlText)>
            </cfif>
            <cfset data_purchasedPrice = trim(tempXML.purchasedPrice.XmlText)>
            <cfif LSParseNumber(data_purchasedPrice) lt 1>
                <cfset data_purchasedPrice = "">
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid value on price field")>
            </cfif>
            <cfset data_isNew = 0>
            <cfif StructKeyExists(tempXML,"isNew") and trim(tempXML.isNew.XmlText) neq "">
                <cfset data_isNew = trim(tempXML.isNew.XmlText)>
                <cfif data_isNew>
                    <cfset data_isNew = 1>
                <cfelse>
                    <cfset data_isNew = 0>
                </cfif>
            </cfif>
            
            <cfset tempXML = theCurrentXml.NMPackage.request.client>
            <cfset data_coverStartDate = trim(tempXML.coverStartDate.XmlText)> 
            <cfset data_coverStartDate = XMLToCF_dateTime(data_coverStartDate)>
            <cfset data_address = trim(tempXML.address.XmlText)>
            <cfset data_addressPostcode = trim(tempXML.addressPostcode.XmlText)>
            <cfset data_storageAddress = trim(tempXML.storageAddress.XmlText)>
            <cfset data_homephone = trim(tempXML.homephone.XmlText)>
            <cfset data_occupation = trim(tempXML.occupation.XmlText)>
            <cfset data_financier = trim(tempXML.financier.XmlText)>
            
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

            
            <cfif data_isMod eq 1 and data_isModDetails eq "">
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Require modification details", "")>
            </cfif>
            
            <cfif data_isSuitableCond eq 0>
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Non-fit motorcycle", "")>
            </cfif>
                        
            <cfif ArrayLen(coverSelection) eq 0>
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - No cover products selected", "")>
            </cfif>
            
            <cfif DateDiff("d",now(),data_coverStartDate) lt 0>
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Invalid Cover start date", "")>
            </cfif>
            
			<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value)  datePurchased was moved to getQuote--->
			<cfif data_datePurchased neq ""> <!--- OPTIONAL --->
	            <cfif DateDiff("d",now(),data_datePurchased) gt 0> <!--- CANNOT BE FUTURE --->
	                <cfset allowCoverBoundEdit = false>
	                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid Date Purchased")>
	            </cfif>
			</cfif>	
			<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value)  datePurchased was moved to getQuote--->
            
            <cfcatch type="Any">
                <cfset allowCoverBoundEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MOTORYCLE/CLIENT", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfif allowCoverBoundEdit>
        <cftry>
            <!--- <cfset attributes.formDefID = CONST_bikeQuoteFormDefId>
            <cfset attributes.siteID = thirdgenDetailsStruct.siteID>
            <cfset attributes.regUserID = thirdgenDetailsStruct.userID>
            <cfset attributes.treeNodeID = thirdgenDetailsStruct.defaultTreeNodeID>
            <cfset attributes.formDataID = thirdgenDetailsStruct.intDataID> 
            <cfset attributes.formAction = "edit"> --->
    
            
            <!--- quote form fields (start) --->
			<cfif data_datePurchased neq ""> <!--- OPTIONAL --->
            	<cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_PurchasedDate_FID,"|"), DateFormat(data_datePurchased,"DD/MM/YYYY"),true)>
			</cfif>	
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_IsModified_FID,"|"), data_isMod,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_ModifiedDesc_FID,"|"), data_isModDetails,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_IsUsable_FID,"|"), data_isSuitableCond,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_UsableDesc_FID,"|"), data_isSuitableCondDetails,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_PurchasePrice_FID,"|"), data_purchasedPrice,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_NewMotorcycle_FID,"|"), data_isNew,true)>
            
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_RegoNo_FID,"|"), data_REGONO,true)>
            
            <cfset tmpStr = "">
            <cfif IsDefined("data_VIN")>
                <cfset tmpStr = ListAppend(tmpStr,data_VIN)>
            </cfif>
            <cfif IsDefined("data_ENGINENO")>
                <cfset tmpStr = ListAppend(tmpStr,data_ENGINENO)>
            </cfif>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_VinNo_FID,"|"), tmpStr,true)>
            
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_CoverCommDate_FID,"|"), DateFormat(data_coverStartDate,"DD/MM/YYYY"),true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_InsuredAddStreet_FID,"|"), data_address,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_InsuredAddPost_FID,"|"), data_addressPostcode,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_StorageAddress_FID,"|"), data_storageAddress,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_Homephone_FID,"|"), data_homephone,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_Occupation_FID,"|"), data_occupation,true)>
            <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_InterestedParties_FID,"|"), data_financier,true)>
            
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
			
			<!--- Restrict Non licence holders access to comprehensive cover --->
			<cfif IsDefined("BikeQuoteStruct.QD_Is_CurrentValid_License") and BikeQuoteStruct.QD_Is_CurrentValid_License neq "">
				<cfif BikeQuoteStruct.QD_Is_CurrentValid_License eq 0>
						<cfif ArrayContains(coverSelection,"COMP")>							
								<cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Comprehensive cover is not offered for non-licence holders.")>							
						</cfif>
				</cfif>			
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
                            
                            <cfif CompareNoCase(ListFirst(aCover,"|"),"LP") eq 0> <!--- LP is a combination of sub-products --->
                                <cfset LP_int_code = StructFind(tmpStruct,"int_code")>
                                <cfset LP_totalBase = LP_totalBase + tmpStruct.base>
                                <cfset LP_totalGST = LP_totalGST + tmpStruct.gst>
                                
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
                                <cfset allCovers = ListAppend(allCovers, StructFind(tmpStruct,"int_code"))>
                                <cfsavecontent variable="tmpStr"><cfoutput>
                                ^ #tmpStruct.coverName# <cfif StructKeyExists(tmpStruct,"details")>(#StructFind(tmpStruct,"details")#)</cfif> - 
                                Base: $#tmpStruct.base#;
                                GST: $#tmpStruct.gst#;<br/>
                                </cfoutput></cfsavecontent>
                                <!--- <cfif StructFind(tmpStruct,"int_code") eq CONST_BQ_QuoteLoanProtect_ListItemID>(#StructFind(tmpStruct,"details")#)</cfif> --->
                                <cfset allCoversDetails = allCoversDetails & APPLICATION.NEWLINE & trim(Replace(tmpStr, "  "," ","ALL"))>
                                
                                <cfif CompareNoCase(ListFirst(aCover,"|"),"GAP") eq 0>
                                    <cfset selectExtra = "Sum Insured #tmpStruct.param#">
                                    <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_extraSelected_FID,"|"), selectExtra,true)>
                                    <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteGapCover_FID,"|"), tmpStruct.totalPremium,true)>
                                </cfif>
                            </cfif>
                            
                            <cfset fslFee = fslFee + tmpStruct.fsl>
                        </cfif>
                    </cfif>
                    
                </cfloop>
              
                <cfif LP_totalBase gt 1> <!--- if Loan Protection product was chosen --->
                    <cfset allCovers = ListAppend(allCovers, LP_int_code)>
                    <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteLoanProtect_FID,"|"), NumberFormat(LP_totalBase + LP_totalGST ,".99"),true)>
                    <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_loanProtectDetails_FID,"|"), LP_detailsPrem, true)>
                    <cfsavecontent variable="tmpStr"><cfoutput>
                    ^ Loan Protection (#LP_detailsPrem#) - 
                    Base: $#LP_totalBase#;
                    GST: $#LP_totalGST#;<br/>
                    </cfoutput></cfsavecontent>
                    <cfset allCoversDetails = allCoversDetails & APPLICATION.NEWLINE & trim(Replace(tmpStr, "  "," ","ALL"))>
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
                
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteSelected_FID,"|"), allCovers,true)>
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_quoteDetails_FID,"|"), allCoversDetails,true)>
                <!--- readjust EXCESS to $500 if TPO is chosen (NOTE: N/A in NZ ?!) --->
                <!--- <cfif ListFindNoCase(allCovers,CONST_BQ_QuoteTPO_ListItemID) gt 0>
                    <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_Excess_FID,"|"))>
            	         <cfset x = StructUpdate(BikeQuoteStruct,ListFirst(CONST_BQ_Excess_FID,"|"),"9458")>
            	    <cfelse>
            	         <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_Excess_FID,"|"),"9458")>
            	    </cfif>
                </cfif> --->
                
                <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_QuoteStatus_FID,"|"), CONST_BQ_QuoteStatus_stage3_LID,true)>
            </cfif>        
        
            <!--- quote form fields (end) --->
    
            <cfif ArrayLen(outerErrorArray) eq 0>
                <cfwddx action="CFML2WDDX" input="#BikeQuoteStruct#" output="BikeQuoteStructWDDX">
                
                <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        	    update thirdgen_form_data
        	    set xml_data = '#BikeQuoteStructWDDX#', last_updated = #CreateODBCDateTime(now())#
        	    where form_data_id = #thirdgenDetailsStruct.intDataID#
                
                update thirdgen_form_header_data
                set form_def_id = form_def_id
                <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_extraSelected_FID,"|"))>
                , #ListLast(CONST_BQ_extraSelected_FID,"|")# = '#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_extraSelected_FID,"|"))#'
                </cfif>
                <!--- readjust EXCESS to $500 if TPO is chosen (NOTE: N/A in NZ ?!) --->
                <!--- <cfif ListFindNoCase(allCovers,CONST_BQ_QuoteTPO_ListItemID) gt 0>
                ,#ListLast(CONST_BQ_Excess_FID,"|")# = '9458'
                </cfif> --->
                where form_data_id = #thirdgenDetailsStruct.intDataID#
                
        	    </cfquery>
                
                <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#CONST_bikeQuoteFormDefId#" formDataID="#thirdgenDetailsStruct.intDataID#">
            
                <!--- RE-QUERY QUOTE DATA STRUCT! --->
                <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
                select fd.form_def_id, fd.form_data_id, fd.xml_data
                from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
                </cfquery>
                <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BikeQuoteStruct">
                
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
            formDefID = "#CONST_bikeQuoteFormDefId#"
            formDataId = "#getFormData.form_data_id#"
            output="theData">
        
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
        <motorcycle>    
            <cfif data_bikeModel eq -1>
            <customDetails>
                <make>#data_bikeCustomMake#</make>
                <model>#data_bikeCustomDetail#</model>
                <year>#data_bikeCustomYear#</year>
                <type>#data_bikeCustomStyle#</type>
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
        <client>
            <firstname>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_FirstName_FID,"|"))#</firstname>
            <lastname>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Surname_FID,"|"))#</lastname>
            <email>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Email_FID,"|"))#</email>
            <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_TotLoanValue_FID,"|"))>
            <totalLoanVal>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_TotLoanValue_FID,"|"))#</totalLoanVal>
            </cfif>
        </client>
        <cover>
            <excess>#StructFind(theData,ListFirst(CONST_BQ_Excess_FID,"|"))#</excess>
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
        <!--- Send email to the dealer --->
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

