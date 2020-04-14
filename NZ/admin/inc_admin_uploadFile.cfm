
<cfif IsDefined("URL.func") and URL.func neq "">
    <cfif compareNoCase(URL.func,"uploadGlass") eq 0>
        <cffile action="upload" filefield="FORM.inp_file" destination="#application.THIRDGENPLUS_TEMP_DIRECTORY#" nameconflict="OVERWRITE" result="upload">
        <cflocation url="admin.cfm" addtoken="No">
    </cfif>
</cfif>

<cfif FileExists("#application.THIRDGENPLUS_TEMP_DIRECTORY#/MOTORCYCLE_GLASSDATA.U12")>
    <cfset fileInformation = GetFileInfo("#application.THIRDGENPLUS_TEMP_DIRECTORY#/MOTORCYCLE_GLASSDATA.U12")>
    <cfoutput>
    <b>MOTORCYCLE_GLASSDATA.U12</b> exist on the location.<br/>
    Modified Date: <b>#DateFormat(fileInformation.lastmodified,"DD-MMM-YYY")# #TimeFormat(fileInformation.lastmodified,"HH:MM:SS")# </b><br/>
    File Size: <b>#round(fileInformation.size/1024)# Kb</b>
    <br/><br/><br/>
    </cfoutput>
</cfif>


<form name="frmUploadFile" id="frmUploadFile" action="admin.cfm?P=uploadFile&func=uploadGlass" method="post" enctype="multipart/form-data">
<input type="File" id="inp_file" name="inp_file"> &nbsp;
<input type="submit" value="Upload"> &nbsp; &nbsp;
*Make sure the filename is <b>MOTORCYCLE_GLASSDATA.U12</b>
</form>
