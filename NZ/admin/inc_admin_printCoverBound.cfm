<cfmodule template="..\thirdgen\util\formurl2attributes.cfm">
<cfset appFormsLoc = "#application.BASE_FOLDER#admin\appforms\">
<cfset timestampNow = DateFormat(now(),"yyyymmdd") & TimeFormat(now(),"HHmmss")>
<cfparam name="attributes.format" default="pdfPrint">
<cfset attributes.formDataId = attributes.fdid>

<!--- DEALER DETAILS (start) --->

<!--- based on the form-owner --->
<cfquery name="getDealerDetails" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    select tfhd.text1 as dealerName, tfhd.text2 as dealerCode, ufd.xml_data as uXML, tli.list_item_display as dealerState
        ,tud.user_email, ufhd.text1 as firstname, ufhd.text2 as lastname, ufhd.text3 as phone
    from thirdgen_form_data tfd
    inner join thirdgen_user_control uc with (nolock) on tfd.user_data_id = uc.user_data_id and tfd.form_data_id = #attributes.formDataId#
    inner join thirdgen_tree_node_data ttnd with (nolock) on uc.default_tree_node_id = ttnd.tree_node_id
    inner join thirdgen_form_header_data tfhd with (nolock) on ttnd.form_data_id = tfhd.form_data_id
    inner join thirdgen_list_item tli with (nolock) on tfhd.newlist1 = tli.list_item_id
    inner join thirdgen_user_data tud on uc.user_data_id = tud.user_data_id
    inner join thirdgen_form_data ufd on tud.user_data_id = ufd.user_data_id and ufd.registration_id = 1 and ufd.form_Def_id = (select top 1 form_def_id from thirdgen_registration)
    inner join thirdgen_form_header_data ufhd on ufd.form_data_id = ufhd.form_data_id
</cfquery>
<cfif getDealerDetails.recordCount>
    <cfwddx action="WDDX2CFML" input="#getDealerDetails.uXML#" output="userFDS">
</cfif>

<cfset thePDFVar = StructNew()>
<cfset x = StructInsert(thePDFVar,"distributor","","YES")>
<cfset x = StructInsert(thePDFVar,"reference_id",attributes.formDataId,"YES")>
<cfif getDealerDetails.recordCount gt 0>
    <cfset x = StructInsert(thePDFVar,"distributor",getDealerDetails.dealerName,"YES")>
    <cfset x = StructInsert(thePDFVar,"reference_id",getDealerDetails.dealerCode & "-" & attributes.formDataId,"YES")>
    <cfset x = StructInsert(thePDFVar,"dealer_firstname",getDealerDetails.firstname,"YES")>
    <cfset x = StructInsert(thePDFVar,"dealer_lastname",getDealerDetails.lastname,"YES")>
</cfif>

<cfif isDefined("userFDS")>
    <cfset emailUser = StructFind(userFDS,CONST_USER_FIRST_NAME_FID)&" "&StructFind(userFDS,CONST_USER_LAST_NAME_FID)>
<cfelse>
    <cfset emailUser = SESSION.thirdgenAS.userName>
</cfif>


<!--- based on the currently logged-in user --->
<cfset emailTo = "">
<cfif isDefined("SESSION.thirdgenAS.userId") 
    and SESSION.thirdgenAS.userId gt 0
    and SESSION.thirdgenAS.userEmail neq "">
    <cfset emailTo = SESSION.thirdgenAS.userEmail>
<cfelseif getDealerDetails.recordcount gt 0>
    <cfset emailTo = getDealerDetails.user_email>
</cfif>

<!--- <cfinclude template="../html/include/indexwizard517.htm">
<cfset stateContactEmail = "">
<cfif StructKeyExists(contactsStruct,"Motorcycle|#getDealerDetails.dealerState#")>
    <cfset stateContact = StructFind(contactsStruct,"Motorcycle|#getDealerDetails.dealerState#")>
    <cfset stateContactEmail = stateContact.email>
</cfif> --->
<cfset stateContactEmail = CONST_BDM_Email>

<cfif isDefined("attributes.debugEmail") and attributes.debugEmail neq "">
    <cfset emailTo = attributes.debugEmail>
    <cfset stateContactEmail = attributes.debugEmail>
</cfif>

<!--- DEALER DETAILS (end) --->

<cfset PDF_quote_filename = "YMINZ_"& StructFind(thePDFVar,"reference_id") & "_" & TimeFormat(now(),"HHmmss") & ".pdf">
<cfset PDF_CBsummary_filename = "YMINZ_CBsummary_"& StructFind(thePDFVar,"reference_id") & "_" & TimeFormat(now(),"HHmmss") & ".pdf">
<cfset PDF_PDS_filename = "">

<cfmodule template="mod_houseKeeping.cfm" maxDaysOld="3" dirToBeCleaned="#appFormsLoc#">

