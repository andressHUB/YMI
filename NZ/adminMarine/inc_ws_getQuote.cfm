<!--- 
sample:
========
<NMPackage>
<header>
    <clientId>YMINZ</clientId>
    <clientType>Marine</clientType>
</header>
<request type="QUOTE"> <!--- action="REFRESH" --->
    <id>
        <extRefId provider="YMSI">Y9IA801279</extRefId>
        <extDealer id="YMINZ001">Auckland Test Marine</extDealer>
        <extUser id="987564">John.Citizen</extUser>
        <refId>82583<refId> <!--- optional --->
    </id>    
    <marine>
        <boatDetails>
            <make>HAINESHUNTER</make> 
            <model/>
            <type>RUN</type> <!--- RUN | PWC --->
            <year>2013</year>
            <construction>ALMUNIUM</construction> <!--- ALMUNIUM | FIBREGLASS | RUBBER | PLASTIC --->
            <inProd>true</inProd>
            <length>5</length>
        </boatDetails> 
        <motorDetails>
            <make>YAMAHA</make>
            <year>2014</year>
            <type>JET</type> <!--- OUTBOARD | IMM | IRM | STERN | JET --->
            <fuelType>PETROL</fuelType> <!--- PETROL | DIESEL --->
            <hp>100</hp>
            <speedMax>21</speedMax> <!--- 35 | 110 | 999 ---> <!--- in km/h --->
        </motorDetails>
        <marketPrice>5000.00</marketPrice> <!--- Insured Value:  --->
        <liability>5000000</liability> <!--- Liability Limit:  ---> <!--- 2000000 | 5000000 | 10000000 --->
        <excess>500</excess> <!--- Excess ---> <!--- 200 | 500 | 1000 | 2000 --->
        <isSkiers>true</isSkiers>
        <layUpMths></layUpMths> <!--- Lay Up Months:  ---> <!--- optional --->
		<isNew>true</isNew> <!--- Is this a new motorcycle (first time purchased)?  Ticket 46291 --->
		<datePurchased>2013-09-04Z</datePurchased>	<!--- Date Motorcycle Purchased: Ticket 46291 --->
    </marine>
    <client>
        <firstname>John</firstname>
        <lastname>Citizen</lastname>
        <email>j.citizen@gmail.com</email>
        <dob>1980-08-25Z</dob>
        <gender>M</gender>
        <storageMethod>TRAILER_PRIVATE</storageMethod> <!--- TRAILER_PRIVATE | TRAILER_COMM | STACK | AIR_DOCK | OTHER | MOORED --->
        <storagePostcode>2035</storagePostcode>
        <storageState>NSW</storageState>
        <storageStateArea>METRO</storageStateArea> <!--- METRO | COUNTRY --->
        <streetPark>true</streetPark>
        <boatingExp>2</boatingExp> <!--- Boating experience --->
        <boatingCourse>true</boatingCourse> <!---  Boating Courses:  --->
        <loanTermMth>12<loanTermMth>
        <totalLoanVal>6700.00</totalLoanVal>
		<promoCode>yam123</promoCode>
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
    <cfset BoatQuoteStruct = StructNew()>
    
    <cfif StructKeyExists(thirdgenDetailsStruct,"intDataID") and thirdgenDetailsStruct.intDataID neq "" and thirdgenDetailsStruct.intDataID neq 0>
        <cfquery name="getformData" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select fd.form_data_id, fd.xml_data, fd.last_updated
        from thirdgen_form_data fd with (nolock) where fd.form_data_id = #thirdgenDetailsStruct.intDataID#
        </cfquery>
        <cfif getformData.recordCount gt 0 and getformData.xml_data neq "">
            <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BoatQuoteStruct">
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
            <cfif StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_ignoreCompl_FID,"|")) eq 1> 
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - compliance-override has been applied")> 
            </cfif>
            
            <!--- can't edit if it has been manually adjusted internally --->
            <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_manualEditor_FID,"|"))
                and StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_manualEditor_FID,"|")) neq ""> 
                <cfset allowQuoteEdit = false>
                <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Update not allowed - manual-edit has been applied")> 
            </cfif>
            
            <!--- can't edit - if it passed QUOTE stage --->
            <cfif StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|")) eq CONST_MQ_QuoteStatus_stage3_LID
                or StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|")) eq CONST_MQ_QuoteStatus_stage4_LID>
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
    
    <cfif allowQuoteEdit>
        <cfset compStruct = StructNew()>
        <cfset motoronlyStruct = StructNew()>
        <cfset tpoStruct = StructNew()>
    
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
                
                <cfif data_boatMake eq "" or data_motorMake eq "" 
                    or data_boatAge eq "" or data_boatConst eq "" or data_boatLength eq "" 
                    or data_motorAge eq "" or data_motorFuel eq "" or data_motorSpeed eq ""
                    or data_motorHP eq "" >
                    <cfset allowQuoteEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE")>
                </cfif>
                
                <cfif data_boatType eq CONST_MQ_BoatTypePWC_LID>
                    <!--- <cfif data_boatMake eq "">
                        <cfset allowQuoteEdit = false>
                        <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on MARINE (PWC)")>
                    </cfif> --->
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
				
				
				<!--- START ASF Ticket 46175 - PromoCode --->
				
				  <cfset tempXMLClient = theCurrentXml.NMPackage.request.client>	
				  
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug PROMO 1" type="HTML">
	<cfdump var="#tempXMLClient.promoCode.XmlText#">
