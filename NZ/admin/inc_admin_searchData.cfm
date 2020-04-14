<cfparam name="URL.page" default="1">
<cfparam name="url.DPS" default="10">
<cfset DATA_PER_SCREEN = 10>
<cfif url.DPS gt DATA_PER_SCREEN>
    <cfset DATA_PER_SCREEN = url.DPS>
</cfif>

<cfif not IsDefined("URL.searchValue")>
    <cfquery name="getBikeData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
        select <cfif IsDefined("URL.make") and url.make neq ""AND  IsDefined("URL.isRev") AND url.isRev neq "0">top 100</cfif> 
            fd.form_data_id, fd.created, fd.last_updated, fhd.date2 as reviewedDate, fhd.text1 as nvic, fhd.yesno1 as IsInsurable, fd.xml_data
        
        from thirdgen_form_data fd with (nolock)
        inner join thirdgen_form_header_data fhd with (nolock) on fd.form_data_id = fhd.form_data_id and fd.form_def_id = 0
        where 1 = 1
        order by fhd.text1, fd.form_data_id
    </cfquery>
<cfelse>
        <cfquery name="getBikeData" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#" result="getBikeData_rst">
        select <cfif IsDefined("URL.make") and url.make neq "" AND  IsDefined("URL.isRev") and url.isRev neq "0">top 100</cfif> 
            fd.form_data_id, fd.created, fd.last_updated, fhd.date2 as reviewedDate, fhd.text1 as nvic, fhd.yesno1 as IsInsurable, fd.xml_data
            
        from thirdgen_form_data fd with (nolock)
        inner join thirdgen_form_header_data fhd with (nolock) on fd.form_data_id = fhd.form_data_id and fd.form_def_id = #CONST_bikeDataFormDefId#

        <cfif IsDefined("URL.make") and Trim(URL.make) neq "">
            inner join thirdgen_form_data_shorttext_values as MAKE with (nolock) on fd.form_data_id = MAKE.form_data_id and MAKE.key_name = '#CONST_BD_Make_FID#' 
                and MAKE.field_value like '%#Trim(URL.make)#%'
        </cfif>
        
        <cfif IsDefined("URL.style") and Trim(URL.style) neq "">
            inner join thirdgen_form_data_shorttext_values as style with (nolock) on fd.form_data_id = style.form_data_id and style.key_name = '#CONST_BD_Style_FID#' 
                and style.field_value like '%#Trim(URL.style)#%'
        </cfif>
        
        <cfif IsDefined("URL.engCooling") and Trim(URL.engCooling) neq "">
            inner join thirdgen_form_data_shorttext_values as engCooling with (nolock) on fd.form_data_id = engCooling.form_data_id and engCooling.key_name = '#CONST_BD_EngCool_FID#' 
                and engCooling.field_value like '%#Trim(URL.engCooling)#%'
        </cfif>
        
        <cfif IsDefined("URL.drive") and Trim(URL.drive) neq "">
            inner join thirdgen_form_data_shorttext_values as drive with (nolock) on fd.form_data_id = drive.form_data_id and drive.key_name = '#CONST_BD_Drive_FID#' 
                and drive.field_value like '%#Trim(URL.drive)#%'
        </cfif>
        
        <cfif IsDefined("URL.year") and Trim(URL.year) neq "">
            inner join thirdgen_form_data_number_values as xyear with (nolock) on fd.form_data_id = xyear.form_data_id and xyear.key_name = '#CONST_BD_Year_FID#' 
                and xyear.field_value = #Trim(URL.year)#
        </cfif>
        
        <cfif IsDefined("URL.country") and Trim(URL.country) neq "">
            inner join thirdgen_form_data_shorttext_values as country with (nolock) on fd.form_data_id = country.form_data_id and country.key_name = '#CONST_BD_Country_FID#' 
                and country.field_value like '%#Trim(URL.country)#%'
        </cfif>
        
        <cfif IsDefined("URL.searchValue") and Trim(URL.searchValue) neq ""> <!--- Generic search --->
            inner join
            (
                select distinct form_data_id from thirdgen_form_data_shorttext_values 
                where field_value like '%#Trim(URL.searchValue)#%' and form_def_id = #CONST_bikeDataFormDefId#
            )genSearch on fd.form_data_id = genSearch.form_data_id
        </cfif>
        
        where 1 = 1
        <cfif IsDefined("URL.isRev") and Trim(URL.isRev) neq "">
            <cfif URL.isRev eq 1>
                and fhd.date1 is not null
            <cfelse>
                and fhd.date1 is null
            </cfif>       
        </cfif>
        <cfif IsDefined("URL.isIns") and Trim(URL.isIns) neq "">
            <cfif URL.isIns eq 1>
                and isnull(fhd.yesno1,0) = 1
            <cfelse>
                and isnull(fhd.yesno1,0) = 0
            </cfif>       
        </cfif>
        order by fhd.text1, fd.form_data_id
    </cfquery>

