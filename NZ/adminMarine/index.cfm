<cfheader name="expires" value="#now()#">
<cfheader name="pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">

<cfinclude template="constants.cfm">

<cfif FileExists(ExpandPath("..\thirdgen\registration\security.cfm"))>
    <cfinclude template="..\thirdgen\registration\security.cfm">
</cfif>
<cfset isAdmin = false>
<cfmodule template="mod_checkUserPriv.cfm" userPriv="CONST_userPrivilege">
<cfif FindNoCase("ADMIN",CONST_userPrivilege) gt 0 >
    <cfset isAdmin = true>
</cfif>

<cfparam name="act" default="main">

<cfswitch expression="#act#">
    <cfcase value="main">
        <cfif isAdmin>
            <cfinclude template="inc_admin_main.cfm">
        </cfif>
    </cfcase>
    
    <cfcase value="rates">
        <cfif isAdmin>
            <cfinclude template="inc_admin_rates.cfm">
        </cfif>
    </cfcase>
    
    <cfcase value="rateEdit">
        <cfif isAdmin>
            <cfinclude template="inc_admin_rateEdit.cfm">
        </cfif>
    </cfcase>

    <cfcase value="saveRates">
        <cfif isAdmin>
            <cfinclude template="inc_admin_saveRates.cfm">
        </cfif>
    </cfcase>

    <cfcase value="rateCopy">
        <cfif isAdmin>
            <cfinclude template="inc_admin_rateCopy.cfm">
        </cfif>
    </cfcase>
  
    <cfcase value="insertDataToForm">
        <cfif isAdmin>
            <cfinclude template="inc_admin_insertDataToForm.cfm">
        </cfif>
    </cfcase>
    
    <cfcase value="searchData">
        <cfinclude template="inc_admin_searchData.cfm">
    </cfcase>
    
    <cfcase value="updateInsurable">
        <cfinclude template="inc_admin_updateInsurable.cfm">
    </cfcase>
	
	<cfcase value="chooseQuote">
        <cfinclude template="inc_admin_chooseQuote.cfm">
    </cfcase>
    
	<cfcase value="printQuote">
        <cfinclude template="inc_admin_printQuote.cfm">
    </cfcase>

    <cfcase value="doCoverBound">
        <cfinclude template="inc_admin_doCoverBound.cfm">
    </cfcase>
    
    <cfcase value="printCoverBound">
        <cfinclude template="inc_admin_printCoverBound.cfm">
    </cfcase>
    
    <cfcase value="printPBM">
        <cfinclude template="inc_admin_printPBM.cfm">
    </cfcase>
    
    <cfcase value="thirdgenAdmin">
        <cfif isAdmin>
            <cfinclude template="inc_admin_thirdgenAdmin.cfm">
        </cfif>
    </cfcase>
    
    <cfcase value="quoteAdmin">
        <cfif isAdmin>
            <cfinclude template="inc_admin_quoteAdmin.cfm">
        </cfif>
    </cfcase>
    
     <cfcase value="quoteDealer">        
        <cfinclude template="inc_admin_quoteDealer.cfm">        
    </cfcase>
    
    <cfcase value="finalizeCoverBound">
        <cfinclude template="inc_admin_finalizeCoverBound.cfm">
    </cfcase>
    
    <cfcase value="viewQuote">
        <cfinclude template="inc_admin_viewQuote.cfm">
    </cfcase>
    
    <cfcase value="editCompliance">
        <cfif isAdmin>
            <cfset attribute.op = "compliance">
            <cfinclude template="inc_admin_editForm.cfm">
        </cfif>
    </cfcase>
    
    <cfcase value="editNonCalcFields">
        <cfif isAdmin>
            <cfset attribute.op = "nonCalculatorFields">
            <cfinclude template="inc_admin_editForm.cfm">
        </cfif>
    </cfcase>
	
	<!--- START ASF Ticket 46175 - PromoCode --->	
	<cfcase value="promoCodes"> 
			<cfif isAdmin>     
				<cfset pageTitle = "Promo Code">
	            <cfinclude template="inc_admin_promo_codes.cfm">        
			</cfif>	
    </cfcase>	
    <!--- END ASF Ticket 46175 - PromoCode --->
    
</cfswitch>