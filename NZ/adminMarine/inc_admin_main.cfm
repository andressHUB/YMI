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
    background-color:#ccffff;
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
	<li><a href="#admin#promoCodes" style="display:block;width:100%">Promo Codes</a></li>
    </cfif>
    <li><a href="#admin#thirdgenAdmin" style="display:block;width:100%" target="_blank">Thirdgen Admin</a></li>
    <li><a href="#admin#quoteAdmin" style="display:block;width:100%">Quotes Reports</a></li>
    <!--- <li><a href="#admin#searchData" style="display:block;width:100%">Marine Admin</a></li> --->
</ul>

</cfoutput>