</cfif>


<cfquery name="getBikeMakers" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
select field_value as val, count(*) as tot
from thirdgen_form_data_shorttext_values
where form_def_id = #CONST_bikeDataFormDefId#
and key_name = '#CONST_BD_Make_FID#'
group by field_value
order by field_value
</cfquery>
<cfquery name="getBikeYears" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
select convert(int,field_value) as val, count(*) as tot
from thirdgen_form_data_number_values
where form_def_id = #CONST_bikeDataFormDefId#
and key_name = '#CONST_BD_Year_FID#'
group by field_value
order by field_value desc
</cfquery>
<cfquery name="getBikeStyles" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
select field_value as val, count(*) as tot
from thirdgen_form_data_shorttext_values
where form_def_id = #CONST_bikeDataFormDefId#
and key_name = '#CONST_BD_Style_FID#'
group by field_value
order by field_value
</cfquery>
<cfquery name="getBikeDrives" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
select field_value as val, count(*) as tot
from thirdgen_form_data_shorttext_values
where form_def_id = #CONST_bikeDataFormDefId#
and key_name = '#CONST_BD_Drive_FID#'
group by field_value
order by field_value
</cfquery>
<cfquery name="getBikeCountries" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#" password="#application.THIRDGENPLUS_PASSWORD#">
select field_value as val, count(*) as tot
from thirdgen_form_data_shorttext_values
where form_def_id = #CONST_bikeDataFormDefId#
and key_name = '#CONST_BD_Country_FID#'
group by field_value
order by field_value
</cfquery>

<cfset numRecords = getBikeData.recordCount>
<cfset numPages = int(numRecords/DATA_PER_SCREEN)>
<cfif (numRecords mod DATA_PER_SCREEN) gt 0>
    <cfset numPages = numPages + 1>
</cfif>
<cfif URL.page gt numPages and numPages gt 0>
    <cfset URL.page = numPages>
</cfif>
<cfset startRow = ((URL.page-1) * DATA_PER_SCREEN) + 1>
<cfif startRow lt 1><cfset startRow = 1></cfif>

<cfset prevPage = 0>
<cfif URL.page gt 1>
    <cfset prevPage = URL.page - 1>
</cfif>
<cfset nextPage = 0>
<cfif URL.page lt numPages>
    <cfset nextPage = URL.page + 1>
</cfif>

<style>
    .tooltip_source
    {
        /*cursor:pointer;*/
        font-weight:bold;
    }
    #tooltip {
    	position: absolute;
    	z-index: 10;
    	background-color: #000;
        margin: -5px;
    	opacity: 0.90;
        border-radius:10px;
        font-size:12px;
    }
    
    #tooltip h3, #tooltip div { margin: 0; }    

    #tooltip.black_white {
    	min-width: 250px;        
        border: 2px solid #333333;
        background-color: #eeeeee;
    }
    #tooltip.black_white div { 
        min-width: 250px;
        padding:5px;
        line-height:150%;
        text-align: left;
        color:#333333;
    }
    #tooltip.black_white h3 {
        padding:5px;
        font-size:12px;
    	min-width: 240px;
    	text-align:center;
        font-weight:bold;
        color:#ffffff; 
        border-top-left-radius:5px;
        border-top-right-radius:5px;
        background-color:#333333;
        letter-spacing:2px;
    }
    .adminSubTitle
    {
        font-size:14px;
        font-weight:bold;
    }
    .allIsInsurable,
    .allNotInsurable {
        cursor: pointer;}
</style>

