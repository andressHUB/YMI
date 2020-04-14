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
    AND (thirdgen_form_data_date_values.key_name = '#ListFirst(CONST_BQ_CoverCommDate_FID,"|")#')
</cfquery>
<cfwddx action="WDDX2CFML" input="#getData.xml_data#" output="BikeQuoteDetails">

<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->
		
		<cfset agreedText = false>
		<cfset displayAgreedMarketValue = false>	
		
		<cfset purchaseDateExists = StructFind(BikeQuoteDetails,"CB_PurchasedDate")>
		<!--- <cfset policyCommDateExists = StructKeyExists(BikeQuoteDetails,"CB_CoverCommDate")> --->
			
		<cfset quoteSelected = BikeQuoteDetails.CQ_quoteSelected>	
		
		

		
		<!--- <cfif IsDefined("BikeQuoteDetails.CB_CoverCommDate") and BikeQuoteDetails.CB_CoverCommDate neq ""> --->
		<cfif IsDefined("getData.last_updated") and getData.last_updated neq ""
			and purchaseDateExists neq "">	
			<!--- <cfif policyCommDateExists eq "YES" and ---> 
			<cfif quoteSelected eq CONST_BQ_QuoteComp_ListItemID> <!--- comprehensive only --->
				<!--- <cfif LSParseDateTime(BikeQuoteDetails.CB_CoverCommDate) ge CONST_START_AGREED_MARKET_VALUE> --->
				<cfif LSParseDateTime(getData.last_updated) ge CONST_START_AGREED_MARKET_VALUE>
					<cfset displayAgreedMarketValue = true>	
				</cfif>	
			</cfif>		
		</cfif>
			
		
		
		
		<cfset bikePurchaseDate =  BikeQuoteDetails.CB_PurchasedDate>


<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au"  subject="Debug" type="HTML">
	<cfdump var="#BikeQuoteDetails.CB_NewMotorcycle#">
