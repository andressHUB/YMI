<cfoutput>
<cfquery name="getExistingRates" datasource="#application.THIRDGENPLUS_DSN#" username="#application.THIRDGENPLUS_USERNAME#"	password="#application.THIRDGENPLUS_PASSWORD#">
    select * from ymi_motorcycle_rateControl where motorcycle_company_id = #CONST_MOTORCYCLE_COMP_ID# order by startAt desc
</cfquery>

<table cellpadding="5" cellspacing="0">
<tr>
    <td><strong>Effective Date</strong></td>
    <td></td>
    <td colspan="2"><!--- <a href="#admin#rateEdit&ratesId=0">Add New</a> ---></td>
</tr>
<cfset currentRateId = 0>    
<cfset prevEffDate = "">
<cfloop query="getExistingRates">
    <cfset ratesId = getExistingRates.motorcycle_rateControlID>
    <cfset isPast=false>

    <cfset rateEffectiveDate=CreateDate(DatePart("yyyy",startAt),  DatePart("m",startAt),  DatePart("d",startAt))>
    <cfif rateEffectiveDate lt now()>
        <cfset isPast=true>
        <cfif currentRateId eq 0>
            <cfset currentRateId = ratesId>
        </cfif>
    </cfif>
    
    <tr
        <cfif currentRateId eq ratesId>
            bgcolor = "##CCFFFF"
        </cfif>
    >
        <td>#DateFormat(startAt,"dd/mm/yyyy")#
            <cfif rateEffectiveDate eq prevEffDate>
                <BR><strong>**Warning - Same Date Used Multiple Times</strong>
            </cfif>
        </td>
        <td>
            <cfif currentRateId eq ratesId>
            Current Rates   
            </cfif>       
        </td>

        <td>
            <a href="#admin#rateEdit&ratesId=#ratesId#">Edit</a>
        </td><td>
            <a href="#admin#rateCopy&ratesId=#ratesId#">Copy</a>
        </td>
    </tr>
    <cfset prevEffDate = rateEffectiveDate>
</cfloop>
</table>


</cfoutput>