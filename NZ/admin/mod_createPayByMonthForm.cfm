<cfinclude template="constants.cfm">
<cfparam name="attributes.appFormsLoc" default="#application.BASE_FOLDER#admin\appforms\">
<cfparam name="attributes.PDF_PayByMonth_filename" default="test.pdf">
<cfparam name="attributes.pdfVariable" default="#StructNew()#">
<cfparam name="attributes.AppFormVariable" default="#StructNew()#">
<cfparam name="attributes.pdfTemplate" default="#application.BASE_FOLDER#admin\pdf_template\YMINZ_Motorcycle_PayByMonth_form.pdf">
<cfparam name="attributes.formdataid" default="0">
<cfparam name="attributes.output" default="">

<cfif attributes.formdataid gt 0 and StructCount(attributes.pdfVariable) eq 0>
    <cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
        select fd.created, fd.user_data_id  from thirdgen_form_data fd  where fd.form_data_id = #attributes.formdataid#
    </cfquery>
    
    <!--- DEALER DETAILS (start) --->
    <cfif session.thirdgenas.userid neq 1> <!--- admin --->
        <cfquery name="getDealerDetails" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select tfhd.text1 as dealerName, tfhd.text2 as dealerCode
            from thirdgen_form_data tfd
            inner join thirdgen_user_control uc with (nolock) on tfd.user_data_id = uc.user_data_id and tfd.user_data_id = #getData.user_data_id#
            inner join thirdgen_tree_node_data ttnd with (nolock) on uc.default_tree_node_id = ttnd.tree_node_id
            inner join thirdgen_form_header_data tfhd with (nolock) on ttnd.form_data_id = tfhd.form_data_id
        </cfquery>
    <cfelse>
        <cfquery name="getDealerDetails" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select tfhd.text1 as dealerName, tfhd.text2 as dealerCode
            from thirdgen_form_data tfd
            inner join thirdgen_user_control uc with (nolock) on tfd.user_data_id = uc.user_data_id and tfd.form_data_id = #attributes.formDataId#
            inner join thirdgen_tree_node_data ttnd with (nolock) on uc.default_tree_node_id = ttnd.tree_node_id
            inner join thirdgen_form_header_data tfhd with (nolock) on ttnd.form_data_id = tfhd.form_data_id
        </cfquery>
    </cfif>
    
    <cfset attributes.pdfVariable = StructNew()>
    <cfset x = StructInsert(attributes.pdfVariable,"createdDate",getData.created,"YES")>
    <cfset x = StructInsert(attributes.pdfVariable,"distributor","","YES")>
    <cfset x = StructInsert(attributes.pdfVariable,"reference_id",attributes.formDataId,"YES")>
    <cfif getDealerDetails.recordCount gt 0>
        <cfset x = StructInsert(attributes.pdfVariable,"distributor",getDealerDetails.dealerName,"YES")>
        <cfset x = StructInsert(attributes.pdfVariable,"reference_id",getDealerDetails.dealerCode & "-" & attributes.formDataId,"YES")>
    </cfif>
</cfif>

