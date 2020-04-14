<cfset DATA_PER_SCREEN = 10>
<cfparam name="URL.page" default="1">
<cfparam name="LOCAL_startAt" default="">
<cfparam name="LOCAL_endAt" default="">
<cfparam name="LOCAL_searchVal" default="">
<cfparam name="LOCAL_nodeVal" default="0">
<cfparam name="op" default="">


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
    <!--- <cfset LOCAL_startAt = "01-JAN-#year(dateAdd('yyyy',-1,now()))#"> --->
    <cfset LOCAL_startAt = "01-JAN-#year(now())#">
</cfif>

<cfif IsDefined("URL.sPE") and URL.sPE neq "" >
    <cfset LOCAL_endAt = URL.sPE >
    <cfset LOCAL_endAt = replaceNoCase(LOCAL_endAt," ","","ALL") >
    <cfif not LSIsDate(LOCAL_endAt) and not IsDate(LOCAL_endAt)>
        <cfset LOCAL_endAt = "">
    </cfif>
</cfif>

<cfif IsDefined("URL.sNode") and URL.sNode neq "" >
    <cfset LOCAL_nodeVal = URL.sNode >
</cfif>

<cfif IsDefined("op") and op neq "" >
    <cfset ATTRIBUTES.op = op>
<cfelse>
    <cfset ATTRIBUTES.op = "search">    
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
        ,tn.tree_node_id
        ,tn.node_name
        ,ud.user_name
    from thirdgen_form_data fd
    inner join thirdgen_form_header_data fhd on fd.form_data_id =  fhd.form_data_id
    
    inner join thirdgen_user_data ud on fd.user_data_id =  ud.user_data_id
    
    inner join thirdgen_form_data_tree_node dtn on fd.form_data_id = dtn.form_data_id
    inner join thirdgen_tree_node tn on dtn.tree_node_id = tn.tree_node_id
    
     left outer join thirdgen_form_data_list_values fdlv on fd.form_data_id = fdlv.form_data_id 
        and fdlv.key_name = '#CONST_BQ_QuoteStatus_FID#'
    left outer join thirdgen_list_item li on fdlv.field_value = li.list_item_id
    left outer join thirdgen_form_data_shorttext_values fdsv on fhd.externallist10 = fdsv.form_data_id 
        and fdsv.key_name = '#ListFirst(CONST_BD_Make_FID,"|")#'
    where fd.form_def_id = #CONST_bikeQuoteFormDefId#
    
    <cfif LOCAL_nodeVal neq "0">
        and tn.tree_node_id = #LOCAL_nodeVal#
    </cfif>
    
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

<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au" type="html" subject="Debug YMI NZ Motor Quotes report">
	<cfoutput>SQL: #r.SQL#</cfoutput>
</cfmail>  --->

<!--- <cfset LOCAL_Qs = CONST_BQ_QuoteStatus_stage2_LID> --->


