<cfinclude template="constants.cfm">
<cfparam name="attributes.appFormsLoc" > 
<cfparam name="attributes.pdfFilename" >
<cfparam name="attributes.formDataID" default="0">
<cfparam name="attributes.docType" default="QUOTESUMMARY"> <!--- QUOTESUMMARY | COVERSUMMARY --->
<cfparam name="attributes.pdfVariable" default="#StructNew()#">
<cfparam name="attributes.output" >

<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.created, fd.xml_data, fd.user_data_id, fd.last_updated, isnull(thirdgen_form_data_date_values.field_value,getdate()) AS coverCommDate
    from thirdgen_form_data fd 
    INNER JOIN thirdgen_form_data_date_values ON fd.form_data_id = thirdgen_form_data_date_values.form_data_id
    where fd.form_data_id = #attributes.formDataID#
    AND (thirdgen_form_data_date_values.key_name = '#ListFirst(CONST_MQ_CoverCommDate_FID,"|")#')
</cfquery>
<cfwddx action="WDDX2CFML" input="#getData.xml_data#" output="BoatQuoteDetails">

<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->
		
		<cfset agreedText = false>
		<cfset displayAgreedMarketValue = false>	
		
		<cfset purchaseDateExists = StructFind(BoatQuoteDetails,"CB_PurchasedDate")>
		<!--- <cfset policyCommDateExists = StructKeyExists(BikeQuoteDetails,"CB_CoverCommDate")> --->
			
		<cfset quoteSelected = BoatQuoteDetails.CQ_quoteSelected>	
		
		

		
		<!--- <cfif IsDefined("BikeQuoteDetails.CB_CoverCommDate") and BikeQuoteDetails.CB_CoverCommDate neq ""> --->
		<cfif IsDefined("getData.last_updated") and getData.last_updated neq ""
			and purchaseDateExists neq "">	
			<!--- <cfif policyCommDateExists eq "YES" and ---> 
			<cfif quoteSelected eq CONST_MQ_Comp_LID> <!--- comprehensive only --->
				<!--- <cfif LSParseDateTime(BikeQuoteDetails.CB_CoverCommDate) ge CONST_START_AGREED_MARKET_VALUE> --->
				<cfif LSParseDateTime(getData.last_updated) ge CONST_START_AGREED_MARKET_VALUE>
					<cfset displayAgreedMarketValue = true>	
				</cfif>	
			</cfif>		
		</cfif>
			
		
		
		
		<cfset bikePurchaseDate =  BoatQuoteDetails.CB_PurchasedDate>


<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug" type="HTML">
	<cfdump var="#BikeQuoteDetails.CB_NewMotorcycle#">
