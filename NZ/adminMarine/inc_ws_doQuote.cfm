<!--- 
SAMPLE:
========

<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Marine</clientType>
</header>
<request type="QUOTE">
    <id>
        <refId>82583<refId> 
        <extRefId provider="YMSI">Y9IA801279</extRefId>
        <extDealer id="YMINZ001">Auckland Test Marine</extDealer>
        <extUser id="987564">John.Citizen</extUser>
    </id>    
    <client>
        <firstname>John</firstname>
        <lastname>Citizen</lastname>
        <email>j.citizen@gmail.com</email>
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
    <cfif not isDefined("tmpXML.XmlAttributes.type") OR CompareNoCase(tmpXML.XmlAttributes.type,"QUOTE") neq 0>
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
    
    <cfset allowQuoteEdit = true>
    <cfset BoatQuoteStruct = StructNew()>
    
    <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_def_id, fd.form_data_id, fd.xml_data, fd.last_updated
    from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
    </cfquery>
    <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BoatQuoteStruct">
    <cfif StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|")) eq CONST_MQ_QuoteStatus_stage3_LID
        or StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|")) eq CONST_MQ_QuoteStatus_stage4_LID>
        <cfset allowQuoteEdit = false>
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
        <cfset allowQuoteEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Formal Quote is not allowed - compliance issue")>
    </cfif>
    
    <!--- can't edit if it has been manually adjusted internally --->
    <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_manualEditor_FID,"|"))
        and StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_manualEditor_FID,"|")) neq ""> 
        <cfset allowQuoteEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Formal Quote is not allowed - manual-edit has been applied")> 
    </cfif>
    
    <cfif DateDiff("d",getformData.last_updated ,now()) gt CONST_QUOTE_VALIDITY>
        <cfset allowQuoteEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Outside #CONST_QUOTE_VALIDITY# days quote validity period")>
    </cfif>
    
    <cftry>
        <cfset tempXML = theCurrentXml.NMPackage.request.client>
        <cfset data_firstname = trim(tempXML.firstname.XmlText)>
        <cfset data_lastname = trim(tempXML.lastname.XmlText)>
        <cfset data_email = trim(tempXML.email.XmlText)>
        
        <cfif data_firstname eq "" or data_lastname eq "" or data_email eq "">
            <cfset allowQuoteEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE")>
        </cfif>

        <cfcatch type="Any">
            <cfset allowQuoteEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MARINE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>

    <cfif allowQuoteEdit>
        <cftry>
            <cfset coverSelection = ArrayNew(1)>
            <cfset tempXML = theCurrentXml.NMPackage.request.cover>
            
            <cfloop index="aProd" array="#xmlsearch(tempXML,'product')#">
                <cfif StructKeyExists(aProd,"subproduct")> <!--- this is CASE-INSENSITIVE search! --->
                    <cfloop index="aSubProd" array="#xmlsearch(aProd,'subProduct')#">
                        <cfset x = ArrayAppend(coverSelection,aProd.XmlAttributes.id&"|"&aSubProd.XmlAttributes.id)>
                    </cfloop>
                <cfelse>
                    <cfset x = ArrayAppend(coverSelection,aProd.XmlAttributes.id)>
                </cfif>
            </cfloop>
           
            <cfif ArrayLen(coverSelection) eq 0>
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - No cover products selected", "")>
            </cfif>
            
            <cfcatch type="Any">
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MARINE/CLIENT", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfif allowQuoteEdit>
        <cftry>
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
                                    <cfset allowQuoteEdit = false>
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
                                    <cfset allowQuoteEdit = false>
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
                            <cfset theCoverID = ListFirst(StructFind(tmpStruct,"int_code"),"|")> <!--- some of the product has multiple LID's --->
                            
                            <cfif CompareNoCase(ListFirst(aCover,"|"),"LP") eq 0> <!--- LP is a combination of sub-products --->
                                <cfset LP_int_code = theCoverID>
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
                                <cfset allCovers = ListAppend(allCovers, theCoverID)>
                                <cfsavecontent variable="tmpStr"><cfoutput>
                                ^ #tmpStruct.coverName# <cfif StructKeyExists(tmpStruct,"details")>(#StructFind(tmpStruct,"details")#)</cfif> - 
                                Base: $#tmpStruct.base#;
                                GST: $#tmpStruct.gst#;<br/>
                                </cfoutput></cfsavecontent>
                                <cfset allCoversDetails = allCoversDetails & APPLICATION.NEWLINE & trim(Replace(tmpStr, "  "," ","ALL"))>
                            
                                <cfif CompareNoCase(ListFirst(aCover,"|"),"GAP") eq 0>
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
                
                <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|"), CONST_MQ_QuoteStatus_stage2_LID,true)>    
            </cfif>
            
            <cfif ArrayLen(outerErrorArray) eq 0>
                <cfwddx action="CFML2WDDX" input="#BoatQuoteStruct#" output="BoatQuoteStructWDDX">
                
                <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        	    update thirdgen_form_data
        	    set xml_data = '#BoatQuoteStructWDDX#', last_updated = #CreateODBCDateTime(now())#
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
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot update QUOTE", cfcatch.message)>
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
        
        <cfset xmlResponse = createXMLPackage(xmlContent="#theContent#",responseType="QUOTE",idStruct=thirdgenDetailsStruct)>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=thirdgenDetailsStruct.intDataID
            ,responseXML=XmlParse(xmlResponse)
            ,note="Formal Quote"
            )>

        <cfoutput>#xmlResponse#</cfoutput>
        <!--- Send email to the dealer --->
        <cftry>
            <cfset attributes.fdid = getFormData.form_data_id>
            <cfset attributes.format = "pdfEmailOnly">
            <cfset attributes.redir = "">
            <!--- <cfset attributes.debugEmail = "david@3rdmill.com.au"> --->
            <cfinclude template="inc_admin_printQuote.cfm">
            <cfcatch type="any">
                <!--- <cfdump var="#cfcatch#"> --->
            </cfcatch>
        </cftry>
        
    </cfif>
    
</cfif>

<cfif ArrayLen(outerErrorArray) gt 0>
    <cfset xmlResponse = createXMLPackage(errorMsg=outerErrorArray[1],responseType="QUOTE",idStruct=thirdgenDetailsStruct)>
    <cfif IsDefined("thirdgenDetailsStruct.intDataID")>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=thirdgenDetailsStruct.intDataID
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Formal Quote"
            )>
    <cfelse>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Formal Quote"
            )>
    </cfif>
   
    <cfoutput>#xmlResponse#</cfoutput>
</cfif>