<cfset LOCAL_Qs = "">
<cfif IsDefined("URL.qs")>
    <cfset LOCAL_Qs = CONST_BQ_QuoteStatus_stage2_LID>
    <cfif URL.qs neq "">
        <cfset LOCAL_Qs = URL.qs>
    </cfif>
    
    <cfif ATTRIBUTES.op eq "export">
        <cfset LOCAL_Qs = "">
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
from ymi_motorcycle_ws_log(nolock)
where requestType = 'QUICKCALC'
and motorcycle_company_id = #CONST_MOTORCYCLE_COMP_ID#
<cfif LOCAL_startAt neq "" >
and responsedAt >= #CreateODBCDate(LOCAL_startAt)#
</cfif>
<cfif LOCAL_endAt neq "" >
and responsedAt < DateAdd(d,1,#CreateODBCDate(LOCAL_endAt)#)
</cfif>
</cfquery>

<!--- Get treenodes --->
<cfquery name="getDataTreenodes" dbtype="query">
select distinct tree_node_id,node_name
from getData
order by node_name
</cfquery>

<!--- <cfmail to="andress@3rdmill.com.au" from="helpdesk@3rdmill.com.au" type="html" subject="Debug YMI NZ getDataTreenodes">
	<cfdump var="#getDataTreenodes#">
</cfmail> --->



    <cfquery name="getDataSection" dbtype="query">
    select * from getData 
    <cfif LOCAL_Qs neq "">
        where quoteStatus = '#LOCAL_Qs#'
    </cfif>    
    order by last_updated desc, created desc, form_data_id desc
    </cfquery>
   

<cfoutput>

<script type="text/javascript">
function searchStatus(aStatus)
{

    doAct ("search");

    var x = document.getElementById("qs")
    x.value = aStatus;
    
    getNode();
    
    document.quotesSearchForm.submit();
}

function gotoPage(p) {

    doAct ("search");

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

function getNode()
{
    
    //var strNode = document.getElementById("sTreeNode").selectedIndex;
    
    var selectElement = document.getElementById("sTreeNode");
    
    var strNode = selectElement.options[selectElement.selectedIndex].id;
    //var strNode = e.options[e.selectedIndex];
    
    document.getElementById("sNode").value = strNode;
    
    //console.log(strNode);
    
    //console.log('getNode');
}


function doAct (theAct)
{
        var anElem
        
        getNode();
        
        anElem = document.getElementById("op");
        anElem.value = theAct;
        

        
        anElem = document.getElementById("quotesSearchForm")
        
        
        x = document.getElementById("qs");
        x.value = "#LOCAL_Qs#";
        
        if (theAct == "export")
        {
            //alert(theAct);
            //anElem.target = "_blank"
            
        }
        anElem.submit();
    }


</script>

<table cellspacing="0" cellpadding="0" border="0" style="width:100%">
<tr>
    <td valign="top" style="width:60%" >
        <form id="quotesSearchForm" action="" name="quotesSearchForm" method="get" >
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
            <!--- <cfif getDataTreenodes.recordCount gt 0> --->
            <tr>
                <td>Treenode</td>
                <td>
                <select id="sTreeNode"  onchange="getNode()">
                    <option id="0"></option>
                    <cfloop query="getDataTreenodes">
                        <option id="#getDataTreenodes.tree_node_id#" <cfif LOCAL_nodeVal eq getDataTreenodes.tree_node_id>selected</cfif>>#getDataTreenodes.node_name#</option>  
                    </cfloop>                      
                </select>
                </td>
                <td><a href="?sV=&sPS=01-JAN-2018&sPE=&p=quoteAdmin&qs=&"><b>Show all Treenodes</b></a></td>
            </tr>
            <!--- </cfif> --->
            <tr>
                <td align="left"><!--- <input type="submit" value="search"> --->
                 <input type="button" class="button" onClick="doAct('search')" value="search">
                 </td>
                 <td><input type="button" class="button" onClick="doAct('export')" value="export"></td>                                
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            </table>
            <input type="hidden" name="p" id="p" value="quoteAdmin">
            <input type="hidden" name="qs" id="qs" value="">
            <input type="hidden" name="page" id="page" value="1">
            <input type="hidden" name="sNode" id="sNode" value="">
            <input type="hidden" id="op" name="op" value="search">
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


<cfif ATTRIBUTES.op eq "search">
<cfif LOCAL_Qs neq "">
   <!---  <cfquery name="getDataSection" dbtype="query">
    select * from getData where quoteStatus = '#LOCAL_Qs#'
    order by last_updated desc, created desc, form_data_id desc
    </cfquery> --->
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
        <th align="left">Treenode</th>
        <th align="left">Username</th>
        <th>&nbsp;</th>
    </tr>
    
    <cfset numRecords = getDataSection.recordCount>        
    <cfset numPages = int(numRecords/DATA_PER_SCREEN)>
    
    <!--- <cfoutput>NR[#numRecords#] - NP[#numPages#]</cfoutput> --->
    
    <cfif (numRecords mod DATA_PER_SCREEN) gt 0>
        <cfset numPages = numPages + 1>
    </cfif>
    <cfif URL.page gt numPages and numPages gt 0>
        <cfset URL.page = numPages>
    </cfif>
    <!--- <cfset startRow = ((URL.page-1) * DATA_PER_SCREEN) + 1>  --->       
    <cfset startRow = ((URL.page-1) * DATA_PER_SCREEN) + 1> 
       
    <cfset endrow = startRow + DATA_PER_SCREEN>
    <cfset endrow = (startRow + DATA_PER_SCREEN) - 1>
    
    <!--- <cfoutput>SR[#startRow#] - ER[#endrow#]</cfoutput> --->
    
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
            <td valign="top">
                 #getDataSection.node_name#
            </td>
            <td valign="top">
                #getDataSection.user_name#
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
</cfif>

<cfif ATTRIBUTES.op eq "export">

   
    
<!--- <cfdump var="#getData#">
<cfabort> --->
    
    

    <cfset theHeader = "">
    <cfset theHeaderType = "">
    
    <cfset theHeader = ListAppend(theHeader,"Quoted_for")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>
    <cfset theHeader = ListAppend(theHeader,"Created")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>
    <cfset theHeader = ListAppend(theHeader,"Last_updated")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>
    <cfset theHeader = ListAppend(theHeader,"Ref")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>    
    <cfset theHeader = ListAppend(theHeader,"Insured_Value")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>
    <cfset theHeader = ListAppend(theHeader,"Model")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>
    <cfset theHeader = ListAppend(theHeader,"Treenode")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>
    <cfset theHeader = ListAppend(theHeader,"Username")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")> 
    <cfset theHeader = ListAppend(theHeader,"Quote_Status")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>
    <cfset theHeader = ListAppend(theHeader,"ExtRefID")><cfset theHeaderType = ListAppend(theHeaderType,"VarChar")>
    
    <cfset queryResult = queryNew(theHeader,theHeaderType)>
    
    <cfloop query="getDataSection">
    
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
             
         <cfset QuoteFor = StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_FirstName_FID,"|")) & " " & StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_Surname_FID,"|"))>
         
         
         <cfset x = queryAddRow(queryResult)>  
           
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,1),QuoteFor)>
         
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,2),DateFormat(getDataSection.created,"DD-MMM-YYYY")& " " & TimeFormat(getDataSection.created,"HH:MM"))>   
                      
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,3),DateFormat(getDataSection.last_updated,"DD-MMM-YYYY"))> 
         
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,4),getDataSection.form_data_id)>   
         
         
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,5),NumberFormat(StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_InsuredValue_FID,"|")),".99"))>
          
         
         <cfset bikeModel = "">
         
          <cfif IsDefined("bikeDataStruct") and StructCount(bikeDataStruct) gt 0>
            <cfset bikeModel = #StructFind(bikeDataStruct,CONST_BD_Make_FID)# & " / " & #StructFind(bikeDataStruct,CONST_BD_Family_FID)# & "/" & #StructFind(bikeDataStruct,CONST_BD_Variant_FID)# &  "/" & #StructFind(bikeDataStruct,CONST_BD_Year_FID)#>
          <cfelseif StructFind(bikeQuoteStruct,ListFirst(CONST_BQ_BikeModel_FID,"|")) eq -1>
                <cfset bikeModel = "Manually entered model">
          <cfelse>
                <cfset bikeModel = "Cannot find bike model">                
          </cfif>
          
         <cfset model = bikeModel>
          
          
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,6),model)>
          
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,7),getDataSection.node_name)>
          
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,8),getDataSection.user_name)>
          
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,9),getDataSection.QUOTESTATUSDISP)>
          
         <cfset x = querySetCell(queryResult, ListGetAt(theHeader,10),getDataSection.extProv & "-" & getDataSection.extRefId)>
                          
           
    </cfloop>
    
    
    <cfset tempLoc = "#application.THIRDGENPLUS_TEMP_DIRECTORY#reports\">
    <cfmodule template="mod_houseKeeping.cfm" maxDaysOld="1" dirToBeCleaned="#tempLoc#">
    
    
    <cfset strOutput = QueryToCSV(Query=queryResult,Fields="#theHeader#") />
    <cfset tmpFileName = "rpt_ymi_nz_mc_quotes_#DateFormat(now(),'YYYYMMDD')##TimeFormat(now(),'HHMMSS')#.csv">
    
    
    
    
    <cffile action="write" file="#tempLoc##tmpFileName#" output="#strOutput#" nameconflict="OVERWRITE">
    
    
      
    
    <cfheader name="Content-Disposition" value="inline; filename=#tmpFileName#">
    <cfheader name="expires" value="#now()#">
    <cfheader name="pragma" value="no-cache">
    <cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
    <cfcontent type="application/csv" file="#tempLoc##tmpFileName#">                      

