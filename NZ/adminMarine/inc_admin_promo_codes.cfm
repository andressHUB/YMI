<cfparam name="subAction" default="view">
<cfparam name="promoCode" default="">
<cfparam name="promoCodeID" default="">
<cfparam name="percentage" default="">
<cfparam name="start_datetime" default="">
<cfparam name="end_datetime" default="">
<cfparam name="vessel_type_id" default="">
<cfparam name="error" default="false">
<cfscript>
	//schemeUtilsObj = createObject("component","cfcs.scheme_utils").init();	
</cfscript>

<!--- <cfdump var="#session.thirdgenas.siteid#"> --->

<cfoutput>
	<h3>#ucase(subAction)#</h3>
</cfoutput>

<!--- VALIDATION --->
<cfif subAction eq "update" or subAction eq "save">
	
	<cfscript>
		error = false;
		form.promoCode = trim(form.promoCode);
		if (!isDate(form.start_datetime) or !isDate(form.end_datetime)) {
			error = true;
		}
		if (isDate(form.start_datetime) and isDate(form.end_datetime)) {
			
			if (dateDiff('n',LSDateFormat(form.start_datetime,"dd/mmm/yyyy"),LSDateFormat(form.end_datetime&' 23:59:59',"dd/mmm/yyyy")) lt 0) {
				error = true;
			}	
		}
		if (form.promoCode eq '') {
			error = true;
		}
		if (form.promoCode neq '' and len(form.promoCode) lt 4) {
			error = true;
		}
    </cfscript>
    <cftry>
		<cfset startfieldValueAsDate = createODBCDateTime(LSParseDateTime(form.start_datetime))>
		<cfcatch type="any">
			<cfset startfieldValueAsDate = ''>
		</cfcatch>
	</cftry>
	<cftry>
		<cfset endfieldValueAsDate = createODBCDateTime(LSParseDateTime(form.end_datetime&' 23:59:59'))>
		<cfcatch type="any">
			<cfset endfieldValueAsDate =''>
		</cfcatch>
	</cftry>

</cfif>

<!--- UPDATE  --->
<cfif subAction eq "update">
	<br /><br />	
	<cfif !error>
	
		<cfquery
			datasource="#application.THIRDGENPLUS_DSN#"
		 	password="#application.THIRDGENPLUS_PASSWORD#"
		 	username="#application.THIRDGENPLUS_USERNAME#" >
			update scheme_promo_code_marine
			set
			promo_code = <cfqueryparam value="#trim(promoCode)#" cfsqltype="cf_sql_varchar">,
			percentage = <cfqueryparam value="#form.percentage#" cfsqltype="cf_sql_double">,
			start_datetime =<cfqueryparam value="#startfieldValueAsDate#" cfsqltype="cf_sql_date" null="#YesNoFormat(NOT Len(Trim(form.start_datetime)))#">,
			end_datetime =<cfqueryparam value="#endfieldValueAsDate#" cfsqltype="cf_sql_timestamp" null="#YesNoFormat(NOT Len(Trim(form.end_datetime)))#">,
			vessel_type_id = <cfqueryparam value="#vessel_type_id#" cfsqltype="cf_sql_integer">,
			created_datetime = #createodbcdatetime(now())#,
			created_udid = #val(session.thirdgenas.userid)#,
			site_id = #session.thirdgenas.siteid#
			where id = #form.promoCodeID#
		</cfquery>
		<cfset subAction = "view">
		<cflocation url="../html/adminMarine.cfm?act=promoCodes" addtoken="false">
	<cfelse>
		<cflocation url="../html/adminMarine.cfm?act=promoCodes&subAction=edit&promoCodeID=#form.promoCodeID#&error=true" addtoken="false">
	</cfif>
	
</cfif>

<!--- SAVE  --->
<cfif subAction eq "save">
	
	<cfif !error>
		
		<cfquery
			datasource="#application.THIRDGENPLUS_DSN#"
		 	password="#application.THIRDGENPLUS_PASSWORD#"
		 	username="#application.THIRDGENPLUS_USERNAME#" >
			insert into scheme_promo_code_marine
			(
				promo_code, percentage, start_datetime, end_datetime, vessel_type_id,created_udid, created_datetime,site_id
			) values (
				<cfqueryparam value="#trim(form.promoCode)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.percentage#" cfsqltype="cf_sql_double">,
				<cfqueryparam value="#startfieldValueAsDate#" cfsqltype="cf_sql_date" null="#YesNoFormat(NOT Len(Trim(form.start_datetime)))#">,
				<cfqueryparam value="#endfieldValueAsDate#" cfsqltype="cf_sql_timestamp" null="#YesNoFormat(NOT Len(Trim(form.end_datetime)))#">,
				#form.vessel_type_id#,
				#val(session.thirdgenas.USERID)#,
				#createODBCDateTime(now())#,				
				<cfqueryparam value="#trim(session.thirdgenas.siteid)#" cfsqltype="cf_sql_varchar">
			)
		</cfquery>
		<cflocation url="../html/adminMarine.cfm?act=promoCodes&subAction=view" addtoken="false">
	<cfelse>
		<cfset subAction = 'add'>
	</cfif>
	
