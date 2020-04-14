<cfmodule template="..\thirdgen\util\formurl2attributes.cfm">
<cfset appFormsLoc = "#application.BASE_FOLDER#adminMarine\appforms\">
<cfset timestampNow = DateFormat(now(),"yyyymmdd") & TimeFormat(now(),"HHmmss")>
<cfparam name="attributes.format" default="pdfPrint">
<cfset attributes.formDataId = attributes.fdid>

<!--- DEALER DETAILS (start) --->

<!--- based on the form-owner --->
<cfquery name="getDealerDetails" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    select tfhd.text1 as dealerName, tfhd.text2 as dealerCode, ufd.xml_data as uXML
        ,tud.user_email, ufhd.text1 as firstname, ufhd.text2 as lastname, ufhd.text3 as phone
    from thirdgen_form_data tfd
    inner join thirdgen_user_control uc with (nolock) on tfd.user_data_id = uc.user_data_id and tfd.form_data_id = #attributes.formDataId#
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
<!--- DEALER DETAILS (end) --->

<!--- <cfset PDF_quote_filename = "YMINZ_"& StructFind(thePDFVar,"reference_id") &".pdf"> --->
<cfset PDF_summary_filename = "YMINZ_summary_"& StructFind(thePDFVar,"reference_id") & "_" & TimeFormat(now(),"HHmmss") & ".pdf">
<cfset PDF_PBM_filename = "YMINZ_PBM_"& StructFind(thePDFVar,"reference_id") & "_" & TimeFormat(now(),"HHmmss") & ".pdf">
<cfset PDF_PDS_filename = "">

<cfmodule template="mod_houseKeeping.cfm" maxDaysOld="3" dirToBeCleaned="#appFormsLoc#">

<cfmodule template="mod_createApplicationForm.cfm" formdataid="#attributes.formDataId#" pdfVariable="#thePDFVar#" output="pdfResult">    <!--- appFormsLoc="#appFormsLoc#" PDF_quote_filename="#PDF_quote_filename#" --->

<!--- invalid application --->
<cfif not StructKeyExists(pdfResult,"summary_premium") or StructFind(pdfResult,"summary_premium") eq 0 or StructFind(pdfResult,"summary_premium") eq "" >
    <cflocation addtoken="No" url="#application.THIRDGENPLUS_ROOT#/html/myquotes_marine.cfm?fdid=#attributes.fdid#">
</cfif>

<cfif ListFind(pdfResult.opt_coverType,CONST_MQ_Comp_LID) gt 0>
    <cfset PDF_PDS_filename = ListAppend(PDF_PDS_filename,"YMINZ_Marine_PDS.pdf")>      
<cfelseif ListFind(pdfResult.opt_coverType,CONST_MQ_MotorOnly_LID) gt 0>
    <cfset PDF_PDS_filename = ListAppend(PDF_PDS_filename,"YMINZ_Marine_PDS.pdf")>
<cfelseif ListFind(pdfResult.opt_coverType,CONST_MQ_TPO_LID) gt 0>
    <cfset PDF_PDS_filename = ListAppend(PDF_PDS_filename,"YMINZ_Marine_PDS.pdf")>
</cfif>

<cfmodule template="mod_createSummaryForm.cfm" formdataid="#attributes.formDataId#" pdfVariable="#pdfResult#" docType="QUOTESUMMARY"
    appFormsLoc="#appFormsLoc#" pdfFilename="#PDF_summary_filename#" output="xxx">

<cfif CompareNoCase(attributes.format,"pdfEmail") eq 0 or CompareNoCase(attributes.format,"pdfEmailOnly") eq 0>
    <cfset thePDFTemplate = "#application.BASE_FOLDER#adminMarine\pdf_template\YMINZ_Marine_PayByMonth_form.pdf">
    <cfmodule template="mod_createPayByMonthForm.cfm" appFormsLoc="#appFormsLoc#" PDF_PayByMonth_filename="#PDF_PBM_filename#"
        pdfTemplate="#thePDFTemplate#" pdfVariable="#thePDFVar#" formdataid="#attributes.fdid#" output="pbmResult"> 

    <cfoutput>    
    <cfmail to="#emailTo#" from="#application.THIRDGENPLUS_SYSTEM_EMAIL_ADDRESS#" replyto="#emailTo#" 
        subject="Yamaha Marine Insurance NZ (Quote - Ref:#attributes.formDataId#)" type="HTML">
        Hi #pdfResult.insured_name#, 
        <br/><br/>
        <p>
            Thank you for allowing us to provide you an Insurance quote.<br/>
            Your quote is attached along with supporting policy information for you to consider. <br/>
            Should you wish to take out a Pay by the Month option please contact our office on 0800 664 678. <br/>
            When making decisions about our insurance policies, you should consider the applicable Product Disclosure Statement relevant to this policy.<br/>
        </p>
        <br/><br/>
        Regards,
        <br/><br/>
        Yamaha Marine Insurance
        <cfmailparam file="#appFormsLoc##PDF_summary_filename#">  
        <cfloop list="#PDF_PDS_filename#" index="aPDS">
            <cfmailparam file="#application.BASE_FOLDER#resource\#aPDS#">
        </cfloop>
        <cfif FileExists("#appFormsLoc##PDF_PBM_filename#")>
            <cfmailparam file="#appFormsLoc##PDF_PBM_filename#">
        </cfif>   
    </cfmail>
    <!--- <cfmailparam file="#appFormsLoc##PDF_quote_filename#"> --->
    </cfoutput>
</cfif>

<!--- <a href="../admin/appforms/YMI_#referenceId#.pdf">Click here to view form</a> --->
<!--- <cflocation url="admin/appforms/YMI_#referenceId#.pdf" addtoken="No"> --->
<!--- <cfif CompareNoCase(attributes.format,"pdfPrint") eq 0 >
    <cfheader name="Content-Disposition" value="inline; filename=#PDF_quote_filename#">
    <cfheader name="expires" value="#now()#">
    <cfheader name="pragma" value="no-cache">
    <cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
    <cfcontent type="application/pdf" file="#appFormsLoc##PDF_quote_filename#">
    <cfabort> --->
<cfif CompareNoCase(attributes.format,"pdfSummary") eq 0 or CompareNoCase(attributes.format,"pdfEmail") eq 0 >
    <cfheader name="Content-Disposition" value="inline; filename=#PDF_summary_filename#">
    <cfheader name="expires" value="#now()#">
    <cfheader name="pragma" value="no-cache">
    <cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
    <cfcontent type="application/pdf" file="#appFormsLoc##PDF_summary_filename#">
    <cfabort>
</cfif>    