<cfoutput>
<script type="text/javascript" src="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/admin/jquery.min.js"></script>
<script type="text/javascript" src="#request.THIRDGENPLUS_URLPREFIX##CGI.SERVER_NAME##application.THIRDGENPLUS_ROOT#/admin/jquery.tooltip.js"></script>
<!--- <span class="adminSubTitle">Search Page</span> --->
<table class="adminTable2" style="width:100%;">
<tr>
    <td>
        <form name="bikesSearchForm" id="bikesSearchForm" action="admin.cfm" method="get">
            <table  class="adminTable2" style="width:100%;">
            <tr>
                <td style="width:15%"><b>Make</b></td>
                <td style="width:35%">
                    <cfif IsDefined("URL.make") and Trim(URL.make) neq ""><cfset optChoosed = Trim(URL.make)><cfelse><cfset optChoosed = ""></cfif>
                    <select id="make" name="make">
                    <option value="">ALL</option>
                    <cfloop query="getBikeMakers">
                        <option value="#getBikeMakers.val#" <cfif CompareNoCase(optChoosed,getBikeMakers.val) eq 0>selected</cfif> >#getBikeMakers.val#</option>
                    </cfloop>
                    </select>
               </td>
               <td style="width:15%"><b>Year</b></td>
               <td style="width:35%">
                    <cfif IsDefined("URL.year") and Trim(URL.year) neq ""><cfset optChoosed = Trim(URL.year)><cfelse><cfset optChoosed = ""></cfif>
                    <select id="year" name="year">
                    <option value="">ALL</option>
                    <cfloop query="getBikeYears">
                        <option value="#getBikeYears.val#" <cfif CompareNoCase(optChoosed,getBikeYears.val) eq 0>selected</cfif> >#getBikeYears.val#</option>
                    </cfloop>
                    </select>
               </td>
            <tr>
            </tr>
                <td><b>Style</b></td>
                <td>
                    <cfif IsDefined("URL.style") and Trim(URL.style) neq ""><cfset optChoosed = Trim(URL.style)><cfelse><cfset optChoosed = ""></cfif>
                    <select id="style" name="style">
                    <option value="">ALL</option>
                    <cfloop query="getBikeStyles">
                        <option value="#getBikeStyles.val#" <cfif CompareNoCase(optChoosed,getBikeStyles.val) eq 0>selected</cfif> >#getBikeStyles.val#</option>
                    </cfloop>
                    </select>
                </td>
                <td><b>Country</b></td>
                <td>
                    <cfif IsDefined("URL.country") and Trim(URL.country) neq ""><cfset optChoosed = Trim(URL.country)><cfelse><cfset optChoosed = ""></cfif>
                    <select id="country" name="country">
                    <option value="">ALL</option>
                    <cfloop query="getBikeCountries">
                        <option value="#getBikeCountries.val#" <cfif CompareNoCase(optChoosed,getBikeCountries.val) eq 0>selected</cfif> >#getBikeCountries.val#</option>
                    </cfloop>
                    </select>
                </td>
            </tr>
            <tr>
                <td><b>Insurable</b></td>
                <td>
                    <cfif IsDefined("URL.isIns") and Trim(URL.isIns) neq ""><cfset optChoosed = Trim(URL.isIns)><cfelse><cfset optChoosed = ""></cfif>
                    <select id="isIns" name="isIns">
                    <option value="">ALL</option>
                    <option value="1" <cfif optChoosed eq 1>selected</cfif>>Is Insurable</option>
                    <option value="0" <cfif optChoosed eq 0>selected</cfif>>Not Insurable</option>
                    </select>
                </td>
                <td><b>Reviewed</b></td>
                <td>
                    <cfif IsDefined("URL.isRev") and Trim(URL.isRev) neq ""><cfset optChoosed = Trim(URL.isRev)><cfelse><cfset optChoosed = ""></cfif>
                    <select id="isRev" name="isRev">
                    <option value="">ALL</option>
                    <option value="1" <cfif optChoosed eq 1>selected</cfif>>Has Been Reviewed</option>
                    <option value="0" <cfif optChoosed eq 0>selected</cfif>>Not Reviewed</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td><b>Extra Search:</b></td>
                <td>
                    <input type="text" size="30" name="searchValue" 
                <cfif IsDefined("URL.searchValue") and Trim(URL.searchValue) neq "">value="#Trim(URL.searchValue)#"<cfelse>value=""</cfif>><br/>
                </td>
                <td><b>Records per page:</b></td>
                <td>
                    <select id="DPS" name="DPS">
                        <option value="10" <cfif DATA_PER_SCREEN eq 10>selected</cfif>>10</option>
                        <option value="100" <cfif DATA_PER_SCREEN eq 100>selected</cfif>>100</option>
                        <option value="500" <cfif DATA_PER_SCREEN eq 500>selected</cfif>>500</option>
                    </select>
                </td>
                <td>
                    <input type="button" value="Search" onclick="doBikeSearch()" class="buttonColour">
                </td>
            </tr>
            </table>            
            
            <input type="hidden" id="p" name="p" value="searchData">
            <cfif IsDefined("URL.page")>
            <input type="hidden" id="page" name="page" value="#Trim(URL.page)#">
            </cfif>
        </form>
    </td>