</cfif>


<!--- get rates --->
<cfquery name="dataQ" 
	datasource="#application.THIRDGENPLUS_DSN#"
 	password="#application.THIRDGENPLUS_PASSWORD#"
 	username="#application.THIRDGENPLUS_USERNAME#" >
	select pc.*, pc.id as promoCodeID, UD.user_name, 'Motor' as vessel_type  <!--- --, vt.vessel_type --->
	from scheme_promo_code_marine pc (nolock)
	left outer join thirdgen_user_data UD on UD.user_data_id = pc.created_udid
	<!--- left outer join scheme_vessel_type vt on vt.type = pc.vessel_type_id --->
	where 1 = 1
	<cfif val(promoCodeID) gt 0>
		and pc.id = #val(promoCodeID)#
	</cfif>
    and pc.vessel_type_id = #val(CONS_YMI_Marine_Promo_ID)#
	and pc.site_id = #val(session.thirdgenas.userid)#
	order by pc.promo_code,pc.percentage, pc.start_datetime asc, pc.created_datetime desc
</cfquery>


<!--- <cfdump var="#dataQ#"> --->


<cfoutput>
<table id="config" class="table table-striped">
	<tr>
		<td class="desc" colspan="2"><img align="absmiddle" style="border:0;" alt="" src="../images/icon_promo.png"> Promo Codes</td>
		<td colspan="1" style="border-left:none;">&nbsp;</td>
		<td colspan="3" style="border-left:none;">
			<span style="color:grey">Grey = Past/Future Rate</span><br />
			<span style="color:##06a212">Green = Current Rate</span>
			
		</td>
		<td style="border-left:none;border-right: 1px solid ##DCDBDB;" colspan="2"> 
			<!--- <cfif (isdefined("session.thirdgenas.ROLECODELIST") and ListFindNoCase(session.thirdgenas.ROLECODELIST,"caravanAUSSuperAdminAccess") neq 0) or session.thirdgenas.username eq "admin"> --->
			<cfif FindNoCase("ADMIN-1",CONST_userPrivilege) gt 0 
        	or FindNoCase("ADMIN-2",CONST_userPrivilege) gt 0 
        	or FindNoCase("ADMIN-3",CONST_userPrivilege) gt 0 >
				<cfif subAction neq 'add'>
					<a title="Add Promo Code" href="../html/adminMarine.cfm?act=promoCodes&subAction=add" class="btn btn-default btn-sm pull-right">
		          		<span class="glyphicon glyphicon-plus"></span> Add 
		        	</a>
	        	</cfif>
	        </cfif>
        </td>
	</tr>
	<tr>
		<th style="display:none;">Type</th>
		<th>Promo Code</th>
		<th>Percentage</th>
		<th>Start Date/Time</th>
		<th>End Date/Time</th>
		<th>User</th>
		<th>Created / Updated</th>
		<th>Admin</th>
	</tr>
	
