<!--- 
sample:
========
<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Motorcycle</clientType>
</header>
<request type="COMPLIANCE">
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
    </motorcycle>
    <client>
        <firstname>John</firstname>
        <lastname>Citizen</lastname>
        <email>j.citizen@gmail.com</email>
       
        <compliance>
            <declaration id="hasRefused">false</declaration> <!--- Has the insured(s) in the last 5 years had any insurance refused or cancelled?  --->
            <declaration id="hasClaims">false</declaration> <!--- Has the insured(s) in the last 5 years suffered any motorcycle or theft insurance claims?  --->
            <declaration id="hasConvicted">false</declaration> <!--- Has the insured(s) in the last 5 years been charged of convicted of any offence (other than vehicle/motorcycle offences)?  --->
            <declaration id="hasSuspended">false</declaration> <!--- Has the insured(s) in the last 5 years ever had their motor vehicle or motorcycle license suspended or revoked for any reason?  --->
            <declaration id="hasValidLicense">true</declaration>  <!--- Do you hold a current/valid New Zealand Motorcycle License? --->  
            <declaration id="isBusinessUse">true</declaration>    <!--- Is the Motorcycle used for any business/ commercial use? --->
        </compliance>
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
    <cfif not isDefined("tmpXML.XmlAttributes.type") OR CompareNoCase(tmpXML.XmlAttributes.type,"COMPLIANCE") neq 0>
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

