<cfparam name="ratesId" default="0">

<cfoutput>
    <a href="#admin#rates">Back to Rates</a>
    <script language="JavaScript">
        var todayMessageColour = "##000066"
        var LeftRightMonthYear = "##36f"
        var SelectMonthBackColor = "##f0f0f0"
        var txtYearStyleColor = "##006"
        var WeekNo = "##d0d0d0"
        var dateMessage = "##909090"
        var dateMessagePointer = "##54A6E2"
    </script>
    <script language="javascript" src="#application.THIRDGENPLUS_ROOT#/thirdgen/form/datepicker/common.js"></script>
    <script language="JavaScript" src="#application.THIRDGENPLUS_ROOT#/thirdgen/include/util.js"></script> 
    <script language="javascript">

    if (typeof calpickwritten=="undefined") // only execute this code once!!!
    {
        var calpickwritten = "done"
        
    	imgDir = '#application.THIRDGENPLUS_ROOT#/thirdgen/form/datepicker/';		// directory for images ... e.g. var imgDir="/img/"

    	if (dom) {
    		for	(i=0;i<imgsrc.length;i++) {
    			img[i] = new Image;
    			img[i].src = imgDir + imgsrc[i];
    		}
    		document.write ('<div onclick="bShow=true" id="calendar" ')
            document.write ('style="z-index:+999;position:absolute;visibility:hidden;">')
            document.write ('<table width="'+((showWeekNumber==1)?250:220)+'" ')
            document.write ('style="font-family:Arial;font-size:11px;border: 1px solid ##A0A0A0;" bgcolor="##ffffff">')
            document.write ('<tr bgcolor="##eeeeee">')
            document.write ('<td>')
            document.write ('<table width="'+((showWeekNumber==1)?248:218)+'">')
            document.write ('<tr>')
            document.write ('<td style="padding:2px;font-family:Arial;font-size:11px;">')
            document.write ('<font color="##3366ff' + '' /*C9D3E9*/ +'">')
            document.write ('<b>')
            document.write ('<span id="caption"></span>')
            document.write ('</b>')
            document.write ('</font>')
            document.write ('</td>')
            document.write ('<td align="right">')
            document.write ('<a href="javascript:hideCalendar()"><img src="'+imgDir+'close.gif" width="15" height="13" border="0" /></a>')
            document.write ('</td>')
            document.write ('</tr>')
            document.write ('</table>')
            document.write ('</td>')
            document.write ('</tr>')
            document.write ('<tr><td style="padding:5px" bgcolor="##ffffff"><span id="calendarcontent"></span></td></tr>');
    
    		if (showToday == 1) {
    			document.write ('<tr bgcolor="##f0f0f0"><td style="padding:5px" align="center"><span id="lblToday"></span></td></tr>');
    		}
    			
    		document.write ('</table>')
            document.write ('</div>')
            document.write ('<div id="selectMonth" style="z-index:+999;position:absolute;visibility:hidden;"></div>')
            document.write ('<div id="selectYear" style="z-index:+999;position:absolute;visibility:hidden;"></div>');
    	}

    	if(ie) {
    		cal_init();
    	} else {
    		window.onload = cal_init;
    	}
    }

    var theCoverTypeLID=new Array("#CONST_BQ_QuoteComp_ListItemID#","#CONST_BQ_QuoteOffRoad_ListItemID#","#CONST_BQ_QuoteTPD_ListItemID#")
    
    function addRateRow(tableName, rateCategory, rateType)
    {
        var rowsCount = document.getElementById(tableName).rows.length;
        var aRow = document.getElementById(tableName).insertRow(rowsCount);
        aRow.id = "row_"+rateCategory+"_0"+rowsCount;
        aRow.insertCell(0).innerHTML="<input type='text' size='12' name='fld_"+rateCategory+"_0"+rowsCount+"_rateEnd' value=''>";
        if(rateType == 'P')
            aRow.insertCell(1).innerHTML="<input type='text' size='6' name='fld_"+rateCategory+"_0"+rowsCount+"_ratePer' value=''>";
        else
            aRow.insertCell(1).innerHTML="<input type='text' size=6' name='fld_"+rateCategory+"_0"+rowsCount+"_rateFee' value=''>";
        aRow.insertCell(2).innerHTML="<input type='Checkbox' name='chk_"+rateCategory+"_delete' value='"+ aRow.id +"'>";
    }
    
    function addRateRowCells_CoverType(tableName, rateCategory, rateType)
    {
        var maxEntryIDElem = document.getElementById("maxEntryID_"+rateCategory);
        maxEntryID = parseInt(maxEntryIDElem.value);
        var rowsCount = document.getElementById(tableName).rows.length;
        var aRow = document.getElementById(tableName).insertRow(rowsCount);
        aRow.id = 'row_'+rateCategory+'_0'+rowsCount;
        var aCell = "";
        aRow.insertCell(0).innerHTML=aCell;
        var listRowsID = "";
        for(var i = 0; i < theCoverTypeLID.length; i++)
        {
            maxEntryID += 1;
            listRowsID += "0"+maxEntryID+",";
            aCell ="<input type=\"hidden\" name=\"fld_"+rateCategory+"_0"+maxEntryID+"_rateFor\" id=\"fld_"+rateCategory+"_0"+maxEntryID+"_rateFor\" value=\""+ theCoverTypeLID[i]+"\">";
            aCell += "<input type=\"hidden\" name=\"fld_"+rateCategory+"_0"+maxEntryID+"_rateEnd\" id=\"fld_"+rateCategory+"_0"+maxEntryID+"_rateEnd\" value=\"\">";
            aCell += "<input type=\"text\" size=\"6\" name=\"fld_"+rateCategory+"_0"+maxEntryID+"_ratePer\" id=\"fld_"+rateCategory+"_0"+maxEntryID+"_ratePer\" value=\"\">";
        
            aRow.insertCell(i+1).innerHTML=aCell;
        }
        maxEntryIDElem.value = maxEntryID;
        listRowsID = listRowsID.substring(0,listRowsID.length-1);
        aCell = "<input type=\"text\" size=\"12\" name=\"temp_"+rateCategory+"_rateEnd_"+rowsCount+"\" id=\"temp_"+rateCategory+"_rateEnd_"+rowsCount+"\" value=\"\" ";
        aCell += "onchange=\"adjustOthers(this,'fld_"+rateCategory+"_','"+listRowsID+"','_rateEnd')\">"
        aRow.cells[0].innerHTML=aCell;
        aRow.insertCell(theCoverTypeLID.length+1).innerHTML="<input type='Checkbox' name='chk_"+rateCategory+"_delete' value='"+ aRow.id +"'>";
    }
    
    function delRateRow(tableName, rateCategory, rateType)
    {
        var arr = new Array();
        arr = document.getElementsByName('chk_'+rateCategory+'_delete');
        var delElems = new Array();
        for(var i = 0; i < arr.length; i++)
        {        
            var obj = arr[i];
            if(obj.checked)
            {
                var elem=document.getElementById(obj.value);
                delElems.push(elem);
            }
        }
        for(var i = 0; i < delElems.length; i++)
        {
            delElems[i].parentNode.removeChild(delElems[i]) 
        }
    }
    
    function adjustOthers(theSource, prefix_ID, listRowsID, suffix_ID)
    {
        var theID
        var theElem
        arrayRowsID = listRowsID.split(",");
        for(var i = 0; i < arrayRowsID.length; i++){
            theID = prefix_ID + arrayRowsID[i] + suffix_ID;
            theElem = document.getElementById(theID);
            theElem.value = theSource.value
        }
    }
    
    function submitRateForm()
    {
        var x = document.getElementById("ratesForm");
        x.submit();
    }
    </script>