</cfmail> --->		
		
		<!--- <cfoutput>[#bikePurchaseDate#]</cfoutput>
		<cfabort> --->
		
			
		<cfif purchaseDateExists neq "" and bikePurchaseDate neq "" and displayAgreedMarketValue> 
		
				<cfif attributes.pdfVariable.detailsManufacturer1 eq "YAMAHA">


					<cfset currentDate = now()>			
								
					<cfset monthsPurchaseDiff = DateDiff("m",bikePurchaseDate,currentDate)>

					<!--- <cfdump var="#bikePurchaseDate#">
					<cfdump var="#monthsPurchaseDiff#"> --->

					<cfif monthsPurchaseDiff lte CONST_YamahaAgreedMonths>
						<cfset agreedText = true>
					</cfif>
				<cfelse>
					<cfset currentDate = now()>			
					<cfset bikePurchaseDate =  LSParseDateTime(BikeQuoteDetails.CB_PurchasedDate)>			
					<cfset monthsPurchaseDiff = DateDiff("m",bikePurchaseDate,currentDate)>

					<!--- <cfdump var="#bikePurchaseDate#"><BR>
					<cfdump var="#monthsPurchaseDiff#"> --->

					<cfif monthsPurchaseDiff lte CONST_nonYamahaAgreedMonths>
						<cfset agreedText = true>
					</cfif>

				</cfif>
						
				<!--- <cfoutput>monthsPurchaseDiff #monthsPurchaseDiff#</cfoutput><br> --->
		</cfif>
		
		
		<cfif (IsDefined("BikeQuoteDetails.CB_NewMotorcycle") and BikeQuoteDetails.CB_NewMotorcycle eq "")
		or (IsDefined("BikeQuoteDetails.CB_NewMotorcycle") and BikeQuoteDetails.CB_NewMotorcycle eq "0")>
				<cfset agreedText = false>
				<cfset displayAgreedMarketValue = false>	
		</cfif>
		
<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->	

<!--- CREATE QUOTE SUMMARY PDF --->
<cfif CompareNoCase(attributes.docType,"QUOTESUMMARY") eq 0>
    <cfsavecontent variable="pdfHeader">
    <cfoutput>
    <table cellpadding="0" cellspacing="0" style="width:100%">
    <tr>
        <td rowspan="2"><img src="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/images/logo_ymi.png"></td>
        <td style="font-size:20px;font-weight:bold;text-align:right">Motorcycle Insurance Quote Summary</td>
    </tr>
    <tr>
        <td style="font-size:14px;font-weight:bold;text-align:right">
            #attributes.pdfVariable.dealer_firstname# #attributes.pdfVariable.dealer_lastname#, #attributes.pdfVariable.distributor# <br/>
            (Ref: #attributes.pdfVariable.reference_Id#) <br/>
            <cfif StructKeyExists(BikeQuoteDetails,listGetAt(CONST_BQ_ExtProvider_FID,1,"|")) and  StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_ExtProvider_FID,1,"|")) neq ""
                and StructKeyExists(BikeQuoteDetails,listGetAt(CONST_BQ_ExtId_FID,1,"|")) and  StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_ExtId_FID,1,"|")) neq "" >
            (Ext Ref: #StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_ExtProvider_FID,1,"|"))# - #StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_ExtId_FID,1,"|"))#)
            </cfif>
        </td>
    </tr>
    </table>
    </cfoutput>
    </cfsavecontent>
        
    <!--- CREATE QUOTE SUMMARY PDF --->
    <cfdocument format="pdf" filename="#attributes.appFormsLoc##attributes.pdfFilename#" overwrite="yes" marginLeft="0.2" marginRight="0.2" marginBottom="0.5" marginTop="0.5">
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
    
    table {border-collapse: collapse;}
    
    th {text-align: left;}
            
    td {vertical-align: top;}
    </style>
    
    <div id="thePDF">
    #pdfHeader#
    <br/>
    
    <p style="line-height:15px;">
    #DateFormat(getData.created,"DD-MMM-YYYY")#<br/><br/>    
    Thank you <b>#attributes.pdfVariable.insured_name#</b> 
    for the opportunity to quote on your Motorcycle insurance as follows. <br/>
    #attributes.pdfVariable.detailsManufacturer1# motorcycle (<b>#attributes.pdfVariable.detailsModel1#</b>) with the specification of <b>#attributes.pdfVariable.detailsModel2#</b> <br/>
    <br/>
    <b>Cover details:</b>
    </p>
    
    <table cellpadding="5" cellspacing="0" border="1"  style="width:100%;">
    <tr>
        <td colspan="4">
            <table class="subborders" border="0" cellpadding="5" cellspacing="0" style="width:100%; border: 0 none;">
            <thead>
                <th>Type</th>
                <th style="width:15%">Amount Due</th>
                <th style="width:15%">Excess</th>
                <th style="width:15%">Term</th>
            </thead>
            <tbody>
            <cfset lpDets = "">
                <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteComp_ListItemID) gt 0>
                    <tr>
                        <td>Comprehensive Road Registered Cover</td>
                        <td>$#attributes.pdfVariable.quoteComp#</td>
                        <td>#attributes.pdfVariable.excess#</td>
                        <td>12 months</td>
                    </tr>
                <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteOffRoad_ListItemID) gt 0>
                    <tr>
                        <td>Off Road/Non-registered Cover</td>
                        <td>$#attributes.pdfVariable.quoteoffRoad#</td>
                        <td>#attributes.pdfVariable.excess#</td>
                        <td>12 months</td>
                    </tr>
                <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteTPD_ListItemID) gt 0>
                    <tr>
                        <td>Third Party, Fire, Theft and Transit Cover</td>
                        <td>$#attributes.pdfVariable.quoteTPD#</td>
                        <td>#attributes.pdfVariable.excess#</td>
                        <td>12 months</td>
                    </tr>
                <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteTPO_ListItemID) gt 0>
                    <tr>
                        <td>Third Party Only Cover</td>
                        <td>$#attributes.pdfVariable.quoteTPO#</td>
                        <td>#attributes.pdfVariable.excess#</td>
                        <td>12 months</td>
                    </tr>
                </cfif>
                <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteTyreRim_ListItemID) gt 0>
                    <tr>
                        <td>Tyre & Rim Cover</td>
                        <td>$#attributes.pdfVariable.quoteTR#</td>
                        <td>$0.00</td>
                        <td>12 months</td>
                    </tr>
                </cfif>
                <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteGapCover_ListItemID) gt 0>
                    <tr>
                        <td>Gap & Extras Cover</td>
                        <td>$#attributes.pdfVariable.quoteGE#</td>
                        <td>$0.00</td>
                        <td>#attributes.pdfVariable.quoteGE_term_disp#</td>
                    </tr>
                </cfif>
                <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteLoanProtect_ListItemID) gt 0>
                    <cfset lpDets = attributes.pdfVariable.quoteLP_details>
                    <tr>
                        <td>Loan Protection Cover</td>
                        <td>$#attributes.pdfVariable.quoteLP#</td>
                        <td>$0.00</td>
                        <td>#attributes.pdfVariable.quoteLP_term_disp#</td>
                    </tr>
                </cfif>

            <!--- <br/><span style="font-size:11px">Admin Fee (inc. GST) - $#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_quoteAdminFee_FID,1,"|")),",.99")#</span><br/> --->
            </tbody>
            </table>
            &nbsp;<br/>
        </td>
    </tr>
    <tr>
        <td>Sum Insured:</td>
        <td>
		<!--- $#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99")# --->
		
		<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->	
		<cfif displayAgreedMarketValue>
			<cfif agreedText>
				Agreed ($#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99")#)
			<cfelse>
				Market Value
			</cfif>
		<cfelse>
			Market Value <!--- $#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99")# --->
		</cfif>
		<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
		</td>
        <td>Admin Fee (inc. GST):</td>
        <td>$#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_quoteAdminFee_FID,1,"|")),",.99")#</td>
    </tr>
    <tr>
        <td>Total Premium:</td>
        <td>#attributes.pdfVariable.summary_premium#</td>
        <td>Excess:</td>
        <td>#attributes.pdfVariable.excess#</td>
    </tr>
    </table>
    <br/> 
    
    <p><b>Insured Details</b></p>
    <table class="borders" border="1" cellpadding="5" cellspacing="0" style="width:100%">
    <tr>
        <td style="width:15%" valign="top">Full Name:</td>
        <td style="width:35%" valign="top">#attributes.pdfVariable.insured_name# (#left(attributes.pdfVariable.insured_sex,1)#)</td>
        <td style="width:15%" valign="top" rowspan="2">Storage Address:</td>
        <td style="width:35%" valign="top" rowspan="2">
            <i>(#attributes.pdfVariable.bike_storageMethod_disp#)</i><br/>
            <cfif trim(attributes.pdfVariable.bike_storageAddress) neq "">
                #attributes.pdfVariable.bike_storageAddress#<br/>
                <cfif attributes.pdfVariable.bike_storageSuburb neq "">#attributes.pdfVariable.bike_storageSuburb#<br/></cfif>
            <cfelse>
                #attributes.pdfVariable.insured_streetAddress#<br/>
                <cfif attributes.pdfVariable.insured_suburb neq "">#attributes.pdfVariable.insured_suburb#<br/></cfif>
            </cfif>
            #attributes.pdfVariable.insured_state# (#attributes.pdfVariable.insured_stateArea#), #attributes.pdfVariable.bike_storagePostcode# <br/>
        </td>
    </tr>
    <tr>
        <td valign="top">DOB:</td>
        <td valign="top">
            <cfif attributes.pdfVariable.insured_dob neq "">
                #attributes.pdfVariable.insured_dob#
            <cfelse>
                #StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_Age_FID,1,"|"))# year(s)
            </cfif>
        </td>
    </tr>
    <tr>
        <td valign="top">Riding Experience:</td>
        <td valign="top">#attributes.pdfVariable.insured_riding_exp# year(s)</td>
        <td valign="top">No-Claim-Benefit:</td>
        <td valign="top">#attributes.pdfVariable.insured_ncb_disp#</td>
    </tr>
    </table>
    <br/>
    
    <p><b>Other details:</b></p>
    <table cellpadding="5" cellspacing="0" border="1" style="width:100%">
    <tr>
        <td style="width:50%">
            <cfif ListLen(attributes.pdfVariable.LayUpMonths) eq 0>
            No layup months
            <cfelse>
            With #ListLen(attributes.pdfVariable.LayUpMonths)# layup months
            </cfif>                    
        </td>
        <td style="width:50%">
           &nbsp;
        </td>
    </tr>
    </table>
    <br/>
    
    
    <p style="font-size:11px;">
        Please note this quotation is valid for 30 days from the date noted above.<br/>
        For further details on this policy and coverage please refer to the policy wording available from your Yamaha dealer, or call us on 0800 664 678. <br/>
        <cfif StructKeyExists(BikeQuoteDetails,listGetAt(CONST_BQ_quoteDetails_FID,1,"|"))>
        <br/><span style="font-size:9px;">#StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_quoteDetails_FID,1,"|"))#</span><br/>
        </cfif>
    </p>  
    <br/>
       
        
    <cfdocumentitem type="pagebreak"></cfdocumentitem>
    
    #pdfHeader#
    <br/>
    <table class="borders" border="0" cellspacing="0" cellpadding="5" >
    <tbody>
        <tr>
            <td style="font-size:18px;text-align:center; font-weight: bold;">Features &amp; Benefits</td>
        </tr>
        <tr>
            <td>
                <cfif FileExists(ExpandPath("../html/inc_featurebenefit_motorcycle.cfm"))>
                    <cfinclude template="../html/inc_featurebenefit_motorcycle.cfm">
                </cfif>
            </td>
        </tr>
    </tbody>
    </table>
    
    <br/>
    
    <div style="font-size:11px;background-color:##eeeeee;padding:10px 10px;">
        <p style="font-size:11px;">
            <!--- The Insurer of this insurance is AIG Insurance New Zealand Limited (AIG).
            American International Group, Inc. (AIG) is a leading insurance organisation serving customers in more than 100 countries and jurisdictions. 
            AIG companies serve commercial, institutional, and individual customers through one of the most extensive worldwide property-casualty networks of any insurer. 
            In addition AIG companies are leading providers of life insurance and retirement services in the United States. 
            AIG common stock is listed on the New York Stock Exchange and the Tokyo Stock Exchange. --->
            The Insurers of this insurance are certain underwriters at Lloyd's of London (Lloyd's). Lloyd's of London has been a pioneer in insurance and has grown over 325 years to become the world's leading market for specialist insurance. Lloyd's of London insures people, businesses and communities in more than 200 countries and territories. Lloyd's of London's unique capital structure provides excellent financial security
            to policy holders. This insurance is underwritten by certain underwriters at Lloyd's of London (Underwriters). Lloyd's of London has current financial strength rating of A+ with
            Standard & Poor's and is listed on the London Stock Exchange.
        </p>
    </div>    
    
    </div>
    </cfoutput>
    </cfdocument>

<cfelseif CompareNoCase(attributes.docType,"COVERSUMMARY") eq 0>
    <cfsavecontent variable="pdfHeader">
    <cfoutput>
    <table cellpadding="0" cellspacing="0" style="width:100%">
    <tr>
        <td rowspan="2"><img src="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/images/logo_ymi.png"></td>
        <td style="font-size:20px;font-weight:bold;text-align:right">Motorcycle Insurance <br/> Certificate of Currency</td>
    </tr>
    <tr>
        <td style="font-size:14px;font-weight:bold;text-align:right">
            #attributes.pdfVariable.dealer_firstname# #attributes.pdfVariable.dealer_lastname#, #attributes.pdfVariable.distributor# <br/>
            (Policy Reference Number: #attributes.pdfVariable.reference_Id#) <br/>
            <cfif StructKeyExists(BikeQuoteDetails,listGetAt(CONST_BQ_ExtProvider_FID,1,"|")) and  StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_ExtProvider_FID,1,"|")) neq ""
                and StructKeyExists(BikeQuoteDetails,listGetAt(CONST_BQ_ExtId_FID,1,"|")) and  StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_ExtId_FID,1,"|")) neq "" >
            (Ext Ref: #StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_ExtProvider_FID,1,"|"))# - #StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_ExtId_FID,1,"|"))#)
            </cfif>
        </td>
    </tr>
    </table>
    </cfoutput>
    </cfsavecontent>
        
    <!--- CREATE Certificate of Currency PDF --->
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
    
    
    table {border-collapse: collapse;}
        
    th {text-align: left;}
            
    td {vertical-align: top;}
    
    .checkbox {
        width: 15px;
        height: 20px;
        border: 1px solid ##000;
        outline: 0 none;
        float: left;}
        
        .cc .checkbox {
            width: 20px;
            height: 25px;}
            
        .cc .opt {
            line-height: 25px;}
            
    .opt {
        float: left;
        padding: 0 10px 0 2px;
        font-size: 11px;
        line-height: 20px;}
        
    .clearleft {clear: left;}    
    .clearright {clear: right;}    
    .clear {clear: both;}  
    
    .gap {
        width: 5px;
        height: 20px;
        float: left;}  
        
    .borders {
        border-left: 1px solid black;
        border-bottom: 1px solid black;}
    .borders th,
    .borders td {
        border-right: 1px solid black;
        border-top: 1px solid black;}    
    .subborders th,
    .subborders td {
        text-align: left;
        border: none;}
        
    </style>
    
    <div id="thePDF">
    #pdfHeader#
    <br/>
    
    <p style="line-height:15px;">
    #DateFormat(getData.last_updated,"DD-MMM-YYYY")#<br/><br/> 
    Thank you <b>#attributes.pdfVariable.insured_name#</b>
    for trusting the insurance of your <b>#attributes.pdfVariable.detailsManufacturer1#</b> <cfif trim(attributes.pdfVariable.bike_rego_no) neq "">(Reg. No: <b>#attributes.pdfVariable.bike_rego_no#</b>)</cfif> 
    with Yamaha Motorcycle Insurance.
    (<b>#attributes.pdfVariable.detailsModel1#</b> - <b>#attributes.pdfVariable.detailsModel2#</b>) <br/>
    <br/>
    <b>Cover details:</b>
    </p>
    
    <table cellpadding="5" cellspacing="0" border="1"  style="width:100%;">
    <tr>
        <td colspan="4">
            <table class="subborders" border="0" cellpadding="5" cellspacing="0" style="width:100%; border: 0 none;">
            <thead>
                <th>Type</th>
                <th style="width:15%">Amount Due</th>
                <th style="width:15%">Excess</th>
                <th style="width:15%">Term</th>
                <th style="width:20%">Period</th>
            </thead>
            <tbody>
            <cfset lpDets = "">
            <cfif trim(attributes.pdfVariable.period_start) neq "">
                <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteComp_ListItemID) gt 0>
                    <tr>
                        <td>Comprehensive Road Registered Cover</td>
                        <td>$#attributes.pdfVariable.quoteComp#</td>
                        <td>#attributes.pdfVariable.excess#</td>
                        <td>12 months</td>
                        <td>#attributes.pdfVariable.period_start# - #attributes.pdfVariable.period_end#</td>
                    </tr>
                <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteOffRoad_ListItemID) gt 0>
                    <tr>
                        <td>Off Road/Non-registered Cover</td>
                        <td>$#attributes.pdfVariable.quoteoffRoad#</td>
                        <td>#attributes.pdfVariable.excess#</td>
                        <td>12 months</td>
                        <td>#attributes.pdfVariable.period_start# - #attributes.pdfVariable.period_end#</td>
                    </tr>
                <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteTPD_ListItemID) gt 0>
                    <tr>
                        <td>Third Party, Fire, Theft and Transit Cover</td>
                        <td>$#attributes.pdfVariable.quoteTPD#</td>
                        <td>#attributes.pdfVariable.excess#</td>
                        <td>12 months</td>
                        <td>#attributes.pdfVariable.period_start# - #attributes.pdfVariable.period_end#</td>
                    </tr>
                <cfelseif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteTPO_ListItemID) gt 0>
                    <tr>
                        <td>Third Party Only Cover</td>
                        <td>$#attributes.pdfVariable.quoteTPO#</td>
                        <td>#attributes.pdfVariable.excess#</td>
                        <td>12 months</td>
                        <td>#attributes.pdfVariable.period_start# - #attributes.pdfVariable.period_end#</td>
                    </tr>
                </cfif>
                <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteTyreRim_ListItemID) gt 0>
                    <tr>
                        <td>Tyre & Rim Cover</td>
                        <td>$#attributes.pdfVariable.quoteTR#</td>
                        <td>$0.00</td>
                        <td>12 months</td>
                        <td>#attributes.pdfVariable.period_start# - #attributes.pdfVariable.period_end#</td>
                    </tr>
                </cfif>
            
                <cfif trim(attributes.pdfVariable.quoteGE_term_disp) neq "">
                    <cfset GE_period_end = DateFormat(DateAdd("m",ListGetAt(attributes.pdfVariable.quoteGE_term_disp,1," "),LSParseDateTime(attributes.pdfVariable.period_start)),"dd/mm/yyyy")>
                <cfelse>
                    <cfset GE_period_end = DateFormat(DateAdd("m",12,LSParseDateTime(attributes.pdfVariable.period_start)),"dd/mm/yyyy")>
                </cfif>
                <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteGapCover_ListItemID) gt 0>
                    <tr>
                        <td>Gap & Extras Cover</td>
                        <td>$#attributes.pdfVariable.quoteGE#</td>
                        <td>$0.00</td>
                        <td>#attributes.pdfVariable.quoteGE_term_disp#</td>
                        <td>#attributes.pdfVariable.period_start# - #GE_period_end#</td>
                    </tr>
                </cfif>
                
                <cfif trim(attributes.pdfVariable.quoteLP_term_disp) neq "">
                    <cfset LP_period_end = DateFormat(DateAdd("m",ListGetAt(attributes.pdfVariable.quoteLP_term_disp,1," "),LSParseDateTime(attributes.pdfVariable.period_start)),"dd/mm/yyyy")>
                <cfelse>
                    <cfset LP_period_end = DateFormat(DateAdd("m",12,LSParseDateTime(attributes.pdfVariable.period_start)),"dd/mm/yyyy")>
                </cfif>
                
                <cfif ListFind(attributes.pdfVariable.opt_coverType,CONST_BQ_QuoteLoanProtect_ListItemID) gt 0>
                    <cfset lpDets = attributes.pdfVariable.quoteLP_details>
                    <tr>
                        <td>Loan Protection Cover</td>
                        <td>$#attributes.pdfVariable.quoteLP#</td>
                        <td>$0.00</td>
                        <td>#attributes.pdfVariable.quoteLP_term_disp#</td>
                        <td>#attributes.pdfVariable.period_start# - #LP_period_end#</td>
                    </tr>
                </cfif>
            </cfif>
            <!--- <br/><span style="font-size:11px">Admin Fee (inc. GST) - $#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_quoteAdminFee_FID,1,"|")),",.99")#</span><br/> --->
            </tbody>
            </table>
            &nbsp;<br/>
        </td>
    </tr>
    <tr>
        <td>Sum Insured:</td>
        <td>
		<!--- $#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99")# --->
		
		<!--- START Ticket 46291:  changes to Certificates (Market/Agreed value) --->	
		<cfif displayAgreedMarketValue>
			<cfif agreedText>
				Agreed ($#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99")#)
			<cfelse>
				Market Value
			</cfif>
		<cfelse>
			Market Value <!--- $#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_InsuredValue_FID,1,"|")),",.99")# --->
		</cfif>
		<!--- END Ticket 46291:  changes to Certificates (Market/Agreed value) --->
		</td>
        <td>Admin Fee (inc. GST):</td>
        <td>$#numberFormat(StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_quoteAdminFee_FID,1,"|")),",.99")#</td>
    </tr>
    <tr>
        <td>Total Premium:</td>
        <td>#attributes.pdfVariable.summary_premium#</td>
        <td>Excess:</td>
        <td>#attributes.pdfVariable.excess#</td>
    </tr>
    </table>
    <br/>
    
    <p><b>Insured Details</b></p>
    <table class="borders" border="0" cellpadding="5" cellspacing="0" style="width:100%">
    <tr>
        <td style="width:15%" valign="top">Full Name:</td>
        <td style="width:35%" valign="top">#attributes.pdfVariable.insured_name# (#left(attributes.pdfVariable.insured_sex,1)#)</td>
        <td style="width:15%" valign="top" rowspan="2">Address:</td>
        <td style="width:35%" valign="top" rowspan="2">
        #attributes.pdfVariable.insured_streetAddress#<br/>
        <cfif attributes.pdfVariable.insured_suburb neq "">#attributes.pdfVariable.insured_suburb#<br/></cfif>
        #attributes.pdfVariable.insured_state#, #attributes.pdfVariable.insured_postcode#<br/>
        </td>
    </tr>
    <tr>
        <td valign="top">DOB:</td>
        <td valign="top">#attributes.pdfVariable.insured_dob#</td>
    </tr>
    <tr>
        <td valign="top">Email:</td>
        <td valign="top">#attributes.pdfVariable.insured_email#</td>
        <td valign="top" rowspan="2">Storage Address:</td>
        <td valign="top" rowspan="2">
            <i>(#attributes.pdfVariable.bike_storageMethod_disp#)</i><br/>
            <cfif trim(attributes.pdfVariable.bike_storageAddress) neq "">
                #attributes.pdfVariable.bike_storageAddress#<br/>
                <cfif attributes.pdfVariable.bike_storageSuburb neq "">#attributes.pdfVariable.bike_storageSuburb#<br/></cfif>
            <cfelse>
                #attributes.pdfVariable.insured_streetAddress#<br/>
                <cfif attributes.pdfVariable.insured_suburb neq "">#attributes.pdfVariable.insured_suburb#<br/></cfif>
            </cfif>
            #attributes.pdfVariable.insured_state# (#attributes.pdfVariable.insured_stateArea#), #attributes.pdfVariable.bike_storagePostcode# <br/>
        </td>
    </tr>
    <tr>
        <td valign="top">Contact No:</td>
        <td valign="top">
        #attributes.pdfVariable.insured_phone_home#<br/>
        #attributes.pdfVariable.insured_phone_mobile#
        </td>
    </tr>
    <tr>
        <td valign="top">Riding Experience:</td>
        <td valign="top">#attributes.pdfVariable.insured_riding_exp# year(s)</td>
        <td valign="top">No-Claim-Benefit:</td>
        <td valign="top">#attributes.pdfVariable.insured_ncb#</td>
    </tr>
    <tr>
        <td colspan="4">
        
        <cfset complianceYearStarDate="#DateFormat("30/08/2018","mm/dd/yyyy")#"/>
        
        In the last <cfif getData.last_updated lte complianceYearStarDate>5<cfelse>3</cfif> years:<br/>
        Has the insured(s) had any insurance refused or cancelled? <b><cfif attributes.pdfVariable.bool_had_insurance_refused eq 1>Yes<cfelse>No</cfif></b> <br/>
        Has the insured(s) suffered any motorcycle or theft insurance claims? <b><cfif attributes.pdfVariable.bool_had_claims eq 1>Yes<cfelse>No</cfif></b><br/>
        Has the insured(s) been charged of convicted of any offence (other than vehicle/motorcycle offences)? <b><cfif attributes.pdfVariable.bool_had_convict_charged eq 1>Yes<cfelse>No</cfif></b><br/>
        Has the insured(s) ever had their motor vehicle or motorcycle license suspended or revoked for any reason? <b><cfif attributes.pdfVariable.bool_had_license_suspended eq 1>Yes<cfelse>No</cfif></b> <br/>
        <cfif IsDefined("attributes.pdfVariable.bool_has_current_valid_license")>
            Do you hold a current/valid New Zealand Motorcycle License? <b><cfif attributes.pdfVariable.bool_has_current_valid_license eq 1>Yes<cfelse>No</cfif></b><br/> 
        </cfif>
        <cfif IsDefined("attributes.pdfVariable.bool_is_business_use")>
            Is the Motorcycle used for any business/ commercial use?  <b><cfif attributes.pdfVariable.bool_is_business_use eq 1>Yes<cfelse>No</cfif></b><br/>
        </cfif>    
        </td>
    </tr>
    </table>
    <br/>
    
    <p><b>Other details:</b></p>
    <table cellpadding="5" cellspacing="0" border="1" style="width:100%">
    <tr>
        <td style="width:50%">
            <cfif ListLen(attributes.pdfVariable.LayUpMonths) eq 0>
            No layup months
            <cfelse>
            With #ListLen(attributes.pdfVariable.LayUpMonths)# layup months
            </cfif>                    
        </td>
        <td style="width:50%">
            <cfif trim(attributes.pdfVariable.insured_interestedParties) neq "">
            Interested Parties / Financiers: #attributes.pdfVariable.insured_interestedParties# &nbsp;
            </cfif>
        </td>
    </tr>
    </table>
    
    <p style="font-size:11px;">
        <cfif StructKeyExists(BikeQuoteDetails,ListFirst(CONST_BQ_quoteDetails_FID,"|"))>
            <cfset tmp=StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_quoteDetails_FID,"|"))>
            <!--- <cfset tmp = ReplaceNoCase(tmp,"^ Loan Protection - ","^ Loan Protection - #lpDets# - ")> --->
            <br/><span style="font-size:9px;">#tmp#</span><br/>
        </cfif>
    </p>
    
    <cfdocumentitem type="pagebreak"></cfdocumentitem>
    
    #pdfHeader#
    <br/>
    
    <p><b>Motorcycle Details</b></p>
    <table class="borders" border="0" cellspacing="0" cellpadding="5" style="width:100%">
    <tr>
        <td style="width:15%" valign="top">Manufacturer:</td>
        <td style="width:35%" valign="top">#attributes.pdfVariable.detailsManufacturer1# #attributes.pdfVariable.detailsManufacturer2#</td>
        <td style="width:15%" valign="top" rowspan="5">Model Details:</td>
        <td style="width:35%" valign="top" rowspan="5">
            #attributes.pdfVariable.detailsModel1# <br/>
            #attributes.pdfVariable.bikeAllDetails#
        </td>
    </tr>
    <tr>
        <td valign="top">Rego No:</td>
        <td valign="top">#attributes.pdfVariable.bike_rego_no#</td>
    </tr>
    <tr>
        <td valign="top">Frame/VIN No:</td>
        <td valign="top"><cfif ListLen(attributes.pdfVariable.bike_vin_no) gt 1>#ListGetAt(attributes.pdfVariable.bike_vin_no,1,",")#<cfelse>#attributes.pdfVariable.bike_vin_no#</cfif></td>
    </tr>
    <tr>
        <td valign="top">Engine No:</td>
        <td valign="top"><cfif ListLen(attributes.pdfVariable.bike_vin_no) gt 1>#ListGetAt(attributes.pdfVariable.bike_vin_no,2,",")#</cfif></td>
    </tr>
    
    <tr>
        <td valign="top">Original Rego Date:</td>
        <td valign="top">#StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_OriginalRegoDate_FID,1,"|"))#</td>
    </tr>
    <tr>
        <td colspan="4">
        Has the motorcycle been modified in any way from the manufacturers original specifications? <b><cfif attributes.pdfVariable.bike_is_modified eq 1>Yes<cfelse>No</cfif></b> <br/>
        <cfif attributes.pdfVariable.bike_is_modified eq 1>
        Details: #attributes.pdfVariable.bike_is_modified_desc#
        </cfif>
    </tr>    
    <tr>
        <td colspan="2">
        Is the motorcycle in current condition suitable for usage as originally manufactured for? <b><cfif attributes.pdfVariable.bike_is_usable eq 1>Yes<cfelse>No</cfif></b> <br/>
        <cfif attributes.pdfVariable.bike_is_usable eq 1>
        Details: #attributes.pdfVariable.bike_is_usable_desc#
        </cfif>
        </td>
        <td colspan="2">
            Is a trailer included?: <b>Yes / No</b>
        </td>
    </tr>
    </table>
    
    <p><b>Payment Received By</b></p>
    <table class="borders" border="0" cellpadding="5" cellspacing="0" style="width:100%">
    <tr>
        <td style="height: 25px; padding-top: 5px;">
            <div class="checkbox"></div><div class="opt"> Cheque/Money Order</div>
            <div class="checkbox"></div><div class="opt"> MasterCard</div>
            <div class="checkbox"></div><div class="opt"> Visa</div>
            <div class="checkbox"></div><div class="opt"> Financed - YMF</div>
            <div class="checkbox"></div><div class="opt"> Financed - Other _______________</div>
            <div class="checkbox"></div><div class="opt"> Pay by the Month (attach)</div>
        </td>
    </tr>
    <tr>
        <td style="height:30px; padding-top: 5px;" class="cc">
            <div class="opt">Credit Card No.:</div>
            <div class="checkbox"></div><div class="checkbox"></div><div class="checkbox"></div><div class="checkbox"></div><div class="gap"></div>
            <div class="checkbox"></div><div class="checkbox"></div><div class="checkbox"></div><div class="checkbox"></div><div class="gap"></div>
            <div class="checkbox"></div><div class="checkbox"></div><div class="checkbox"></div><div class="checkbox"></div><div class="gap"></div>
            <div class="checkbox"></div><div class="checkbox"></div><div class="checkbox"></div><div class="checkbox"></div>
            <div class="gap"></div><div class="gap"></div><div class="gap"></div><div class="gap"></div>
            
            <div class="opt">Expiry: ____ / ____</div>
            <div class="opt">CVV: _______</div>
        </td>
    </tr>
    <tr>
        <td style="height:35px; padding-top: 10px;">
            <div class="opt">Cardholder Name: ________________________________________________ </div>
            <div class="opt">Signature: ________________________________________________ </div>
        </td>
    </tr>
    </table>
    
    <br/>
    
    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
    <tr>
        <td style="width:67%;">
            Business Partner's Authorised Signature: &nbsp; ___________________________ 
        </td>
        <td>
            Date: &nbsp; ____________________
        </td>
    </tr>
    </table>
    
    <br/><br/>
    
    <p style="font-size:11px;">
    This confirmation of cover is a summary. The full policy schedule, including any endorsements to the cover, 
    will be sent by Yamaha Marine Insurance to the policy holder within 10 business days. If required earlier, please contact Yamaha Motor Insurance on 0800 664 678.
    <br/><br/>
    This schedule is to be read in conjunction with the policy wording / Product Disclosure Statement for full policy terms and conditions, 
    this is available from your local Yamaha dealer or visit http://www.yamaha-motor.co.nz/sites/yamaha-motor/files/Yamaha_PDS.pdf 
    <br/><br/>
    
    <!--- The Insurer of this insurance is AIG Insurance New Zealand Limited (AIG).
    American International Group, Inc. (AIG) is a leading insurance organisation serving customers in more than 100 countries and jurisdictions. 
    AIG companies serve commercial, institutional, and individual customers through one of the most extensive worldwide property-casualty networks of any insurer. 
    In addition AIG companies are leading providers of life insurance and retirement services in the United States. 
    AIG common stock is listed on the New York Stock Exchange and the Tokyo Stock Exchange. --->
    
    The Insurers  of  this insurance are certain underwriters at Lloyd's of London (Lloyd's). Lloyd's of London has been a pioneer in insurance and has grown over 325 years 
    to become the world's leading market for specialist insurance. Lloyd's of London insures people, businesses and communities in more than 200 countries and territories. 
    Lloyd's of London's unique capital structure provides excellent financial security to policy holders.  This insurance is underwritten by certain underwriters at Lloyd's 
    of London (Underwriters). Lloyd's of London has current financial strength rating of A+ with Standard & Poor's and is listed on the London Stock Exchange.
   
    </p>
    </div>
    </cfoutput>
    </cfdocument>



</cfif>