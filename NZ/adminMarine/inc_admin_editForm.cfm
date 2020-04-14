<cfinclude template="../adminMarine/constants.cfm">
<cfparam name="attribute.op" default="compliance">

<cfquery name="selectQuote" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
select fd.form_data_id, fd.xml_data, fd.created,  fd.last_updated, fdtn.tree_node_id
from thirdgen_form_data fd
inner join thirdgen_form_header_data fhd on fd.form_Data_id = fhd.form_Data_id
inner join thirdgen_form_data_tree_node fdtn on fd.form_Data_id = fdtn.form_Data_id
where fd.form_def_id = #CONST_marineQuoteFormDefId#
and fd.form_data_id = #URL.fdid#
</cfquery>

<cfif IsDefined("URL.op")>
    <cfset attribute.op = URL.op>
</cfif>

<cfif selectQuote.xml_data eq "">
    No Data
<cfelse>
    <cfwddx action="WDDX2CFML" input="#selectQuote.xml_data#" output="boatQuoteStruct">

    <cfset attributes.formDefId = CONST_marineQuoteFormDefId>
    <cfset attributes.registrationID = 1> <!--- this is hack ?! --->
    <cfset attributes.siteID = session.thirdgenAS.siteID>
    <cfset attributes.regUserID = session.thirdgenas.userid>
    <cfset attributes.formDataID = URL.fdid>
    <cfset attributes.formAction = "edit">
    <!--- <cfset attributes.redirectURL = "#admin#quoteAdmin"> --->
    <cfset attributes.redirectURL = "#CGI.script_name#?act=#URL.act#&fdid=#URL.fdid#">
    <cfif NOT isdefined("attributes.fml")>
        <cfset attributes.fml="">
    </cfif>
    <cfset WSQuoteOptions = "">
    
    <cfset isExternalData = false>
    <cfif StructKeyExists(boatQuoteStruct,ListFirst(CONST_MQ_ExtId_FID,"|")) and StructFind(boatQuoteStruct,ListFirst(CONST_MQ_ExtId_FID,"|")) neq "" >
        <cfset isExternalData = true>
    </cfif>
    <cfif not StructKeyExists(boatQuoteStruct,ListFirst(CONST_MQ_manualEditReason_FID,"|"))>
        <cfset x = StructInsert(boatQuoteStruct,ListFirst(CONST_MQ_manualEditReason_FID,"|"),"")>
    </cfif>
    
    <cfif isExternalData>
        <cfquery name="getWSQuoteData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select ws_data_id, ws_data, last_updated 
        from ymi_marine_ws_data
        where data_type = 'COVER_OPTIONS'
        and form_data_id = #selectQuote.form_data_id# 
        and requester_id = '#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|"))#'
        and external_id = '#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_ExtId_FID,"|"))#'
        </cfquery>
        <cfif getWSQuoteData.recordCount gt 0>
            <cfwddx action="WDDX2CFML" input="#getWSQuoteData.ws_data#" output="coverQuoteStruct">
            <cfsavecontent variable="WSQuoteOptions"><cfoutput>
            <br/>
            Cover Options:<br/>
            
            <table cellpadding="5" cellspacing="0" border="1">
            <cfset tmpStruct = StructFind(coverQuoteStruct,"FEE_ADMIN")>
            <tr>
                <td>Admin Fee</td>
                <td>
                    base: $#NumberFormat(tmpStruct.base,".99")#<br/>
                    gst: $#NumberFormat(tmpStruct.GST,".99")#<br/>
                    total: $#NumberFormat(tmpStruct.total,".99")#<br/>
                </td>
            </tr>
            <cfloop collection="#coverQuoteStruct#" item="aCover">
                <cfset tmpStruct = StructFind(coverQuoteStruct,aCover)>
                <cfif StructKeyExists(tmpStruct,"totalPremium") and StructKeyExists(tmpStruct,"int_code")>
                <tr>
                    <td>(#aCover#) #tmpStruct.covername#</td>
                    <td>
                        base: $#NumberFormat(tmpStruct.base,".99")#<br/>
                        gst: $#NumberFormat(tmpStruct.GST,".99")#<br/>
                        fsl: $#NumberFormat(tmpStruct.fsl,".99")#<br/>
                        total: $#NumberFormat(tmpStruct.totalPremium,".99")#<br/>
                        <cfif StructKeyExists(tmpStruct,"details")>
                            (#tmpStruct.details#)<br/>
                        </cfif>
                    </td>
                </tr>
                </cfif>
            </cfloop>
            </table>
            </cfoutput></cfsavecontent>
        </cfif>
        
       <!---  <cfdump var="#coverQuoteStruct#"> --->
    </cfif>
    
    
    <cfif CompareNoCase(attribute.op,"compliance") eq 0>       
        <cfinclude template="../thirdgen/query/qry_form_def_fields.cfm" >
        <cfquery name="CBFields" dbtype="query">
        select key_name
        from FormDefFieldsQuery
        where key_name like 'CB_%'
        </cfquery>
        <cfloop query="CBFields">
            <cfset attributes.fml = listAppend(attributes.fml,"#CBFields.key_name#~H")>
        </cfloop>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteComp_FID,'|')#~R")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteMotorOnly_FID,'|')#~R")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteTPO_FID,'|')#~R")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteGapCover_FID,'|')#~R")> 
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_extraSelected_FID,'|')#~H")>
        
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteSelected_FID,'|')#~H")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteDetails_FID,'|')#~H")>  
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteAdminFee_FID,'|')#~H")> 
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_manualEditReason_FID,'|')#~H")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_manualEditor_FID,'|')#~H")>
            
        <cfif StructKeyExists(boatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|")) and StructFind(boatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|")) neq "">
            <!--- do nothing --->
        <cfelse>           
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_ExtProvider_FID,'|')#~H")> 
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_ExtId_FID,'|')#~H")> 
        </cfif>
       
        <cfoutput>
        <style>
        tr##tr_field_#CONST_MQ_ignoreCompl_FID#, tr##tr_field_#CONST_MQ_ignoreComplReason_FID#{background-color:##ffcccc}
        </style>
        <h2>#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_FirstName_FID,"|"))# #StructFind(boatQuoteStruct,ListFirst(CONST_MQ_Surname_FID,"|"))# at #DateFormat(selectQuote.created,"DD-MMM-YYYY")#</h2>
        (last updated: #DateFormat(selectQuote.last_updated,"DD-MMM-YYYY")#)
        <br/><br/>
        <div style="background-color:##000000;color:##ffffff;font-weight:bold;padding:5px;">* This submission will not recalculate the price</div>
        <cfinclude template="..\thirdgen\form\inc_form_handler.cfm">
        
        <cfif IsDefined("session.thirdgenAS.userid") and session.thirdgenAS.userid neq 1> <!--- only Super Admin can view all fields --->
            <!--- <cfset attributes.ignoreValidation = true> --->
            <cfmodule template="../custom/mod_marineQuoteForm.cfm" incValidation=false ignoreInsValue=true formDataId="#attributes.formDataID#">
        </cfif>

        </cfoutput>
        
        <cfoutput>
        <div style="background-color:##000000;color:##ffffff;font-weight:bold;padding:5px;">* This submission will not recalculate the price</div><br/>
        #WSQuoteOptions#
        </cfoutput>
        
        
    <cfelseif CompareNoCase(attribute.op,"updateWSData") eq 0>
    
        <cfquery name="getWSQuoteData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select ws_data_id, ws_data, last_updated 
        from ymi_marine_ws_data
        where data_type = 'COVER_OPTIONS'
        and form_data_id = #selectQuote.form_data_id# 
        and requester_id = '#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|"))#'
        and external_id = '#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_ExtId_FID,"|"))#'
        </cfquery>
        <cfif getWSQuoteData.recordCount gt 0>
            <cfwddx action="WDDX2CFML" input="#getWSQuoteData.ws_data#" output="coverQuoteStruct">
    
            <cfif IsDefined("FORM")>
                <cfloop index="fieldName" list="#FORM.FieldNames#">
                    <cfset prem_prm = ListFirst(fieldName,"_")>
                    <cfset prod_code = ListLast(fieldName,"_")>
                    <cfif StructKeyExists(coverQuoteStruct,prod_code)>
                        <cfset aStruct = StructFind(coverQuoteStruct,prod_code)>
                        <cfset x = StructUpdate(aStruct,prem_prm,FORM[fieldName])>
                    </cfif>
                    <cfif compareNoCase(prem_prm,"totalPremium") eq 0>
                        <cfif compareNoCase(prod_code,"COMP") eq 0>
                            <cfset x = StructInsert(boatQuoteStruct,ListFirst(CONST_MQ_quoteComp_FID,"|"),FORM[fieldName],true)>
                        <cfelseif compareNoCase(prod_code,"MOTOR") eq 0>
                            <cfset x = StructInsert(boatQuoteStruct,ListFirst(CONST_MQ_quoteMotorOnly_FID,"|"),FORM[fieldName],true)>
                        <cfelseif compareNoCase(prod_code,"TPO") eq 0>
                            <cfset x = StructInsert(boatQuoteStruct,ListFirst(CONST_MQ_quoteTPO_FID,"|"),FORM[fieldName],true)>
                        <cfelseif compareNoCase(prod_code,"GAP") eq 0>
                            <cfset x = StructInsert(boatQuoteStruct,ListFirst(CONST_MQ_quoteGapCover_FID,"|"),"",true)> <!--- ignore --->
                        </cfif>
                    </cfif>
                </cfloop>
                <cfwddx action="CFML2WDDX" input="#coverQuoteStruct#" output="ws_data_WDDX">
                <cfquery name="updateWSQuoteData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                update ymi_marine_ws_data set ws_data = '#ws_data_WDDX#' where ws_data_id = #getWSQuoteData.ws_data_id#
                </cfquery>
    
                <cfwddx action="CFML2WDDX" input="#boatQuoteStruct#" output="boatQuoteStructWDDX">
                <cfquery name="updateInsurable" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        	    update thirdgen_form_data
        	    set xml_data = '#boatQuoteStructWDDX#', last_updated = #CreateODBCDateTime(now())#
        	    where form_data_id = #selectQuote.form_data_id#
        	    
        	    update thirdgen_form_header_data
        	    set form_header_def_id = form_header_def_id
                <cfif StructFind(boatQuoteStruct,ListFirst(CONST_MQ_quoteComp_FID,"|")) neq "">
                ,#ListLast(CONST_MQ_quoteComp_FID,"|")# = #StructFind(boatQuoteStruct,ListFirst(CONST_MQ_quoteComp_FID,"|"))# 
                </cfif>
                <cfif StructFind(boatQuoteStruct,ListFirst(CONST_MQ_quoteMotorOnly_FID,"|")) neq "">
                ,#ListLast(CONST_MQ_quoteMotorOnly_FID,"|")# = #StructFind(boatQuoteStruct,ListFirst(CONST_MQ_quoteMotorOnly_FID,"|"))# 
                </cfif>
                <cfif StructFind(boatQuoteStruct,ListFirst(CONST_MQ_quoteTPO_FID,"|")) neq "">
                ,#ListLast(CONST_MQ_quoteTPO_FID,"|")# = #StructFind(boatQuoteStruct,ListFirst(CONST_MQ_quoteTPO_FID,"|"))# 
                </cfif>
        	    where form_data_id = #selectQuote.form_data_id#
        	    </cfquery>
    
            </cfif>
        </cfif>
    
        <cflocation addtoken="No" url="#CGI.script_name#?act=editCalcFields&fdid=#URL.fdid#">

        
    <cfelseif CompareNoCase(attribute.op,"nonCalculatorFields") eq 0>
        <cfinclude template="../thirdgen/query/qry_form_def_fields.cfm" >
        <cfquery name="CBFields" dbtype="query">
        select key_name
        from FormDefFieldsQuery
        where key_name not like 'CB_%'
        and key_name not like 'QD_TitleInsured'
        and key_name not like '#ListFirst(CONST_MQ_FirstName_FID,"|")#'
        and key_name not like '#ListFirst(CONST_MQ_Surname_FID,"|")#'
        and key_name not like '#ListFirst(CONST_MQ_manualEditReason_FID,"|")#'
        and key_name not like '#ListFirst(CONST_MQ_manualEditor_FID,"|")#'
        and key_name not like 'QD_Surname'
        </cfquery>
        <cfloop query="CBFields">
            <cfset attributes.fml = listAppend(attributes.fml,"#CBFields.key_name#~H")>
        </cfloop>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteComp_FID,'|')#~R")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteMotorOnly_FID,'|')#~R")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteTPO_FID,'|')#~R")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteGapCover_FID,'|')#~R")> 
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_extraSelected_FID,'|')#~R")> 
        
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteSelected_FID,'|')#~H")>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteDetails_FID,'|')#~H")>  
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteAdminFee_FID,'|')#~H")> 

        <cfif StructKeyExists(boatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|")) and StructFind(boatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|")) neq "">
            <!--- do nothing --->
        <cfelse>
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_ExtProvider_FID,'|')#~H")> 
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_ExtId_FID,'|')#~H")> 
        </cfif>
        
        <cfoutput>
        <style>
        tr##tr_field_#CONST_MQ_manualEditReason_FID# {background-color:##ffcccc}
        </style>
        <h2>#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_FirstName_FID,"|"))# #StructFind(boatQuoteStruct,ListFirst(CONST_MQ_Surname_FID,"|"))# at #DateFormat(selectQuote.created,"DD-MMM-YYYY")#</h2>
        (last updated: #DateFormat(selectQuote.last_updated,"DD-MMM-YYYY")#)
        <br/><br/>
        <div style="background-color:##000000;color:##ffffff;font-weight:bold;padding:5px;">
        * This submission WILL NOT RECALCULATE the price
        <cfif isExternalData >
        and will cause data to be OUT-OF-SYNC with external provider
        </cfif>
        </div>
        <cfinclude template="..\thirdgen\form\inc_form_handler.cfm">
        </cfoutput>
        
        <cfoutput>     
        <div style="background-color:##000000;color:##ffffff;font-weight:bold;padding:5px;">
        * This submission WILL NOT RECALCULATE the price
        <cfif isExternalData >
        and will cause data to be OUT-OF-SYNC with external provider
        </cfif>
        </div><br/>
        #WSQuoteOptions#
        
        <br/><b>Manual Edit Reasons History:</b><br/>
        <div id="theCurrentReason" style="display:none;">#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_manualEditReason_FID,"|"))#</div>
        <script type="text/javascript">
        var x, y
        x = document.getElementById("field_CQ_manualEditor")
        if(x){x.value = "#session.thirdgenas.userid#";}
        
        var theOriReason = ""
        x = document.getElementById("field_CQ_manualEditReason")
        if(x){
            y = document.getElementById("theCurrentReason")
            <cfif IsDefined("attributes.formErrorList") and attributes.formErrorList neq "">
            theOriReason = y.innerHTML;
            <cfelse>
            theOriReason = x.value;
            </cfif>
            x.value = ""; //HIDE THE ORIGINAL NOTE            
            y.innerHTML = theOriReason.replace(/\n/gi,"<br/>");
            y.style.display = "";
        }
        
        var submitBtn = document.getElementById("cmdSubmit"); // STANDARD 3RDGEN FORM SUBMIT BUTTON
        submitBtn.onclick = function() { submit_custom(); };
        
        function submit_custom() {
            var x = document.getElementById("field_CQ_manualEditReason");
            if ((x.value).length < 5)
            { alert("Please fill the manual-edit-reasons properly")  }
            else 
            { 
                x.value = theOriReason + "\n" + "[NC-#DateFormat(now(),'YYYYMMDD')#-#session.thirdgenas.userid#] " + x.value;
                x.value = x.value.trim();
                x.readOnly = true;
                submit_();  // STANDARD 3RDGEN FORM SUBMIT FUNCTION
            }   
        }
        </script>
        </cfoutput>
        
    <cfelseif CompareNoCase(attribute.op,"calculatorFields") eq 0>
    
        <cfinclude template="../thirdgen/query/qry_form_def_fields.cfm" >
        <cfquery name="CBFields" dbtype="query">
        select key_name
        from FormDefFieldsQuery
        where key_name like 'CB_%'
        or key_name like '#ListFirst(CONST_MQ_FirstName_FID,"|")#'
        or key_name like '#ListFirst(CONST_MQ_Surname_FID,"|")#'
        or key_name like '#ListFirst(CONST_MQ_hadInsuranceRefused_FID,"|")#'
        or key_name like '#ListFirst(CONST_MQ_hadClaims_FID,"|")#'
        or key_name like '#ListFirst(CONST_MQ_hadChargedWithOffence_FID,"|")#'
        or key_name like '#ListFirst(CONST_MQ_ignoreCompl_FID,"|")#'
        or key_name like '#ListFirst(CONST_MQ_ignoreComplReason_FID,"|")#'
        </cfquery>
        <cfloop query="CBFields">
            <cfset attributes.fml = listAppend(attributes.fml,"#CBFields.key_name#~H")>
        </cfloop>
        <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteAdminFee_FID,'|')#~H")> 
        
        <cfif StructKeyExists(boatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|")) and StructFind(boatQuoteStruct,ListFirst(CONST_MQ_ExtProvider_FID,"|")) neq "">
            <!--- do nothing --->

            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteComp_FID,'|')#~R")>
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteMotorOnly_FID,'|')#~R")>
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteTPO_FID,'|')#~R")>
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteGapCover_FID,'|')#~R")> 
            
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteSelected_FID,'|')#~R")>
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteDetails_FID,'|')#~R")>  
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_quoteAdminFee_FID,'|')#~R")> 
                        
        <cfelse>
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_ExtProvider_FID,'|')#~H")> 
            <cfset attributes.fml = listAppend(attributes.fml,"#ListFirst(CONST_MQ_ExtId_FID,'|')#~H")> 
        </cfif>
        <cfoutput>
        <style>
        tr##tr_field_#CONST_MQ_manualEditReason_FID# {background-color:##ffcccc}
        </style>
        <h2>#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_FirstName_FID,"|"))# #StructFind(boatQuoteStruct,ListFirst(CONST_MQ_Surname_FID,"|"))# at #DateFormat(selectQuote.created,"DD-MMM-YYYY")#</h2>
        (last updated: #DateFormat(selectQuote.last_updated,"DD-MMM-YYYY")#)
        <br/><br/>
        <div style="background-color:##000000;color:##ffffff;font-weight:bold;padding:5px;">
        * This submission WILL NOT RECALCULATE the price
        <cfif isExternalData >
        and will cause data to be OUT-OF-SYNC with external provider
        </cfif>
        </div>
        <cfinclude template="..\thirdgen\form\inc_form_handler.cfm">
        
        <cfif IsDefined("getWSQuoteData") and getWSQuoteData.recordCount gt 0>
            <script type="text/javascript">
            function checkGapTerm(theObj)
            {
                var theVal = theObj.value;
                x = document.getElementById("termMth_GAP-OPT1")
                if(x){x.value = theVal;}
                x = document.getElementById("termMth_GAP-OPT2")
                if(x){x.value = theVal;}
                x = document.getElementById("termMth_GAP-OPT3")
                if(x){x.value = theVal;}
            }
            </script>
            <cfwddx action="WDDX2CFML" input="#getWSQuoteData.ws_data#" output="coverQuoteStruct">
            <cfoutput>
            <br/>
            Cover Options:<br/>
            <style>
            input[type="text"].longTxt {width:240px;}
            input[type="text"].mediumTxt {width:80px;}
            input[type="text"].shortTxt {width:40px;}
            </style>
            <form name="frm_updateWSData" id="frm_updateWSData" action="#CGI.script_name#?op=updateWSData&#CGI.query_string#" method="POST"  enctype="multipart/form-data">
            <table cellpadding="5" cellspacing="0" border="1">
            <tr>
                <td>Product</td>
                <td>Total ($)</td>
                <td>Base ($)</td>
                <td>GST ($)</td>
                <td>FSL ($)</td>
            </tr>
            <cfset tmpStruct = StructFind(coverQuoteStruct,"FEE_ADMIN")>
            <tr>
                <td>Admin Fee</td>
                <td>#NumberFormat(tmpStruct.total,".99")#</td>
                <td>#NumberFormat(tmpStruct.base,".99")#</td>
                <td>#NumberFormat(tmpStruct.GST,".99")#</td>
                <td>&nbsp;</td>
            </tr>
            <cfquery name="getTermMth" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
            select * from thirdgen_list_item where list_id = #CONST_MQ_LoanTerm_ListID# 
            </cfquery>
            
            <cfloop collection="#coverQuoteStruct#" item="aCover">
                <cfset tmpStruct = StructFind(coverQuoteStruct,aCover)>
                <cfif StructKeyExists(tmpStruct,"totalPremium") and StructKeyExists(tmpStruct,"int_code")>
                <tr>
                    <td rowspan="2">(#aCover#) #tmpStruct.covername#</td>
                    <td><input type="text" id="totalPremium_#aCover#" name="totalPremium_#aCover#" value="#NumberFormat(tmpStruct.totalPremium,".99")#" class="mediumTxt"></td>
                    <td><input type="text" id="base_#aCover#" name="base_#aCover#" value="#NumberFormat(tmpStruct.base,".99")#" class="mediumTxt"></td>
                    <td><input type="text" id="gst_#aCover#" name="gst_#aCover#" value="#NumberFormat(tmpStruct.GST,".99")#" class="mediumTxt"></td>
                    <td><input type="text" id="fsl_#aCover#" name="fsl_#aCover#" value="#NumberFormat(tmpStruct.FSL,".99")#" class="mediumTxt"></td>
                </tr>
                <tr>
                    <td>Term: &nbsp; 
                        <cfif CompareNoCase(aCover,"COMP") eq 0 or CompareNoCase(aCover,"MOTOR") eq 0
                            or CompareNoCase(aCover,"TPO") eq 0 >
                            <input type="hidden" id="termMth_#aCover#" name="termMth_#aCover#" value="#tmpStruct.termMth#" class="shortTxt"> #tmpStruct.termMth# months
                        <cfelse>   
                            <select id="termMth_#aCover#" name="termMth_#aCover#" 
                                <cfif Len(aCover) gt 3 and left(aCover,3) eq "GAP">onChange="checkGapTerm(this)"</cfif>>
                                <cfloop query="#getTermMth#">
                                <cfset tmpStr = replaceNoCase(replaceNoCase(getTermMth.list_item_display,"months","")," ","")>
                                <option value="#tmpStr#" <cfif CompareNoCase(tmpStr,tmpStruct.termMth) eq 0>selected</cfif>>#getTermMth.list_item_display#</option>
                                </cfloop>
                            </select>
                        </cfif>
                    </td>
                    <td colspan="3">
                        <cfif StructKeyExists(tmpStruct,"details")>
                            Details: <input type="text" id="details_#aCover#" name="details_#aCover#" value="#tmpStruct.details#" class="longTxt">
                        </cfif>
                    </td>
                </tr>
                </cfif>
            </cfloop>
            </table>
                <input type="hidden" id="ws_data_id" name="ws_data_id" value="#getWSQuoteData.ws_data_id#">
                <cfset x = evaluate("attributes.field_"&ListFirst(CONST_MQ_ExtProvider_FID,"|"))>
                <input type="hidden" id="requester_id" name="requester_id" value="#x#">
                <cfset x = evaluate("attributes.field_"&ListFirst(CONST_MQ_ExtId_FID,"|"))>
                <input type="hidden" id="external_id" name="external_id" value="#x#">
                <input type="submit" value="Update cover options">
            </form>
            </cfoutput>
        </cfif>
        
        <div style="background-color:##000000;color:##ffffff;font-weight:bold;padding:5px;">
        * This submission WILL NOT RECALCULATE the price
        <cfif isExternalData >
        and will cause data to be OUT-OF-SYNC with external provider
        </cfif>
        </div><br/>
        
        <br/><b>Manual Edit Reasons History:</b><br/>
        <div id="theCurrentReason" style="display:none">#StructFind(boatQuoteStruct,ListFirst(CONST_MQ_manualEditReason_FID,"|"))#</div>
        
        <script type="text/javascript">
        var x, y
        x = document.getElementById("field_CQ_manualEditor")
        if(x){x.value = "#session.thirdgenas.userid#";}
        
        var theOriReason = ""
        x = document.getElementById("field_CQ_manualEditReason")
        if(x){
            y = document.getElementById("theCurrentReason")
            <cfif IsDefined("attributes.formErrorList") and attributes.formErrorList neq "">
            theOriReason = y.innerHTML;
            <cfelse>
            theOriReason = x.value;
            </cfif>
            x.value = ""; //HIDE THE ORIGINAL NOTE            
            y.innerHTML = theOriReason.replace(/\n/gi,"<br/>");
            y.style.display = "";
        }
        
        var submitBtn = document.getElementById("cmdSubmit"); // STANDARD 3RDGEN FORM SUBMIT BUTTON
        submitBtn.onclick = function() { submit_custom(); };
        
        function submit_custom() {
            var x = document.getElementById("field_CQ_manualEditReason");
            if ((x.value).length < 5)
            { alert("Please fill the manual-edit-reasons properly")  }
            else 
            { 
                x.value = theOriReason + "\n" + "[C-#DateFormat(now(),'YYYYMMDD')#-#session.thirdgenas.userid#] " + x.value;
                x.value = x.value.trim();
                x.readOnly = true;
                submit_();  // STANDARD 3RDGEN FORM SUBMIT FUNCTION
            }   
        }
        </script>
        </cfoutput>
    </cfif>
    
    
</cfif>