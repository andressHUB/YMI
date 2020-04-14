// Returns the shortname of the supplied month number
function g_getshtmnth(monthno)
{
	var m=new Array(12);
	m[1]="Jan";		m[2]="Feb";		m[3]="Mar";		m[4]="Apr";
	m[5]="May";		m[6]="Jun";		m[7]="Jul";		m[8]="Aug";
	m[9]="Sep";		m[10]="Oct";	m[11]="Nov";	m[12]="Dec";
	if (monthno>=1 && monthno <=12)	return m[monthno];
	else return false;
}
	
	
// Returns the month number of the supplied month name. eg g_getmnthnum(January) returns 1
function g_getmnthnum(monthname)
{
	var sm=monthname.substring(0,3).toLowerCase()
	for (x=1;x<=12;x++)	{
			if (sm==g_getshtmnth(x).toLowerCase())
			return x;
		}
	return false;
}
	
// Checks if the number of days is valid for the supplied month and year.	
function g_chkdaysmnth(days,month,year)
{
	if (month==1 || month==3 || month==5 || month==7 || month==8 || month==10 || month==12)
		if (days>=1 && days <=31) return true;
		else return false; 
	if (month==4 || month==6 || month==9 || month==11)
		 if (days>=1 && days <=30) return true;
		 else return false; 
	if (month==2) 
		if (days>=1 && days <=28) return true;
		else
			if (days==29) 
			 	if (parseInt(year/4,10)==(year/4)) return true;
				else return false;
			else return false;
}
	function g_trim(ts) {
		if (ts) {
			ts=""+ts
			for (;ts.charAt(ts.length-1)==' ';) 
				ts=ts.substring(0,ts.length-1);
			for (;ts.charAt(0)==' ';)
				ts=ts.substring(1,ts.length);
		}
		return ts;
	}
	function g_listgetat(inwhat,which,sep)
	{
		var n = 0,wstr = 0,i = 0,s = 0,f = 0;
		for (i=1 ; i < which ; i++) {
			n = inwhat.indexOf(sep,n)
			if (n < 0) return ''
			n++ }
		if (n >= 0) { var s=n;
			var f = inwhat.indexOf(sep,n)
			if (f < 0) f = inwhat.length
			wstr = inwhat.substring(n,f)}
		return wstr
	}

    // Examines a text field and tries to convert it into a recognised date.	
    function g_checkdate(fd_datefield,date_format,no_change,clear_it)
    {
    	if (!date_format) date_format="DD/MM/YYYY"
    	date_format=date_format.toUpperCase()
    	var datefield = g_trim(fd_datefield.value)
    	if (g_trim(datefield)=='')
    	{
    		if (!no_change) // If this has a value, don't fire the pagechanged event
    			if (typeof pagechanged != "undefined") 
    				pagechanged()
    		return true;
    	}
    	//convert slashes to dashes
    	while (datefield.indexOf("/") != -1) 
    	{  // The end of the next line is not commented out. Only the editor thinks so!
    		datefield = datefield.replace(/\//g,"-"); 
    	}
    	// convert spaces to dashes
    	while (datefield.indexOf(" ") != -1) 
    	{  // The end of the next line is not commented out. Only the editor thinks so!
    		datefield = datefield.replace(/\ /g,"-"); 
    	}
    	// remove commas
    	while (datefield.indexOf(",") != -1) 
    	{  // The end of the next line is not commented out. Only the editor thinks so!
    		datefield = datefield.replace(/\,/g,""); 
    	}
    	var delim1 = datefield.indexOf("-");   		// find the first dash
    	var delim2 = datefield.lastIndexOf("-");	// find the last dash
    	if (delim1 != -1 && delim1 == delim2) {		// if both can't be found then give up
    		alert ('Date format not valid.');
    		if (clear_it)
    			fd_datefield.value=""
    		else
    		{
    			fd_datefield.focus();
    			fd_datefield.select();
    		}
    		return false;
    	}
    	if (delim1 != -1) 
    	{	 // There are delimiters
    		if (date_format=="MMM-DD-YYYY")
    		{
    			var mmstring=datefield.substring(0,delim1);	// extract the month part
    			var dd=parseInt(datefield.substring(delim1+1,delim2),10);	// extract the day part
    		} else
    		{ // Assume Euro Date
    			var dd=parseInt(datefield.substring(0,delim1),10);	// extract the day part
    			var mmstring=datefield.substring(delim1+1,delim2);	// extract the month part
    		}
    		if (isNaN(mmstring)) { //if the month isn't a number, check for a month name.
    			var mm=g_getmnthnum(mmstring);	// convert the monthname to a number
    			if (isNaN(mm)) { 	// if it couldn't be converted, then exit.
    				alert('Date format not valid. Month name not found');
    				if (clear_it)
    					fd_datefield.value=""
    				else
    				{
    					fd_datefield.focus();
    					fd_datefield.select();
    				}
    				return false;
    			}
    		} else { var mm=parseInt(mmstring,10); } // the month is a number, so keep it
    		var yyyy=parseInt(datefield.substring(delim2+1,datefield.length),10); // get the year part
    	} else 
    	{ // there are no delimitors. Assume a date format of DDMMYY[YY] or MMDDYY[YY]
    		if (date_format=="MMM-DD-YYYY")
    		{
    			var mm=parseInt(datefield.substring(0,2),10);	// get the month part
    			var dd=parseInt(datefield.substring(2,4),10);	// get the day part
    		} else
    		{
    			var dd=parseInt(datefield.substring(0,2),10);	// get the day part
    			var mm=parseInt(datefield.substring(2,4),10);	// get the month part
    		}
    		var yyyy=parseInt(datefield.substring(4,datefield.length),10);	// get the year part
    	}
    	yyyy=parseInt(g_trim((yyyy+"    ").substring(0,4)))
    	if (isNaN(dd) || isNaN(mm) || isNaN(yyyy)) {	// All the fields need to be numeric
    		alert('Date format not valid - Non numeric entries');
    		if (clear_it)
    			fd_datefield.value=""
    		else
    		{
    			fd_datefield.focus();
    			fd_datefield.select();
    		}
    		return false;
    	}
    	if (mm<1 || mm >12) {	// month as to be 1 to 12 
    		alert('Date format not valid. Invalid month');
    		if (clear_it)
    			fd_datefield.value=""
    		else
    		{
    			fd_datefield.focus();
    			fd_datefield.select();
    		}
    		return false;
    	}
    	if (yyyy < 100)		// If the year had only 2 digits
    		if (yyyy > 30) yyyy+=1900; else yyyy+=2000;		// add to it. Pivot year is 1930
    	if (yyyy < 1753) {	// SQL doesn't like less than 1753
    		alert('Date not valid. Invalid Year');
    		if (clear_it)
    			fd_datefield.value=""
    		else
    		{
    			fd_datefield.focus();
    			fd_datefield.select();
    		}
    		return false;
    	}
    
    	if (!g_chkdaysmnth(dd,mm,yyyy)) {	// Check the number of days is valid for this month.
    		alert('Date format not valid. Invalid days');
    		if (clear_it)
    			fd_datefield.value=""
    		else
    		{
    			fd_datefield.focus();
    			fd_datefield.select();
    		}
    		return false;
    	}
    	if (date_format=="MMM-DD-YYYY")
    	{
    		fd_datefield.value=""+g_getshtmnth(mm)+" "+dd+", "+yyyy;	// Format the return date as MMM-DD-YYYY
    	} else
    	{
    		fd_datefield.value=""+dd+"/"+mm+"/"+yyyy;	// Format the return date as dd/mm/yyyy
    	}
    	return true;
    }
