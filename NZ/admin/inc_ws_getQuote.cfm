<!--- 
sample:
========
<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Motorcycle</clientType>
</header>
<request type="QUOTE">
    <id>
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
        <marketPrice>5000.00</marketPrice> <!--- Market Value:  --->
        <isRoadReg>true</isRoadReg> <!--- Will this unit be road registered? --->
        <dateRego>2002-10-05Z</dateRego> <!--- Date of original registration: --->
        <isRTC>false</isRTC> <!--- Do you require Rider Total Care?  --->
        <excess>$500</excess> <!--- Excess --->
        <layUpMths></layUpMths> <!--- Lay Up Months:  --->
		<isNew>true</isNew> <!--- Is this a new motorcycle (first time purchased)?  Ticket 46291 --->
		<datePurchased>2013-09-04Z</datePurchased>	<!--- Date Motorcycle Purchased: Ticket 46291 --->
    </motorcycle>
    <client>
        <firstname>John</firstname>
        <lastname>Citizen</lastname>
        <email>j.citizen@gmail.com</email>
        <mobile>0401234567</mobile>
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
		<promoCode>yam123</promoCode>
    </client>
</request>
</NMPackage>


<NMPackage>
<header>
    <clientId>YMI</clientId>
    <clientType>Motorcycle</clientType>
</header>
<request type="QUOTE">
    <id>
        <extRefId provider="YMF">Y9IA801279<extRefId>
        <extDealer id="D987">ROCKAFELLER MOTORCYCLE LTD</extDealer>
        <extUser id="123">Fred.flinstone</extUser>
    </id>    
    <motorcycle>
        <glassDetails>
            <make>HONDA</make>
            <nvic>2XL02E</nvic>
            <code>HON-50CH-2002XL2002E</code>
        </glassDetails>
        <otherDetails></otherDetails>
        <marketPrice>5000.00</marketPrice> <!--- Market Value:  --->
        <isRoadReg>true</isRoadReg> <!--- Will this unit be road registered? --->
        <dateRego>2002-10-05Z</dateRego> <!--- Date of original registration: --->
        <isRTC>false</isRTC> <!--- Do you require Rider Total Care?  --->
        <excess>$500</excess> <!--- Excess --->
        <layUpMths></layUpMths> <!--- Lay Up Months:  --->
    </motorcycle>
    <client>
        <firstname>John</firstname>
        <lastname>Citizen</lastname>
        <email>j.citizen@gmail.com</email>
        <mobile>0401234567</mobile>
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
<cfset requestAction = ""> <!--- REFRESH  --->

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
    <cfset BikeQuoteStruct = StructNew()>

    <cfif StructKeyExists(thirdgenDetailsStruct,"intDataID") and thirdgenDetailsStruct.intDataID neq "" and thirdgenDetailsStruct.intDataID neq 0>
        <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select fd.form_data_id, fd.xml_data, fd.last_updated
        from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
        </cfquery>
        <cfif getformData.recordCount gt 0 and getformData.xml_data neq "">
            <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BikeQuoteStruct">
        <cfelse>
            <cfset allowQuoteEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid Ref-Id")>
        </cfif>
        
        <cfif CompareNoCase(requestAction,"REFRESH") eq 0> <!--- only refresh - not editing --->
            <cfset allowQuoteEdit = false>
            <cfif DateDiff("d",getformData.last_updated ,now()) gt CONST_QUOTE_VALIDITY>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Outside #CONST_QUOTE_VALIDITY# days quote validity period")>
            </cfif>
        </cfif>
        
        <cfif allowQuoteEdit>
            <!--- can't edit if it has compliance-override attached --->
            <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_ignoreCompl_FID,"|")) eq 1> 
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - compliance-override has been applied")> 
            </cfif>
            
            <!--- can't edit if it has been manually adjusted internally --->
            <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_manualEditor_FID,"|"))
                and StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_manualEditor_FID,"|")) neq ""> 
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - manual-edit has been applied")> 
            </cfif>
            
            <!--- can't edit - if it passed QUOTE stage --->
            <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_QuoteStatus_FID,"|")) eq CONST_BQ_QuoteStatus_stage3_LID
                or StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_QuoteStatus_FID,"|")) eq CONST_BQ_QuoteStatus_stage4_LID>
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - no longer QUOTE STAGE")>
            </cfif>
        </cfif>

    <cfelse>    
        <cfif CompareNoCase(requestAction,"REFRESH") eq 0> <!--- only refresh - not editing --->
            <cfset allowQuoteEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"IDENTITY","Internal ID is required")>
        </cfif>
    </cfif>
        
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
                and data_bikeCustomYear neq "" and data_bikeCustomMake neq "">
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
        
        
		
		 <!--- START ASF Ticket 46175 - PromoCode --->
		 <cfset tempXML = theCurrentXml.NMPackage.request.client>
	      <cfset data_promoCode = "">
	      <cfif StructKeyExists(tempXML,"promoCode") and trim(tempXML.promoCode.XmlText) neq "">
	        <cfset data_promoCode  = trim(tempXML.promoCode.XmlText)>
	      </cfif>
		  
 <!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug YMI AUS MC data_promoCode" type="HTML">
	<cfdump var="#data_promoCode#">
