<!--- 
SAMPLE:
========

<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Motorcycle</clientType>
</header>
<request type="DOCUMENT">
    <id>
        <refId>82583<refId> <!--- this is mandatory  ! --->
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
    </client>
    <documents>
        <document type="QUOTESUMMARY"/>
        <document type="COVERSUMMARY"/>
        <document type="PBM"/>
        <document type="PDS"/>
    </documents>
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
    <cfif not isDefined("tmpXML.XmlAttributes.type") OR CompareNoCase(tmpXML.XmlAttributes.type,"DOCUMENT") neq 0>
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
        
    <cfset allowDocument = true>
    <cfset BikeQuoteStruct = StructNew()>
    
    <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#"password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.form_def_id, fd.form_data_id, fd.xml_data, fd.last_updated
    from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
    </cfquery>    
    <cfif getformData.recordCount gt 0>
        <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BikeQuoteStruct">
    <cfelse>
        <cfset allowDocument = false>
        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","No Application Data")>
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
        
        
        <cfset tempXML = theCurrentXml.NMPackage.request.documents>
        <cfset arrayPrintout = ArrayNew(1)>
        <cfloop index="aDoc" array="#xmlsearch(tempXML,'document')#">
            <cfset tmpStruct = StructNew()>
            <cfset x = StructInsert(tmpStruct,"TYPE",aDoc.XmlAttributes.type)> 
            <cfset x = ArrayAppend(arrayPrintout,tmpStruct)> 
        </cfloop>
        
        <cfif data_firstname eq "" or data_lastname eq "" or data_email eq "">
            <cfset allowDocument = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MOTORYCLE")>
        </cfif>
        
        <cfcatch type="Any">
            <cfset allowDocument = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MOTORYCLE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>
    
    <cfif allowDocument>
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
            
            <!--- GENERATE APPLICATION FORM (start) --->
            <cfset appFormsLoc = "#application.BASE_FOLDER#adminMotor\appforms\">
            
            <cfquery name="getDealerDetails" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                select tfhd.text1 as dealerName, tfhd.text2 as dealerCode, ufd.xml_data as uXML
                    ,tud.user_email, ufhd.text1 as firstname, ufhd.text2 as lastname, ufhd.text3 as phone
                from thirdgen_form_data tfd
                inner join thirdgen_user_control uc with (nolock) on tfd.user_data_id = uc.user_data_id and tfd.form_data_id = #thirdgenDetailsStruct.intDataID#
                inner join thirdgen_tree_node_data ttnd with (nolock) on uc.default_tree_node_id = ttnd.tree_node_id
                inner join thirdgen_form_header_data tfhd with (nolock) on ttnd.form_data_id = tfhd.form_data_id
                inner join thirdgen_user_data tud on uc.user_data_id = tud.user_data_id
                inner join thirdgen_form_data ufd on tud.user_data_id = ufd.user_data_id and ufd.registration_id = 1
                inner join thirdgen_form_header_data ufhd on ufd.form_data_id = ufhd.form_data_id
            </cfquery>
            <cfif getDealerDetails.recordCount>
                <cfwddx action="WDDX2CFML" input="#getDealerDetails.uXML#" output="userFDS">
            </cfif>
            
            <cfset thePDFVar = StructNew()>
            <cfset x = StructInsert(thePDFVar,"distributor","","YES")>
            <cfset x = StructInsert(thePDFVar,"reference_id",thirdgenDetailsStruct.intDataID,"YES")>
            <cfif getDealerDetails.recordCount gt 0>
                <cfset x = StructInsert(thePDFVar,"distributor",getDealerDetails.dealerName,"YES")>
                <cfset x = StructInsert(thePDFVar,"reference_id",getDealerDetails.dealerCode & "-" & thirdgenDetailsStruct.intDataID,"YES")>
                <cfset x = StructInsert(thePDFVar,"dealer_firstname",getDealerDetails.firstname,"YES")>
                <cfset x = StructInsert(thePDFVar,"dealer_lastname",getDealerDetails.lastname,"YES")>
                <cfset x = StructInsert(thePDFVar,"dealer_email",getDealerDetails.user_email,"YES")>
            </cfif>
            
            <cfmodule template="mod_houseKeeping.cfm" maxDaysOld="3" dirToBeCleaned="#appFormsLoc#">

            <cfmodule template="mod_createApplicationForm.cfm" formdataid="#thirdgenDetailsStruct.intDataID#" pdfVariable="#thePDFVar#" output="pdfResult">
            
            <!--- GENERATE APPLICATION FORM (end) --->
            
            
            <cfset appStatus = StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_QuoteStatus_FID,"|")) >
            <cfset fileCount = 0>
            <!--- QUOTESUMMARY | COVERSUMMARY | PBM | PDS --->
            <cfloop array="#arrayPrintout#" index="aStruct">
                <cfset aDoc = StructFind(aStruct,"TYPE")>
                <cfif CompareNoCase(aDoc,"QUOTESUMMARY") eq 0>
                    <cfif appStatus eq CONST_BQ_QuoteStatus_stage2_LID
                        or appStatus eq CONST_BQ_QuoteStatus_stage3_LID
                        or appStatus eq CONST_BQ_QuoteStatus_stage4_LID>
                        <cftry>
                            <cfset PDFfilename = "YMIAUS_summary_ws_"& StructFind(pdfResult,"reference_id") &".pdf">
                            <cfmodule template="mod_createSummaryForm.cfm" formdataid="#thirdgenDetailsStruct.intDataID#" pdfVariable="#pdfResult#" 
                                docType="QUOTESUMMARY" appFormsLoc="#appFormsLoc#" pdfFilename="#PDFfilename#" output="xxx">
                            <cfset x = StructInsert(aStruct,"FILE","#appFormsLoc##PDFfilename#")>
                            <cfset fileCount = fileCount + 1>
                            
                            <cfcatch type="any">
                            </cfcatch>
                        </cftry>
                    </cfif>
                <cfelseif CompareNoCase(aDoc,"COVERSUMMARY") eq 0>
                    <cfif appStatus eq CONST_BQ_QuoteStatus_stage3_LID
                        or appStatus eq CONST_BQ_QuoteStatus_stage4_LID>
                        <cftry>
                            <cfset PDFfilename = "YMIAUS_CBsummary_ws_"& StructFind(pdfResult,"reference_id") &".pdf">
                            <cfmodule template="mod_createSummaryForm.cfm" formdataid="#thirdgenDetailsStruct.intDataID#" pdfVariable="#pdfResult#" 
                                docType="COVERSUMMARY" appFormsLoc="#appFormsLoc#" pdfFilename="#PDFfilename#" output="xxx">
                            <cfset x = StructInsert(aStruct,"FILE","#appFormsLoc##PDFfilename#")>
                            <cfset fileCount = fileCount + 1>
                             
                            <cfcatch type="any">
                            </cfcatch>
                        </cftry>
                    </cfif>
                <cfelseif CompareNoCase(aDoc,"PBM") eq 0>
                    <cfif appStatus eq CONST_BQ_QuoteStatus_stage2_LID
                        or appStatus eq CONST_BQ_QuoteStatus_stage3_LID
                        or appStatus eq CONST_BQ_QuoteStatus_stage4_LID>
                        <cftry>
                            <cfset thePDFTemplate = "#application.BASE_FOLDER#adminMotor\pdf_template\YMIAus_Motorcycle_PayByMonth_form.pdf">
                            <cfset PDFfilename = "YMIAUS_PBM_ws_"& StructFind(pdfResult,"reference_id") &".pdf">
                            <cfmodule template="mod_createPayByMonthForm.cfm" formdataid="#thirdgenDetailsStruct.intDataID#" pdfVariable="#pdfResult#"
                                pdfTemplate="#thePDFTemplate#" appFormsLoc="#appFormsLoc#" PDF_PayByMonth_filename="#PDFfilename#" output="pbmResult">
                            <cfset x = StructInsert(aStruct,"FILE","#appFormsLoc##PDFfilename#")>
                            <cfset fileCount = fileCount + 1>
                            
                            <cfcatch type="any">
                            </cfcatch>
                        </cftry>
                    </cfif>
                <cfelseif CompareNoCase(aDoc,"PDS") eq 0>
                    <!--- get all necesary PDS --->
                </cfif>
            </cfloop>
            
            <cfif fileCount eq 0>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","No Documents Available")>
            </cfif>
            
            <cfcatch type="Any">
                <cfset allowDocument = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot print DOCUMENT", cfcatch.message)>
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
            <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_TotLoanValue_FID,"|"))>
            <totalLoanVal>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_TotLoanValue_FID,"|"))#</totalLoanVal>
            </cfif>
        </client>
        </cfoutput></cfsavecontent>
        
        <cfset xmlResponse = createXMLPackage(xmlContent="#theContent#",responseType="QUOTE",idStruct=thirdgenDetailsStruct)>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=thirdgenDetailsStruct.intDataID
            ,responseXML=XmlParse(xmlResponse)
            ,note="Document"
            )>

        <cfoutput>#xmlResponse#</cfoutput>
        
        <!--- <cfdump var="#arrayPrintout#"> --->
        <cfif fileCount gt 0>
            <cfoutput>
            <cfmail to="#thePDFVar.dealer_email#" from="#application.THIRDGENPLUS_SYSTEM_EMAIL_ADDRESS#" subject="YMI Australia Documents - #thirdgenDetailsStruct.intDataID#" type="HTML">
                Hi #thePDFVar.dealer_firstname# #thePDFVar.dealer_lastname#,
                
                These are the documents that you requested for the client.
                <br/>
                <cfloop array="#arrayPrintout#" index="aStruct">
                    <cfif StructKeyExists(aStruct,"FILE")>
                        <cfmailparam file="#aStruct.file#">
                    </cfif>
                </cfloop>
            </cfmail>
            </cfoutput>
        </cfif>
        
    </cfif>
</cfif>

<cfif ArrayLen(outerErrorArray) gt 0>
    <cfset xmlResponse = createXMLPackage(errorMsg=outerErrorArray[1],responseType="DOCUMENT",idStruct=thirdgenDetailsStruct)>
    <cfif IsDefined("thirdgenDetailsStruct.intDataID")>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=thirdgenDetailsStruct.intDataID
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Document"
            )>
    <cfelse>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Document"
            )>
    </cfif>
   
    <cfoutput>#xmlResponse#</cfoutput>
</cfif>