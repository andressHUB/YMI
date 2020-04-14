<cfset DATA_PER_SCREEN = 10>
<cfparam name="URL.page" default="1">
<cfparam name="LOCAL_startAt" default="">
<cfparam name="LOCAL_endAt" default="">
<cfparam name="LOCAL_searchVal" default="">

<cfif IsDefined("URL.sV") and URL.sV neq "" >
    <cfset LOCAL_searchVal = URL.sV >
</cfif>

<cfif IsDefined("URL.sPS") and URL.sPS neq "" >
    <cfset LOCAL_startAt = URL.sPS >
    <cfset LOCAL_startAt = replaceNoCase(LOCAL_startAt," ","","ALL") >
    <cfif not LSIsDate(LOCAL_startAt) and not IsDate(LOCAL_startAt)>
        <cfset LOCAL_startAt = "">
    </cfif>
</cfif>
<cfif LOCAL_startAt eq "">
    <cfset LOCAL_startAt = "01-JAN-#year(dateAdd('yyyy',-1,now()))#">
</cfif>

<cfif IsDefined("URL.sPE") and URL.sPE neq "" >
    <cfset LOCAL_endAt = URL.sPE >
    <cfset LOCAL_endAt = replaceNoCase(LOCAL_endAt," ","","ALL") >
    <cfif not LSIsDate(LOCAL_endAt) and not IsDate(LOCAL_endAt)>
        <cfset LOCAL_endAt = "">
    </cfif>
</cfif>

<cfset LOCAL_searchVal = trim(LOCAL_searchVal)>
<cfset TEMP_searchVal = ReReplace(LOCAL_searchVal,"\s+"," ","All")>
<cfset TEMP_searchVal = Replace(TEMP_searchVal," ","%","ALL")>

<cfquery name="getStatusList" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select CONVERT(varchar(50), list_item_id) as list_item_id, list_item_display, list_item_seq
    from thirdgen_list_item
    where list_id = #CONST_BQ_AppStatus_ListID#
</cfquery>