<cfif ratesId gt 0>
    <cfquery name="getDate"  datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select startAt
        from ymi_motorcycle_rateControl
        where motorcycle_rateControlID = #ratesId#
        and motorcycle_company_id = #CONST_MOTORCYCLE_COMP_ID#
    </cfquery>
    
    <cfset effectiveDate = getDate.startAt>
    <cfif effectiveDate neq ""> 
        <cfset disp_effectiveDate = DateFormat(effectiveDate,"dd/mm/yyyy")> 
    <cfelse>
        <cfset disp_effectiveDate = "">  
    </cfif>
    
    <cfquery name="getValues" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select cat.motorcycle_rateCategoryID, cat.categoryName, data.motorcycle_rate_item_id, data.rateEnd, data.rateFor, data.loadingPercent, data.feeDollar
            ,li.list_item_display ,li.list_item_image ,li.list_item_seq
        ,case when ISNUMERIC(li.list_item_display) = 1 then
			case 
				when charindex('$',li.list_item_display) > 0 then convert(decimal,replace(li.list_item_display,'$',''))
				else convert(decimal,li.list_item_display)
			end
        else null
        end  as list_item_display_num
        
        from ymi_motorcycle_rateCategory cat
        inner join ymi_motorcycle_rateData data on cat.motorcycle_rateCategoryID = data.motorcycle_rateCategoryID
        left outer join thirdgen_list_item li on isnumeric(data.rateFor) = 1 and data.rateFor = cast(li.list_item_id as varchar)
        where data.motorcycle_rateControlID = #ratesId#
        order by cat.motorcycle_rateCategoryID asc, data.rateEnd asc
    </cfquery>
    
    <cfquery name="getGST" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_GST#
    </cfquery>
    <cfquery name="getFSLFee" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_FSL_fee# order by list_item_seq
    </cfquery>
    <cfquery name="getAdminFee" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_Admin_Fee#
    </cfquery>
    <cfquery name="getMaxDisc" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_MaxDisc# order by list_item_seq
    </cfquery>
    <cfquery name="getLayup" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_Layup_Discount#
    </cfquery>
    <cfquery name="getTPOPrice" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_TPO_Price#
    </cfquery>
    <cfquery name="getMinPremCost" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_Min_Premium_Cost#
    </cfquery>
    
    <cfquery name="getStateRate" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_State# order by list_item_seq
    </cfquery>
    
    <cfquery name="getStorageMethodRate" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_StorageMethod# order by list_item_seq
    </cfquery>
    
    <cfquery name="getExcessDisc" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_Excess_Discount# order by rateEnd asc, list_item_display_num asc
    </cfquery>
    
    <!--- Service Ticket #26533 - NZ Motorcycle calculator changes --->
    <cfquery name="getExcessDiscOffRoad" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_Excess_Discount_OffRoad# order by rateEnd asc, list_item_display_num asc
    </cfquery>
    
    <cfquery name="getNCB" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_NCB# order by list_item_seq
    </cfquery>
    
    <cfquery name="getLicenseYr" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_LicenseYr# order by list_item_seq
    </cfquery>
    
    <cfquery name="getYMIDisc" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_YMIDealerRate# order by list_item_seq
    </cfquery>
    
    <cfquery name="getBikeYr" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_BikeYr# order by list_item_seq
    </cfquery>
    
    <cfquery name="getBikeType" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_BikeType# order by list_item_seq
    </cfquery>
    
    <cfquery name="getLiabAmountBase" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_LiabilityAmountBase# order by list_item_seq
    </cfquery>
    
    <cfquery name="getTyreRimBase" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_TyreRimBase# order by list_item_seq
    </cfquery>
    
    <cfquery name="getTyreRimBaseMax" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_TyreRimMaxBase# order by list_item_seq
    </cfquery>
        
    <cfquery name="getGapExtraCover" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_GapExtraCover# order by list_item_seq
    </cfquery>
    
    <cfquery name="getBikeAgeMax" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_BikeAgeLimit# order by list_item_seq
    </cfquery>
    
    <cfquery name="getLPLifeTerm" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_LP_LifeTerm# order by list_item_seq
    </cfquery>
    
    <cfquery name="getLPDisableTerm" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_LP_DisableTerm# order by list_item_seq
    </cfquery>
    
    <cfquery name="getLPUnemploymentTerm" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_LP_UnempTerm# order by list_item_seq
    </cfquery>
    
    <cfquery name="getLPCashAssistTerm" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_LP_CashAssTerm# order by list_item_seq
    </cfquery>
      
    <cfquery name="getPBMCharge" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_PayByMonthCharge# order by list_item_seq
    </cfquery>
      
    <cfquery name="getPBMChargeCC" dbtype="query">
        select * from getValues where motorcycle_rateCategoryID = #CONST_ID_PayByMonthCharge_CCExtra# order by list_item_seq
    </cfquery>
    
    <!--- Readjusting the query due to layout --->
    <cfquery name="getBaseRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select rateEndDisc.rateEnd, 
        rateComp.motorcycle_rate_item_id as rateComp_ID, rateComp.loadingPercent as rateComp_Per,
        rateOffRoad.motorcycle_rate_item_id as rateOffRoad_ID, rateOffRoad.loadingPercent as rateOffRoad_Per,
        rateTPD.motorcycle_rate_item_id as rateTPD_ID, rateTPD.loadingPercent as rateTPD_Per
        from
        (select distinct rateEnd from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId# and motorcycle_rateCategoryid = #CONST_ID_Base_Rates#) rateEndDisc
        left outer join (select * from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId# and motorcycle_rateCategoryid = #CONST_ID_Base_Rates# and rateFor = '#CONST_BQ_QuoteComp_ListItemID#' ) rateComp on rateEndDisc.rateEnd = rateComp.rateEnd
        left outer join (select * from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId# and motorcycle_rateCategoryid = #CONST_ID_Base_Rates# and rateFor = '#CONST_BQ_QuoteOffRoad_ListItemID#' ) rateOffRoad on rateEndDisc.rateEnd = rateOffRoad.rateEnd
        left outer join (select * from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId# and motorcycle_rateCategoryid = #CONST_ID_Base_Rates# and rateFor = '#CONST_BQ_QuoteTPD_ListItemID#' ) rateTPD on rateEndDisc.rateEnd = rateTPD.rateEnd
    </cfquery>

    <!--- Readjusting the query due to layout --->
    <cfquery name="getAgeLoadings" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select rateEndDisc.rateEnd, 
        rateComp.motorcycle_rate_item_id as rateComp_ID, rateComp.loadingPercent as rateComp_Per,
        rateOffRoad.motorcycle_rate_item_id as rateOffRoad_ID, rateOffRoad.loadingPercent as rateOffRoad_Per,
        rateTPD.motorcycle_rate_item_id as rateTPD_ID, rateTPD.loadingPercent as rateTPD_Per
        from
        (select distinct rateEnd from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId# and motorcycle_rateCategoryid = #CONST_ID_Age_Loadings#) rateEndDisc
        left outer join (select * from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId# and motorcycle_rateCategoryid = #CONST_ID_Age_Loadings# and rateFor = '#CONST_BQ_QuoteComp_ListItemID#' ) rateComp on rateEndDisc.rateEnd = rateComp.rateEnd
        left outer join (select * from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId# and motorcycle_rateCategoryid = #CONST_ID_Age_Loadings# and rateFor = '#CONST_BQ_QuoteOffRoad_ListItemID#' ) rateOffRoad on rateEndDisc.rateEnd = rateOffRoad.rateEnd
        left outer join (select * from ymi_motorcycle_rateData where motorcycle_rateControlID = #ratesId# and motorcycle_rateCategoryid = #CONST_ID_Age_Loadings# and rateFor = '#CONST_BQ_QuoteTPD_ListItemID#' ) rateTPD on rateEndDisc.rateEnd = rateTPD.rateEnd
    </cfquery>
    
<cfelse>
    <cfset tomorrow=DateAdd("d",1,now())>
    <cfset effectiveDate=CreateDate(DatePart("yyyy",tomorrow),  DatePart("m",tomorrow),  DatePart("d",tomorrow))>
    <cfset disp_effectiveDate = DateFormat(effectiveDate,"dd/mm/yyyy")> 
    
</cfif>


<br/><br/>
<form id="ratesForm" name="ratesForm" action="#admin#saveRates" method="post">
    <input type="hidden" name="ratesId" id="ratesId" value="#ratesId#">
    <table id="basicTable" cellpadding="3" border="0" cellspacing="0" style="width:100%;background-color:##ffffff;">
    <tr style="background-color:##ccffff">
        <th style="text-align:left;">
            <h2>Constants</h2>
        </th>
        <th colspan="3"  style="text-align:right;">
             Effective Date &nbsp; &nbsp;
             <cfmodule template="../thirdgen/form/datepicker/popupcalendar.cfm" 
                formDefId=""
                fieldname="effectiveDate" 
                no_disable="YES" 
                calendardir="#application.THIRDGENPLUS_ROOT#/thirdgen/form/" 
                value="#disp_effectiveDate#" 
                format="dd/mm/yyyy" 
                size="11" 
                formName="ratesForm"
                on_change="">    
        </th>
    </tr>
    </tr>
        <th style="text-align:left;width:25%">GST (%)</th>
        <th style="text-align:left;width:25%">Min Premium Cost ($)</th>
        <th style="text-align:left;width:25%">Admin Fee ($)</th>
        <th style="text-align:left;width:25%">Layup Rate (%)</th>
    </tr>
    <tr>
        <td>
            <cfset tempId = getGST.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_GST#_#tempId#_ratePer" id="fld_#CONST_ID_GST#_#tempId#_ratePer" value="#getGST.loadingPercent#">
        </td>
        <td>
            <cfset tempId = getMinPremCost.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_Min_Premium_Cost#_#tempId#_rateFee" id="fld_#CONST_ID_Min_Premium_Cost#_#tempId#_rateFee" value="#getMinPremCost.feeDollar#">
        </td>
        <td>
            <cfset tempId = getAdminFee.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_Admin_Fee#_#tempId#_rateFee" id="fld_#CONST_ID_Admin_Fee#_#tempId#_rateFee" value="#getAdminFee.feeDollar#">
        </td>
        <td>
            <cfset tempId = getLayup.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_Layup_Discount#_#tempId#_ratePer" id="fld_#CONST_ID_Layup_Discount#_#tempId#_ratePer" value="#getLayup.loadingPercent#">
        </td>
    </tr>
    </tr>
        <th style="text-align:left;">FSL Cost ($)</th>
        <th style="text-align:left;">YMI Dealer Rate (%)</th>
        <th style="text-align:left;">Liability Base Charge ($)</th>
        <th style="text-align:left;">Max Discount Rate (%)</th>
    </tr>
    <tr>
        <td>
            <cfset tempId = getFSLFee.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_FSL_fee#_#tempId#_rateFee" id="fld_#CONST_ID_FSL_fee#_#tempId#_rateFee" value="#getFSLFee.feeDollar#">
        </td>
        <td>
            <cfset tempId = getYMIDisc.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_YMIDealerRate#_#tempId#_ratePer" id="fld_#CONST_ID_YMIDealerRate#_#tempId#_ratePer" value="#getYMIDisc.loadingPercent#">
        </td>
        <td>
            <cfset tempId = getLiabAmountBase.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_LiabilityAmountBase#_#tempId#_rateFee" id="fld_#CONST_ID_LiabilityAmountBase#_#tempId#_rateFee" value="#getLiabAmountBase.feeDollar#"></td>
        </td>
        <td>
            <cfset tempId = getMaxDisc.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_MaxDisc#_#tempId#_ratePer" id="fld_#CONST_ID_MaxDisc#_#tempId#_ratePer" value="#getMaxDisc.loadingPercent#"></td>
        </td>
    </tr>
    </tr>
        <th style="text-align:left;">Pay-By-Mth Charge (%)</th>
        <th style="text-align:left;">Pay-By-Mth<br/>Credit Card Extra (%)</th>
        <th style="text-align:left;"></th>
        <th style="text-align:left;"></th>
    </tr>
    <tr>
        <td>
            <cfset tempId = getPBMCharge.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_PayByMonthCharge#_#tempId#_ratePer" id="fld_#CONST_ID_PayByMonthCharge#_#tempId#_ratePer" value="#getPBMCharge.loadingPercent#">
        </td>
        <td>
            <cfset tempId = getPBMChargeCC.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_PayByMonthCharge_CCExtra#_#tempId#_ratePer" id="fld_#CONST_ID_PayByMonthCharge_CCExtra#_#tempId#_ratePer" value="#getPBMChargeCC.loadingPercent#">
        </td>
    </tr>
    </table>
    
    <br/><br/>
    <table cellpadding="5" border="0" cellspacing="0" style="width:100%;">
    <tr>
        <td valign="top" style="width:45%">
            <table cellpadding="5" border="0" cellspacing="0" style="width:100%;">
            <tr>
                <td colspan="2">   
                    <table id="BaseRatesTable" cellpadding="2" cellspacing="0" border="0">
                    <tr>
                        <th style="text-align:left;" colspan="2"><h2>Base Rates (%)</h2></th>
                        <th style="text-align:right;" colspan="3">
                            <input type="button" onClick="addRateRowCells_CoverType('BaseRatesTable','#CONST_ID_Base_Rates#','P')" value="Add"> &nbsp;
                            <input type="button" onClick="delRateRow('BaseRatesTable','#CONST_ID_Base_Rates#','P')" value="Del">
                        </th>
                    </tr>
                    <tr>
                        <th style="width:160px;text-align:left;" valign="top" rowspan="2">Amount Up To ($)</th>
                        <th style="text-align:center;" colspan="3">Rates for Cover Type (%)</th>
                    </tr>
                    <tr>
                        <th style="width:80px;text-align:left;">Comp</th>
                        <th style="width:80px;text-align:left;">Off-Road</th>
                        <th style="width:80px;text-align:left;">TP-FTT</th>
                    </tr>
                    <cfset newEntryID = 0>
                    <cfloop query="getBaseRates">
                    <tr id="row_#CONST_ID_Base_Rates#_#getBaseRates.currentRow#">
                        <cfset listRowsID = "">
                        <cfsavecontent variable="theEntrants">
                        <td>
                            <cfif getBaseRates.rateCOMP_ID neq "">
                                <cfset tempID = getBaseRates.rateCOMP_ID>
                            <cfelse>
                                <cfset newEntryID += 1>
                                <cfset tempID = "0" & newEntryID>
                            </cfif>
                            <cfset listRowsID = ListAppend(listRowsID,tempID)>
                            <input type="hidden" name="fld_#CONST_ID_Base_Rates#_#tempID#_rateFor" id="fld_#CONST_ID_Base_Rates#_#tempID#_rateFor" value="#CONST_BQ_QuoteComp_ListItemID#">
                            <input type="hidden" name="fld_#CONST_ID_Base_Rates#_#tempID#_rateEnd" id="fld_#CONST_ID_Base_Rates#_#tempID#_rateEnd" value="#getBaseRates.rateEnd#">
                            <input type="text" size="6" name="fld_#CONST_ID_Base_Rates#_#tempID#_ratePer" id="fld_#CONST_ID_Base_Rates#_#tempID#_ratePer" value="#getBaseRates.rateComp_Per#">
                        </td>
                        <td>
                            <cfif getBaseRates.rateOffRoad_ID neq "">
                                <cfset tempID = getBaseRates.rateOffRoad_ID>
                            <cfelse>
                                <cfset newEntryID += 1>
                                <cfset tempID = "0" & newEntryID>
                            </cfif>
                            <cfset listRowsID = ListAppend(listRowsID,tempID)>
                            <input type="hidden" name="fld_#CONST_ID_Base_Rates#_#tempID#_rateFor" id="fld_#CONST_ID_Base_Rates#_#tempID#_rateFor" value="#CONST_BQ_QuoteOffRoad_ListItemID#">
                            <input type="hidden" name="fld_#CONST_ID_Base_Rates#_#tempID#_rateEnd" id="fld_#CONST_ID_Base_Rates#_#tempID#_rateEnd" value="#getBaseRates.rateEnd#">
                            <input type="text" size="6" name="fld_#CONST_ID_Base_Rates#_#tempID#_ratePer" id="fld_#CONST_ID_Base_Rates#_#tempID#_ratePer" value="#getBaseRates.rateOffRoad_Per#">
                        </td>
                        <td>
                            <cfif getBaseRates.rateTPD_ID neq "">
                                <cfset tempID = getBaseRates.rateTPD_ID>
                            <cfelse>
                                <cfset newEntryID += 1>
                                <cfset tempID = "0" & newEntryID>
                            </cfif> 
                            <cfset listRowsID = ListAppend(listRowsID,tempID)>
                            <input type="hidden" name="fld_#CONST_ID_Base_Rates#_#tempID#_rateFor" id="fld_#CONST_ID_Base_Rates#_#tempID#_rateFor" value="#CONST_BQ_QuoteTPD_ListItemID#">
                            <input type="hidden" name="fld_#CONST_ID_Base_Rates#_#tempID#_rateEnd" id="fld_#CONST_ID_Base_Rates#_#tempID#_rateEnd" value="#getBaseRates.rateEnd#">
                            <input type="text" size="6" name="fld_#CONST_ID_Base_Rates#_#tempID#_ratePer" id="fld_#CONST_ID_Base_Rates#_#tempID#_ratePer" value="#getBaseRates.rateTPD_Per#">
                        </td>
                        </cfsavecontent>
                        <td>
                            <input type="text" size="12" name="temp_#CONST_ID_Base_Rates#_rateEnd_#getBaseRates.currentRow#" id="temp_#CONST_ID_Base_Rates#_rateEnd_#getBaseRates.currentRow#" value="#rateEnd#" onchange="adjustOthers(this,'fld_#CONST_ID_Base_Rates#_','#listRowsID#','_rateEnd')">
                        </td>
                        <cfoutput>#theEntrants#</cfoutput>
                        <td>
                            <input type="Checkbox" name="chk_#CONST_ID_Base_Rates#_delete" value="row_#CONST_ID_Base_Rates#_#getBaseRates.currentRow#">
                        </td>
                    </tr>
                    </cfloop>
                    </table>
                    <input type="hidden" id="maxEntryID_#CONST_ID_Base_Rates#" value="#newEntryID#">
                </td>
            </tr>
            </table>
            <br/>
            
            <table id="TyreRimBaseTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;">TPO Price ($)</th>
                <td>
                    <cfset tempId = getTPOPrice.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
                    <input type="text" size="6" name="fld_#CONST_ID_TPO_Price#_#tempId#_rateFee" id="fld_#CONST_ID_TPO_Price#_#tempId#_rateFee" value="#getTPOPrice.feeDollar#">
                </td>
            </tr>
            </table>
            <br/>
            
            <i>
            *TP-FTT = Third Party, Fire, Theft and Transit Cover<br/>
            *TPO = Third Party Only Cover<br/>
            <br/>
            </i>
            <br/><br/>
            
                        
            <table id="BikeStateTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>Region Loading</h2></th>
            </tr>
            <tr>
                <th style="width:200px;text-align:left;">Region</th>
                <th style="width:80px;text-align:left;">Rate (%)</th>
            </tr>
            <cfloop query="getStateRate">
            <tr>
                <td title="(#list_item_image#)"><input type="hidden" name="fld_#CONST_ID_State#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_State#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#">#list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_State#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_State#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
            <br/>
            
            
        </td>
        <td style="width:10%">&nbsp;</td>
        <td style="width:45%" valign="top">
        
            <table id="BikeYearTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>Bike Age Rate</h2></th>
                <th style="text-align:left;"><input type="button" onClick="addRateRow('BikeYearTable','#CONST_ID_BikeYr#','P')" value="Add"></th>
                <th style="text-align:left;"><input type="button" onClick="delRateRow('BikeYearTable','#CONST_ID_BikeYr#','P')" value="Del"></th>
            </tr>
            <tr>
                <th style="width:200px;text-align:left;">Up to</th>
                <th style="width:80px;text-align:left;">Rate (%)</th>
            </tr>
            <cfloop query="getBikeYr">
            <tr id="row_#CONST_ID_BikeYr#_#motorcycle_rate_item_id#">
                <td><input type="text" name="fld_#CONST_ID_BikeYr#_#motorcycle_rate_item_id#_rateEnd" id="fld_#CONST_ID_BikeYr#_#motorcycle_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_BikeYr#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_BikeYr#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_BikeYr#_delete" value="row_#CONST_ID_BikeYr#_#motorcycle_rate_item_id#"></td>
            </tr>
            </cfloop>
            </table>
            <br/>
            
            <table id="BikeAgeLimistTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>Bike Age Limit</h2></th>
            </tr>
            <tr>
                <th style="width:200px;text-align:left;">Type</th>
                <th style="width:160px;text-align:left;">Max Insurable Bike Age</th>
            </tr>
            <cfloop query="getBikeAgeMax">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_BikeAgeLimit#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_BikeAgeLimit#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_BikeAgeLimit#_#motorcycle_rate_item_id#_rateFee" id="fld_#CONST_ID_BikeAgeLimit#_#motorcycle_rate_item_id#_rateFee" value="#feeDollar#"></td>
            </tr>
            </cfloop>
            </table>
            <br/>
            
            <table id="BikeTypeTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>Bike Type</h2></th>
            </tr>
            <tr>
                <th style="width:200px;text-align:left;">Type</th>
                <th style="width:80px;text-align:left;">Rate (%)</th>
            </tr>
            <cfloop query="getBikeType">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_BikeType#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_BikeType#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_BikeType#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_BikeType#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
            <br/>
            
        </td>
    </tr>
    <tr>
        <td valign="top">
            <table id="ExcessDiscTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="3"><h2>Excess Discounts</h2></th>
            </tr>
            <tr>
                <th style="width:120px;text-align:left;">Sum Insurable ($)</th>
                <th style="width:80px;text-align:left;">Excess</th>
                <th style="width:80px;text-align:left;">Rate (%)</th>
            </tr>
            <cfloop query="getExcessDisc">
            <tr>
                <td><input type="text" size="6" name="fld_#CONST_ID_Excess_Discount#_#motorcycle_rate_item_id#_rateEnd" id="fld_#CONST_ID_Excess_Discount#_#motorcycle_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="hidden" name="fld_#CONST_ID_Excess_Discount#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_Excess_Discount#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_Excess_Discount#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_Excess_Discount#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
            <br/>
            
            <table id="NCBTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>No Claim Benefit</h2></th>
            </tr>
            <tr>
                <th style="width:200px;text-align:left;">Category</th>
                <th style="width:80px;text-align:left;">Rate (%)</th>
            </tr>
            <cfloop query="getNCB">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_NCB#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_NCB#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_NCB#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_NCB#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
            <br/>
            
            
            <table id="BikeStorageTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>Storage Method</h2></th>
            </tr>
            <tr>
                <th style="width:200px;text-align:left;">Storage Location</th>
                <th style="width:80px;text-align:left;">Rate (%)</th>
            </tr>
            <cfloop query="getStorageMethodRate">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_StorageMethod#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_StorageMethod#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_StorageMethod#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_StorageMethod#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
            <br/>

        </td>
        <td>&nbsp;</td>
        <td valign="top">
        
            <cfif getExcessDiscOffRoad.recordcount gt 0>
                <table id="ExcessDiscTable" cellpadding="2" cellspacing="0" border="0">
                <tr>
                    <th style="text-align:left;" colspan="3"><h2>Excess Discounts Off Road</h2></th>
                </tr>
                <tr>
                    <th style="width:120px;text-align:left;">Sum Insurable ($)</th>
                    <th style="width:80px;text-align:left;">Excess</th>
                    <th style="width:80px;text-align:left;">Rate (%)</th>
                </tr>
                <cfloop query="getExcessDiscOffRoad">
                <tr>
                    <td><input type="text" size="6" name="fld_#CONST_ID_Excess_Discount_OffRoad#_#motorcycle_rate_item_id#_rateEnd" id="fld_#CONST_ID_Excess_Discount_OffRoad#_#motorcycle_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                    <td><input type="hidden" name="fld_#CONST_ID_Excess_Discount_OffRoad#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_Excess_Discount_OffRoad#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                    <td><input type="text" size="6" name="fld_#CONST_ID_Excess_Discount_OffRoad#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_Excess_Discount_OffRoad#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                </tr>
                </cfloop>
                </table>
                <br/>
            </cfif>        
        
            
            <table id="LicenseYrTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>Consecutive License Year Rate</h2></th>
                <th style="text-align:left;"><input type="button" onClick="addRateRow('LicenseYrTable','#CONST_ID_LicenseYr#','P')" value="Add"></th>
                <th style="text-align:left;"><input type="button" onClick="delRateRow('LicenseYrTable','#CONST_ID_LicenseYr#','P')" value="Del"></th>
            </tr>
            <tr>
                <th style="width:200px;text-align:left;">Up To</th>
                <th style="width:80px;text-align:left;">Rate (%)</th>
            </tr>
            <cfloop query="getLicenseYr">
            <tr id="row_#CONST_ID_LicenseYr#_#motorcycle_rate_item_id#">
                <td><input type="text" name="fld_#CONST_ID_LicenseYr#_#motorcycle_rate_item_id#_rateEnd" id="fld_#CONST_ID_LicenseYr#_#motorcycle_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_LicenseYr#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_LicenseYr#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_LicenseYr#_delete" value="row_#CONST_ID_LicenseYr#_#motorcycle_rate_item_id#"></td>
            </tr>
            </cfloop>
            </table>
            <br/>

            
            
            <table id="AgeTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>Age Loading (%)</h2></th>
                <th style="text-align:right;" colspan="3">
                    <input type="button" onClick="addRateRowCells_CoverType('AgeTable','#CONST_ID_Age_Loadings#','P')" value="Add"> &nbsp;
                    <input type="button" onClick="delRateRow('AgeTable','#CONST_ID_Age_Loadings#','P')" value="Del">
                </th>
            </tr>
            <tr>
                <th style="width:160px;text-align:left;" valign="top" rowspan="2">Up To ($)</th>
                <th style="text-align:center;" colspan="3">Rates for Cover Type (%)</th>
            </tr>
            <tr>
                <th style="width:80px;text-align:left;">Comp</th>
                <th style="width:80px;text-align:left;">Off-Road</th>
                <th style="width:80px;text-align:left;">TP-FTT</th>
            </tr>
            <cfset newEntryID = 0>
            <cfloop query="getAgeLoadings">
            <tr id="row_#CONST_ID_Age_Loadings#_#getAgeLoadings.currentRow#">
                <cfset listRowsID = "">
                <cfsavecontent variable="theEntrants">
                <td>
                    <cfif getAgeLoadings.rateCOMP_ID neq "">
                        <cfset tempID = getAgeLoadings.rateCOMP_ID>
                    <cfelse>
                        <cfset newEntryID += 1>
                        <cfset tempID = "0" & newEntryID>
                    </cfif>
                    <cfset listRowsID = ListAppend(listRowsID,tempID)>
                    <input type="hidden" name="fld_#CONST_ID_Age_Loadings#_#tempID#_rateFor" id="fld_#CONST_ID_Age_Loadings#_#tempID#_rateFor" value="#CONST_BQ_QuoteComp_ListItemID#">
                    <input type="hidden" name="fld_#CONST_ID_Age_Loadings#_#tempID#_rateEnd" id="fld_#CONST_ID_Age_Loadings#_#tempID#_rateEnd" value="#getAgeLoadings.rateEnd#">
                    <input type="text" size="6" name="fld_#CONST_ID_Age_Loadings#_#tempID#_ratePer" id="fld_#CONST_ID_Age_Loadings#_#tempID#_ratePer" value="#getAgeLoadings.rateComp_Per#">
                </td>
                <td>
                    <cfif getAgeLoadings.rateOffRoad_ID neq "">
                        <cfset tempID = getAgeLoadings.rateOffRoad_ID>
                    <cfelse>
                        <cfset newEntryID += 1>
                        <cfset tempID = "0" & newEntryID>
                    </cfif>
                    <cfset listRowsID = ListAppend(listRowsID,tempID)>
                    <input type="hidden" name="fld_#CONST_ID_Age_Loadings#_#tempID#_rateFor" id="fld_#CONST_ID_Age_Loadings#_#tempID#_rateFor" value="#CONST_BQ_QuoteOffRoad_ListItemID#">
                    <input type="hidden" name="fld_#CONST_ID_Age_Loadings#_#tempID#_rateEnd" id="fld_#CONST_ID_Age_Loadings#_#tempID#_rateEnd" value="#getAgeLoadings.rateEnd#">
                    <input type="text" size="6" name="fld_#CONST_ID_Age_Loadings#_#tempID#_ratePer" id="fld_#CONST_ID_Age_Loadings#_#tempID#_ratePer" value="#getAgeLoadings.rateOffRoad_Per#">
                </td>
                <td>
                    <cfif getAgeLoadings.rateTPD_ID neq "">
                        <cfset tempID = getAgeLoadings.rateTPD_ID>
                    <cfelse>
                        <cfset newEntryID += 1>
                        <cfset tempID = "0" & newEntryID>
                    </cfif> 
                    <cfset listRowsID = ListAppend(listRowsID,tempID)>
                    <input type="hidden" name="fld_#CONST_ID_Age_Loadings#_#tempID#_rateFor" id="fld_#CONST_ID_Age_Loadings#_#tempID#_rateFor" value="#CONST_BQ_QuoteTPD_ListItemID#">
                    <input type="hidden" name="fld_#CONST_ID_Age_Loadings#_#tempID#_rateEnd" id="fld_#CONST_ID_Age_Loadings#_#tempID#_rateEnd" value="#getAgeLoadings.rateEnd#">
                    <input type="text" size="6" name="fld_#CONST_ID_Age_Loadings#_#tempID#_ratePer" id="fld_#CONST_ID_Age_Loadings#_#tempID#_ratePer" value="#getAgeLoadings.rateTPD_Per#">
                </td>
                </cfsavecontent>
                <td>
                    <input type="text" size="12" name="temp_#CONST_ID_Age_Loadings#_rateEnd_#getAgeLoadings.currentRow#" id="temp_#CONST_ID_Age_Loadings#_rateEnd_#getAgeLoadings.currentRow#" value="#rateEnd#" onchange="adjustOthers(this,'fld_#CONST_ID_Age_Loadings#_','#listRowsID#','_rateEnd')">
                </td>
                <cfoutput>#theEntrants#</cfoutput>
                <td>
                    <input type="Checkbox" name="chk_#CONST_ID_Age_Loadings#_delete" value="row_#CONST_ID_Age_Loadings#_#getAgeLoadings.currentRow#">
                </td>
            </tr>
            </cfloop>
            </table>
            <input type="hidden" id="maxEntryID_#CONST_ID_Age_Loadings#" value="#newEntryID#">
            
            <!--- <table id="AgeTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h2>Rider Age Rate</h2></th>
                <th style="text-align:left;"><input type="button" onClick="addRateRow('AgeTable','#CONST_ID_Age_Loadings#','P')" value="Add"></th>
                <th style="text-align:left;"><input type="button" onClick="delRateRow('AgeTable','#CONST_ID_Age_Loadings#','P')" value="Del"></th>
            </tr>
            <tr>
                <th style="width:200px;text-align:left;">Up To</th>
                <th style="width:80px;text-align:left;">Rate (%)</th>
            </tr>
            <cfloop query="getAgeLoadings">
            <tr id="row_#CONST_ID_Age_Loadings#_#motorcycle_rate_item_id#">
                <td><input type="text" name="fld_#CONST_ID_Age_Loadings#_#motorcycle_rate_item_id#_rateEnd" id="fld_#CONST_ID_Age_Loadings#_#motorcycle_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_Age_Loadings#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_Age_Loadings#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_Age_Loadings#_delete" value="row_#CONST_ID_Age_Loadings#_#motorcycle_rate_item_id#"></td>
            </tr>
            </cfloop>
            </table> --->
            <br/>
        
        </td>
    </tr>
    
    </table>    
    
    
    
    <hr/><br/>
    <h2>Tyre & Rim Cover Parameters</h2><br/>
    <table id="TyreRimBaseTable" cellpadding="2" cellspacing="0" border="0">
    <tr>
        <th style="text-align:left;">Base Price &nbsp; </th>
        <td>
            <cfset tempId = getTyreRimBase.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_TyreRimBase#_#tempId#_rateFee" id="fld_#CONST_ID_TyreRimBase#_#tempId#_rateFee" value="#getTyreRimBase.feeDollar#">
        </td>
        <td style="width:50px;">&nbsp;</td>
        <th style="text-align:left;">Max Base Price &nbsp; </th>
        <td>
            <cfset tempId = getTyreRimBaseMax.motorcycle_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_TyreRimMaxBase#_#tempId#_rateFee" id="fld_#CONST_ID_TyreRimMaxBase#_#tempId#_rateFee" value="#getTyreRimBaseMax.feeDollar#">
        </td>
    </tr>
    </table>
    <br/>

    <hr/><br/>
    <h2>Gap Cover Parameters</h2><br/>
    <table id="GapExtraCoverTable" cellpadding="2" cellspacing="0" border="0">
    <tr>
        <th style="width:200px;text-align:left;">Sum Insured</th>
        <th style="width:80px;text-align:left;">Price ($)</th>
        <th style="text-align:left;"><input type="button" onClick="addRateRow('GapExtraCoverTable','#CONST_ID_GapExtraCover#','F')" value="Add"></th>
        <th style="text-align:left;"><input type="button" onClick="delRateRow('GapExtraCoverTable','#CONST_ID_GapExtraCover#','F')" value="Del"></th>
    </tr>
    <cfloop query="getGapExtraCover">
    <tr id="row_#CONST_ID_GapExtraCover#_#motorcycle_rate_item_id#">
        <td><input type="text" name="fld_#CONST_ID_GapExtraCover#_#motorcycle_rate_item_id#_rateEnd" id="fld_#CONST_ID_GapExtraCover#_#motorcycle_rate_item_id#_rateEnd" value="#rateEnd#"></td>
        <td><input type="text" size="6" name="fld_#CONST_ID_GapExtraCover#_#motorcycle_rate_item_id#_rateFee" id="fld_#CONST_ID_GapExtraCover#_#motorcycle_rate_item_id#_rateFee" value="#feeDollar#"></td>
        <td><input type="Checkbox" name="chk_#CONST_ID_GapExtraCover#_delete" value="row_#CONST_ID_GapExtraCover#_#motorcycle_rate_item_id#"></td>
    </tr>
    </cfloop>
    </table>
    <br/>
    
    <hr/><br/>

    <h2>Loan Protection Parameters - Rate (%)</h2> <br/>
        
    <table style="width:100%">
    <tr>
        <td valign="top" style="width:25%">
            <table id="LPLifeTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h3>Life</h3></th>
            </tr>
            <cfloop query="getLPLifeTerm">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_LP_LifeTerm#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_LP_LifeTerm#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_LP_LifeTerm#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_LP_LifeTerm#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
        </td>
        <td valign="top" style="width:25%">
            <table id="LPDisableTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h3>Disablement</h3></th>
            </tr>
            <cfloop query="getLPDisableTerm">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_LP_DisableTerm#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_LP_DisableTerm#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_LP_DisableTerm#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_LP_DisableTerm#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
        </td>
        <td valign="top" style="width:25%">
            <table id="LPUnemploymentTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h3>Unemployment</h3></th>
            </tr>
            <cfloop query="getLPUnemploymentTerm">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_LP_UnempTerm#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_LP_UnempTerm#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_LP_UnempTerm#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_LP_UnempTerm#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
        </td>
        <td valign="top" style="width:25%"> 
            <table id="LPCashAssistTable" cellpadding="2" cellspacing="0" border="0">
            <tr>
                <th style="text-align:left;" colspan="2"><h3>Cash Assist</h3></th>
            </tr>
            <cfloop query="getLPCashAssistTerm">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_LP_CashAssTerm#_#motorcycle_rate_item_id#_rateFor" id="fld_#CONST_ID_LP_CashAssTerm#_#motorcycle_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_LP_CashAssTerm#_#motorcycle_rate_item_id#_ratePer" id="fld_#CONST_ID_LP_CashAssTerm#_#motorcycle_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
            </cfloop>
            </table>
        </td>
    </tr>
    </table>
            

    <input type="Button" onclick="submitRateForm()" value="save">
</form>
</cfoutput>