<cfset LOCAL_insurancePremium = 0>
<cfif attributes.formdataid gt 0 and StructCount(attributes.AppFormVariable) eq 0>
    <cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select fd.created, fd.xml_data, fd.user_data_id
    from thirdgen_form_data fd 
    where fd.form_data_id = #attributes.formDataID#
    </cfquery>
    <cfwddx action="WDDX2CFML" input="#getData.xml_data#" output="BikeQuoteDetails">
        
    <cfset attributes.AppFormVariable = StructNew()>
    <cfset x = StructInsert(attributes.AppFormVariable,"insured_name",StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_FirstName_FID,1,"|")) & " " & StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_Surname_FID,1,"|")),"YES")>
    <cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_Homephone_FID,1,"|"))>
        <cfset x = StructInsert(attributes.AppFormVariable,"insured_phone_home",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_Homephone_FID,1,"|")),"YES")>
    <cfelse>
        <cfset x = StructInsert(attributes.AppFormVariable,"insured_phone_home","","YES")>
    </cfif>
    <cfif StructKeyExists(BikeQuoteDetails, listGetAt(CONST_BQ_MobilePhone_FID,1,"|"))>
        <cfset x = StructInsert(attributes.AppFormVariable,"insured_phone_mobile",StructFind(BikeQuoteDetails, listGetAt(CONST_BQ_MobilePhone_FID,1,"|")),"YES")>
    <cfelse>
        <cfset x = StructInsert(attributes.AppFormVariable,"insured_phone_mobile","","YES")>
    </cfif>
    
    <cfset coverSelected = "">
    <cfif StructKeyExists(BikeQuoteDetails,listGetAt(CONST_BQ_quoteSelected_FID,1,"|"))>
        <cfset coverSelected = StructFind(BikeQuoteDetails,listGetAt(CONST_BQ_quoteSelected_FID,1,"|"))>
    </cfif>
    
    <!---  <cfif coverSelected neq "">
        <cfset LOCAL_insurancePremium = "">
        <cfquery name="getPremiumValue" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_image
            from thirdgen_list_item
            where list_item_id = #coverSelected#
        </cfquery>
        <cfif getPremiumValue.recordCount gt 0>
            <cfset LOCAL_insurancePremium = StructFind(BikeQuoteDetails,listGetAt(getPremiumValue.list_item_image,1,"|"))>
            <cfset LOCAL_insurancePremium = reReplaceNoCase(LOCAL_insurancePremium,"[$, ]","","all")>            
            <cfset x = StructInsert(attributes.AppFormVariable,"summary_premium","$"&numberFormat(LOCAL_insurancePremium,",.99"),"YES")>
        </cfif>
    </cfif>  --->
    
    <cfloop list="#coverSelected#" index="aCover">
        <cfquery name="getPremiumValue" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select list_item_image
            from thirdgen_list_item
            where list_item_id = #aCover#
        </cfquery>
        <cfset temp_insurancePremium = 0>
        <cfif getPremiumValue.recordCount gt 0 
            and (aCover eq CONST_BQ_QuoteComp_ListItemID OR aCover eq CONST_BQ_QuoteOffRoad_ListItemID 
                OR aCover eq CONST_BQ_QuoteTPD_ListItemID OR aCover eq CONST_BQ_QuoteTPO_ListItemID
                OR aCover eq CONST_BQ_QuoteTyreRim_ListItemID) >
            <!--- PBM only applicable to COMP, MOTOR, and TPO --->
            <cfset temp_insurancePremium = StructFind(BikeQuoteDetails,listGetAt(getPremiumValue.list_item_image,1,"|"))>
            <cfset temp_insurancePremium = reReplaceNoCase(temp_insurancePremium,"[$, ]","","all")>
        </cfif>
        <cfset LOCAL_insurancePremium =  LOCAL_insurancePremium + temp_insurancePremium>
    </cfloop>
    <cfif LOCAL_insurancePremium neq 0> <!--- if there is some product chosen - then add admin fee --->
        <cfset LOCAL_insurancePremium =  LOCAL_insurancePremium + reReplaceNoCase(StructFind(BikeQuoteDetails,ListFirst(CONST_BQ_quoteAdminFee_FID,"|")),"[$, ]","","all")>
    </cfif>
    
    <cfset x = StructInsert(attributes.AppFormVariable,"summary_premium","$"&numberFormat(LOCAL_insurancePremium,",.99"),"YES")>    
</cfif>