<cfif subAction eq "view">
	
	<cfloop query="dataQ">
		
		<cfif isDate(dataQ.end_datetime)>
			<cfif dateDiff('n',lsDateFormat(dataQ.end_datetime,"dd/mmm/yyyy"),lsDateFormat(now(),"dd/mmm/yyyy")) gte 0>
				<cfset endfontCol = 'grey'>
			<cfelse>
				<cfset endfontCol = '##06a212'>
			</cfif>
		<cfelse>
			<cfset endfontCol = '##06a212'>
		</cfif>
		
		<cfif endfontCol eq 'grey'>
			<!--- If end date out of range, start must be past rate also --->
			<cfset startfontCol = 'grey'>
		<cfelse>
		
			<cfif isDate(dataQ.start_datetime)>
				<cfif dateDiff('n',lsDateFormat(dataQ.start_datetime,"dd/mmm/yyyy"),lsDateFormat(now(),"dd/mmm/yyyy")) gte 0>
					<cfset startfontCol = '##06a212'>
				<cfelse>
					<cfset startfontCol = 'grey'>
				</cfif>
			<cfelse>
				<cfset startfontCol = '##06a212'>
			</cfif>
			
		</cfif>
		
		<cfif startfontCol eq 'grey'>
			<cfset endfontCol = 'grey'>
		</cfif>
		
		<tr>
			<td style="display:none;">#dataQ.vessel_type#</td>
			<td>#dataQ.promo_code#</td>
			<td>#dataQ.percentage#</td>
			
			<td style="color:#startfontCol#">
				#lsDateFormat(dataQ.start_datetime,"dd/mm/yyyy")#
				<cfif isDate(dataQ.start_datetime)>
					#lsTimeformat(dataQ.start_datetime,"HH:mm:ss")#
				</cfif>
			</td>
			
			<td style="color:#endfontCol#">
				#lsDateFormat(dataQ.end_datetime,"dd/mm/yyyy")#
				<cfif isDate(dataQ.end_datetime)>
					#lsTimeformat(dataQ.end_datetime,"HH:mm:ss")#
				</cfif>
			</td>
			
			<td>#dataQ.user_name#</td>
			<td>#lsDateFormat(dataQ.created_datetime,"dd/mm/yyyy")# #lsTimeformat(dataQ.created_datetime,"HH:mm")#</td>
			<td>
				<cfset okToEditStartDate = false>
				<cfif isDate(dataQ.start_datetime) and dateDiff('n',lsDateFormat(dataQ.start_datetime,'dd/mmm/yyyy'),now()) lt 0>
					<cfset okToEditStartDate = true>
				</cfif>
				
				<cfset okToEditEndDate = false>
				<cfif isDate(dataQ.end_datetime)>
					<cfif dateDiff('n',lsDateFormat(dataQ.end_datetime,'dd/mmm/yyyy'),now()) lt 0>
						<cfset okToEditEndDate = true>
					</cfif>
				<cfelse>
					<cfset okToEditEndDate = true>
				</cfif>
				<!--- <cfif (isdefined("session.thirdgenas.ROLECODELIST") and ListFindNoCase(session.thirdgenas.ROLECODELIST,"caravanAUSSuperAdminAccess") neq 0) or session.thirdgenas.username eq "admin"> --->
				<cfif FindNoCase("ADMIN-1",CONST_userPrivilege) gt 0 
        	or FindNoCase("ADMIN-2",CONST_userPrivilege) gt 0 
        	or FindNoCase("ADMIN-3",CONST_userPrivilege) gt 0 >
					<cfif okToEditStartDate or okToEditEndDate> 
						<a title="Edit Promo Code" href="../html/adminMarine.cfm?act=promoCodes&subAction=edit&promoCodeID=#dataQ.id#">
							<img align="" style="cursor:hand;padding-top:5px" SRC="../images/icon_edit.gif" border="0" class="pull-right">
						</a>
					</cfif>
				</cfif>
			</td>
		</tr>
	</cfloop>
	<!--- <tr>
		<td colspan="100%" style="text-align:right;" class="separator">
			<a title="Add New Hull Rates" href="../adminCaravan/index.cfm?action=promoCodes&subAction=add"><img align="" style="cursor:hand;padding-top:5px" SRC="../images/add.png" border="0" ></a>
		</td>
	</tr> --->
</cfif>