<cfquery name="getData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#" result="r">
    select fd.form_data_id, fd.created, fd.last_updated, fdlv.field_value as quoteStatus,
        li.list_item_display as quoteStatusDisp, fdsv.field_value as bikeMake, fhd.text8 as extProv, fhd.text9 as extRefId
        ,case when fhd.text8 is not null and fhd.text8 != '' then 1 else 0 end as isExt
    from thirdgen_form_data fd
    inner join thirdgen_form_header_data fhd on fd.form_data_id =  fhd.form_data_id
    left outer join thirdgen_form_data_list_values fdlv on fd.form_data_id = fdlv.form_data_id 
        and fdlv.key_name = '#CONST_BQ_QuoteStatus_FID#'
    left outer join thirdgen_list_item li on fdlv.field_value = li.list_item_id
    left outer join thirdgen_form_data_shorttext_values fdsv on fhd.externallist10 = fdsv.form_data_id 
        and fdsv.key_name = '#ListFirst(CONST_BD_Make_FID,"|")#'
    where fd.form_def_id = #CONST_bikeQuoteFormDefId#
    <cfif LOCAL_searchVal neq "" >
    and 
    (
    fhd.text1 like '%#TEMP_searchVal#%'
    or fhd.text2 like '%#TEMP_searchVal#%'
    or fdsv.field_value like '%#TEMP_searchVal#%'
    or convert(varchar(20),fd.form_data_id) like '#TEMP_searchVal#'
    )
    </cfif>
    <cfif LOCAL_startAt neq "" >
    and fd.last_updated >= #CreateODBCDate(LOCAL_startAt)#
    </cfif>
    <cfif LOCAL_endAt neq "" >
    and fd.last_updated < DateAdd(d,1,#CreateODBCDate(LOCAL_endAt)#)
    </cfif>
    order by fd.last_updated desc, fd.created desc, fd.form_data_id desc
</cfquery>

<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au" type="html" subject="Debug YMI NZ Quotes report">
	<cfoutput>SQL: #r.SQL#</cfoutput>
</cfmail> --->




<cfset LOCAL_Qs = CONST_BQ_QuoteStatus_stage2_LID>
<cfif IsDefined("URL.qs")>
    <cfset LOCAL_Qs = CONST_BQ_QuoteStatus_stage2_LID>
    <cfif URL.qs neq "">
        <cfset LOCAL_Qs = URL.qs>
    </cfif>
</cfif>

<cfif IsDefined("URL.fdid") and URL.fdid neq "">
    <cfquery name="getAData" dbtype="query">
     select * from getData where form_data_id = #URL.fdid#
    </cfquery>
    <cfset LOCAL_Qs = getAData.quoteStatus>
</cfif>

<cfquery name="getStatusCount" dbtype="query">
select quoteStatus, count(*) as tot
from getData
group by quoteStatus
</cfquery>

<cfquery name="getStatusCountExt" dbtype="query">
select quoteStatus, count(*) as tot
from getData
where isExt = 1
group by quoteStatus
</cfquery>

<cfquery name="getDataCount" dbtype="query">
select getStatusList.list_item_display as quoteStatusDisp, getStatusList.list_item_id, getStatusCount.tot, getStatusList.list_item_seq, getStatusCount.quoteStatus
from getStatusCount, getStatusList
where getStatusList.list_item_id = getStatusCount.quoteStatus

union

select getStatusList.list_item_display as quoteStatusDisp, getStatusList.list_item_id, 0 as tot, getStatusList.list_item_seq, '' as quoteStatus
from getStatusList
<cfif getData.recordCount gt 0>
where getStatusList.list_item_id not in (#ListQualify(ValueList(getStatusCount.quoteStatus),"'")#)
</cfif>

order by list_item_seq
</cfquery>

<cfquery name="getQuickCalcReq" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
select count(*) as tot
from ymi_motorcycle_ws_log
where requestType = 'QUICKCALC'
and motorcycle_company_id = #CONST_MOTORCYCLE_COMP_ID#
<cfif LOCAL_startAt neq "" >
and responsedAt >= #CreateODBCDate(LOCAL_startAt)#
</cfif>
<cfif LOCAL_endAt neq "" >
and responsedAt < DateAdd(d,1,#CreateODBCDate(LOCAL_endAt)#)
</cfif>
</cfquery>

<cfoutput>

<script type="text/javascript">
function searchStatus(aStatus)
{
    var x = document.getElementById("qs")
    x.value = aStatus;
    document.quotesSearchForm.submit();
}

function gotoPage(p) {
    if (p>0) {
        var x = document.getElementById("page");
        x.value = p;
        x = document.getElementById("qs");
        x.value = "#LOCAL_Qs#";
        document.quotesSearchForm.submit();
    }
}

function finalizeCoverBound(fdid)
{
    var dd = confirm("You about to finalize cover ##" + fdid);
    if (dd == true) {
        location.href="#admin#finalizeCoverBound&fdid="+fdid
    }
    else {
        //cancelled
    }
    
}
</script>

<table cellspacing="0" cellpadding="0" border="0" style="width:100%">
<tr>
    <td valign="top" style="width:60%" >
        <form name="quotesSearchForm" method="get" >
            <table cellpadding="5" border="0" cellspacing="0" style="width:100%;background-color:##ffffff;">
            <tr style="background-color:##ccffff">
                <th style="text-align:left;" colspan="3">
                Search Data
                </th>
            </tr>
            <tr>
                <td>Search Value</td>
                <td><input type="text" id="sV" name="sV" value="#LOCAL_searchVal#"></td>
                <td>Firstname, Surname, Bike-make, Ref-Id</td>
            </tr>
            <tr>
                <td>Period Start</td>
                <td><input type="text" id="sPS" name="sPS" value="#LOCAL_startAt#"></td>
                <td><b>DD-MMM-YYYY</b></td>
            </tr>
            <tr>
                <td>Period End</td>
                <td><input type="text" id="sPE" name="sPE" value="#LOCAL_endAt#"></td>
                <td><b>DD-MMM-YYYY</b></td>
            </tr>
            <tr>
                <td align="left"><input type="submit" value="search"></td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            </table>
            <input type="hidden" name="p" id="p" value="quoteAdmin">
            <input type="hidden" name="qs" id="qs" value="">
            <input type="hidden" name="page" id="page" value="1">
        </form>
    </td>
    <td valign="top" align="right">
        <cfif getDataCount.recordCount gt 0>
            <table cellspacing="0" cellpadding="5" border="1">
            <tr>
                <td colspan="2"><b>Total of #getData.recordCount# record(s)</b></td>
            </tr>
            <cfloop query="getDataCount">
            <tr <cfif getDataCount.list_item_id eq LOCAL_Qs>style="font-weight:bold;background-color:##ffffff"</cfif>>
                <td >
                    #getDataCount.quoteStatusDisp#
                </td>
                <td>
                    <cfif getDataCount.tot gt 0>
                        <a href="javascript:searchStatus(#getDataCount.list_item_id#)">#getDataCount.tot# record(s)</a>
                        <cfquery name="chckExtVal" dbtype="query">
                        select tot from getStatusCountExt where quoteStatus = '#getDataCount.quoteStatus#'
                        </cfquery>
                        <br/><div style="font-size:11px;font-style:italic;margin-top:5px;">*Inc #chckExtVal.tot# record(s) via WS</div>
                        <cfif getDataCount.list_item_id eq CONST_BQ_QuoteStatus_stage1_LID>
                        <div style="font-size:11px;font-style:italic;margin-top:5px;">(WS-QuickCalc): #getQuickCalcReq.tot# attempts(s)</div>                        
                        </cfif>
                    <cfelse>
                    No Record
                    </cfif>
                </td>
            </tr>
            </cfloop>
            </table>
        <cfelse>
            No Result
        </cfif>
    </td>
</tr>
</table><br/>
</cfoutput>



<cfif LOCAL_Qs neq "">
    <cfquery name="getDataSection" dbtype="query">
    select * from getData where quoteStatus = '#LOCAL_Qs#'
    order by last_updated desc, created desc, form_data_id desc
    </cfquery>
    <cfoutput>
    <style>
    .prev_next_cursor
    {
        cursor:pointer
    }
    .prev_next_cursor:hover
    {
        color:##0066cc;
    }
    </style>
    
    <table cellspacing="0" cellpadding="5" border="1" style="width:100%">
    <tr>
        <th align="left">Quoted For</th>
        <th align="left">Insured Value</th>
        <th align="left">Bike Details</th>
        <th>&nbsp;</th>
    </tr>
    
    <cfset numRecords = getDataSection.recordCount>
    <cfset numPages = int(numRecords/DATA_PER_SCREEN)>
    <cfif (numRecords mod DATA_PER_SCREEN) gt 0>
        <cfset numPages = numPages + 1>
    </cfif>
    <cfif URL.page gt numPages and numPages gt 0>
        <cfset URL.page = numPages>
    </cfif>
    <cfset startRow = ((URL.page-1) * DATA_PER_SCREEN) + 1>
    <cfset endrow = startRow + DATA_PER_SCREEN>
    
    <cfset prevPage = 0>
    <cfif URL.page gt 1>
        <cfset prevPage = URL.page - 1>
    </cfif>
    <cfset nextPage = 0>
    <cfif URL.page lt numPages>
        <cfset nextPage = URL.page + 1>
    </cfif>
   
    
    <cfloop query="getDataSection" startrow="#startRow#" endrow="#endrow#">
        <cfquery name="getXMLData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
        select xml_data from thirdgen_form_data where form_data_id = #getDataSection.form_data_id#
        </cfquery>
        <cfwddx action="WDDX2CFML" input="#getXMLData.xml_data#" output="bikeQuoteStruct">
        <cfquery name="getBike" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select form_data_id, xml_data
        from thirdgen_form_data
        where form_def_id = #CONST_bikeDataFormDefId#
        and form_data_id = #StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_BikeModel_FID,"|"))#
        </cfquery>
        <cfif getBike.xml_data neq "">
            <cfwddx action="WDDX2CFML" input="#getBike.xml_data#" output="bikeDataStruct">
        <cfelse>
            <cfset bikeDataStruct = StructNew()>
        </cfif>
        
        <tr>
            <td valign="top">
                <a target=_blank href="admin.cfm?p=viewQuote&fdid=#getDataSection.form_data_id#"><b>#StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_FirstName_FID,"|"))# #StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_Surname_FID,"|"))# 
                at #DateFormat(getDataSection.last_updated,"DD-MMM-YYYY")#</b></a> (Ref:#getDataSection.form_data_id#) 
                <cfif getDataSection.extRefId neq "">
                (Ext Ref: #getDataSection.extProv#-#getDataSection.extRefId#) 
                </cfif><br/>
                (Created: #DateFormat(getDataSection.created,"DD-MMM-YYYY")# #TimeFormat(getDataSection.created,"HH:MM")#)
            </td>
            <td valign="top">$ #NumberFormat(StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_InsuredValue_FID,"|")),".99")#</td>
            <td valign="top">
                <cfif IsDefined("bikeDataStruct") and StructCount(bikeDataStruct) gt 0>
                    #StructFind(bikeDataStruct,CONST_BD_Make_FID)# /  #StructFind(bikeDataStruct,CONST_BD_Family_FID)# / #StructFind(bikeDataStruct,CONST_BD_Variant_FID)# / #StructFind(bikeDataStruct,CONST_BD_Year_FID)#
                <cfelseif StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_BikeModel_FID,"|")) eq -1>
                    Manually entered model
                <cfelse>
                    Cannot find bike model                
                </cfif>
            
               <!---  <b>#StructFind(bikeQuoteStruct,ListFirst(CONST_MQ_BoatMake_FID,"|"))#</b><br/>
                #getDataSection.type_display# / #getDataSection.const_display# / #getDataSection.speed_display# --->
            </td>
            <td valign="top" nowrap>
                <cfif LOCAL_Qs eq CONST_BQ_QuoteStatus_stage1_LID>
                    <a href="#admin#editCompliance&fdid=#getDataSection.form_data_id#" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_compliance.png" border="0" alt="Override Compliance" title="Override Compliance"></a>
                    &nbsp;
                    <a href="myquotes.cfm?fdid=#getDataSection.form_data_id#" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_edit.png" border="0" alt="Edit Quote" title="Edit Quote"></a>
                
                <cfelseif LOCAL_Qs eq CONST_BQ_QuoteStatus_stage2_LID>
                    <cfif StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_quoteSelected_FID,"|")) neq "">
                    <a href="#admin#printCoverBound&format=pdfPrint&fdid=#getDataSection.form_data_id#" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_printquote2.png" border="0" alt="Print Application Details" title="Print Application Details"></a>
                    &nbsp;
                    <a href="#admin#printQuote&format=pdfSummary&fdid=#getDataSection.form_data_id#" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_printsummary2.png" border="0" alt="Print Summary" title="Print Summary"></a>
                    &nbsp;
                    </cfif>

                <cfelseif LOCAL_Qs eq CONST_BQ_QuoteStatus_stage3_LID>
                    <a href="#admin#printCoverBound&format=pdfPrint&fdid=#getDataSection.form_data_id#" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_printquote2.png" border="0" alt="Print Application Details" title="Print Application Details"></a>
                    &nbsp;
                    <a href="#admin#printCoverBound&fdid=#getDataSection.form_data_id#&format=pdfSummary" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_printcoverbound.png" border="0" alt="Print Certificate of Currency" title="Print Certificate of Currency"></a> 
                    &nbsp;
                    <a href="#admin#editNonCalcFields&fdid=#getDataSection.form_data_id#" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_edit2.png" border="0" alt="Edit Details" title="Edit Details"></a> 
                    &nbsp;
                    <!--- <a href="javascript:finalizeCoverBound(#getDataSection.form_data_id#)" ><img src="#application.THIRDGENPLUS_ROOT#/images/icon_processCover.png" border="0" alt="Finalize Certificate of Currency" title="Finalize Certificate of Currency"></a> --->
                    
                <cfelseif LOCAL_Qs eq CONST_BQ_QuoteStatus_stage4_LID>
                    <a href="#admin#printQuote&format=pdfPrint&fdid=#getDataSection.form_data_id#" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_coverOk.png" border="0" alt="Print Application Details" title="Print Application Details"></a>
                    &nbsp;
                    <a href="#admin#printCoverBound&fdid=#getDataSection.form_data_id#&format=pdfSummary" target="_blank"><img src="#application.THIRDGENPLUS_ROOT#/images/icon_printcoverbound.png" border="0" alt="Print Certificate of Currency" title="Print Certificate of Currency"></a> 
                </cfif>
            </td>
        </tr>
    </cfloop>
    </table>
    
    <!--- <form name="usersQuotesForm" method="get" > --->
    <cfif prevPage gt 0 >
    <span onclick="gotoPage(#prevPage#)" class="prev_next_cursor"><b><<</b></span>
    </cfif>
    &nbsp; Page #URL.page# of #numPages# &nbsp;
    <cfif nextPage gt 0 >
    <span onclick="gotoPage(#nextPage#)" class="prev_next_cursor"><b>>></b></span>
    </cfif>
    &nbsp;
    <cfif nextPage gt 0 or prevPage gt 0>
    <select onchange="gotoPage(this.value)">
    <option value="0">Go To Page ...
    <cfloop index="i" from="1" to="#numPages#"><option value="#i#">#i#</cfloop>
    </select>
    </cfif>
    
    </cfoutput>
</cfif>