<!--- CHECK EXISTING DATA --->
<cfif ArrayLen(outerErrorArray) eq 0>
    <cfset tmpStr = getWebServiceTempData(form_data_id=thirdgenDetailsStruct.intDataID
        ,data_type="COVER_OPTIONS"
        ,requester_id=thirdgenDetailsStruct.extDataProvider
        ,external_id=thirdgenDetailsStruct.extDataID
        )> 
        
    <cfif trim(tmpStr) eq "">
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot find cover options for (Ext-Ref:"&thirdgenDetailsStruct.extDataID&") and (Int-Ref:" & thirdgenDetailsStruct.intDataID & ")")>
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
        
    <cfset allowComplianceEdit = true>
    <cfset BikeQuoteStruct = StructNew()>
    
    <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_def_id, fd.form_data_id, fd.xml_data, fd.last_updated
    from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
    </cfquery>
    <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BikeQuoteStruct">
    <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_QuoteStatus_FID,"|")) eq CONST_BQ_QuoteStatus_stage3_LID
        or StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_QuoteStatus_FID,"|")) eq CONST_BQ_QuoteStatus_stage4_LID>
        <cfset allowComplianceEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - no longer QUOTE STAGE")>
    </cfif>
    
    <!--- can't edit if it has compliance-override attached --->
    <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_ignoreCompl_FID,"|")) eq 1> 
        <cfset allowComplianceEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - compliance-override has been applied")>
    </cfif>
    
    <!--- can't edit if it has been manually adjusted internally --->
    <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_manualEditor_FID,"|"))
        and StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_manualEditor_FID,"|")) neq ""> 
        <cfset allowQuoteEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - manual-edit has been applied")> 
    </cfif>
    
    
    <cfif DateDiff("d",getformData.last_updated ,now()) gt CONST_QUOTE_VALIDITY>
        <cfset allowComplianceEdit = false>
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
            <cfquery name="getBikeData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
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
            <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
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

        <cfcatch type="Any">
            <cfset allowComplianceEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MOTORYCLE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>
    
    <cfif allowComplianceEdit>
        <cftry>
            <cfset tempXML = theCurrentXml.NMPackage.request.client>
            <cfif IsDefined("tempXML.compliance")>
                <cfloop index="aDecl" array="#xmlsearch(tempXML.compliance,'declaration')#">
                    <cfset tmpStr = trim(aDecl.XmlText)>
                    <cfif tmpStr>
                        <cfset tmpStr = 1>
                    <cfelse>
                        <cfset tmpStr = 0>
                    </cfif>
                    <cfset x = evaluate("data_"&aDecl.XmlAttributes.id&" = "& tmpStr)> <!--- hasRefused | hasClaims | hasConvicted | hasSuspended  --->
                </cfloop>
            </cfif>
            <cfcatch type="Any">
                <cfset allowComplianceEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MOTORYCLE/CLIENT", cfcatch.message)>
            </cfcatch>
        </cftry>
    
        <cfif allowComplianceEdit>
            <cftry>
                <!--- quote form fields (start) --->
                <cfif IsDefined("data_hasRefused")>
                    <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_InsRefCan_FID,"|"), data_hasRefused,true)>
                </cfif>
                <cfif IsDefined("data_hasClaims")>
                    <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_Claims_FID,"|"), data_hasClaims,true)>
                </cfif>
                <cfif IsDefined("data_hasConvicted")>
                    <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_Charged_FID,"|"), data_hasConvicted,true)>
                </cfif>
                <cfif IsDefined("data_hasSuspended")>
                    <cfset x = StructInsert(BikeQuoteStruct,ListFirst(CONST_BQ_Suspended_FID,"|"), data_hasSuspended,true)>
                </cfif>
                <cfif IsDefined("data_hasValidLicense")>
                    <cfset x = StructInsert(BikeQuoteStruct,"QD_Is_CurrentValid_License", data_hasValidLicense,true)>
                </cfif>
                <cfif IsDefined("data_isBusinessUse")>
                    <cfset x = StructInsert(BikeQuoteStruct,"QD_Is_BusinessUse", data_isBusinessUse,true)>
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
                <!--- quote form fields (end) --->
                
                <cfif ArrayLen(outerErrorArray) eq 0>
                    <cfwddx action="CFML2WDDX" input="#BikeQuoteStruct#" output="BikeQuoteStructWDDX">
                    
                    <!--- NOTE: this MUST NOT updated LAST_UPDATED date --->
                    <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            	    update thirdgen_form_data
            	    set xml_data = '#BikeQuoteStructWDDX#'
            	    where form_data_id = #thirdgenDetailsStruct.intDataID#
                    
                    update thirdgen_form_header_data
            	    set form_def_id = form_def_id
                    <cfif IsDefined("data_hasRefused")>
                    , #ListLast(CONST_BQ_InsRefCan_FID,"|")# = #data_hasRefused#
                    </cfif>
                    <cfif IsDefined("data_hasClaims")>
                    , #ListLast(CONST_BQ_Claims_FID,"|")# = #data_hasClaims#
                    </cfif>
                    <cfif IsDefined("data_hasConvicted")>
                    , #ListLast(CONST_BQ_Charged_FID,"|")# = #data_hasConvicted#
                    </cfif>
                    <cfif IsDefined("data_hasSuspended")>
                    , #ListLast(CONST_BQ_Suspended_FID,"|")#  = #data_hasSuspended#
                    </cfif>
            	    where form_data_id = #thirdgenDetailsStruct.intDataID#
            	    </cfquery>
                    
                    <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#CONST_bikeQuoteFormDefId#" formDataID="#thirdgenDetailsStruct.intDataID#">
                
                    <!--- RE-QUERY QUOTE DATA STRUCT! --->
                    <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                    select fd.form_def_id, fd.form_data_id, fd.xml_data
                    from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
                    </cfquery>
                    <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BikeQuoteStruct">
                </cfif> 
                
                <cfcatch type="Any">
                    <cfset allowCoverBoundEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot insert/update COMPLIANCE", cfcatch.message)>
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
            </client>
            <options>
                <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_ignoreCompl_FID,"|")) neq 1
                    and
                    (
                        (IsDefined("data_hasRefused") and data_hasRefused eq 1)
                        or (IsDefined("data_hasClaims") and data_hasClaims eq 1)
                        or (IsDefined("data_hasConvicted") and data_hasConvicted eq 1)
                        or (IsDefined("data_hasSuspended") and data_hasSuspended eq 1) 
                        or (IsDefined("data_isBusinessUse") and data_isBusinessUse eq 1)                                                                         
                    )
                    >
                    #createErrorElem("COMPLIANCE","Referral due to compliance")#
                <cfelse>
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
                            
                            <cfif (IsDefined("data_hasValidLicense") and data_hasValidLicense eq 0) and anItem eq "COMP">
                            
                            <cfelse> 
                            
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
                                
                             </cfif>
                             
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
                </cfif>
            </options>
            </cfoutput></cfsavecontent>
            
            <cfset xmlResponse = createXMLPackage(xmlContent="#theContent#",responseType="QUOTE",idStruct=thirdgenDetailsStruct)>
            <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
                ,form_data_id=thirdgenDetailsStruct.intDataID
                ,responseXML=XmlParse(xmlResponse)
                ,note="Compliance"
                )>
            <cfoutput>#xmlResponse#</cfoutput>
            
        </cfif>
        
    </cfif>
    
</cfif>

<cfif ArrayLen(outerErrorArray) gt 0>
    <cfset xmlResponse = createXMLPackage(errorMsg=outerErrorArray[1],responseType="COMPLIANCE",idStruct=thirdgenDetailsStruct)>
    <cfif IsDefined("thirdgenDetailsStruct.intDataID")>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=thirdgenDetailsStruct.intDataID
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Compliance"
            )>
    <cfelse>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Compliance"
            )>
    </cfif>
   
    <cfoutput>#xmlResponse#</cfoutput>
</cfif>