<cfmodule template="mod_createApplicationForm.cfm" appFormsLoc="#appFormsLoc#" pdfFilename="#PDF_quote_filename#"
    formdataid="#attributes.formDataId#" pdfVariable="#thePDFVar#" output="pdfResult">
    
<cfif ListFind(pdfResult.opt_coverType,CONST_BQ_QuoteComp_ListItemID) gt 0>
    <cfset PDF_PDS_filename = ListAppend(PDF_PDS_filename,"YMINZ_Motorcycle_PDS.pdf")>
<cfelseif ListFind(pdfResult.opt_coverType,CONST_BQ_QuoteOffRoad_ListItemID) gt 0>
    <cfset PDF_PDS_filename = ListAppend(PDF_PDS_filename,"YMINZ_Motorcycle_PDS.pdf")>
</cfif>

<!--- <cfif ListFind(pdfResult.opt_coverType,CONST_BQ_QuoteLoanProtect_ListItemID) gt 0>
    <cfset PDF_PDS_filename = ListAppend(PDF_PDS_filename,"")>
</cfif>
<cfif ListFind(pdfResult.opt_coverType,CONST_BQ_QuoteGapCover_ListItemID) gt 0>
    <cfset PDF_PDS_filename = ListAppend(PDF_PDS_filename,"")>
</cfif>
<cfif ListFind(pdfResult.opt_coverType,CONST_BQ_QuoteTyreRim_ListItemID) gt 0>
    <cfset PDF_PDS_filename = ListAppend(PDF_PDS_filename,"")>
</cfif> --->

<cfmodule template="mod_createSummaryForm.cfm" formdataid="#attributes.formDataId#" pdfVariable="#pdfResult#" docType="COVERSUMMARY"
    appFormsLoc="#appFormsLoc#" pdfFilename="#PDF_CBsummary_filename#" output="xxx">
    
<!--- <cfset thePDFTemplate = "#application.BASE_FOLDER#adminMotor\pdf_template\YMIAus_Motorcycle_PayByMonth_form.pdf">
<cfmodule template="mod_createPayByMonthForm.cfm" appFormsLoc="#appFormsLoc#" PDF_PayByMonth_filename="#PDF_PBM_filename#"
    pdfTemplate="#thePDFTemplate#" pdfVariable="#thePDFVar#" formdataid="#attributes.fdid#" output="pbmResult"> <!--- AppFormVariable="#pdfResult#" ---> --->
    
<cfif CompareNoCase(attributes.format,"pdfEmail") eq 0>
    <cfoutput>

    <cfset emailToAddr = emailTo>
    <!--- <cfif StructKeyExists(pdfResult,"insured_email") and StructFind(pdfResult,"insured_email") neq "">
        <cfset emailToAddr = ListAppend(emailToAddr,StructFind(pdfResult,"insured_email"))>
    </cfif> --->
    <cfmail to="#emailToAddr#" bcc="#stateContactEmail#" from="#application.THIRDGENPLUS_SYSTEM_EMAIL_ADDRESS#" replyto="#stateContactEmail#" 
        subject="Yamaha Motorcycle Insurance NZ (#pdfResult.insured_name#) (Cover Bound - Ref:#attributes.formDataId#)" type="HTML">
        Hi #pdfResult.insured_name#, 
        <br/><br/>
        <p>
            Thank you for choosing Yamaha Insurance for your insurance needs.<br/>
            Your Certificate of Currency and Product Disclosure Statement are attached. <br/>
            Further documents will be sent to your nominated email address within 10 working days.<br/>
        </p>
        <br/><br/>
        Regards,
        <br/><br/>
        Yamaha Motorcycle Insurance
        <cfmailparam file="#appFormsLoc##PDF_quote_filename#">
        <cfmailparam file="#appFormsLoc##PDF_CBsummary_filename#">
        <cfloop list="#PDF_PDS_filename#" index="aPDS">
        	<cfmailparam file="#application.BASE_FOLDER#resource\#aPDS#">
    	</cfloop>
    </cfmail>
    </cfoutput>
</cfif>

<cfif CompareNoCase(attributes.format,"pdfPrint") eq 0  >
    <cfheader name="Content-Disposition" value="inline; filename=#PDF_quote_filename#"> 
    <cfheader name="expires" value="#now()#">
    <cfheader name="pragma" value="no-cache">
    <cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
    <cfcontent type="application/pdf" file="#appFormsLoc##PDF_quote_filename#">
    <cfabort> 
<cfelseif CompareNoCase(attributes.format,"pdfSummary") eq 0 >
    <cfheader name="Content-Disposition" value="inline; filename=#PDF_CBsummary_filename#">
    <cfheader name="expires" value="#now()#">
    <cfheader name="pragma" value="no-cache">
    <cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
    <cfcontent type="application/pdf" file="#appFormsLoc##PDF_CBsummary_filename#">
    <cfabort>
</cfif>

<cfif attributes.redir neq "">
    <cflocation addtoken="No" url="#application.THIRDGENPLUS_ROOT#/html/#attributes.redir#">
</cfif>