</cfmail>	--->
				
			      <cfset data_promoCode = "">
			      <cfif StructKeyExists(tempXMLClient,"promoCode") and trim(tempXMLClient.promoCode.XmlText) neq "">
			        <cfset data_promoCode  = trim(tempXMLClient.promoCode.XmlText)>
			      </cfif>
				  
				  
<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug PROMO 1" type="HTML">
	<cfdump var="#data_promoCode#">
</cfmail>	--->
			      
			     <!--- END ASF Ticket 46175 - PromoCode --->
				
				<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->
			  
				  <cfset data_isBoatNew = "">
				  <cfset data_datePurchased = "">
				  
				  
				  
				  
			      <cfif StructKeyExists(tempXML,"isNew") and trim(tempXML.isNew.XmlText) neq "">
			        <cfset data_isBoatNew = trim(tempXML.isNew.XmlText)>
					
					 <cfif data_isBoatNew>
			        	<cfset data_isBoatNew = 1>
			         <cfelse>
			        	<cfset data_isBoatNew = 0>
			         </cfif>
			   
					  <cfif StructKeyExists(tempXML,"datePurchased") and trim(tempXML.datePurchased.XmlText) neq "">	  
							<cfset data_datePurchased  = trim(tempXML.datePurchased.XmlText)>
							<cfset data_datePurchased  = XMLToCF_dateTime(data_datePurchased)>				
					  </cfif>			  
				  </cfif>				
					  
			  <!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
        
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
                where list_id = #CONST_MQ_personAge_ListID#
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
                
                <cfset tempXML = theCurrentXml.NMPackage.request.client>
                <cfset data_firstname = trim(tempXML.firstname.XmlText)>
                <cfset data_lastname = trim(tempXML.lastname.XmlText)>
                <cfset data_email = trim(tempXML.email.XmlText)>
        
                <cfif data_firstname eq "" or data_lastname eq "" or data_email eq ""   
                    or data_storageMethodID eq "">
                    <cfset allowQuoteEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing/Invalid mandatory elements on CLIENT")>
                </cfif>
                
                <cfif data_totalLoanVal neq "" and data_loanTermMth eq ""> <!--- check if Loan Term Month is invalid when Loan Value exists --->
                    <cfset allowQuoteEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid/missing value on loan fields")>
                </cfif>
				
				<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value)
	   
			   <cfif data_isBoatNew eq 1 and data_datePurchased eq "">
					  <cfset allowCoverBoundEdit = false>
		              <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Invalid - Date Boat Purchased missing (isNew = true)", "")>  
			   </cfif> --->
	   
	   			<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
                
                <cfcatch type="Any">
                    <cfset allowQuoteEdit = false>
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot process other elements on MARINE/CLIENT", cfcatch.message)>
                </cfcatch>
            </cftry>
        </cfif>
    
        <cfif ArrayLen(outerErrorArray) eq 0>
            <!--- GET COVER OPTIONS (start) --->
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
					promoCode= "#data_promoCode#"				<!--- ASF Ticket 46175 PromoCode ---> 
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
                    <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,MOTOR")>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,MOTOR")>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","UNIQUE|COMP,TPO,MOTOR")>
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","REQ_OR|LP-LIFE,LP-DISABLE")> <!--- UNEMPLOYMENT Cover must be chosen with either LIFE or DISABLEMENT Cover --->
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
                <cfset x = StructInsert(tmpStruct,"prodOpt","REQ_OR|LP-LIFE,LP-DISABLE")> <!--- CASH-ASSIST Cover must be chosen with either LIFE or DISABLEMENT Cover --->
                <cfset x = StructInsert(coverOpts,"LP-CASH",tmpStruct)>
    
            </cfif>
            
            <!--- GET COVER OPTIONS (end) --->
        </cfif>
             
        <cfif ArrayLen(outerErrorArray) eq 0>
            <cftry>
                <cfset attributes.formDefID = CONST_marineQuoteFormDefId>
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
    
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatMake_FID,"|"), data_boatMake, true)>
                
                <!--- N/A in NZ --->
                <!--- <cfif data_boatType eq CONST_MQ_BoatTypePWC_LID>
                    <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                    select list_item_id, list_item_display, list_item_image
                    from thirdgen_list_item
                    where list_id = #CONST_MQ_insurablePWCMaker_ListID#
                    and list_item_display like '#data_boatMake#'
                    </cfquery>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_insurablePWCMaker_FID,"|"), getListItem.list_item_id, true)>  
                </cfif> ---> 

                <cfquery name="getListItem" datasource="#application.THIRDGENPLUS_DSN#"	username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                select list_item_id, list_item_display, list_item_image
                from thirdgen_list_item
                where list_id = #CONST_MQ_BoatMake_ListID#
                and list_item_display like '#data_boatMake#'
                </cfquery>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatMakeBrand_FID,"|"), getListItem.list_item_id, true)>  
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatModel_FID,"|"), data_boatModel, true)>
                
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatType_FID,"|"), data_boatType,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_HullYear_FID,"|"), data_boatYear,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatConst_FID,"|"), data_boatConst,true)>
                <cfif data_boatIsProd>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatProd_FID,"|"), CONST_MQ_BoatProd_Yes_LID,true)>
                <cfelse>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatProd_FID,"|"), CONST_MQ_BoatProd_No_LID,true)>
                </cfif>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_HullLength_FID,"|"), data_boatLength,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatAge_FID,"|"),  data_boatAge,true)>
                
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_MotorMake_FID,"|"), data_motorMake, true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_Motor_Year_FID,"|"), data_motorYear,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_MotorType_FID,"|"),  data_motorType,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatFuelType_FID,"|"),  data_motorFuel,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_MotorHP_FID,"|"),  data_motorHP,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatSpeed_FID,"|"), data_motorSpeed,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_MotorAge_FID,"|"),  data_motorAge,true)>

                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_InsuredValue_FID,"|"), data_marineValue,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_LiabiltyLmt_FID,"|"),  data_liability,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_ExcessOpt_FID,"|"), data_excessId,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_SkiersLiabilityOpt_FID,"|"),  data_isSkiers,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_layUpMths_FID,"|"), data_layUpMths,true)>
				
				<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->
				<cfset x = StructInsert(attributes,"field_CB_NewMotorcycle", data_isBoatNew,true)>
				<cfif  data_datePurchased neq "">
					<cfset x = StructInsert(attributes,"field_CB_PurchasedDate", DateFormat(data_datePurchased,"DD/MM/YYYY"),true)> 
				</cfif>
				<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
                
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_FirstName_FID,"|"), data_firstname,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_Surname_FID,"|"), data_lastname,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_Email_FID,"|"), data_email,true)>
                
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_InsurerDOB_FID,"|"), DateFormat(data_sailorDOB,"DD/MM/YYYY"),true)>    
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_SailorAge_FID,"|"),  data_sailorAge,true)>        
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_StorageMethod_FID,"|"), data_storageMethodID,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatStoragePostcode_FID,"|"), data_storagePostCode,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_State_FID,"|"), data_stateId,true)>            
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_BQ_StateArea_FID,"|"), data_stateAreaID,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_StreetParked_FID,"|"), data_streetPark,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatExp_FID,"|"),  data_boatingExpYr,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_BoatingCourseOpt_FID,"|"),  data_boatingCourse,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_loanTermMth_FID,"|"), data_loanTermMth,true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_TotLoanValue_FID,"|"), data_totalLoanVal,true)>
                
                
                <cfif StructKeyExists(thirdgenDetailsStruct,"extDataProvider")>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_ExtProvider_FID,"|"), thirdgenDetailsStruct.extDataProvider,true)>
                </cfif>
                <cfif StructKeyExists(thirdgenDetailsStruct,"extDataID")>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_ExtId_FID,"|"), thirdgenDetailsStruct.extDataID,true)>
                </cfif>
                
                <!--- <cfset x = StructInsert(BoatQuoteStruct,ListFirst(CONST_BQ_gapCoverTerm_FID,"|"), data_loanTermMth,true)> --->
                <cfif StructKeyExists(coverOpts,"COMP")>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_quoteComp_FID,"|"), NumberFormat(coverOpts.COMP.totalPremium,".99"),true)>
                </cfif>
                <cfif StructKeyExists(coverOpts,"TPO")>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_quoteTPO_FID,"|"), NumberFormat(coverOpts.TPO.totalPremium,".99"),true)>
                </cfif>
                <cfif StructKeyExists(coverOpts,"MOTOR")>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_quoteMotorOnly_FID,"|"), NumberFormat(coverOpts.MOTOR.totalPremium,".99"),true)>
                </cfif>
                
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_extraSelected_FID,"|"), "",true)>
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_quoteAdminFee_FID,"|"), NumberFormat(adminFeeTotal,".99"),true)>
                
                <!--- IGNORED IN QUOTES XML --->
                <!--- 
                <cfif IsDefined("data_hasRefused")>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_hadInsuranceRefused_FID,"|"), data_hasRefused,true)>
                </cfif>
                <cfif IsDefined("data_hasClaims")>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_hadClaims_FID,"|"), data_hasClaims,true)>
                </cfif>
                <cfif IsDefined("data_hasConvicted")>
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_hadChargedWithOffence_FID,"|"), data_hasConvicted,true)>
                </cfif>
                --->
                
                <!--- RE-SAVING CURRENT DATA FOR COMPLIANCE - IF EXISTS (start) --->
                <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_hadInsuranceRefused_FID,"|"))> 
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_hadInsuranceRefused_FID,"|"), StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_hadInsuranceRefused_FID,"|")),true)>
                </cfif>
                <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_hadClaims_FID,"|"))> 
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_hadClaims_FID,"|"), StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_hadClaims_FID,"|")),true)>
                </cfif>
                <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_hadChargedWithOffence_FID,"|"))> 
                    <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_hadChargedWithOffence_FID,"|"), StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_hadChargedWithOffence_FID,"|")),true)>
                </cfif>
                <!--- RE-SAVING CURRENT DATA FOR COMPLIANCE - IF EXISTS (end) --->
                
                <cfset x = StructInsert(attributes,"field_"&ListFirst(CONST_MQ_QuoteStatus_FID,"|"), CONST_MQ_QuoteStatus_stage1_LID,true)>
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
                <cfwddx action="WDDX2CFML" input="#getformData.xml_data#" output="BoatQuoteStruct">

                <!--- CHECK IF FIELDS ARE PROPERLY UPDATED --->
                <cfif StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_quoteAdminFee_FID,"|")) eq "" >
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot save QUOTE properly - please retry")>
                </cfif>
                
                <cfcatch type="Any">
                    <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Cannot insert/update QUOTE", cfcatch.message)>
                </cfcatch>
            </cftry>
            
            <cfif StructCount(compStruct) gt 0 OR StructCount(motoronlyStruct) gt 0 and IsDefined("theFormDataId")>
                <!--- STORE DATA TEMPORARILY --->
                <cfset xmlRequestId = updateWebServiceTempData(form_data_id=theFormDataId
                    ,data_type="COVER_OPTIONS"
                    ,requester_id=thirdgenDetailsStruct.extDataProvider
                    ,external_id=thirdgenDetailsStruct.extDataID
                    ,theData=coverOpts
                    )>         
            </cfif>
            
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
            
            <cfset data_hasRefused = StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_hadClaims_FID,"|"))>
            <cfset data_hasClaims = StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_hadChargedWithOffence_FID,"|"))>
            <cfset data_hasConvicted = StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_QuoteStatus_FID,"|"))>
        <cfelse>
            <cfset outerErrorArray = appendErrArray(outerErrorArray,"DATA","Missing Ref Id")>
        </cfif>
        
    </cfif>
    
    
    <cfif ArrayLen(outerErrorArray) eq 0 and StructCount(BoatQuoteStruct) gt 1 >
        <!--- PRINT XML --->
        <!--- show the list-item 'real' value - only use this when necessary --->
        <cfmodule template="../thirdgen/form/mod_get_form_data.cfm"
            formDefID = "#CONST_marineQuoteFormDefId#"
            formDataId = "#theFormDataId#"
            output="theData">
            
        <cfif CompareNoCase(requestAction,"REFRESH") eq 0> 
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
            
            <cfquery name="getFormDataListSpec" dbtype="query">
            select * from getFormDataList where key_name = '#ListFirst(CONST_MQ_loanTermMth_FID,"|")#'
            </cfquery>
            <cfset list_loanTermMth = UCase(getFormDataListSpec.list_item_display)>
        </cfif>
            
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
            <firstname>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_FirstName_FID,"|"))#</firstname>
            <lastname>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_Surname_FID,"|"))#</lastname>
            <email>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_Email_FID,"|"))#</email>
            <!--- DON'T NEED TO BE RETURNED AT THE MOMENT
            <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_loanTermMth_FID,"|"))>
                <loanTermMth>#list_loanTermMth#</loanTermMth>
            </cfif> --->
            <cfif StructKeyExists(BoatQuoteStruct,ListFirst(CONST_MQ_TotLoanValue_FID,"|"))>
                <totalLoanVal>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_TotLoanValue_FID,"|"))#</totalLoanVal>
            </cfif>
        </client>
        <options>
            <cfif StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_ignoreCompl_FID,"|")) neq 1
                and
                (
                    (IsDefined("data_hasRefused") and data_hasRefused eq 1)
                    or (IsDefined("data_hasClaims") and data_hasClaims eq 1)
                    or (IsDefined("data_hasConvicted") and data_hasConvicted eq 1)
                )
                >
                #createErrorElem("COMPLIANCE","Referral due to compliance")#
            <cfelse>
                <cfif StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_ignoreCompl_FID,"|")) eq 1
                and
                (
                    (IsDefined("data_hasRefused") and data_hasRefused eq 1)
                    or (IsDefined("data_hasClaims") and data_hasClaims eq 1)
                    or (IsDefined("data_hasConvicted") and data_hasConvicted eq 1)
                )
                >
                <adjustments>
                    <reason>#StructFind(BoatQuoteStruct,ListFirst(CONST_MQ_ignoreComplReason_FID,"|"))#</reason>
                    <excess>#StructFind(theData,ListFirst(CONST_MQ_ExcessOpt_FID,"|"))#</excess>
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
    <cfset xmlRequestId = updateWebServiceResponseLog( ws_request_id=xmlWSDataId
        ,responseXML=XmlParse(xmlResponse)
        ,note="Error - Quote"
        )>
    <cfoutput>#xmlResponse#</cfoutput>
</cfif>