</cfif>


<cffunction name="QueryToCSV" access="public" returntype="string" output="false"
	hint="I take a query and convert it to a comma separated value string.">
 
	<!--- Define arguments. --->
	<cfargument name="Query" type="query" required="true"
		hint="I am the query being converted to CSV." />
 
	<cfargument name="Fields" type="string" required="true"
		hint="I am the list of query fields to be used when creating the CSV value." />
 
	<cfargument name="CreateHeaderRow" type="boolean" required="false" default="true"
		hint="I flag whether or not to create a row of header values." />
        
    <cfargument name="HeaderTitles" type="string" required="false" default=""
		hint="I am the title for header fields - must be same length with [Fields]." />
 
	<cfargument name="Delimiter" type="string" required="false" default=","
		hint="I am the field delimiter in the CSV value." />
 
	<!--- Define the local scope. --->
	<cfset var LOCAL = {} />
 
	<!---
		First, we want to set up a column index so that we can
		iterate over the column names faster than if we used a
		standard list loop on the passed-in list.
	--->
	<cfset LOCAL.ColumnNames = [] />
 
	<!---
		Loop over column names and index them numerically. We
		are working with an array since I believe its loop times
		are faster than that of a list.
	--->
	<cfloop index="LOCAL.ColumnName" list="#ARGUMENTS.Fields#" delimiters=",">
		<!--- Store the current column name. --->
		<cfset ArrayAppend(LOCAL.ColumnNames,Trim( LOCAL.ColumnName )) />
	</cfloop>
 
	<!--- Store the column count. --->
	<cfset LOCAL.ColumnCount = ArrayLen( LOCAL.ColumnNames ) />
 
 
	<!---
		Now that we have our index in place, let's create
		a string buffer to help us build the CSV value more
		effiently.
	--->
	<cfset LOCAL.Buffer = CreateObject( "java", "java.lang.StringBuffer" ).Init() />
 
	<!--- Create a short hand for the new line characters. --->
	<cfset LOCAL.NewLine = (Chr( 13 ) & Chr( 10 )) />
 
 
	<!--- Check to see if we need to add a header row. --->
	<cfif ARGUMENTS.CreateHeaderRow>
 
		<!--- Create array to hold row data. --->
		<cfset LOCAL.RowData = [] />
 
        <cfif ARGUMENTS.HeaderTitles neq "">
            <!--- Loop over the column names. --->
            <cfset LOCAL.ColumnIndex = 1>
    		<cfloop list="#ARGUMENTS.HeaderTitles#" index="aColumn">
    			<!--- Add the field name to the row data. --->
    			<cfset LOCAL.RowData[LOCAL.ColumnIndex] = """#aColumn#""" />
                <cfset LOCAL.ColumnIndex = LOCAL.ColumnIndex + 1>
    		</cfloop>
        <cfelse>
            <!--- Loop over the column names. --->
    		<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">
    			<!--- Add the field name to the row data. --->
    			<cfset LOCAL.RowData[LOCAL.ColumnIndex] = """#LOCAL.ColumnNames[ LOCAL.ColumnIndex ]#""" />
    		</cfloop>
        </cfif>

		<!--- Append the row data to the string buffer. --->
		<cfset LOCAL.Buffer.Append(
			JavaCast("string",(ArrayToList(LOCAL.RowData,ARGUMENTS.Delimiter) & LOCAL.NewLine))) />
 
	</cfif>
 
 
	<!---
		Now that we have dealt with any header value, let's
		convert the query body to CSV. When doing this, we are
		going to qualify each field value. This is done be
		default since it will be much faster than actually
		checking to see if a field needs to be qualified.
	--->
 
	<!--- Loop over the query. --->
	<cfloop query="ARGUMENTS.Query">
 
		<!--- Create array to hold row data. --->
		<cfset LOCAL.RowData = [] />
 
		<!--- Loop over the columns. --->
		<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">
			<!--- Add the field to the row data. --->
			<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#Replace( ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ], """", """""", "all" )#""" />
		</cfloop>
 
 
		<!--- Append the row data to the string buffer. --->
		<cfset LOCAL.Buffer.Append(
			JavaCast("string",(ArrayToList(LOCAL.RowData,ARGUMENTS.Delimiter) & LOCAL.NewLine))) />
 
	</cfloop>
 
 
	<!--- Return the CSV value. --->
	<cfreturn LOCAL.Buffer.ToString() />
</cffunction>  
  