<cfif LOCAL_insurancePremium gt 1>
    
    <!--- Get the active rates --->
    <cfquery name="getExistingRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select ymrd.*, ymrc.startAt
        from (select top 1 * from ymi_motorcycle_rateControl where startAt < #CreateODBCDateTime(now())# and motorcycle_company_id = #CONST_MOTORCYCLE_COMP_ID# order by startAt desc) ymrc
        inner join ymi_motorcycle_rateData ymrd on ymrc.motorcycle_rateControlID = ymrd.motorcycle_rateControlID
    </cfquery>
    
    <!--- 
    Direct Debit
    $800.00 x 10% = $80.00 
    $800.00 + 80.00 =  $880.00    (funding Total)   divided by 12 = $73.33 
    
    Credit Card  additional 1.39% charged 
    $800.00 x 11.20% = $91.12 
    $800.00 + 91.12 = $891.12  (funding total) divided by 12 = $74.26
    --->
    
    <cfset thePremium = reReplaceNoCase(attributes.AppFormVariable.summary_premium,"[$, ]","","all")>
    <cfset theAdminCharge = "">
    <cfset amount_directdebit = "">
    <cfset amount_creditcard = "">
    
    <cfquery name="getSpecificRate" dbtype="query">
    select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_PayByMonthCharge# order by motorcycle_rate_item_id
    </cfquery>
    <cfif LSIsNumeric(thePremium) and thePremium gt 1 and getSpecificRate.motorcycle_rate_item_id neq "">
        <cfset PBMBaseRates = getSpecificRate.loadingPercent>
    
        <cfset theAdminCharge = numberFormat((getSpecificRate.loadingPercent/100 * thePremium),".99")>
        <cfset amount_directdebit = (thePremium + theAdminCharge)/12 >
        
        <cfquery name="getSpecificRate" dbtype="query">
        select * from getExistingRates where motorcycle_rateCategoryID = #CONST_ID_PayByMonthCharge_CCExtra# order by motorcycle_rate_item_id
        </cfquery>
        <cfif LSIsNumeric(thePremium) and thePremium gt 1 and getSpecificRate.motorcycle_rate_item_id neq "">
            <!--- <cfset theAdminCharge = numberFormat(((PBMBaseRates + getSpecificRate.loadingPercent)/100 * thePremium),",.99")>
            <cfset amount_creditcard = (thePremium + theAdminCharge)/12 > --->
            <cfset amount_creditcard = ((1 + getSpecificRate.loadingPercent/100) * amount_directdebit)>
        </cfif>
    </cfif>
    
    <cfset amount_directdebit = numberFormat(amount_directdebit,",.99")>
    <cfset amount_creditcard = numberFormat(amount_creditcard,",.99")>
    
    <cfset tmpFile = "pdfResponse_motorcycle_yminz_pbm_#attributes.formDataId#.pdf">
    <cfpdfform source="#attributes.pdfTemplate#" destination="#attributes.appFormsLoc##tmpFile#" overwrite="yes" action="populate">
        <cfpdfformparam name="distributor" value="#attributes.pdfVariable.distributor#">
        <cfpdfformparam name="reference_id" value="#attributes.pdfVariable.reference_id#">  
        <cfpdfformparam name="reference_id_2" value="#attributes.pdfVariable.reference_id#">    
        <cfpdfformparam name="payee_name" value="#attributes.AppFormVariable.insured_name#">
        <cfpdfformparam name="payee_phone" value="#attributes.AppFormVariable.insured_phone_home#">
        <cfpdfformparam name="payee_mobile" value="#attributes.AppFormVariable.insured_phone_mobile#">
    
        <cfpdfformparam name="premium_total" value="#thePremium#">
        <cfpdfformparam name="premium_admin" value="#theAdminCharge#">
        <cfpdfformparam name="premium_installment" value="#amount_directdebit#">
        <cfpdfformparam name="payee_directdebit_amount_monthly" value="#amount_directdebit#">
        <cfpdfformparam name="payee_creditcard_amount_monthly" value="#amount_creditcard#">
    </cfpdfform>

   <!---  <cfpdfform source="#attributes.pdfTemplate#" destination="#attributes.appFormsLoc##attributes.PDF_PayByMonth_filename#" overwrite="yes" action="populate">
        <cfpdfformparam name="distributor" value="#attributes.pdfVariable.distributor#">
        <cfpdfformparam name="reference_id" value="#attributes.pdfVariable.reference_id#">  
        <cfpdfformparam name="reference_id_2" value="#attributes.pdfVariable.reference_id#">    
        <cfpdfformparam name="payee_name" value="#attributes.AppFormVariable.insured_name#">
        <cfpdfformparam name="payee_phone" value="#attributes.AppFormVariable.insured_phone_home#">
        <cfpdfformparam name="payee_mobile" value="#attributes.AppFormVariable.insured_phone_mobile#">
    
        <cfpdfformparam name="premium_total" value="#thePremium#">
        <cfpdfformparam name="premium_admin" value="#theAdminCharge#">
        <cfpdfformparam name="premium_installment" value="#amount_directdebit#">
        <cfpdfformparam name="payee_directdebit_amount_monthly" value="#amount_directdebit#">
        <cfpdfformparam name="payee_creditcard_amount_monthly" value="#amount_creditcard#">
    </cfpdfform> --->
  
    <cfpdf action="write" destination="#attributes.appFormsLoc##attributes.PDF_PayByMonth_filename#" flatten="yes" source="#attributes.appFormsLoc##tmpFile#" overwrite="yes">

    <cftry>
        <cffile action="DELETE" file="#attributes.appFormsLoc##tmpFile#">
        <cfcatch type="Any">
        </cfcatch>
    </cftry>
    
    
<cfelse>
    <cfif FileExists("#attributes.appFormsLoc##attributes.PDF_PayByMonth_filename#")>
        <cffile action="DELETE" file="#attributes.appFormsLoc##attributes.PDF_PayByMonth_filename#">
    </cfif>
    
    <cfif attributes.output neq "">
        <cfset outputVar = "caller.#attributes.output#"> 
        <cfset setVariable(outputVar,"Pay By The Month is not applicable to this quote - Ref Id: #attributes.formDataId#")>
    </cfif>
    
</cfif>