</cfmail> --->		  
	      
	     <!--- END ASF Ticket 46175 - PromoCode --->
		
		<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->
		<cfset data_coverStartDate = trim(tempXML.coverStartDate.XmlText)> 
    	<cfset data_coverStartDate = XMLToCF_dateTime(data_coverStartDate)>
	 	<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
		
		
        <cfset data_firstname = trim(tempXML.firstname.XmlText)>
        <cfset data_lastname = trim(tempXML.lastname.XmlText)>
        <cfset data_email = trim(tempXML.email.XmlText)>

        <cfif data_firstname eq "" or data_lastname eq "" or data_email eq "">
            <cfset allowQuoteEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MOTORYCLE")>
        </cfif>
        
        <cfcatch type="Any">
            <cfset allowQuoteEdit = false>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process mandatory elements on MOTORYCLE/CLIENT", cfcatch.message)>
        </cfcatch>
    </cftry>
    
    <cfif allowQuoteEdit>
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
			
			<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->
			  
			  <cfset data_isBikeNew = "">
			  <cfset data_datePurchased = "">
			  
		      <cfif StructKeyExists(tempXML,"isNew") and trim(tempXML.isNew.XmlText) neq "">
		        <cfset data_isBikeNew = trim(tempXML.isNew.XmlText)>
				
				 <cfif data_isBikeNew>
		        	<cfset data_isBikeNew = 1>
		         <cfelse>
		        	<cfset data_isBikeNew = 0>
		         </cfif>
		   
				  <cfif StructKeyExists(tempXML,"datePurchased") and trim(tempXML.datePurchased.XmlText) neq "">	  
						<cfset data_datePurchased  = trim(tempXML.datePurchased.XmlText)>
						<cfset data_datePurchased  = XMLToCF_dateTime(data_datePurchased)>				
				  </cfif>			  
			  </cfif>				
			  
		  <!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->

            <cfset tempXML = theCurrentXml.NMPackage.request.client>
            <cfset data_mobile = trim(tempXML.mobile.XmlText)>
            <cfset data_storagePostCode = trim(tempXML.storagePostcode.XmlText)>
            <cfset data_licenseConsYr = trim(tempXML.consYrsLicense.XmlText)>
            
            <cfset data_riderDOB = trim(tempXML.dob.XmlText)> 
            <cfset data_riderDOB = XMLToCF_dateTime(data_riderDOB)>
        
            <!--- IGNORED IN QUOTES XML --->
            <!--- <cfif IsDefined("tempXML.compliance")>
                <cfloop index="aDecl" array="#xmlsearch(tempXML.compliance,'declaration')#">
                    <cfset tmpStr = aDecl.XmlText>
                    <cfif tmpStr>
                        <cfset tmpStr = 1>
                    <cfelse>
                        <cfset tmpStr = 0>
                    </cfif>
                    <cfset x = evaluate("data_"&aDecl.XmlAttributes.id&" = "& tmpStr)> <!--- hasRefused | hasClaims | hasConvicted | hasSuspended  --->
                </cfloop>
            </cfif> --->
            
            
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
                <cfif data_totalLoanVal lte 0>
                    <cfset data_totalLoanVal = "">
                </cfif>
            <cfelse>
                <cfset data_totalLoanVal = "">
            </cfif>
			
			
			<!--- START ASF Ticket 46175 - PromoCode 
		      <cfset data_promoCode = "">
		      <cfif StructKeyExists(tempXML,"promoCode") and trim(tempXML.promoCode.XmlText) neq "">
		        <cfset data_promoCode  = trim(tempXML.promoCode.XmlText)>
		      </cfif>--->
		      
		      <!--- END ASF Ticket 46175 - PromoCode --->
			  
			  
			   <!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) 
			   
			   <cfif data_isBikeNew eq 1 and data_datePurchased eq "">
					  <cfset allowCoverBoundEdit = false>
		              <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Motorcycle Purchase Date missing (isNew = true)", "")>  
			   </cfif>
			   
			  <cfif DateDiff("d",now(),data_coverStartDate) lt 0>
		                <!--- removed this CB 27/01/2017
		                OR DateDiff("d","1-jan-2017",data_coverStartDate) gte 0>  cannot do COVER BOUND on cover commencing 1st of January 2017 - as per Janet's request (14/10/2016) --->
		                <cfset allowCoverBoundEdit = false>
		                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Invalid Cover start date", "")>
		       </cfif>--->
		    <!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
            
            <cfif data_bikeValue eq ""
                or data_ncbratingID eq "" 
                or data_riderDOB eq "" 
                or data_licenseConsYr eq "" 
                or data_under25Restr eq "" 
                or data_stateID eq "" 
                or data_stateRegionID eq "" 
                or data_storageMethodID eq "" 
                or data_excessId eq "" 
                or data_loanTermMth eq "">
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid/missing value on mandatory fields on MOTORYCLE/CLIENT")>
            </cfif>
            
            <cfcatch type="Any">
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MOTORYCLE/CLIENT", cfcatch.message)>
            </cfcatch>
        </cftry>
        
    </cfif>
    

    <cfif allowQuoteEdit>

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
                        bikeMake_manual="#data_bikeCustomMake#"
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
						promoCode= "#data_promoCode#"				<!--- ASF Ticket 46175 PromoCode ---> 
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
						promoCode= "#data_promoCode#"				<!--- ASF Ticket 46175 PromoCode ---> 
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
            <cfset fslFee = otherProdsStruct.calcParams.fslFee >
            <cfset adminFeeTotal = adminFee + gstRate*adminFee>
            
            <cfset tmpStruct = StructNew()>
            <cfset x = StructInsert(tmpStruct,"base",adminFee)>
            <cfset x = StructInsert(tmpStruct,"GST",NumberFormat(gstRate*adminFee,".99"))>
            <cfset x = StructInsert(tmpStruct,"total",tmpStruct.base + tmpStruct.GST)>
            <cfset x = StructInsert(coverOpts,"FEE_ADMIN",tmpStruct)>
            
            <cfcatch type="Any">
                <!--- can't get quote --->
                <cfset allowQuoteEdit = false>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,TPD,OFFROAD")>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,TPD,OFFROAD")>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,TPD,OFFROAD")>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,TPD,OFFROAD")>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,TPD,OFFROAD")>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,TPD,OFFROAD")>
                <cfset x = StructInsert(coverOpts,"TPD",tmpStruct)>
            </cfif>
            
        </cfif>
        
        <!--- MUST always have TPO options - UNLESS parameters gone missing OR cannot be found --->
        <cfif StructCount(tpoStruct) gt 0>
            <cfif tpoStruct.calcResult neq "OK">
                <cfset allowQuoteEdit = false>
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
        
        <!--- 
        THIS RULE IS NOT APPLICABLE FOR YMI NZ Motor at the moment - since there is NO OFF-ROAD product offered
        <cfif not StructKeyExists(coverOpts,"COMP") and not StructKeyExists(coverOpts,"OFFROAD")>  <!--- MUST HAVE AT LEAST COMPREHENSIVE or OFFROAD PRODUCT --->
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Bike is not insurable")>
        </cfif> 
        --->
        
        <cfif ArrayLen(outerErrorArray) eq 0>
        
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","REQ_OR|LP-LIFE,LP-DISABLE")> <!--- UNEMPLOYMENT Cover must be chosen with either LIFE or DISABLEMENT Cover --->
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","REQ_OR|LP-LIFE,LP-DISABLE")> <!--- CASH-ASSIST Cover must be chosen with either LIFE or DISABLEMENT Cover --->
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
        </cfif>
        
        <!--- GET COVER OPTIONS (end) --->
        
        <cftry>
            <cfset attributes.formDefID = CONST_bikeQuoteFormDefId>
            <cfset attributes.siteID = thirdgenDetailsStruct.siteID>
            <cfset attributes.regUserID = thirdgenDetailsStruct.userID>
            <cfset attributes.treeNodeID = thirdgenDetailsStruct.currentTreeNodeId>
            <cfif StructKeyExists(thirdgenDetailsStruct,"intDataID") and thirdgenDetailsStruct.intDataID neq "" and thirdgenDetailsStruct.intDataID neq 0>  <!--- edit form --->
                <cfset attributes.formDataID = thirdgenDetailsStruct.intDataID> 
                <cfset attributes.formAction = "edit">
            <cfelse>  <!--- new form --->
                <cfset attributes.formAction = "new">
            </cfif>
            
            <!--- quote form fields (start) --->
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_BikeModel_FID,"|"), data_bikeFormDataId,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_customBikeMake,"|"), data_bikeCustomMake,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_customBikeStyle,"|"), data_bikeCustomStyle,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_customBikeYear,"|"), data_bikeCustomYear,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_customBikeDetail1,"|"), data_bikeCustomDetail,true)>
            
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_InsuredValue_FID,"|"), data_bikeValue,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_RoadReg_FID,"|"), data_isRoadReg,true)>
            <cfif data_dateRego neq "">
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_OriginalRegoDate_FID,"|"), DateFormat(data_dateRego,"DD/MM/YYYY"),true)>
            </cfif>
            <!--- <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_RiderTotalCare_FID,"|"), data_RTC,true)> --->
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Excess_FID,"|"), data_excessId,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_layUpMths_FID,"|"), data_layUpMths,true)>
			
			<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->
				<cfset x = StructInsert(attributes,"field_CB_NewMotorcycle", data_isBikeNew,true)>
				<cfif  data_datePurchased neq "">
					<cfset x = StructInsert(attributes,"field_CB_PurchasedDate", DateFormat(data_datePurchased,"DD/MM/YYYY"),true)> 
				</cfif>
			<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
            
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_FirstName_FID,"|"), data_firstname,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Surname_FID,"|"), data_lastname,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_InsurerDOB_FID,"|"), DateFormat(data_riderDOB,"DD/MM/YYYY"),true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_InsurerSex_FID,"|"), data_gender,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_RidingExp_FID,"|"), data_licenseConsYr,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_StorageMethod_FID,"|"), data_storageMethodID,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_StoragePostcode_FID,"|"), data_storagePostCode,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_State_FID,"|"), data_stateId,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_StateArea_FID,"|"), data_stateRegionID,true)>
            <!--- <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_OtherRiderUnder25_FID,"|"), data_under25Restr,true)> --->
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_NCB_FID,"|"), data_ncbratingID,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Email_FID,"|"), data_email,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_MobilePhone_FID,"|"), data_mobile,true)>
            <cfif StructKeyExists(thirdgenDetailsStruct,"extDataProvider")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_ExtProvider_FID,"|"), thirdgenDetailsStruct.extDataProvider,true)>
            </cfif>
            <cfif StructKeyExists(thirdgenDetailsStruct,"extDataID")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_ExtId_FID,"|"), thirdgenDetailsStruct.extDataID,true)>
            </cfif>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_loanProtectTerm_FID,"|"), data_loanTermMth,true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_gapCoverTerm_FID,"|"), data_loanTermMth,true)>
            <cfif StructKeyExists(coverOpts,"COMP")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteComp_FID,"|"), NumberFormat(coverOpts.COMP.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"OFFROAD")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteOffRoad_FID,"|"), NumberFormat(coverOpts.OFFROAD.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"TPD")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteTPD_FID,"|"), NumberFormat(coverOpts.TPD.totalPremium,".99"),true)>
            </cfif>
            <cfif StructKeyExists(coverOpts,"TPO")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteTPO_FID,"|"), NumberFormat(coverOpts.TPO.totalPremium,".99"),true)>
            </cfif>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteGapCover_FID,"|"), NumberFormat(0,".99"),true)>
            <cfif StructKeyExists(coverOpts,"TR")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteTyreRim_FID,"|"), NumberFormat(coverOpts.TR.totalPremium,".99"),true)>
            </cfif>
            <!--- <cfif StructKeyExists(coverOpts,"LP")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteLoanProtect_FID,"|"), NumberFormat(coverOpts.LP.totalPremium,".99"),true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_loanProtectDetails_FID,"|"), coverOpts.LP.details,true)>
            </cfif> --->
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteLoanProtect_FID,"|"), NumberFormat(0,".99"),true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_loanProtectDetails_FID,"|"), "", true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteAdminFee_FID,"|"), NumberFormat(adminFeeTotal,".99"),true)>
            <!--- <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteFSLFee_FID,"|"), NumberFormat(fslRate*data_bikeValue,".99"),true)> --->
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_quoteFSLFee_FID,"|"), NumberFormat(fslFee,".99"),true)>
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_TotLoanValue_FID,"|"), data_totalLoanVal,true)>
            
            <!--- IGNORED IN QUOTES XML --->
            <!---  <cfif IsDefined("data_hasRefused")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_InsRefCan_FID,"|"), data_hasRefused,true)>
            </cfif>
            <cfif IsDefined("data_hasClaims")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Claims_FID,"|"), data_hasClaims,true)>
            </cfif>
            <cfif IsDefined("data_hasConvicted")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Charged_FID,"|"), data_hasConvicted,true)>
            </cfif>
            <cfif IsDefined("data_hasSuspended")>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Suspended_FID,"|"), data_hasSuspended,true)>
            </cfif> --->
            <!--- RE-SAVING CURRENT DATA FOR COMPLIANCE - IF EXISTS (start) --->
            <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_InsRefCan_FID,"|"))> 
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_InsRefCan_FID,"|"), StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_InsRefCan_FID,"|")),true)>
            </cfif>
            <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_Claims_FID,"|"))> 
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Claims_FID,"|"), StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Claims_FID,"|")),true)>
            </cfif>
            <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_Charged_FID,"|"))> 
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Charged_FID,"|"), StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Charged_FID,"|")),true)>
            </cfif>
            <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_Suspended_FID,"|"))> 
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_Suspended_FID,"|"), StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Suspended_FID,"|")),true)>
            </cfif>
            <!--- RE-SAVING CURRENT DATA FOR COMPLIANCE - IF EXISTS (end) --->
            
            <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_QuoteStatus_FID,"|"), CONST_BQ_QuoteStatus_stage1_LID,true)>
        
            <!--- quote form fields (end) --->
    
            <cfinclude template="../thirdgen/form/inc_save_form.cfm">
            <cfset theFormDataId = session.thirdgenas.lastSavedFormDataID>
            <cfif not StructKeyExists(thirdgenDetailsStruct,"intDataID") OR thirdgenDetailsStruct.intDataID eq "">
                <cfset x = StructInsert(thirdgenDetailsStruct,"intDataID",theFormDataId,true)>
            </cfif>
   
            <!--- RE-QUERY QUOTE DATA STRUCT! --->
            <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select fd.form_data_id, fd.xml_data
            from thirdgen_form_data fd with (nolock) where fd.form_data_id = #theFormDataId#
            </cfquery>
            <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BikeQuoteStruct">
            
            <!--- CHECK IF FIELDS ARE PROPERLY UPDATED --->
            <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_quoteAdminFee_FID,"|")) eq "" >
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot save QUOTE properly - please retry")>
            </cfif>
            
            <cfcatch type="Any">
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot insert/update QUOTE", cfcatch.message)>
            </cfcatch>
        </cftry>
        
        <!--- MUST always have tpoStruct - UNLESS parameters gone missing OR cannot be found --->
        <cfif StructCount(tpoStruct) gt 0 and IsDefined("theFormDataId")>
            <!--- STORE DATA TEMPORARILY --->
            <cfset xmlRequestId = updateWebServiceTempData(form_data_id=theFormDataId
                ,data_type="COVER_OPTIONS"
                ,requester_id=thirdgenDetailsStruct.extDataProvider
                ,external_id=thirdgenDetailsStruct.extDataID
                ,theData=coverOpts
                )>         
        </cfif>
        
    <cfelse>
        <cfif StructKeyExists(thirdgenDetailsStruct,"intDataID") and thirdgenDetailsStruct.intDataID neq "" and thirdgenDetailsStruct.intDataID neq 0>
            <cfset theFormDataId = thirdgenDetailsStruct.intDataID>
            <!--- GET TEMPORARY DATA --->
            <cfset tmpStr = getWebServiceTempData(form_data_id=theFormDataId
                ,data_type="COVER_OPTIONS"
                ,requester_id=thirdgenDetailsStruct.extDataProvider
                ,external_id=thirdgenDetailsStruct.extDataID
                )> 
            
            <cfif trim(tmpStr) eq "">
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot find cover options for (Ext-Ref:"&thirdgenDetailsStruct.extDataID&") and (Int-Ref:" & theFormDataId & ")")>
            <cfelse>
                <cfwddx action="WDDX2CFML" input="#tmpStr#" output="coverOpts">
            </cfif>
            
            <cfset data_hasRefused = StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_InsRefCan_FID,"|"))>
            <cfset data_hasClaims = StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Claims_FID,"|"))>
            <cfset data_hasConvicted = StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Charged_FID,"|"))>
            <cfset data_hasSuspended = StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Suspended_FID,"|"))>
        <cfelse>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing Ref Id")>
        </cfif>
        
    </cfif>
    
    <cfif ArrayLen(outerErrorArray) eq 0>
        <!--- PRINT XML --->
        <!--- show the list-item 'real' value - only use this when necessary --->
        <cfmodule template="../thirdgen/form/mod_get_form_data.cfm"
            formDefID = "#CONST_bikeQuoteFormDefId#"
            formDataId = "#theFormDataId#"
            output="theData">

        <cfif not StructKeyExists(thirdgenDetailsStruct,"intDataID") OR thirdgenDetailsStruct.intDataID eq "" OR thirdgenDetailsStruct.intDataID eq 0
            and IsDefined("theFormDataId")>
            <cfset x = StructInsert(thirdgenDetailsStruct,"intDataID",theFormDataId)>
        </cfif>
        
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
        <client>
            <firstname>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_FirstName_FID,"|"))#</firstname>
            <lastname>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Surname_FID,"|"))#</lastname>
            <email>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_Email_FID,"|"))#</email>
            <cfif StructKeyExists(BikeQuoteStruct,ListFirst(CONST_BQ_TotLoanValue_FID,"|"))>
            <totalLoanVal>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_TotLoanValue_FID,"|"))#</totalLoanVal>
            </cfif>
        </client>
        <options>
            <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_ignoreCompl_FID,"|")) neq 1
                and
                (
                    (IsDefined("data_hasRefused") and data_hasRefused eq 1)
                    or (IsDefined("data_hasClaims") and data_hasClaims eq 1)
                    or (IsDefined("data_hasConvicted") and data_hasConvicted eq 1)
                    or (IsDefined("data_hasSuspended") and data_hasSuspended eq 1) 
                )
                >
                #createErrorElem("COMPLIANCE","Referral due to compliance")#
            <cfelse>
                <cfif StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_ignoreCompl_FID,"|")) eq 1
                and
                (
                    (IsDefined("data_hasRefused") and data_hasRefused eq 1)
                    or (IsDefined("data_hasClaims") and data_hasClaims eq 1)
                    or (IsDefined("data_hasConvicted") and data_hasConvicted eq 1)
                    or (IsDefined("data_hasSuspended") and data_hasSuspended eq 1) 
                )
                >
                <adjustments>
                    <reason>#StructFind(BikeQuoteStruct,ListFirst(CONST_BQ_ignoreComplReason_FID,"|"))#</reason>
                    <excess>#StructFind(theData,ListFirst(CONST_BQ_Excess_FID,"|"))#</excess>
                </adjustments>
                </cfif>
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
        
        <cfif IsDefined("attributes.formAction")>
            <cfif attributes.formAction eq "edit">
                <cfset tempXML = theCurrentXml.NMPackage.request.client>
                <cfif IsDefined("tempXML.compliance.declaration")>
                    <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
                        ,form_data_id=theFormDataId
                        ,responseXML=XmlParse(xmlResponse)
                        ,note="Update Quote - Compliance"
                        )>
                <cfelse>
                    <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
                        ,form_data_id=theFormDataId
                        ,responseXML=XmlParse(xmlResponse)
                        ,note="Update Quote - Data"
                        )>
                </cfif>
            <cfelse>
                <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
                    ,form_data_id=theFormDataId
                    ,responseXML=XmlParse(xmlResponse)
                    ,note="Create Quote"
                    )>
            </cfif>
            
        <cfelse>
            <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
                ,form_data_id=theFormDataId
                ,responseXML=XmlParse(xmlResponse)
                ,note="Refresh Quote"
                )>
        </cfif>
        
        <cfoutput>#xmlResponse#</cfoutput>
    </cfif>
    
    
</cfif>

<cfif ArrayLen(outerErrorArray) gt 0>
    <cfset xmlResponse = createXMLPackage(errorMsg=outerErrorArray[1],responseType="QUOTE",idStruct=thirdgenDetailsStruct)>
    <cfif IsDefined("thirdgenDetailsStruct.intDataID") and thirdgenDetailsStruct.intDataID neq "">
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,form_data_id=thirdgenDetailsStruct.intDataID
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Quote"
            )>
    <cfelse>
        <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
            ,responseXML=XmlParse(xmlResponse)
            ,note="Error - Quote"
            )>
    </cfif>
    
    <cfoutput>#xmlResponse#</cfoutput>
</cfif>

