<style>
ul#adminMenu
{
    margin-left:20px;
    list-style-type:square;
    width:150px;
    font-weight:bold;
}

ul#adminMenu li
{
    padding:5px;
}

ul#adminMenu li:hover
{
    background-color:#ffcccc;
}

ul#adminMenu li a
{
    color:#000000;
    text-decoration:none;
}

</style>
<cfoutput>
<h2>Administration</h2><br/>
<ul id="adminMenu">
    <cfif FindNoCase("ADMIN-1",CONST_userPrivilege) gt 0 
        or FindNoCase("ADMIN-2",CONST_userPrivilege) gt 0 
        or FindNoCase("ADMIN-3",CONST_userPrivilege) gt 0 >
    <li><a href="#admin#rates" style="display:block;width:100%">Maintain Rates</a></li>
    <li><a href="#admin#searchData" style="display:block;width:100%">Motorcycle Admin</a></li>
	<li><a href="#admin#promoCodes" style="display:block;width:100%">Promo Codes</a></li>
        <cfif environment eq "DEV">
            <li><a href="#admin#uploadFile" style="display:block;width:100%">Upload GLASS file</a></li>
            <li><a href="#admin#uploadData&cont=1" style="display:block;width:100%">Sync Motorcycle Data</a> <i>* Must pause "XML Flatten" Scheduled-Task before doing this!</i></li> --->
        </cfif>
    </cfif>
    <li><a href="#admin#thirdgenAdmin" style="display:block;width:100%" target="_blank">Thirdgen Admin</a></li>
    <li><a href="#admin#quoteAdmin" style="display:block;width:100%">Quotes Reports</a></li>
</ul>

</cfoutput>