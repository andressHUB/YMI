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
    
    function addRateMotorType(tableName, rateCategory, listItems, listItemDisplays)
    {
        var listItemArray = listItems.split(",");
        var listItemDisplayArray = listItemDisplays.split(",");
        for(var i = 0; i < listItemArray.length; i++)
        {
            var rowsCount = document.getElementById(tableName).rows.length;
            var aRow = document.getElementById(tableName).insertRow(rowsCount);
            aRow.id = 'row_'+rateCategory+'_0'+rowsCount;
            aRow.insertCell(0).innerHTML="<input type='hidden' name='fld_"+rateCategory+"_0"+rowsCount+"_rateFor' value='"+listItemArray[i]+"'>" + listItemDisplayArray[i];
            aRow.insertCell(1).innerHTML="<input type='text' size='12' name='fld_"+rateCategory+"_0"+rowsCount+"_rateEnd' value=''>";
            aRow.insertCell(2).innerHTML="<input type='text' size='6' name='fld_"+rateCategory+"_0"+rowsCount+"_ratePer' value=''>";
            aRow.insertCell(3).innerHTML="<input type='Checkbox' name='chk_"+rateCategory+"_delete' value='"+ aRow.id +"'>";
        }
    }
    
    function delRateRow(tableName, rateCategory, rateType)
    {
        var arr = new Array();
        arr = document.getElementsByName('chk_'+rateCategory+'_delete');
        var delElems = new Array();
        for(var i = 0; i < arr.length; i++)
        {
            var obj = arr(i);
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
    </script>

<cfif ratesId gt 0>
    <cfquery name="getDate"  datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select startAt
        from ymi_marine_rateControl
        where marine_rateControlID = #ratesId#
        and marine_company_id = #CONST_MARINE_COMP_ID#
    </cfquery>
    
    <cfquery name="getValues" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select cat.marine_rateCategoryID, cat.categoryName, data.marine_rate_item_id, data.rateEnd, data.rateFor, data.loadingPercent, data.feeDollar, li.list_item_display, li.list_item_seq
        from ymi_marine_rateCategory cat
        inner join ymi_marine_rateData data on cat.marine_rateCategoryID = data.marine_rateCategoryID
        left outer join thirdgen_list_item li on isnumeric(data.rateFor) = 1 and data.rateFor = cast(li.list_item_id as varchar)
        where data.marine_rateControlID = #ratesId#
        order by cat.marine_rateCategoryID asc, data.rateEnd asc
    </cfquery>
<!---     <cfdump var="#getValues#"> --->
    
    <cfquery name="getGST" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_GST#
    </cfquery>
    <cfquery name="getFSL" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Fire_Service_Levy#
    </cfquery>
    <cfquery name="getAdmin" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Admin_Fee#
    </cfquery>
    <cfquery name="getLayup" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Layup_Discount#
    </cfquery>
    <cfquery name="getSkiers" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Water_Skiers#
    </cfquery>
     <cfquery name="getStreet" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Street_Parking#
    </cfquery>
    <cfquery name="getBoatCourse" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Boating_Course#
    </cfquery>
    <cfquery name="getMOR" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Motor_Only_Rate#
    </cfquery>
    
    
    
    
    <cfset effectiveDate = getDate.startAt>
    <cfif effectiveDate neq ""> 
        <cfset disp_effectiveDate = DateFormat(effectiveDate,"dd/mm/yyyy")> 
    <cfelse>
        <cfset disp_effectiveDate="">  
    </cfif>
    
    <cfquery name="getPWCBaseRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_PWC_Insured_Value_Bands#
    </cfquery>
    
    <cfquery name="getRABaseRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_RA_Insured_Value_Bands#
    </cfquery>
    
    <cfquery name="getPWCAgeRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_PWC_Boat_Age#
    </cfquery>
    
    <cfquery name="getRAAgeRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_RA_Boat_Age#
    </cfquery>
    
    <cfquery name="getRAMotorTypeRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_RA_Motor_Type# order by list_item_seq
    </cfquery>
    
    <cfquery name="getConstructionRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Boat_Construction# order by list_item_seq
    </cfquery>
    
    <cfquery name="getExpRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Boating_Experience# order by list_item_seq
    </cfquery>
    
    <cfquery name="getPwcExcess" dbtype="query">
        select *, cast(list_item_display as integer) as list_item_num from getValues where marine_rateCategoryID = #CONST_ID_PWC_Excess_Rating# order by rateEnd asc, list_item_num asc
    </cfquery>
    
    <cfquery name="getRaExcess" dbtype="query">
        select *, cast(list_item_display as integer) as list_item_num from getValues where marine_rateCategoryID = #CONST_ID_RA_Excess_Rating# order by rateEnd asc, list_item_num asc
    </cfquery>
    
    <cfquery name="getLiabilityLims" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Liability_Limit# order by list_item_seq
    </cfquery>
    
    <cfquery name="getPwcMotorAge" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_PWC_Motor_Age# order by list_item_seq
    </cfquery>
    
    <cfquery name="getRaMotorAge" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_RA_Motor_Age# order by list_item_seq
    </cfquery>
    
    <cfquery name="getPwcSpeedRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_PWC_Boat_Speed# order by list_item_seq
    </cfquery>
    
    <cfquery name="getRaSpeedRates" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_RA_Boat_Speed# order by list_item_seq
    </cfquery>
    
    <cfquery name="getBoatStorage" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Boat_Storage# order by list_item_seq
    </cfquery>
    
    <cfquery name="getCustAge" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_Customer_Age#
    </cfquery>
    
    <cfquery name="getTPO" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_TPO_Amount# order by list_item_seq
    </cfquery>
    
    <cfquery name="getMinPremBase" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_MIN_PremiumBase# order by list_item_seq
    </cfquery>
    
    <cfquery name="geMaxBoatPrice" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_MAX_BoatPrice# order by list_item_seq
    </cfquery>
    
    <cfquery name="getGapExtraCover" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_GapExtraCover# order by list_item_seq
    </cfquery>
    
    <cfquery name="getPersonalAccCover" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_PersonalAccidentCover# order by list_item_seq
    </cfquery>
    
    <cfquery name="getPBMCharge" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_PayByMonthCharge# order by list_item_seq
    </cfquery>
      
    <cfquery name="getPBMChargeCC" dbtype="query">
        select * from getValues where marine_rateCategoryID = #CONST_ID_PayByMonthCharge_CCExtra# order by list_item_seq
    </cfquery>
    
<cfelse>
    <cfset tomorrow=DateAdd("d",1,now())>
    <cfset effectiveDate=CreateDate(DatePart("yyyy",tomorrow),  DatePart("m",tomorrow),  DatePart("d",tomorrow))>
    <cfset disp_effectiveDate = DateFormat(effectiveDate,"dd/mm/yyyy")> 
    <!--- 
    <cfquery name="getGST" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_GST# as marine_rateCategoryID, '' as categoryName, 0 as marine_rate_item_id, NULL as rateEnd, NULL as rateFor, 15.0 as loadingPercent, NULL as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getMOR" dbtype="query">
        select #CONST_ID_Motor_Only_Rate# as marine_rateCategoryID, '' as categoryName, 0 as marine_rate_item_id, NULL as rateEnd, NULL as rateFor, 1.75 as loadingPercent, NULL as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getFSL" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Fire_Service_Levy# as marine_rateCategoryID, '' as categoryName, 0 as marine_rate_item_id, NULL as rateEnd, NULL as rateFor, 0.076 as loadingPercent, NULL as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getAdmin" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Admin_Fee# as marine_rateCategoryID, '' as categoryName, 0 as marine_rate_item_id, NULL as rateEnd, NULL as rateFor, NULL as loadingPercent, 30.00 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getLayup" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Layup_Discount# as marine_rateCategoryID, '' as categoryName, 0 as marine_rate_item_id, NULL as rateEnd, NULL as rateFor, -5.00 as loadingPercent, NULL as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getSkiers" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Water_Skiers# as marine_rateCategoryID, '' as categoryName, 0 as marine_rate_item_id, NULL as rateEnd, 'YES' as rateFor, NULL as loadingPercent, 0.00 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getStreet" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Street_Parking# as marine_rateCategoryID, '' as categoryName, 0 as marine_rate_item_id, NULL as rateEnd, 'YES' as rateFor, 0.0 as loadingPercent, NULL as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getBoatCourse" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Boating_Course# as marine_rateCategoryID, '' as categoryName, 0 as marine_rate_item_id, NULL as rateEnd, 'YES' as rateFor, 0.0 as loadingPercent, NULL as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getPWCBaseRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_PWC_Insured_Value_Bands# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getRABaseRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_RA_Insured_Value_Bands# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getPWCAgeRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_PWC_Boat_Age# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getRAAgeRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_RA_Boat_Age# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getRAMotorTypeRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_RA_Motor_Type# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getConstructionRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Boat_Construction# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, list_item_display
        from thirdgen_list_item
        where list_id = 758
        order by list_item_display
    </cfquery>
    
    <cfquery name="getExpRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Boating_Experience# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getPwcExcess" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_PWC_Excess_Rating# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getRaExcess" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_RA_Excess_Rating# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getLiabilityLims" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Liability_Limit# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getPwcMotorAge" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_PWC_Motor_Age# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getRaMotorAge" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_RA_Motor_Age# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getPwcSpeedRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_PWC_Boat_Speed# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getRaSpeedRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_RA_Boat_Speed# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
     <cfquery name="getBoatStorage" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select #CONST_ID_Boat_Storage# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, null as feeDollar, list_item_display
        from thirdgen_list_item
        where list_id = 764
        order by list_item_display
    </cfquery>
    
    <cfquery name="getCustAge" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
       select #CONST_ID_Customer_Age# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, null as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getTPO" dbtype="query">
        select #CONST_ID_TPO_Amount# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, 0 as loadingPercent, null as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="getMinPremBase" dbtype="query">
        select #CONST_ID_MIN_PremiumBase# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, null as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery>
    
    <cfquery name="geMaxBoatPrice" dbtype="query">
        select #CONST_ID_MAX_BoatPrice# as marine_rateCategoryID, 0 as categoryName, 0 as marine_rate_item_id, 0 as rateEnd, 0 as rateFor, null as loadingPercent, 0 as feeDollar, null as list_item_display
    </cfquery> --->
</cfif>


<br/><br/>
<form name="ratesForm" action="#admin#saveRates" method="post">
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
        <th style="text-align:left;width:25%">FSL (%)</th>
        <th style="text-align:left;width:25%">Admin Fee ($)</th>
        <th style="text-align:left;width:25%">Motor-Only Rate (%)</th>
    </tr>
    <tr>
        <td><input type="text" size="6" name="fld_#CONST_ID_GST#_#getGST.marine_rate_item_id#_ratePer" id="fld_#CONST_ID_GST#_#getGST.marine_rate_item_id#_ratePer" value="#getGST.loadingPercent#"></td>
        <td><input type="text" size="6" name="fld_#CONST_ID_Fire_Service_Levy#_#getFSL.marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Fire_Service_Levy#_#getFSL.marine_rate_item_id#_ratePer" value="#getFSL.loadingPercent#"></td>
        <td><input type="text" size="6" name="fld_#CONST_ID_Admin_Fee#_#getAdmin.marine_rate_item_id#_rateFee" id="fld_#CONST_ID_Admin_Fee#_#getAdmin.marine_rate_item_id#_rateFee" value="#getAdmin.feeDollar#"></td>
        <td><input type="text" size="6" name="fld_#CONST_ID_Motor_Only_Rate#_#getMOR.marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Motor_Only_Rate#_#getMOR.marine_rate_item_id#_ratePer" value="#getMOR.loadingPercent#"></td>
    </tr>
    </tr>
        <th style="text-align:left;width:25%">Water Skiers Loading (%)</th>
        <th style="text-align:left;width:25%">Street Parked Loading (%)</th>
        <th style="text-align:left;width:25%">Boating Course Loading (%)</th>
        <th style="text-align:left;width:25%">Layup Rate / mth (%) </th>
    </tr>
    <tr>
        <td>
            <!--- <cfloop query="getSkiers">
                <input type="hidden" id="fld_#CONST_ID_Water_Skiers#_#marine_rate_item_id#_rateFor" name="fld_#CONST_ID_Water_Skiers#_#marine_rate_item_id#_rateFor" value="#rateFor#">
                <cfif CompareNoCase(rateFor,"1") eq 0>
                <input type="text" size="6" name="fld_#CONST_ID_Water_Skiers#_#marine_rate_item_id#_rateFee" id="fld_#CONST_ID_Water_Skiers#_#marine_rate_item_id#_rateFee" value="#feeDollar#">
                <cfelse>
                <input type="hidden" name="fld_#CONST_ID_Water_Skiers#_#marine_rate_item_id#_rateFee" id="fld_#CONST_ID_Water_Skiers#_#marine_rate_item_id#_rateFee" value="#feeDollar#">
                </cfif>
            </cfloop>    --->
            <input type="text" size="6" name="fld_#CONST_ID_Water_Skiers#_#getSkiers.marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Water_Skiers#_#getSkiers.marine_rate_item_id#_ratePer" value="#getSkiers.loadingPercent#">
        </td>
        <td>
            <cfloop query="getStreet">
                <input type="hidden" id="fld_#CONST_ID_Street_Parking#_#marine_rate_item_id#_rateFor" name="fld_#CONST_ID_Street_Parking#_#marine_rate_item_id#_rateFor" value="#rateFor#">
                <cfif CompareNoCase(rateFor,"1") eq 0>
                <input type="text" size="6" name="fld_#CONST_ID_Street_Parking#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Street_Parking#_#marine_rate_item_id#_ratePer" value="#loadingPercent#">
                <cfelse>
                <input type="hidden" name="fld_#CONST_ID_Street_Parking#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Street_Parking#_#marine_rate_item_id#_ratePer" value="#loadingPercent#">
                </cfif>
            </cfloop>
        </td>
        <td>
            <cfloop query="getBoatCourse">
                <input type="hidden" id="fld_#CONST_ID_Boating_Course#_#marine_rate_item_id#_rateFor" name="fld_#CONST_ID_Boating_Course#_#marine_rate_item_id#_rateFor" value="#rateFor#">
                <cfif CompareNoCase(rateFor,"1") eq 0>
                <input type="text" size="6" name="fld_#CONST_ID_Boating_Course#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Boating_Course#_#marine_rate_item_id#_ratePer" value="#loadingPercent#">
                <cfelse>
                <input type="hidden" name="fld_#CONST_ID_Boating_Course#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Boating_Course#_#marine_rate_item_id#_ratePer" value="#loadingPercent#">
                </cfif>
            </cfloop>
        </td>
        <td>
            <input type="text" size="6" name="fld_#CONST_ID_Layup_Discount#_#getLayup.marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Layup_Discount#_#getLayup.marine_rate_item_id#_ratePer" value="#getLayup.loadingPercent#">
        </td>
    </tr>
    </tr>
        <th style="text-align:left;">Min Premium Cost ($)</th>
        <th style="text-align:left;">Max Quotable Boat Price ($)</th>
        <th style="text-align:left;">Pay-By-Mth Charge (%)</th>
        <th style="text-align:left;">Pay-By-Mth<br/>Credit Card Extra (%)</th>
    </tr>
    <tr>
        <td><input type="text" size="6" name="fld_#CONST_ID_MIN_PremiumBase#_#getMinPremBase.marine_rate_item_id#_rateFee" id="fld_#CONST_ID_MIN_PremiumBase#_#getMinPremBase.marine_rate_item_id#_rateFee" value="#getMinPremBase.feeDollar#"></td>
        <td><input type="text" size="12" name="fld_#CONST_ID_MAX_BoatPrice#_#geMaxBoatPrice.marine_rate_item_id#_rateFee" id="fld_#CONST_ID_MAX_BoatPrice#_#geMaxBoatPrice.marine_rate_item_id#_rateFee" value="#geMaxBoatPrice.feeDollar#"></td>
        <td>
            <cfset tempId = getPBMCharge.marine_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_PayByMonthCharge#_#tempId#_ratePer" id="fld_#CONST_ID_PayByMonthCharge#_#tempId#_ratePer" value="#getPBMCharge.loadingPercent#">
        </td>
        <td>
            <cfset tempId = getPBMChargeCC.marine_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_PayByMonthCharge_CCExtra#_#tempId#_ratePer" id="fld_#CONST_ID_PayByMonthCharge_CCExtra#_#tempId#_ratePer" value="#getPBMChargeCC.loadingPercent#">
        </td>
    </tr>
    <tr>
        <th style="text-align:left;">Personal Accident Cover ($)</th>
    </tr>
    <tr>
        <td>
            <cfset tempId = getPersonalAccCover.marine_rate_item_id><cfif tempId eq ""><cfset tempId = 0></cfif>
            <input type="text" size="6" name="fld_#CONST_ID_PersonalAccidentCover#_#tempId#_rateFee" id="fld_#CONST_ID_PersonalAccidentCover#_#tempId#_rateFee" value="#getPersonalAccCover.feeDollar#">
        </td>
    </tr>
</table>

<table cellpadding="5" border="0" cellspacing="0" style="width:100%;">
<tr>
    <td valign="top" style="width:50%">
        <table id="BoatConstrTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th colspan="2" style="text-align:left;"><h2>Boat Construction</h2></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Construction</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getConstructionRates">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_Boat_Construction#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_Boat_Construction#_#marine_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_Boat_Construction#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Boat_Construction#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>

        <table id="BoatStorageTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;" colspan="2"><h2>Boat Storage</h2></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Storage Location</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getBoatStorage">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_Boat_Storage#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_Boat_Storage#_#marine_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_Boat_Storage#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Boat_Storage#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>

        <table id="BoatExpTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;" colspan="2"><h2>Boating Experience</h2></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Experience (years) up to</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getExpRates">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_Boating_Experience#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_Boating_Experience#_#marine_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_Boating_Experience#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Boating_Experience#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>

        <h2>Gap Cover Parameters</h2><br/>
        <table id="GapExtraCoverTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="width:200px;text-align:left;">Sum Insured</th>
            <th style="width:80px;text-align:left;">Price ($)</th>
            <th style="text-align:left;"><input type="button" onClick="addRateRow('GapExtraCoverTable','#CONST_ID_GapExtraCover#','F')" value="Add"></th>
            <th style="text-align:left;"><input type="button" onClick="delRateRow('GapExtraCoverTable','#CONST_ID_GapExtraCover#','F')" value="Del"></th>
        </tr>
        <cfloop query="getGapExtraCover">
        <tr id="row_#CONST_ID_GapExtraCover#_#marine_rate_item_id#">
            <td><input type="text" name="fld_#CONST_ID_GapExtraCover#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_GapExtraCover#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
            <td><input type="text" size="6" name="fld_#CONST_ID_GapExtraCover#_#marine_rate_item_id#_rateFee" id="fld_#CONST_ID_GapExtraCover#_#marine_rate_item_id#_rateFee" value="#feeDollar#"></td>
            <td><input type="Checkbox" name="chk_#CONST_ID_GapExtraCover#_delete" value="row_#CONST_ID_GapExtraCover#_#marine_rate_item_id#"></td>
        </tr>
        </cfloop>
        </table>
        <br/>
    </td>
    <td valign="top" >
        <table id="LiabilityTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;" colspan="2"><h2>Liability Limits</h2></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Liability ($)</th>
            <th style="width:80px;text-align:left;">Loading ($)</th>
        </tr>
        <cfloop query="getLiabilityLims">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_Liability_Limit#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_Liability_Limit#_#marine_rate_item_id#_rateFor" value="#rateFor#">#list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_Liability_Limit#_#marine_rate_item_id#_rateFee" id="fld_#CONST_ID_Liability_Limit#_#marine_rate_item_id#_rateFee" value="#feeDollar#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
        
        <table id="TPOTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;" colspan="2"><h2>Third-Party-Only Cover</h2></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Liability ($)</th>
            <th style="width:80px;text-align:left;">Flat-rate ($)</th>
        </tr>
        <cfloop query="getTPO">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_TPO_Amount#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_TPO_Amount#_#marine_rate_item_id#_rateFor" value="#rateFor#">#list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_TPO_Amount#_#marine_rate_item_id#_rateFee" id="fld_#CONST_ID_TPO_Amount#_#marine_rate_item_id#_rateFee" value="#feeDollar#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
        
        <table id="CustomerAgeTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;"><h2>Customer Age</h2></th>
            <th style="text-align:left;"> <input type="button" onClick="addRateRow('CustomerAgeTable','#CONST_ID_Customer_Age#','P')" value="Add"></th>
            <th style="text-align:left;"> <input type="button" onClick="delRateRow('CustomerAgeTable','#CONST_ID_Customer_Age#','P')" value="Del"></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Up to (years)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getCustAge">
            <tr id="row_#CONST_ID_Customer_Age#_#marine_rate_item_id#">
                <td><input type="text" size="12" name="fld_#CONST_ID_Customer_Age#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_Customer_Age#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_Customer_Age#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_Customer_Age#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_Customer_Age#_delete" value="row_#CONST_ID_Customer_Age#_#marine_rate_item_id#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
    </td>
</tr>
</table>


<table cellpadding="5" border="0" cellspacing="0" style="width:100%;">
<tr>
    <td valign="top" style="width:50%">
        <table id="PwcRatesTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;"><h2>PWC Base Rates</h2></th>
            <th style="text-align:left;"> <input type="button" onClick="addRateRow('PwcRatesTable','#CONST_ID_PWC_Insured_Value_Bands#','P')" value="Add"></th>
            <th style="text-align:left;"> <input type="button" onClick="delRateRow('PwcRatesTable','#CONST_ID_PWC_Insured_Value_Bands#','P')" value="Del"></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Amount Up To ($)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getPWCBaseRates">
            <tr id="row_#CONST_ID_PWC_Insured_Value_Bands#_#marine_rate_item_id#">
                <td><input type="text" size="12" name="fld_#CONST_ID_PWC_Insured_Value_Bands#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_PWC_Insured_Value_Bands#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_PWC_Insured_Value_Bands#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_PWC_Insured_Value_Bands#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_PWC_Insured_Value_Bands#_delete" value="row_#CONST_ID_PWC_Insured_Value_Bands#_#marine_rate_item_id#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
        
        <table id="PwcExcessTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th colspan="3" style="text-align:left;"><h2>PWC Excess</h2></th>
        </tr>
        <tr>
            <th style="width:120px;text-align:left;">Sum Insurable ($)</th>
            <th style="width:80px;text-align:left;">Excess ($)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getPwcExcess">
            <tr>
                <td><input type="text" size="6" name="fld_#CONST_ID_PWC_Excess_Rating#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_PWC_Excess_Rating#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="hidden" name="fld_#CONST_ID_PWC_Excess_Rating#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_PWC_Excess_Rating#_#marine_rate_item_id#_rateFor" value="#rateFor#">#list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_PWC_Excess_Rating#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_PWC_Excess_Rating#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
    </td>
    <td valign="top" >
        <table id="PwcMotorAgeTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;" colspan="2"><h2>PWC Motor Age Rates</h2></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Age Up To (years)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getPwcMotorAge">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_PWC_Motor_Age#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_PWC_Motor_Age#_#marine_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_PWC_Motor_Age#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_PWC_Motor_Age#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
    
        <table id="PwcAgeTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;"><h2>PWC Age Rates</h2></th>
            <th style="text-align:left;"> <input type="button" onClick="addRateRow('PwcAgeTable','#CONST_ID_PWC_Boat_Age#','P')" value="Add"></th>
            <th style="text-align:left;"> <input type="button" onClick="delRateRow('PwcAgeTable','#CONST_ID_PWC_Boat_Age#','P')" value="Del"></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Age Up To (years)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getPWCAgeRates">
            <tr id="row_#CONST_ID_PWC_Boat_Age#_#marine_rate_item_id#">
                <td><input type="text" size="12" name="fld_#CONST_ID_PWC_Boat_Age#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_PWC_Boat_Age#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_PWC_Boat_Age#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_PWC_Boat_Age#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_PWC_Boat_Age#_delete" value="row_#CONST_ID_PWC_Boat_Age#_#marine_rate_item_id#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
        
        <table id="PwcSpeedTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;" colspan="2"><h2>PWC Speed Rates</h2></th>
            <!--- <th style="text-align:left;"> <input type="button" onClick="addRateRow('PwcSpeedTable','#CONST_ID_PWC_Boat_Speed#','P')" value="Add"></th>
            <th style="text-align:left;"> <input type="button" onClick="delRateRow('PwcSpeedTable','#CONST_ID_PWC_Boat_Speed#','P')" value="Del"></th> --->
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Speed Up To (km/h)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getPwcSpeedRates">
            <!--- <tr id="row_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#">
                <td><input type="text" size="12" name="fld_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_PWC_Boat_Speed#_delete" value="row_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#"></td>
            </tr> --->
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#_rateFor" value="#rateFor#">#list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_PWC_Boat_Speed#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
    </td>
</tr>
</table>
        
<br/>
        
<table cellpadding="5" border="0" cellspacing="0" style="width:100%;">
<tr>               
    <td valign="top" style="width:50%">
        <table id="RaRatesTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;"><h2>RA Base Rates</h2></th>
            <th style="text-align:left;"> <input type="button" onClick="addRateRow('RaRatesTable','#CONST_ID_RA_Insured_Value_Bands#','P')" value="Add"></th>
            <th style="text-align:left;"> <input type="button" onClick="delRateRow('RaRatesTable','#CONST_ID_RA_Insured_Value_Bands#','P')" value="Del"></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Amount Up To ($)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getRABaseRates">
            <tr id="row_#CONST_ID_RA_Insured_Value_Bands#_#marine_rate_item_id#">
                <td><input type="text" size="12" name="fld_#CONST_ID_RA_Insured_Value_Bands#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_RA_Insured_Value_Bands#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_RA_Insured_Value_Bands#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_RA_Insured_Value_Bands#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_RA_Insured_Value_Bands#_delete" value="row_#CONST_ID_RA_Insured_Value_Bands#_#marine_rate_item_id#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
        
        <table id="RaExcessTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th colspan="3" style="text-align:left;"><h2>RA Excess</h2></th>
        </tr>
        <tr>
            <th style="width:120px;text-align:left;">Sum Insurable ($)</th>
            <th style="width:80px;text-align:left;">Excess ($)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getRaExcess">
            <tr>
                <td><input type="text" size="6" name="fld_#CONST_ID_RA_Excess_Rating#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_RA_Excess_Rating#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="hidden" name="fld_#CONST_ID_RA_Excess_Rating#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_RA_Excess_Rating#_#marine_rate_item_id#_rateFor" value="#rateFor#">#list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_RA_Excess_Rating#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_RA_Excess_Rating#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
    </td>
    <td valign="top" >
        <table id="RaMotorAgeTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;" colspan="2"><h2>RA Motor Age Rates</h2></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Age Up To (years)</th>
        </tr>
        <cfloop query="getRaMotorAge">
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_RA_Motor_Age#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_RA_Motor_Age#_#marine_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_RA_Motor_Age#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_RA_Motor_Age#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
    
        <table id="RaAgeTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;"><h2>RA Age Rates</h2></th>
            <th style="text-align:left;"> <input type="button" onClick="addRateRow('RaAgeTable','#CONST_ID_RA_Boat_Age#','P')" value="Add"></th>
            <th style="text-align:left;"> <input type="button" onClick="delRateRow('RaAgeTable','#CONST_ID_RA_Boat_Age#','P')" value="Del"></th>
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Age Up To (years)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getRAAgeRates">
            <tr id="row_#CONST_ID_RA_Boat_Age#_#marine_rate_item_id#">
                <td><input type="text" size="12" name="fld_#CONST_ID_RA_Boat_Age#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_RA_Boat_Age#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_RA_Boat_Age#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_RA_Boat_Age#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_RA_Boat_Age#_delete" value="row_#CONST_ID_RA_Boat_Age#_#marine_rate_item_id#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
        
        <table id="RaSpeedTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th style="text-align:left;" colspan="2"><h2>RA Speed Rates</h2></th>
            <!--- <th style="text-align:left;"> <input type="button" onClick="addRateRow('RaSpeedTable','#CONST_ID_RA_Boat_Speed#','P')" value="Add"></th>
            <th style="text-align:left;"> <input type="button" onClick="delRateRow('RaSpeedTable','#CONST_ID_RA_Boat_Speed#','P')" value="Del"></th> --->
        </tr>
        <tr>
            <th style="width:160px;text-align:left;">Speed Up To (km/h)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getRaSpeedRates">
           <!---  <tr id="row_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#">
                <td><input type="text" size="12" name="fld_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <td><input type="Checkbox" name="chk_#CONST_ID_RA_Boat_Speed#_delete" value="row_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#"></td>
            </tr> --->
            <tr>
                <td><input type="hidden" name="fld_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#_rateFor" value="#rateFor#">#list_item_display#</td>
                <td><input type="text" size="6" name="fld_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_RA_Boat_Speed#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
            </tr>
        </cfloop>
        </table>
        <br/>
        
        <table id="RaMotorTypeTable" cellpadding="2" cellspacing="0" border="0">
        <tr>
            <th colspan="2" style="text-align:left;"><h2>RA Motor Type</h2></th>
            <!--- <th style="text-align:left;"> <input type="button" onClick="addRateMotorType('RaMotorTypeTable','#CONST_ID_RA_Motor_Type#','7227,7333','Inboard - Mid Mount,Inboard - Rear Mount')" value="Add"></th>
            <th style="text-align:left;"> <input type="button" onClick="delRateRow('RaMotorTypeTable','#CONST_ID_RA_Motor_Type#','P')" value="Del"></th> --->
        </tr>
        <tr>
            <th style="width:120px;text-align:left;">Motor Type</th>
            <th style="width:60px;text-align:left;">Age (years)</th>
            <th style="width:80px;text-align:left;">Rate (%)</th>
        </tr>
        <cfloop query="getRAMotorTypeRates">
            <tr id="row_#CONST_ID_RA_Motor_Type#_#marine_rate_item_id#">
                <td><input type="hidden" name="fld_#CONST_ID_RA_Motor_Type#_#marine_rate_item_id#_rateFor" id="fld_#CONST_ID_RA_Motor_Type#_#marine_rate_item_id#_rateFor" value="#rateFor#"> #list_item_display#</td>
                <td><input type="text" size="12" name="fld_#CONST_ID_RA_Motor_Type#_#marine_rate_item_id#_rateEnd" id="fld_#CONST_ID_RA_Motor_Type#_#marine_rate_item_id#_rateEnd" value="#rateEnd#"></td>
                <td><input type="text" size="6" name="fld_#CONST_ID_RA_Motor_Type#_#marine_rate_item_id#_ratePer" id="fld_#CONST_ID_RA_Motor_Type#_#marine_rate_item_id#_ratePer" value="#loadingPercent#"></td>
                <!--- <td><input type="Checkbox" name="chk_#CONST_ID_RA_Motor_Type#_delete" value="row_#CONST_ID_RA_Motor_Type#_#marine_rate_item_id#"></td> --->
            </tr>
        </cfloop>
        </table>
        
    </td>
</tr>
</table>
    <input type="submit" value="Save">
</form>
</cfoutput>