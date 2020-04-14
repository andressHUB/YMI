<cfif not IsDefined("FORM.FIELDNAMES")>
    Invalid Form. <a href="../html/myquotes.cfm">Click here to go back to Company Quotes page</a>.
    <cfabort>
</cfif>

<cfif IsDefined("URL.formDataID") and URL.formDataID neq "">

	<cfset selectCover = "">
	<cfset selectExtra = "">
	<cfset quoteComp = 0>
	<cfset quoteOffRoad = 0>
	<cfset quoteTPD = 0>
    <cfset quoteTPO = 0>
    <cfset quoteCompDetails = "">
    <cfset quoteOffRoadDetails = "">
    <cfset quoteTPDDetails = "">
    <cfset quoteTPODetails = "">
    <cfset quoteCompPrm = 0>
	<cfset quoteOffRoadPrm = 0>
	<cfset quoteTPDPrm = 0>
    <cfset quoteTPOPrm = 0>
    <cfset selectGapExtraCover = "">
    <cfset selectGapExtraCoverTerm = CONST_BQ_DefaultTerm_ListItemID> 
    <cfset quoteTyreRimCover = "">
    <cfset quoteLoanProtectCover = "">
    <cfset selectLP_CashAssistCover = "">
    <cfset selectLP_UnempCover = "">
    <cfset selectLP_DisableCover = "">
    <cfset selectLP_LifeCover = "">
    <cfset selectLoanProtectTerm = "">
    <cfset selectLoanProtectDetails = "">
    <cfset adminFee = 0>
    <!--- <cfset fslRate = 0> --->
    <cfset fslFee = 0>
    <cfset gstRate = 0.15>  <!--- 15% by default --->
    <cfset selectQuoteDetails = "">
    
	<cfloop list="#FORM.FIELDNAMES#" index="aField">
		<cfif CompareNoCase(aField,"inp_StandardCover") eq 0>
			<cfset selectCover = StructFind(FORM,aField)>	
		<cfelseif CompareNoCase(aField,"inp_quoteComp") eq 0>
			<cfset quoteComp = StructFind(FORM,aField)>
		<cfelseif CompareNoCase(aField,"inp_quoteOffRoad") eq 0>
			<cfset quoteOffRoad = StructFind(FORM,aField)>
		<cfelseif CompareNoCase(aField,"inp_quoteTPD") eq 0>
			<cfset quoteTPD = StructFind(FORM,aField)>
        <cfelseif CompareNoCase(aField,"inp_quoteTPO") eq 0>
			<cfset quoteTPO = StructFind(FORM,aField)>
        <cfelseif CompareNoCase(aField,"inp_quoteComp_details") eq 0>
			<cfset quoteCompDetails = trim(StructFind(FORM,aField))>
        <cfelseif CompareNoCase(aField,"inp_quoteOffRoad_details") eq 0>
			<cfset quoteOffRoadDetails = trim(StructFind(FORM,aField))>
        <cfelseif CompareNoCase(aField,"inp_quoteTPD_details") eq 0>
			<cfset quoteTPDDetails = trim(StructFind(FORM,aField))>
        <cfelseif CompareNoCase(aField,"inp_quoteTPO_details") eq 0>
			<cfset quoteTPODetails = trim(StructFind(FORM,aField))>
        <cfelseif CompareNoCase(aField,"inp_quoteComp_prm") eq 0>
			<cfset quoteCompPrm = StructFind(FORM,aField)>
		<cfelseif CompareNoCase(aField,"inp_quoteOffRoad_prm") eq 0>
			<cfset quoteOffRoadPrm = StructFind(FORM,aField)>
		<cfelseif CompareNoCase(aField,"inp_quoteTPD_prm") eq 0>
			<cfset quoteTPDPrm = StructFind(FORM,aField)>
        <cfelseif CompareNoCase(aField,"inp_quoteTPO_prm") eq 0>
			<cfset quoteTPOPrm = StructFind(FORM,aField)>
        <cfelseif CompareNoCase(aField,"inp_GapExtraCover") eq 0>
            <cfset selectGapExtraCover = StructFind(FORM,aField)>
        <cfelseif CompareNoCase(aField,"inp_quoteProduct_adminFee") eq 0>   
            <cfset adminFee = StructFind(FORM,aField)>
        <!--- <cfelseif CompareNoCase(aField,"inp_quoteProduct_fslRate") eq 0>  
            <cfset fslRate = StructFind(FORM,aField)/100> --->
        <cfelseif CompareNoCase(aField,"inp_quoteProduct_gstRate") eq 0>   
            <cfset gstRate = StructFind(FORM,aField)/100>
		</cfif>    
	</cfloop>
    
    <cfset adminFeeTotal = adminFee + gstRate*adminFee>
    
    <cfif selectCover eq CONST_BQ_QuoteComp_ListItemID >
        <cfset selectQuoteDetails = quoteCompDetails >
        <cfset fslFee = ListLast(quoteCompPrm,"|")>
    <cfelseif selectCover eq CONST_BQ_QuoteOffRoad_ListItemID >
        <cfset selectQuoteDetails = quoteOffRoadDetails >
        <cfset fslFee = ListLast(quoteOffRoadPrm,"|")>
    <cfelseif selectCover eq CONST_BQ_QuoteTPD_ListItemID >
        <cfset selectQuoteDetails = quoteTPDDetails >
        <cfset fslFee = ListLast(quoteTPDPrm,"|")>
    <cfelseif selectCover eq CONST_BQ_QuoteTPO_ListItemID>
        <cfset selectQuoteDetails = quoteTPODetails >
        <cfset fslFee = ListLast(quoteTPOPrm,"|")>
    </cfif>
    
    <cfquery name="getFormData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
	select xml_data, form_def_id, form_data_id
	from thirdgen_form_data
	where form_data_id = #URL.formDataID#
	</cfquery>
    <cfset theData = StructNew()>
    <cfif getFormData.recordCount gt 0>
	    <cfwddx action="WDDX2CFML" input="#getFormData.xml_data#" output="theData">
    </cfif> 

    <cfset quoteGapExtraCover = 0>
    <cfif selectGapExtraCover neq "">
        
        <!--- <cfset quoteGapExtraCover = ListGetAt(selectGapExtraCover,2,"|")>
        <cfset tmpPrem = quoteGapExtraCover / (1 + gstRate)>
        <cfset tmpGst = quoteGapExtraCover - tmpPrem> --->
        
        <cfset tmpPrem = NumberFormat(ListGetAt(selectGapExtraCover,2,"|"),".99")>
        <cfset tmpGst = gstRate*tmpPrem>
        <cfset tmpGst = NumberFormat(tmpGst,".99")>
        <cfset quoteGapExtraCover = tmpPrem + tmpGst > 
        
        <cfset tmpParam = ListGetAt(selectGapExtraCover,3,"|")>
        
        <cfsavecontent variable="quoteGapExtraCoverDetails">
        <cfoutput>
        ^ Gap & Extra Cover (Sum Insured: #tmpParam#) - (12 months)
        Base: $#NumberFormat(tmpPrem,".99")#;
        GST: $#NumberFormat(tmpGst,".99")#;
        </cfoutput>
        </cfsavecontent>
        
        <cfset selectExtra = "Sum Insured #tmpParam#">
        <cfset selectCover = ListAppend(selectCover,ListFirst(selectGapExtraCover,"|"))>
        
        <cfset selectQuoteDetails = selectQuoteDetails & " <br/>" & APPLICATION.NEWLINE & REReplace(trim(quoteGapExtraCoverDetails),"( )+"," ","ALL")>
    </cfif>
    
    <cfset selectQuoteDetails = selectQuoteDetails & " <br/>" & APPLICATION.NEWLINE & "^ Admin Fee (inc. GST): $#NumberFormat(adminFeeTotal,".99")#">
    <!--- 
    FSL is APPLIED PER PRODUCT
    <cfif fslFee gt 0>
        <cfset selectQuoteDetails = selectQuoteDetails & " <br/>" & APPLICATION.NEWLINE & "^ FSL: $#NumberFormat(fslFee,".99")#">
    </cfif> 
    --->

	<cfif getFormData.recordCount gt 0 and StructCount(theData) gt 1>
	    <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteComp_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteComp_FID,"|"),quoteComp)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteComp_FID,"|"),quoteComp)>
	    </cfif>           
	    <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteOffRoad_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteOffRoad_FID,"|"),quoteOffRoad)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteOffRoad_FID,"|"),quoteOffRoad)>
	    </cfif> 
		<cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteTPD_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteTPD_FID,"|"),quoteTPD)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteTPD_FID,"|"),quoteTPD)>
	    </cfif> 
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteTPO_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteTPO_FID,"|"),quoteTPO)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteTPO_FID,"|"),quoteTPO)>
	    </cfif> 
		<cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteSelected_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteSelected_FID,"|"),selectCover)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteSelected_FID,"|"),selectCover)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteDetails_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteDetails_FID,"|"),selectQuoteDetails)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteDetails_FID,"|"),selectQuoteDetails)>
	    </cfif>
		<cfif StructKeyExists(theData,ListFirst(CONST_BQ_extraSelected_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_extraSelected_FID,"|"),selectExtra)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_extraSelected_FID,"|"),selectExtra)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteGapCover_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteGapCover_FID,"|"),quoteGapExtraCover)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteGapCover_FID,"|"),quoteGapExtraCover)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_gapCoverTerm_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_gapCoverTerm_FID,"|"),selectGapExtraCoverTerm)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_gapCoverTerm_FID,"|"),selectGapExtraCoverTerm)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteTyreRim_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteTyreRim_FID,"|"),quoteTyreRimCover)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteTyreRim_FID,"|"),quoteTyreRimCover)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteLoanProtect_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteLoanProtect_FID,"|"),quoteLoanProtectCover)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteLoanProtect_FID,"|"),quoteLoanProtectCover)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_loanProtectTerm_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_loanProtectTerm_FID,"|"),selectLoanProtectTerm)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_loanProtectTerm_FID,"|"),selectLoanProtectTerm)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_loanProtectDetails_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_loanProtectDetails_FID,"|"),selectLoanProtectDetails)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_loanProtectDetails_FID,"|"),selectLoanProtectDetails)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteAdminFee_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteAdminFee_FID,"|"),adminFeeTotal)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteAdminFee_FID,"|"),adminFeeTotal)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_quoteFSLFee_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_quoteFSLFee_FID,"|"),fslFee)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_quoteFSLFee_FID,"|"),fslFee)>
	    </cfif>
        <cfif StructKeyExists(theData,ListFirst(CONST_BQ_QuoteStatus_FID,"|"))>
	         <cfset x = StructUpdate(theData,ListFirst(CONST_BQ_QuoteStatus_FID,"|"),CONST_BQ_QuoteStatus_stage2_LID)>
	    <cfelse>
	         <cfset x = StructInsert(theData,ListFirst(CONST_BQ_QuoteStatus_FID,"|"),CONST_BQ_QuoteStatus_stage2_LID)>
	    </cfif>
        
	    <cfwddx action="CFML2WDDX" input="#theData#" output="theDataWDDX">
        
	    <cfquery name="updateInsurable" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
	    update thirdgen_form_data
	    set xml_data = '#theDataWDDX#'
	    where form_data_id = #getFormData.form_data_id#
	    
	    update thirdgen_form_header_data
	    set #ListLast(CONST_BQ_quoteComp_FID,"|")# = #quoteComp#, #ListLast(CONST_BQ_quoteOffRoad_FID,"|")# = #quoteOffRoad#
            , #ListLast(CONST_BQ_quoteTPD_FID,"|")# = #quoteTPD#, #ListLast(CONST_BQ_quoteTPO_FID,"|")# = #quoteTPO#
            , #ListLast(CONST_BQ_extraSelected_FID,"|")# = '#selectExtra#'
	    where form_data_id = #getFormData.form_data_id#
	    </cfquery>
	</cfif>
	
    
    
    <!--- <cflocation url="admin.cfm?p=printQuote&format=pdfPrint&fdid=#URL.formDataID#" addtoken="no"> --->
    <!--- when live use the bottom one!!!! --->
	<cflocation url="admin.cfm?p=printQuote&format=pdfEmail&fdid=#URL.formDataID#" addtoken="no">

</cfif>