</cfmail> --->		
		
		<!--- <cfoutput>[#bikePurchaseDate#]</cfoutput>
		<cfabort> --->
		
			
		<cfif purchaseDateExists neq "" and bikePurchaseDate neq "" and displayAgreedMarketValue> 
		
				<cfif attributes.pdfVariable.boat_hull_make eq "YAMAHA">


					<cfset currentDate = now()>			
								
					<cfset monthsPurchaseDiff = DateDiff("m",bikePurchaseDate,currentDate)>

					<!--- <cfdump var="#bikePurchaseDate#">
					<cfdump var="#monthsPurchaseDiff#"> --->

					<cfif monthsPurchaseDiff lte CONST_YamahaAgreedMonths>
						<cfset agreedText = true>
					</cfif>
				<cfelse>
					<cfset currentDate = now()>			
					<cfset bikePurchaseDate =  LSParseDateTime(BoatQuoteDetails.CB_PurchasedDate)>			
					<cfset monthsPurchaseDiff = DateDiff("m",bikePurchaseDate,currentDate)>

					<cfdump var="#bikePurchaseDate#"><BR>
					<cfdump var="#monthsPurchaseDiff#"><BR>
					
					

					<cfif monthsPurchaseDiff lte CONST_nonYamahaAgreedMonths>
						<cfset agreedText = true>
					</cfif>

				</cfif>
						
				<!--- <cfoutput>monthsPurchaseDiff #monthsPurchaseDiff#</cfoutput><br> 
				<cfoutput>agreedText #agreedText#</cfoutput><br> 
				<cfoutput>displayAgreedMarketValue #displayAgreedMarketValue#</cfoutput><br> --->
		</cfif>
		
		
		
		<cfif (IsDefined("BoatQuoteDetails.CB_NewMotorcycle") and BoatQuoteDetails.CB_NewMotorcycle eq "")
		or (IsDefined("BoatQuoteDetails.CB_NewMotorcycle") and BoatQuoteDetails.CB_NewMotorcycle eq "0")>
				<cfset agreedText = false>
				<cfset displayAgreedMarketValue = false>	
		</cfif>
		
		<!--- CB_NewMotorcycle: <cfdump var="#BoatQuoteDetails.CB_NewMotorcycle#"><br>
		<cfoutput>agreedText #agreedText#</cfoutput><br> 
		<cfoutput>displayAgreedMarketValue #displayAgreedMarketValue#</cfoutput><br> --->
		
		
		
<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->	

<!--- CREATE QUOTE SUMMARY PDF --->
<cfif CompareNoCase(attributes.docType,"QUOTESUMMARY") eq 0>
    <cfsavecontent variable="pdfHeader">
    <cfoutput>
    <table cellpadding="0" cellspacing="0" style="width:100%">
    <tr>
        <td rowspan="2"><img src="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/images/logo_ymi.png"></td>
        <td style="font-size:24px;font-weight:bold;text-align:center">Marine Insurance<br/> Quote Summary</td>
    </tr>
    <tr>
        <td style="font-size:13px;font-weight:bold;text-align:center">
            #attributes.pdfVariable.dealer_firstname# #attributes.pdfVariable.dealer_lastname#, #attributes.pdfVariable.distributor# <br/>
            (Ref: #attributes.pdfVariable.reference_Id#) <br/>
            <cfif StructKeyExists(BoatQuoteDetails,listGetAt(CONST_MQ_ExtProvider_FID,1,"|")) and  StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_ExtProvider_FID,1,"|")) neq ""
                and StructKeyExists(BoatQuoteDetails,listGetAt(CONST_MQ_ExtId_FID,1,"|")) and  StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_ExtId_FID,1,"|")) neq "" >
            (Ext Ref: #StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_ExtProvider_FID,1,"|"))# - #StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_ExtId_FID,1,"|"))#)
            </cfif>
        </td>
    </tr>
    </table>
    </cfoutput>
    </cfsavecontent>
    
    <cfdocument format="pdf" filename="#attributes.appFormsLoc##attributes.pdfFilename#" overwrite="yes">
    <cfoutput>    
    <style>
    body, table, p, div
    {
        font-family:arial;
        font-size:13px;
    }
    ul.featureBenefits
    {
        margin-left:20px;
    }
    
    ul.featureBenefits li
    {
        padding:2px;
        text-indent: 0px;
    }
    
    .tbl_featureBenefits
    {
        width:100%;
    }
    
    .tbl_featureBenefits tr td
    {
        padding:5px;
        /*border:1px solid black;*/
    }
    </style>
    
    <div id="thePDF">
    #pdfHeader#
    <br/>
    
    <p style="line-height:15px;">
    #DateFormat(getData.created,"DD - MMM - YYYY")#<br/><br/>    
    Thank you, <b>#attributes.pdfVariable.insured_name#</b> 
    for the opportunity to provide you with a quote to insure your <b>#attributes.pdfVariable.boat_hull_make#</b> 
    <!--- (#detailsModel#) ---> through Yamaha Marine Insurance.<br/>
    </p>
    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
    <tr>
        <td align="left" valign="top" style="width:40%">
            <p><b>Cover details:</b></p>
            <table cellpadding="5" cellspacing="0" border="1">
            <tr>
                <td>Cover Type:</td>
                <td>
                    <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_Comp_LID) gt 0>
                        Comprehensive Cover 
                    <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_MotorOnly_LID) gt 0>
                        Motor Only Cover 
                    <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_TPO_LID) gt 0>
                        Third Party Only Cover
                    </cfif>
                </td>
            </tr>
            <tr>
                <td>Sum Insured:</td>
                <td>
				<!--- $#numberFormat(StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_InsuredValue_FID,1,"|")),",.99")# --->
				<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->	
					<cfif displayAgreedMarketValue>
						<cfif agreedText>
							Agreed ($#numberFormat(StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_InsuredValue_FID,1,"|")),",.99")#)
						<cfelse>
							Market Value
						</cfif>
					<cfelse>
						Market Value <!--- $#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99")# --->
					</cfif>
					<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
				</td>
            </tr>
            <tr>
                <td>Excess:</td>
                <td>#attributes.pdfVariable.excess#</td>
            </tr>
            <!--- <tr>
                <td>Insurance Premium:</td>
                <td><!--- #attributes.pdfVariable.summary_premium# --->
                    <cfset tmpPrem = reReplaceNoCase(attributes.pdfVariable.summary_premium,"[$, ]","","all")>
                    <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_QuoteGapCover_LID) gt 0>
                        <cfset tmpPrem = tmpPrem - reReplaceNoCase(attributes.pdfVariable.quoteGE,"[$, ]","","all")>
                    </cfif>
                    $#numberFormat(reReplaceNoCase(tmpPrem,"[$, ]","","all"),",.99")#
                </td>
            </tr>
            <tr>
                <td>Gap Premium:</td>
                <td><cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_QuoteGapCover_LID) gt 0>$#attributes.pdfVariable.quoteGE#<cfelse>n/a</cfif>
                <!--- <cfif attributes.pdfVariable.summary_gap eq 0 or attributes.pdfVariable.summary_gap eq "">n/a<cfelse>#attributes.pdfVariable.summary_gap#</cfif> --->
                <!--- <cfif gapPremium eq 0 or gapPremium eq "">n/a<cfelse>$#gapPremium#</cfif> --->
                </td>
            </tr> --->
            <tr>
                <td>Total Premium</td>
                <td>#attributes.pdfVariable.summary_premium#</td>
                <!--- <td>#attributes.pdfVariable.summary_payable#</td> --->
            </tr>
            <tr>
                <td>Liability Limit</td>
                <td>#attributes.pdfVariable.liability_limit#</td>
            </tr>
            </table>
            &nbsp;<br/>
        </td>
        <td align="right" valign="top" style="font-size:11px;">
            <img src="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/images/logo_3_yrs_replacement.png"><br/>
            <i>*Applicable to new Yamaha powered Boats and Waverunners<br/>insured with Yamaha Marine Insurance</i>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <p><b>Other details:</b></p>
            <table cellpadding="5" cellspacing="0" border="1" style="width:100%">
            <tr>
                <td style="width:50%">
                    <cfif attributes.pdfVariable.opt_waterSkiers eq 1>
                    Include Skiers Liability option
                    <cfelse>
                    Does not include Skiers Liability option
                    </cfif>
                </td>
                <td style="width:50%">
                    <cfif ListLen(attributes.pdfVariable.LayUpMonths) eq 0>
                    No layup months
                    <cfelse>
                    With #ListLen(attributes.pdfVariable.LayUpMonths)# layup months
                    </cfif>                    
                </td>
            </tr>
            </table>
        </td>
    </tr>
    </table>
    
    <br/><br/>
    <table class="borders" border="0" cellspacing="0" cellpadding="5" > 
    <tbody>
        <tr>
            <td style="font-size:18px;text-align:center; font-weight: bold;">Features &amp; Benefits</td>
        </tr>
        <tr>
            <td>
                <cfif FileExists(ExpandPath("../html/inc_featurebenefit_marine.cfm"))>
                    <cfinclude template="../html/inc_featurebenefit_marine.cfm">
                </cfif>
            </td>
        </tr>
    </tbody>
    </table>
       
    <cfdocumentitem type="pagebreak"></cfdocumentitem>
    
    #pdfHeader#
    <br/><br/>
    
    <p style="font-size:11px;">
        Please note this quotation is valid for 30 days from the date noted above.<br/>
        For further details on this policy and coverage please refer to the policy wording available from your Yamaha dealer, or call us on 0800 664 678. <br/> 
        <cfif StructKeyExists(BoatQuoteDetails,listGetAt(CONST_MQ_quoteDetails_FID,1,"|"))>
        <br/><span style="font-size:9px;">#StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_quoteDetails_FID,1,"|"))#</span><br/>
        </cfif>
    </p>
    <br/>
    
    <div style="padding: 10px; font-size: 11px; background-color: rgb(221, 221, 221);">
        <table border="0" class="tbl_featureBenefits" cellspacing="0" cellpadding="0" >
	        <tbody>
		        <tr>
                    <td>
                    <!--- The Insurer of this insurance is AIG Insurance New Zealand Limited (AIG).
                    American International Group, Inc. (AIG) is a leading insurance organisation serving customers in more than 100 countries and jurisdictions. 
                    AIG companies serve commercial, institutional, and individual customers through one of the most extensive worldwide property-casualty networks of any insurer.
                    In addition AIG companies are leading providers of life insurance and retirement services in the United States. 
                    AIG common stock is listed on the New York Stock Exchange and the Tokyo Stock Exchange. --->
                    The Insurers  of  this insurance are certain underwriters at Lloyd's of London (Lloyd's). Lloyd's of London has been a pioneer in insurance and has grown over 325 years 
                    to become the world's leading market for specialist insurance. Lloyd's of London insures people, businesses and communities in more than 200 countries and territories. 
                    Lloyd's of London's unique capital structure provides excellent financial security to policy holders.  This insurance is underwritten by certain underwriters at Lloyd's 
                    of London (Underwriters). Lloyd's of London has current financial strength rating of A+ with Standard & Poor's and is listed on the London Stock Exchange.
                    </td>
                 </tr>
             </tbody>
        </table>            
    </div>
    
    <br/>
    
    </div>
    </cfoutput>
    </cfdocument>
    
