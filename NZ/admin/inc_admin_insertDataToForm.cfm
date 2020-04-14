<cfsetting requestTimeOut = "300" enablecfoutputonly="Yes">
<cfset rowsPerLoad_Default = 1000> <!--- how many rows will be processed in 1 iteration --->
<cfset loadQty_MAX = 30> <!--- MAX ITERATION - in case of crazy recursive happening --->

<cfset local.fullURL = "http://#CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/admin/index.cfm?p=insertDataToForm">
<cfset local.jobName = "YMI INSERT DATA TO FORM at #DateFormat(now(),'YYYYMMDD')#">

<cfset loadQty = 0>
<cfset le_id = 0>
<cfif IsDefined("URL.lq") and URL.lq neq "" and IsDefined("URL.le_id") and URL.le_id neq "">
    <cfset loadQty = URL.lq>
    <cfset le_id = URL.le_id>
</cfif>

<cfif loadQty lte loadQty_MAX>
    <cfquery name="getYMIData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
    select top #rowsPerLoad_Default# entryID,
        code, mth, make, family, variant, 
        series, style, engine, cc, size, 
        transmission, cyl, valve_gear, boreXStroke, kW, 
        comp_ratio, engine_cooling, kerb_weight, wheelbase, seat_height, 
        drive, front_tyres, rear_tyres, front_rims, rear_rims, 
        ftank, warranty_mths, warranty_kms, country, released_date, 
        discount_date, nvic, [year], new_pr, trade_low, 
        trade, retail, fhd.form_data_id, fhd.yesno1, fhd.date1
    from ymi_productData_raw ymi
    left outer join thirdgen_form_header_data fhd with (nolock) on ymi.nvic = fhd.text1 and fhd.form_def_id = #CONST_bikeDataFormDefId#
    where ymi.processedAt is null
    order by entryID
    </cfquery>
    <cfoutput>
    <br/>Start at: #DateFormat(now(),"DD-MMM-YYYY")# #TimeFormat(now(),"HH:MM:SS")#<br/>
    </cfoutput>
    <cfif getYMIData.recordCount gt 0>
        <!--- <cfinclude template="../thirdgen/query/qry_form_def_fields.cfm">
        <cfdump var="#FormDefFieldsQuery#"> --->
        <cftry>
            <cfloop query="getYMIData">
                <cfif IsDefined("attributes")>
                    <cfset x = StructClear(attributes)>
                </cfif>
                
                <cfset attributes.formDefId = CONST_bikeDataFormDefId>
                <cfset attributes.registrationID = 1> <!--- this is hack ?! --->
                <cfset attributes.siteID = 1>
                <cfset attributes.treeNodeIDList = 2> <!--- to save data in Nautilus Node --->
                <!--- <cfset attributes.siteID = session.thirdgenAS.siteID>
                <cfset attributes.regUserID = session.thirdgenas.userid> --->
                
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Code_FID,getYMIData.code)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Mth_FID,getYMIData.mth)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Make_FID,getYMIData.make)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Family_FID,getYMIData.family)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Variant_FID,getYMIData.variant)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Series_FID,getYMIData.series)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Style_FID,getYMIData.style)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Engine_FID,getYMIData.engine)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_CC_FID,getYMIData.cc)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Size_FID,getYMIData.size)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Trans_FID,getYMIData.transmission)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_CYL_FID,getYMIData.cyl)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_ValveG_FID,getYMIData.valve_gear)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_BoreStr_FID,getYMIData.boreXStroke)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_KW_FID,getYMIData.kW)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_CompRatio_FID,getYMIData.comp_ratio)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_EngCool_FID,getYMIData.engine_cooling)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_KerbW_FID,getYMIData.kerb_weight)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_WheelBase_FID,getYMIData.wheelbase)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_SeatHeight_FID,getYMIData.seat_height)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Drive_FID,getYMIData.drive)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_FrontTyres_FID,getYMIData.front_tyres)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_RearTyres_FID,getYMIData.rear_tyres)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_FrontRims_FID,getYMIData.front_rims)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_RearRims_FID,getYMIData.rear_rims)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Ftank_FID,getYMIData.ftank)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_WarrantyMth_FID,getYMIData.warranty_mths)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_WarranttKm_FID,getYMIData.warranty_kms)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Country_FID,getYMIData.country)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_ReleasedDate_FID,DateFormat(getYMIData.released_date,"DD/MM/YYYY"))>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_DiscDate_FID,DateFormat(getYMIData.discount_date,"DD/MM/YYYY"))>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_NVIC_FID,getYMIData.nvic)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Year_FID,getYMIData.year)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_NewPR_FID,getYMIData.new_pr)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_TradeLow_FID,getYMIData.trade_low)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Trade_FID,getYMIData.trade)>
                <cfset x = StructInsert(attributes,"field_"&CONST_BD_Retail_FID,getYMIData.retail)>
                
                <cfif getYMIData.form_data_id eq ""> <!--- INSERT INTO NEW FORM DATA --->
                    <cfinclude template="../thirdgen/form/inc_save_form.cfm">
                    <cfoutput>insert #getYMIData.code# (#getYMIData.nvic#)<br/></cfoutput>
                <cfelse> <!--- UPDATE EXISTING FORM DATA --->
                    <cfset x = StructInsert(attributes,"field_"&CONST_BD_IsInsurable_FID,getYMIData.yesno1)> 
                    <cfset x = StructInsert(attributes,"field_"&CONST_BD_ReviewedDate_FID,DateFormat(getYMIData.date1,"DD/MM/YYYY")&" "&TimeFormat(getYMIData.date1,"HH:mm:ss"))>
                    <!---
                    <cfset x = StructInsert(attributes,"field_"&CONST_BD_IsInsurable_FID,"")> <!--- reset the isInsurable to unknown --->
                    <cfset x = StructInsert(attributes,"field_"&CONST_BD_ReviewedDate_FID,"")> <!--- reset the reviewed Date to nothing --->
                    --->
                    
                    <cfset attributes.formAction = "edit">
                    <cfset attributes.formDataID = getYMIData.form_data_id>
                    <cfinclude template="../thirdgen/form/inc_save_form.cfm">
                    <cfoutput>update #getYMIData.code# (#getYMIData.nvic#)<br/></cfoutput>
                </cfif>
                <cfoutput>#APPLICATION.NEWLINE#</cfoutput>
                
                <!--- UPDATE processedAt ON ymi_productData_raw --->
                <cfquery name="updateYMIData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
                update ymi_productData_raw
                set processedAt = #CreateODBCDateTime(now())#
                where entryID = #getYMIData.entryID#
                </cfquery>
                
                <cfset le_id = getYMIData.entryID>
            </cfloop>
            <cfcatch type="Any" >
                <cfmail from="helpdesk@3rdmill.com.au" to="feriantol@3rdmill.com.au" type="HTML" subject="YMI NZ">
                <cfoutput>
                <p>#cfcatch.message#</p><br/>
                <p>#cfcatch.detail#</p><br/>
                <cfif IsDefined("cfcatch.Sql")>
                <p>#cfcatch.Sql#</p><br/>
                </cfif>
                <cfif IsDefined("cfcatch.queryError")>
                <p>#cfcatch.queryError#</p><br/>
                </cfif>
                <p>The contents of the tag stack are:</p> 
                <cfloop index=i from=1 to="#ArrayLen(CFCATCH.TAGCONTEXT)#"> 
                    <cfset sCurrent = CFCATCH.TAGCONTEXT[i]>
                    #i# #sCurrent["ID"]# <br/>
                    #sCurrent["TEMPLATE"]# (#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) <br/>
                </cfloop>
                </cfoutput>
                </cfmail>
                <cfabort>
            </cfcatch>
        </cftry>
        <cfset plusMinutes=DateAdd("n", 2, now())>
      
        <!--- check if the task status become EXPIRED - if so, we need to RE-CREATE it --->
        <cfschedule action="list" task="#local.jobName#" result="checkSched" />
        <cfif CompareNoCase(checkSched.status,"EXPIRED") eq 0>
            <cfschedule action="DELETE" task="#local.jobName#">
        </cfif>
        
        <CFSCHEDULE 
            ACTION="UPDATE" 
            TASK="#local.jobName#"
            OPERATION="HTTPRequest"
            starttime="#TimeFormat(plusMinutes,'HH:mm')#" 
            startdate="#DateFormat(now(),'DD-MMM-YYYY')#"
            enddate="#DateFormat(now(),'DD-MMM-YYYY')#"
            ENDTIME="23:58:00"
            URL="#local.fullURL#&le_id=#le_id#&lq=#loadQty+1#"
            publish="yes"
            PATH = "#application.THIRDGENPLUS_TEMP_DIRECTORY#"
            FILE="YMI_INSERT_DATA_TO_FORM.txt"
            INTERVAL="once"
            requesttimeout="360">
        <cfoutput>
        <br/>Scheduling tasks: #DateFormat(now(),"DD-MMM-YYYY")# #TimeFormat(now(),"HH:MM:SS")#<br/>
        </cfoutput>
    <cfelse>
        <cfoutput>
            Finished inserting Data to Form
        </cfoutput>
        <CFSCHEDULE 
            ACTION="delete" 
            TASK="#local.jobName#">
        <cfoutput>
        <br/>Finish at: #DateFormat(now(),"DD-MMM-YYYY")# #TimeFormat(now(),"HH:MM:SS")#<br/>
        </cfoutput>
    </cfif>
    
<cfelse>
    <cfoutput>
    Reach Max Iteration after entryID: #le_id#
    </cfoutput>
    <CFSCHEDULE 
        ACTION="delete" 
        TASK="#local.jobName#">
</cfif>