</tr>
<cfif IsDefined("URL.searchValue")>
<tr>
    <td>Page #URL.page# of #numPages#</td>
</tr>
<tr>
    <td>
        <form name="bikesListForm" id="bikesListForm" method="post">
            <table class="adminTable" style="width:100%;" border="1">
            <tr>
                <th rowspan="2">NVIC</th>
                <th rowspan="2">Code</th>
                <th rowspan="2">Make/Family</th>
                <th rowspan="2">Year</th>
                <th rowspan="2">Style</th>
                <th rowspan="2">Variant</th>
                <th rowspan="2">Country</th>
                <th colspan="2">Insurable</th>
            </tr>
            <tr>
                <th class="allIsInsurable" title="Mark all records shown as Insurable">Yes</th>
                <th class="allNotInsurable" title="Mark all records shown as Not Insurable">No</th>
            </tr>
            <tr>
                <td colspan="7" > &nbsp; * <cfif getBikeData.recordCount lt DATA_PER_SCREEN>#getBikeData.recordCount#<cfelse>#DATA_PER_SCREEN#</cfif> of the top #getBikeData.recordCount# results shown.</td>
                <td colspan="2" align="center">
                    <button type="button" id="btn_updateInsurable" name="btn_updateInsurable" style="margin:5px 0px;" onclick="updateInsurable()">Update</button>
                </td>
            </tr>
            <cfset rowCount = 0>
            
            <cfloop query="getBikeData" startrow="#startRow#">
                <cfwddx action="WDDX2CFML" input="#getBikeData.xml_data#" output="theXMLData">
                <cfsavecontent variable="theExtraData">
                <b>Trade/Retail:</b> #StructFind(theXMLData,CONST_BD_Trade_FID)# / #StructFind(theXMLData,CONST_BD_Retail_FID)# <br/>
                <b>Warranty:</b> #StructFind(theXMLData,CONST_BD_WarrantyMth_FID)# mth(s) / #StructFind(theXMLData,CONST_BD_WarranttKm_FID)# Km(s) <br/>
                <b>Engine:</b> #StructFind(theXMLData,CONST_BD_Engine_FID)# <br/>
                <b>Style:</b> #StructFind(theXMLData,CONST_BD_Style_FID)# <br/>
                <b>Drive:</b> #StructFind(theXMLData,CONST_BD_Drive_FID)# <br/>
                <b>Trans:</b> #StructFind(theXMLData,CONST_BD_Trans_FID)# <br/>
                <b>Cyl / Valve-Gear:</b> #StructFind(theXMLData,CONST_BD_CYL_FID)# / #StructFind(theXMLData,CONST_BD_ValveG_FID)#<br/>            
                </cfsavecontent>
                
                <tr>
                    <td><a title="Review" href="admin.cfm?p=reviewBike&act=edit&fid=#form_data_id#">#getBikeData.nvic#</a></td>
                    <td><span id="code_#getBikeData.form_data_id#" title="NVIC: #getBikeData.nvic#||#theExtraData#" class="tooltip_source">#StructFind(theXMLData,CONST_BD_Code_FID)#</span></td>
                    <td>#StructFind(theXMLData,CONST_BD_Make_FID)# / #StructFind(theXMLData,CONST_BD_Family_FID)#</td>
                    <td>#StructFind(theXMLData,CONST_BD_Year_FID)#</td>
                    <td>#StructFind(theXMLData,CONST_BD_Style_FID)#</td>
                    <td>#StructFind(theXMLData,CONST_BD_Variant_FID)#</td>
                    <td>#StructFind(theXMLData,CONST_BD_Country_FID)#</td>
                    <td>
                        <!--- <cfif getBikeData.reviewedDate eq "">
                        <a title="Review" href="admin.cfm?p=reviewBike&act=edit&fid=#form_data_id#">Review</a>
                        </cfif> --->
                        <input type="radio" class="isInsurable" id="inp_isIns_yes" name="inp_isIns_#form_data_id#" value="1" <cfif getBikeData.IsInsurable eq true>checked</cfif>>
                    </td>
                    <td>
                        <input type="radio" class="notInsurable" id="inp_isIns_no" name="inp_isIns_#form_data_id#" value="0" <cfif getBikeData.IsInsurable eq false>checked</cfif>>
                    </td>
                </tr>
                <script type="text/javascript">
                $(function() { $('##code_#getBikeData.form_data_id#').tooltip({showBody: "||",extraClass: "black_white" }); });
                </script>
                <cfset rowCount = rowCount + 1>
                <cfif rowCount ge DATA_PER_SCREEN>
                    <cfbreak>
                </cfif>
                
            </cfloop>
            <tr>
                <td colspan="7" > &nbsp; * <cfif getBikeData.recordCount lt DATA_PER_SCREEN>#getBikeData.recordCount#<cfelse>#DATA_PER_SCREEN#</cfif> of the top #getBikeData.recordCount# results shown.</td>
                <td colspan="2" align="center">
                    <button type="button" id="btn_updateInsurable" name="btn_updateInsurable" style="margin:5px 0px;" onclick="updateInsurable()">Update</button>
                </td>
            </tr>
            </table>
            
            <br/>
            <cfif nextPage gt 0 or prevPage gt 0>
                Page #URL.page# of #numPages#
                <select onchange="gotoPage(this.value)" name="goPage">
                <option value="0">Go To Page ...
                <cfloop index="i" from="1" to="#numPages#"><option value="#i#">#i#</cfloop>
                </select>
            </cfif>
            
            <!--- 
            <input type="hidden" name="p" value="searchData">
            <input type="hidden" name="searchValue" value="#Trim(URL.searchValue)#">
            <input type="hidden" name="make" value="#Trim(URL.make)#">
            <input type="hidden" name="year" value="#Trim(URL.year)#">
            <input type="hidden" name="style" value="#Trim(URL.style)#">
            <!--- <input type="hidden" name="engCooling" value="#Trim(URL.engCooling)#"> --->
            <cfif IsDefined("URL.isRev")>
            <input type="hidden" name="isRev" value="#Trim(URL.isRev)#">
            </cfif>
            <cfif IsDefined("URL.isIns")>
            <input type="hidden" name="isIns" value="#Trim(URL.isIns)#">
            </cfif>
            <input type="hidden" name="country" value="#Trim(URL.country)#"> 
            --->
        </form>
    </td>
</tr>
</cfif>
</table>
</cfoutput>

<cfoutput>
<script language="javascript">
    function doBikeSearch() {
        var x = document.getElementById("bikesSearchForm");
        if(x){x.submit();}
    }

    function gotoPage(p) {
        if (p>0) {
            var x = document.getElementById("page");
            x.value = p;
            x = document.getElementById("bikesSearchForm");
            if(x){x.submit();}
        }
    }
    
    function updateInsurable()
    {
        var x = document.getElementById("bikesListForm");
        if(x){
            x.method="post";
            x.action="admin.cfm?p=updateInsurable&redir=#URLEncodedFormat(CGI.QUERY_STRING)#";
            /*var children = x.childNodes;
        	for (var i=0; i < children.length; i++) {
        		if (children[i].name == "p") {
        			children[i].value = "updateInsurable";
        			break;
        		}
        	} */       
            x.submit();
        }
    }
    
    $(function() {
        //jquery
        $('.allIsInsurable').click(function(){
            $('.isInsurable').prop('checked',true);
        });
        $('.allNotInsurable').click(function(){
            $('.notInsurable').prop('checked',true);
        });
    });
</script>
</cfoutput>