<cfelseif CompareNoCase(attributes.docType,"COVERSUMMARY") eq 0>
    <cfsavecontent variable="pdfHeader">
    <cfoutput>
    <table cellpadding="0" cellspacing="0" style="width:100%">
    <tr>
        <td rowspan="2"><img src="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/images/logo_ymi.png"></td>
        <td style="font-size:24px;font-weight:bold;text-align:center">Marine Insurance<br/> Certificate of Currency</td>
    </tr>
    <tr>
        <td style="font-size:13px;font-weight:bold;text-align:center">
            #attributes.pdfVariable.dealer_firstname# #attributes.pdfVariable.dealer_lastname#, #attributes.pdfVariable.distributor# <br/>
            (Policy Reference Number: #attributes.pdfVariable.reference_Id#) <br/>
            <cfif StructKeyExists(BoatQuoteDetails,listGetAt(CONST_MQ_ExtProvider_FID,1,"|")) and  StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_ExtProvider_FID,1,"|")) neq ""
                and StructKeyExists(BoatQuoteDetails,listGetAt(CONST_MQ_ExtId_FID,1,"|")) and  StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_ExtId_FID,1,"|")) neq "" >
            (Ext Ref: #StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_ExtProvider_FID,1,"|"))# - #StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_ExtId_FID,1,"|"))#)
            </cfif>
        </td>
    </tr>
    </table>
    </cfoutput>
    </cfsavecontent>
        
    <!--- CREATE QUOTE SUMMARY PDF --->
    <cfdocument format="pdf" filename="#attributes.appFormsLoc##attributes.pdfFilename#" overwrite="yes" marginLeft="0.2" marginRight="0.2" marginBottom="0.5" marginTop="0.5" >
    <cfoutput>    
    <style>
    body, table, p, div
    {
        font-family:arial;
        font-size:13px;
    }
    ul.featureBenefits
    {
        margin-left:20px;
    }
    
    ul.featureBenefits li
    {
        padding:2px;
        text-indent: 0px;
    }
    
    .tbl_featureBenefits
    {
        width:100%;
    }
    
    .tbl_featureBenefits tr td
    {
        padding:5px;
        /*border:1px solid black;*/
    }
    </style>
    
    <div id="thePDF">
    #pdfHeader#
    <br/>
    
    <p style="line-height:15px;">
    #DateFormat(getData.created,"DD - MMM - YYYY")#<br/><br/>    
    Thank you, <b>#attributes.pdfVariable.insured_name#</b>  
    for trusting the insurance of your <b>#attributes.pdfVariable.boat_hull_make#</b> with Yamaha Marine Insurance.<br/>
    </p>
    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
    <tr>
        <td align="left" valign="top" style="width:50%">
            <p><b>Cover details:</b></p>
            <table cellpadding="5" cellspacing="0" border="1" style="width:100%">
            <tr>
                <td>Cover Type:</td>
                <td>
                    <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_Comp_LID) gt 0>
                        Comprehensive Cover 
                    <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_MotorOnly_LID) gt 0>
                        Motor Only Cover 
                    <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_TPO_LID) gt 0>
                        Third Party Only Cover
                    </cfif>
                </td>
            </tr>
            <tr>
                <td>Sum Insured:</td>
                <td>
				<!--- $#numberFormat(StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_InsuredValue_FID,1,"|")),",.99")# --->
				<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->	
					<cfif displayAgreedMarketValue>
						<cfif agreedText>
							Agreed ($#numberFormat(StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_InsuredValue_FID,1,"|")),",.99")#)
						<cfelse>
							Market Value
						</cfif>
					<cfelse>
						Market Value <!--- $#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99")# --->
					</cfif>
					<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
				</td>
            </tr>
            <tr>
                <td>Excess:</td>
                <td>#attributes.pdfVariable.excess#</td>
            </tr>
            <!--- <tr>
                <td>Insurance Premium:</td>
                <td><!--- #attributes.pdfVariable.summary_premium# --->
                    <cfset tmpPrem = reReplaceNoCase(attributes.pdfVariable.summary_premium,"[$, ]","","all")>
                    <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_QuoteGapCover_LID) gt 0>
                        <cfset tmpPrem = tmpPrem - reReplaceNoCase(attributes.pdfVariable.quoteGE,"[$, ]","","all")>
                    </cfif>
                    $#numberFormat(reReplaceNoCase(tmpPrem,"[$, ]","","all"),",.99")#
                </td>
            </tr>
             <tr>
                <td>Gap Premium:</td>
                <td><cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_MQ_QuoteGapCover_LID) gt 0>$#attributes.pdfVariable.quoteGE#<cfelse>n/a</cfif>
                </td>
            </tr> --->
           <!---  <tr>
                <td>Gap Premium:</td>
                <td>
                    <cfset tempInt = attributes.pdfVariable.summary_gap>
                    <cfset tempInt = reReplaceNoCase(tempInt,"[$,.]","")>
                    <cfif attributes.pdfVariable.summary_gap eq "" or LSParseNumber(tempInt) eq 0>n/a<cfelse>#attributes.pdfVariable.summary_gap#</cfif>
                </td>
            </tr> --->
            <tr>
                <td>Total Premium</td>
                <td>#attributes.pdfVariable.summary_premium#</td>
            </tr>
            <tr>
                <td>Liability Limit</td>
                <td>#attributes.pdfVariable.liability_limit#</td>
            </tr>
            <tr>
                <td>Cover Period:</td>
                <td>#attributes.pdfVariable.period_start# - #attributes.pdfVariable.period_end#</td>
            </tr>
            </table>
            <br/>
        </td>
        <td align="right" valign="top" style="font-size:11px;">
            <img src="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/images/logo_3_yrs_replacement.png"><br/>
            <i>*Applicable to new Yamaha powered Boats and Waverunners<br/>insured with Yamaha Marine Insurance</i>
        </td>
    </tr>
    </table>
    
    <p><b>Boat details:</b></p>
    <table border="1" cellspacing="0" cellpadding="5" style="width:100%">
    <tr>
        <td colspan="4"><b>HULL</b></td>
    </tr>
    <tr>
        <td style="width:15%">Make:</td>
        <td style="width:35%">#attributes.pdfVariable.boat_hull_make# (#attributes.pdfVariable.boat_hull_year#)</td>
        <td style="width:15%">Details:</td>
        <td style="width:35%">#attributes.pdfVariable.boat_hull_construction#;#attributes.pdfVariable.boat_hull_length# mtr</td>
    </tr>
    <tr>
        <td>HIN No:</td>
        <td>#attributes.pdfVariable.boat_hull_HIN#</td>
        <td>Rego No:</td>
        <td>#attributes.pdfVariable.boat_hull_rego#</td>
    </tr>
    <tr>
        <td colspan="4"><b>MOTOR</b></td>
    </tr>
    <tr>
        <td>Make:</td>
        <td>#attributes.pdfVariable.boat_motor_make# (#attributes.pdfVariable.boat_motor_year#)</td>
        <td>Serial No:</td>
        <td>#attributes.pdfVariable.boat_motor_serialNo#</td>
    </tr>
    <tr>
        <td colspan="4"><b>TRAILER</b></td>
    </tr>
    <tr>
        <td>Make:</td>
        <td>
            <cfif attributes.pdfVariable.boat_trailer_make neq "">
            #attributes.pdfVariable.boat_trailer_make# (#attributes.pdfVariable.boat_trailer_year#)
            <cfelse>
            N/A
            </cfif>
        </td>
        <td>Rego:</td>
        <td>
            <cfif attributes.pdfVariable.boat_trailer_reg neq "">
            #attributes.pdfVariable.boat_trailer_reg#
            <cfelse>
            N/A
            </cfif>
        </td>
    </tr>
    <!--- <cfif attributes.pdfVariable.payment_type neq CONST_MQ_paymentType_FinancedYMF_LID and attributes.pdfVariable.payment_type neq CONST_MQ_paymentType_FinancedOther_LID>
    <!--- do nothing --->
    <cfelse> --->
    <tr>
        <td colspan="4"><b>FINANCIER DETAILS/INTERESTED PARTIES</b></td>
    </tr>
    <tr>
        <td colspan="4">
        #attributes.pdfVariable.insured_interestedParties# &nbsp;
        </td>
    </tr>
    <!--- </cfif> --->
    </table>
    
    <p><b>Other details:</b></p>
    <table cellpadding="5" cellspacing="0" border="1" style="width:100%">
    <tr>
        <td style="width:50%">
            <cfif StructFind(BoatQuoteDetails, listGetAt(CONST_MQ_SkiersLiabilityOpt_FID,1,"|")) eq 1>
            Include Skiers Liability option
            <cfelsE>
            Does not include Skiers Liability option
            </cfif>
        </td>
        <td style="width:50%">
            <cfif ListLen(attributes.pdfVariable.LayUpMonths) eq 0>
            No layup months
            <cfelse>
            With #ListLen(attributes.pdfVariable.LayUpMonths)# layup months
            </cfif>                    
        </td>
    </tr>
    <!--- <cfif attributes.pdfVariable.payment_type neq CONST_MQ_paymentType_FinancedYMF_LID and attributes.pdfVariable.payment_type neq CONST_MQ_paymentType_FinancedOther_LID>
    <tr>
        <td>
            Payment recevied by #attributes.pdfVariable.payment_type_disp#
        </td>
    </tr>
    </cfif> --->
    </table>
    
    <cfdocumentitem type="pagebreak"></cfdocumentitem>
    
    #pdfHeader#
    <br/>
    
    <p><b>Payment Received By:</b></p>
    <table cellpadding="5" cellspacing="0" border="1" style="width:100%">
    <tr>
        <td style="width:33%;height:50px;">
            Cheque/Money Order
        </td>
        <td style="width:34%">
            Credit Card - MasterCard         
        </td>
        <td style="width:33%">
            Credit Card - Visa
        </td>
    </tr>
    <tr>
        <td style="height:50px;">
            Financed - YMF
        </td>
        <td >
            Financed - Other         
        </td>
        <td >
            Other ____________________
        </td>
    </tr>
    </table>
    
    <br/><br/><br/><br/><br/><br/>
    
    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
    <tr>
        <td style="width:67%;">
            Dealer's Authorised Signature : &nbsp; ______________________________ 
        </td>
        <td>
            Date : &nbsp; ____________________
        </td>
    </tr>
    </table>
    
    <br/><br/><br/><br/>
    <p style="font-size:11px;">
    This confirmation of cover is a summary. The full policy schedule, including any endorsements to the cover, 
    will be sent by Yamaha Marine Insurance to the policy holder within 10 business days. If required earlier, please contact Yamaha Marine Insurance on 0800 664 678.
    <br/><br/>
    This schedule is to be read in conjunction with the policy wording / Product Disclosure Statement for full policy terms and conditions, 
    this is available from your local Yamaha dealer or visit http://www.yamaha-motor.co.nz/sites/yamaha-motor/files/Yamaha_PDS.pdf 
    <br/><br/>
    </p>
    
    
    <!--- <p>
    <b>About the Insurers:</b>
    The underwriter of this insurance is AIG Australia Limited ("AIG Australia") ABN 93 004 727 753 AFSL 381686.
    AIG is the marketing name for the worldwide property-casualty, life and retirement, and general insurance operations of American International Group,Inc.
    </p> --->
    <br/><br/>
    
    <div style="padding: 10px; font-size: 11px; background-color: rgb(221, 221, 221);">
        <table border="0" class="tbl_featureBenefits" cellspacing="0" cellpadding="0" >
	        <tbody>
		        <tr>
                    <td>
                    <!--- The Insurer of this insurance is AIG Insurance New Zealand Limited (AIG).
                    American International Group, Inc. (AIG) is a leading insurance organisation serving customers in more than 100 countries and jurisdictions.
                    AIG companies serve commercial, institutional, and individual customers through one of the most extensive worldwide property-casualty networks of any insurer.
                    In addition AIG companies are leading providers of life insurance and retirement services in the United States.
                    AIG common stock is listed on the New York Stock Exchange and the Tokyo Stock Exchange. --->
                    The Insurers  of  this insurance are certain underwriters at Lloyd's of London (Lloyd's). Lloyd's of London has been a pioneer in insurance and has grown over 325 years 
                    to become the world's leading market for specialist insurance. Lloyd's of London insures people, businesses and communities in more than 200 countries and territories. 
                    Lloyd's of London's unique capital structure provides excellent financial security to policy holders.  This insurance is underwritten by certain underwriters at Lloyd's 
                    of London (Underwriters). Lloyd's of London has current financial strength rating of A+ with Standard & Poor's and is listed on the London Stock Exchange.
                    </td>
                 </tr>
             </tbody>
        </table>            
    </div>
            
    <br/>
    
    </div>
    </cfoutput>
    </cfdocument>
    
</cfif>