<cfif subAction eq "edit">
	
	<!--- EDIT --->
	<form name="editpromoCode" action="../adminMarine/index.cfm?act=promoCodes&subAction=update"  method="post">
	<input name="promoCodeID" id="promoCodeID" value="#promoCodeID#" type="hidden">
	<tr>
		
		<td style="display:none;">       
			<select name="vessel_type_id" class="form-control" style="display:none;">
				<!--- <option value="0">Please select...</option> --->
				<option value="0" <cfif dataQ.vessel_type_id eq 10>selected</cfif>>Caravan</option> 
            	<!--- <option value="2" <cfif dataQ.vessel_type_id eq 2>selected</cfif>>YACHT</option>
            	<option value="3" <cfif dataQ.vessel_type_id eq 3>selected</cfif>>CRUISER</option>
            	<option value="4" <cfif dataQ.vessel_type_id eq 4>selected</cfif>>CATAMARAN</option>				
                <option value="5" <cfif dataQ.vessel_type_id eq 5>selected</cfif>>Runabout</option> --->
			</select>
		</td>
		<td><input type="text" size="10"  class="form-control" name="promoCode"  id="promoCode" value="#dataQ.promo_code#"  /></td>
		<td><input type="text" name="percentage" size="8" value="#dataQ.percentage#" class="form-control"></td>
		
		<cfset okToEditStartDate = false>
		<cfif isDate(dataQ.start_datetime) and dateDiff('n',lsDateFormat(dataQ.start_datetime,'dd/mmm/yyyy'),now()) lt 0>
			<cfset okToEditStartDate = true>
		</cfif>
		
		
		<cfset okToEditEndDate = false>
		<cfif isDate(dataQ.end_datetime)>
			<cfif dateDiff('n',lsDateFormat(dataQ.end_datetime,'dd/mmm/yyyy'),now()) lt 0>
				<cfset okToEditEndDate = true>
			</cfif>
		<cfelse>
			<cfset okToEditEndDate = true>
		</cfif>
		
		<cfif !isDate(dataQ.start_datetime) and okToEditEndDate>
			<cfset okToEditStartDate = true>
		</cfif>
		
		<td>
			<cfif okToEditStartDate>
				<input type="text" size="10" class="datepicker form-control" name="start_datetime"  id="start_datetime" value="#lsDateFormat(dataQ.start_datetime,'dd/mm/yyyy')#"  />
			<cfelse>
				<input type="hidden" name="start_datetime" id="start_datetime" value="#lsDateFormat(dataQ.start_datetime,'dd/mm/yyyy')#" />#lsDateFormat(dataQ.start_datetime,'dd/mm/yyyy')#
			</cfif>
		</td>
		<td>
			<cfif okToEditEndDate>
				<input type="text" size="10" class="datepicker form-control" name="end_datetime"  id="end_datetime" value="#lsDateFormat(dataQ.end_datetime,'dd/mm/yyyy')#" />
			<cfelse>
				<input type="hidden" name="end_datetime" id="end_datetime" value="#lsDateFormat(dataQ.end_datetime,'dd/mm/yyyy')#" />#lsDateFormat(dataQ.end_datetime,'dd/mm/yyyy')#
			</cfif>
		</td>
		<td>#session.thirdgenas.username#</td>
		<td>#lsDateFormat(dataQ.created_datetime,"dd/mm/yyyy")# #lsTimeformat(dataQ.created_datetime,"HH:mm")#</td>
		
		<td>
			<button class="btn btn-default btn-sm pull-right" style="align:right" type="Submit">Save</button>
		</td>
		<tr>
			<td colspan="1">Enter promo code.</td>
			<td>Discount %</td>
			<td colspan="2">Enter start or end date or both.</td>
			<td colspan="4">&nbsp;</td>
		</tr>
		<cfif error>
			<tr>
				<td colspan="100%">
					<div class="warning">
						Please enter dates, percentage and Promo Code field with valid values<br />
						Promo code must be at least 4 digits<br />
						Start date must not be after end date
						
					</div>		
				</td>
			</tr>
		</cfif>	
	</tr>
	</form>
	
<cfelseif subAction eq "add">
	
	<!--- ADD --->
	<form name="addHullForm" action="../html/adminMarine.cfm?act=promoCodes&subAction=save"  method="post">
	<tr>
		<td style="display:none;">       
			<!--- vessel type --->
			<select name="vessel_type_id" class="form-control" style="display:none;">
				<option value="0" <cfif vessel_type_id eq 10>selected</cfif>>Caravan</option> 
            	<!--- <option value="2" <cfif vessel_type_id eq 2>selected</cfif>>YACHT</option>
            	<option value="3" <cfif vessel_type_id eq 3>selected</cfif>>CRUISER</option>
            	<option value="4" <cfif vessel_type_id eq 4>selected</cfif>>CATAMARAN</option>				
				<option value="5" <cfif vessel_type_id eq 5>selected</cfif>>Runabout</option> --->
			</select>
		</td>
		<td><input type="text" name="promoCode" size="8" value="#promoCode#" class="form-control"></td>
		<td><input type="text" name="percentage" size="8" value="#percentage#" class="form-control"></td>
		<td><input type="text" size="10" class="datepicker form-control" name="start_datetime"  id="start_datetime" value="#start_datetime#"  /></td>
		<td><input type="text" size="10" class="datepicker form-control" name="end_datetime"  id="end_datetime" value="#end_datetime#"  /></td>
		<td>#session.thirdgenas.username#</td>
		<td>#lsDateFormat(now(),"dd/mm/yyyy")# #lsTimeformat(now(),"HH:mm")#</td>
		<td style="border-right: 1px solid ##DCDBDB;"><button class="btn btn-default btn-sm pull-right" style="align:right;" type="Submit">Save</button></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Min 4 characters</td>
		<td>Discount %  &nbsp;&nbsp; e.g. 5.5</td>
		<td colspan="2">Enter start or end date or both.</td>
		<td colspan="4">&nbsp;</td>
	</tr>
	<cfif error>
		<tr>
			<td colspan="100%">
				<div class="warning">
					Please enter dates, percentage and Promo Code field with valid values<br />
						Promo code must be at least 4 digits<br />
						Start date must not be after end date
				</div>		
			</td>
		</tr>
	</cfif>
	</form>
	
</cfif>
</table>
</cfoutput>
