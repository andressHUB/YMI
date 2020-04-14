<cfmodule template="..\thirdgen\util\formurl2attributes.cfm">
<cfset appFormsLoc = "#application.BASE_FOLDER#adminMarine\appforms\">
<cfset timestampNow = DateFormat(now(),"yyyymmdd") & TimeFormat(now(),"HHmmss")>
<cfparam name="attributes.format" default="pdfPrint">

<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.created, fd.xml_data, fd.user_data_id, fd.last_updated
    from thirdgen_form_data fd 
    where fd.form_data_id = #attributes.fdid#
</cfquery>
<cfwddx action="WDDX2CFML" input="#getData.xml_data#" output="BoatQuoteDetails">



<cfset coverSelected = "">
<cfif StructKeyExists(BoatQuoteDetails,listGetAt(CONST_MQ_quoteSelected_FID,1,"|"))>
    <cfset coverSelected = StructFind(BoatQuoteDetails,listGetAt(CONST_MQ_quoteSelected_FID,1,"|"))>
</cfif>

<cfset attributes.formDataId = attributes.fdid>
    
<!--- DEALER DETAILS (start) --->
<cfif isDefined("session.thirdgenAS.userId") and session.thirdgenas.userid neq 1> <!--- admin --->
    <cfquery name="getDealerDetails" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select tfhd.text1 as dealerName, tfhd.text2 as dealerCode, tud.user_name, tud.user_email, ufd.xml_data as uXML
        from thirdgen_form_data tfd
        inner join thirdgen_user_control uc with (nolock) on tfd.user_data_id = uc.user_data_id and tfd.user_data_id = #getData.user_data_id#
        inner join thirdgen_user_data tud on uc.user_data_id = tud.user_data_id
        inner join thirdgen_tree_node_data ttnd with (nolock) on uc.default_tree_node_id = ttnd.tree_node_id
        inner join thirdgen_form_header_data tfhd with (nolock) on ttnd.form_data_id = tfhd.form_data_id
        inner join thirdgen_form_data ufd on tud.user_data_id = ufd.user_data_id and ufd.registration_id = 1
    </cfquery>
    <cfif getDealerDetails.recordCount>
        <cfwddx action="WDDX2CFML" input="#getDealerDetails.uXML#" output="userFDS">
    </cfif>
<cfelse>
    <cfquery name="getDealerDetails" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select tfhd.text1 as dealerName, tfhd.text2 as dealerCode, tud.user_name, tud.user_email, ufd.xml_data as uXML
        from thirdgen_form_data tfd
        inner join thirdgen_user_control uc with (nolock) on tfd.user_data_id = uc.user_data_id and tfd.form_data_id = #attributes.formDataId#
        inner join thirdgen_user_data tud on uc.user_data_id = tud.user_data_id
        inner join thirdgen_tree_node_data ttnd with (nolock) on uc.default_tree_node_id = ttnd.tree_node_id
        inner join thirdgen_form_header_data tfhd with (nolock) on ttnd.form_data_id = tfhd.form_data_id
        inner join thirdgen_form_data ufd on tud.user_data_id = ufd.user_data_id and ufd.registration_id = 1
    </cfquery>
    <cfif getDealerDetails.recordCount>
        <cfwddx action="WDDX2CFML" input="#getDealerDetails.uXML#" output="userFDS">
    </cfif>
</cfif>
<cfif isDefined("userFDS")>
    <cfset emailUser = StructFind(userFDS,CONST_USER_FIRST_NAME_FID)&" "&StructFind(userFDS,CONST_USER_LAST_NAME_FID)>
<cfelse>
    <cfset emailUser = "No User Found">
</cfif>

<cfif isDefined("session.thirdgenAS.userId") and session.thirdgenAS.userId gt 0>
    <cfset emailTo = session.thirdgenAS.userEmail>
<cfelse>
    <cfif getDealerDetails.recordcount>
        <cfset emailTo = getDealerDetails.user_email>
    <cfelse>
        <cfset emailTo = session.thirdgenAS.userEmail>
    </cfif>
</cfif>

