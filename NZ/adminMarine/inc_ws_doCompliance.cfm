<!--- 
sample:
========
<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Marine</clientType>
</header>
<request type="COMPLIANCE">
    <id>
        <refId>82583<refId> <!--- this is mandatory for compliance ! --->
        <extRefId provider="YMF">Y9IA801279<extRefId>
        <extDealer id="YMINZ001">Auckland Test Marine</extDealer>
        <extUser id="987564">John.Citizen</extUser>
    </id>    
    <client>
        <firstname>John</firstname>
        <lastname>Citizen</lastname>
        <email>j.citizen@gmail.com</email>
        <compliance>
            <declaration id="hasRefused">false</declaration> <!--- Has the insured(s) ever had any insurance refused or cancelled?  --->
            <declaration id="hasClaims">false</declaration> <!--- Has the insured had any boat or any theft claims in the last five years?  --->
            <declaration id="hasConvicted">false</declaration> <!--- Has the insured been convicted of any offence in the last five years?  --->
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
    <cfset MarineQuoteStruct = StructNew()>
    
    <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_def_id, fd.form_data_id, fd.xml_data, fd.last_updated
    from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
    </cfquery>
    <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="MarineQuoteStruct">
    <cfif StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|")) eq CONST_MQ_QuoteStatus_stage3_LID
        or StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|")) eq CONST_MQ_QuoteStatus_stage4_LID>
        <cfset allowComplianceEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - no longer QUOTE STAGE")>
    </cfif>
    
    <!--- can't edit if it has compliance-override attached --->
    <cfif StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_ignoreCompl_FID,"|")) eq 1> 
        <cfset allowComplianceEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - compliance-override has been applied")>
    </cfif>
    
    <!--- can't edit if it has been manually adjusted internally --->
    <cfif StructKeyExists(MarineQuoteStruct,ListFirst(CONST_MQ_manualEditor_FID,"|"))
        and StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_manualEditor_FID,"|")) neq ""> 
        <cfset allowQuoteEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - manual-edit has been applied")> 
    </cfif>
    
    
    <cfif DateDiff("d",getformData.last_updated ,now()) gt CONST_QUOTE_VALIDITY>
        <cfset allowComplianceEdit = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Outside #CONST_QUOTE_VALIDITY# days quote validity period")>
    </cfif>
        
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
                    <cfset x = evaluate("data_"&aDecl.XmlAttributes.id&" = "& tmpStr)> <!--- hasRefused | hasClaims | hasConvicted --->
                </cfloop>
            </cfif>
            <cfcatch type="Any">
                <cfset allowComplianceEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MARINE/CLIENT", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfif allowComplianceEdit>
        <cftry>
            <!--- quote form fields (start) --->
            <cfif IsDefined("data_hasRefused")>
                <cfset x = StructInsert(MarineQuoteStruct,ListFirst(CONST_MQ_hadInsuranceRefused_FID,"|"), data_hasRefused,true)>
            </cfif>
            <cfif IsDefined("data_hasClaims")>
                <cfset x = StructInsert(MarineQuoteStruct,ListFirst(CONST_MQ_hadClaims_FID,"|"), data_hasClaims,true)>
            </cfif>
            <cfif IsDefined("data_hasConvicted")>
                <cfset x = StructInsert(MarineQuoteStruct,ListFirst(CONST_MQ_hadChargedWithOffence_FID,"|"), data_hasConvicted,true)>
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
                <cfwddx action="CFML2WDDX" input="#MarineQuoteStruct#" output="MarineQuoteStructWDDX">
                
                <!--- NOTE: this MUST NOT updated LAST_UPDATED date --->
                <cfquery name="updateQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        	    update thirdgen_form_data
        	    set xml_data = '#MarineQuoteStructWDDX#'
        	    where form_data_id = #thirdgenDetailsStruct.intDataID#
                
                update thirdgen_form_header_data
        	    set form_def_id = form_def_id
                <cfif IsDefined("data_hasRefused")>
                , #ListLast(CONST_MQ_hadInsuranceRefused_FID,"|")# = #data_hasRefused#
                </cfif>
                <cfif IsDefined("data_hasClaims")>
                , #ListLast(CONST_MQ_hadClaims_FID,"|")# = #data_hasClaims#
                </cfif>
                <cfif IsDefined("data_hasConvicted")>
                , #ListLast(CONST_MQ_hadChargedWithOffence_FID,"|")# = #data_hasConvicted#
                </cfif>
        	    where form_data_id = #thirdgenDetailsStruct.intDataID#
        	    </cfquery>
                
                <cfmodule template="mod_refresh_valueTables.cfm" formDefID="#CONST_marineQuoteFormDefId#" formDataID="#thirdgenDetailsStruct.intDataID#">
            
                <!--- RE-QUERY QUOTE DATA STRUCT! --->
                <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                select fd.form_def_id, fd.form_data_id, fd.xml_data
                from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
                </cfquery>
                <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="MarineQuoteStruct">
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
        <!--- <cfmodule template="../thirdgen/form/mod_get_form_data.cfm"
            formDefID = "#CONST_marineQuoteFormDefId#"
            formDataId = "#getFormData.form_data_id#"
            output="theData"> --->
    
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
        
        
    
        <cfsavecontent variable="theContent"><cfoutput>
        <marine>
            <boatDetails>
                <make>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_BoatMake_FID,"|"))#</make>
                <model>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_BoatModel_FID,"|"))#</model>
                <type>#list_boatType#</type>
                <year>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_HullYear_FID,"|"))#</year>
                <construction>#list_boatConst#</construction>
                <inProd>#data_boatIsProd#</inProd>
                <length>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_HullLength_FID,"|"))#</length> 
            </boatDetails>
            <motorDetails>
                <make>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_MotorMake_FID,"|"))#</make>
                <year>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_Motor_Year_FID,"|"))#</year>
                <type>#list_motorType#</type>
                <fuelType>#list_motorFuel#</fuelType>
                <hp>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_MotorHP_FID,"|"))#</hp> 
                <speedMax>#list_motorSpeed#</speedMax>
            </motorDetails>
        </marine>
        <client>
            <firstname>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_FirstName_FID,"|"))#</firstname>
            <lastname>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_Surname_FID,"|"))#</lastname>
            <email>#StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_Email_FID,"|"))#</email>
        </client>
        <options>
            <cfif StructFind(MarineQuoteStruct,ListFirst(CONST_MQ_ignoreCompl_FID,"|")) neq 1
                and
                (
                    (IsDefined("data_hasRefused") and data_hasRefused eq 1)
                    or (IsDefined("data_hasClaims") and data_hasClaims eq 1)
                    or (IsDefined("data_hasConvicted") and data_hasConvicted eq 1)
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