<cfif isDefined("attributes.debugEmail") and attributes.debugEmail neq "">
    <cfset emailTo = attributes.debugEmail>
</cfif>

<cfset thePDFVar = StructNew()>
<cfset x = StructInsert(thePDFVar,"distributor","","YES")>
<cfset x = StructInsert(thePDFVar,"reference_id",attributes.formDataId,"YES")>
<cfif getDealerDetails.recordCount gt 0>
    <cfset x = StructInsert(thePDFVar,"distributor",getDealerDetails.dealerName,"YES")>
    <cfset x = StructInsert(thePDFVar,"reference_id",getDealerDetails.dealerCode & "-" & attributes.formDataId,"YES")>
</cfif>

<!--- DEALER DETAILS (end) --->

<cfmodule template="mod_houseKeeping.cfm" maxDaysOld="3" dirToBeCleaned="#appFormsLoc#">
<cfset PDF_PBM_filename = "YMINZ_PBM_"& StructFind(thePDFVar,"reference_id") & "_" & TimeFormat(now(),"HHmmss") & ".pdf">

<!--- Change PBTM template change financier from "Macquarie Equipment Finance Limited" to  "IQumulate Funding Services Limited" --->
<cfset PBTMTemplateName = "YMINZ_Marine_PayByMonth_form">


<!--- Change effective 18-Jun-2019 --->
<cfset newPBTMFromDate = CreateDate(2019,6,18)>

<cfif BoatQuoteDetails.CB_CoverCommDate neq "">
    <cfset CoverCommDate = LSParseDateTime(BoatQuoteDetails.CB_CoverCommDate)>
    
    <cfif CoverCommDate ge newPBTMFromDate>
            <cfset PBTMTemplateName = PBTMTemplateName & ".pdf">    
    <cfelse>
            <cfset PBTMTemplateName = PBTMTemplateName & "_pr_2019.pdf">    
    </cfif>
    
<cfelse>
        <cfset PBTMTemplateName = PBTMTemplateName & ".pdf">
</cfif>    


<!--- <cfset thePDFTemplate = "#application.BASE_FOLDER#adminMarine\pdf_template\YMINZ_Marine_PayByMonth_form.pdf"> --->
<cfset thePDFTemplate = "#application.BASE_FOLDER#adminMarine\pdf_template\#PBTMTemplateName#">


<cfmodule template="mod_createPayByMonthForm.cfm" appFormsLoc="#appFormsLoc#" PDF_PayByMonth_filename="#PDF_PBM_filename#"
        pdfTemplate="#thePDFTemplate#" formdataid="#attributes.fdid#" pdfVariable="#thePDFVar#" output="pbmResult">

<cfif FileExists("#appFormsLoc##PDF_PBM_filename#")>
    <cfif CompareNoCase(attributes.format,"pdfSummary") eq 0 >
        <cfheader name="Content-Disposition" value="inline; filename=#PDF_PBM_filename#">
        <cfheader name="expires" value="#now()#">
        <cfheader name="pragma" value="no-cache">
        <cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
        <cfcontent type="application/pdf" file="#appFormsLoc##PDF_PBM_filename#">
        <Cfabort>
        
    <cfelseif CompareNoCase(attributes.format,"pdfEmail") eq 0>
        <cfoutput>
        <cfmail to="#emailTo#" from="#application.THIRDGENPLUS_SYSTEM_EMAIL_ADDRESS#" subject="Yamaha Marine Insurance NZ Pay By Month" type="HTML">
            Hi #emailUser#, <br/>
            Your Pay by the Month application for Yamaha Insurance is attached. <br/><br/>
            Thank you.
            <cfmailparam file="#appFormsLoc##PDF_PBM_filename#">
        </cfmail>
        </cfoutput>
    </cfif>
<cfelse>
    <cfoutput>#pbmResult#</cfoutput>
</cfif>

<cfif IsDefined("attributes.redir") and attributes.redir neq "">
    <cflocation addtoken="No" url="#application.THIRDGENPLUS_ROOT#/html/#attributes.redir#">
</cfif>