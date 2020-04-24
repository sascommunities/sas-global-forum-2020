/********************************************************************************************/
/* Example Four - Streaming Both SAS Proc Output And HTML In The Same Job					*/
/********************************************************************************************/
/* We can combine both of our previous techniques to create output that includes both 		*/	
/* SAS PROC output and custom HTML. This requires us to toggle between output types 		*/	
/* programmatically. In the job definition’s parameters, specify _output_type = HTML in 	*/
/* order to render the HTML and capture SAS PROC code that creates output within 			*/
/* ODS HTML tags. SAS procedure output has to be explicitly captured between ODS 			*/
/* HTML tags in order to render. This approach allows us to freely switch back and forth 	*/
/* between both output types, giving us the foundation for any application development.		*/
/********************************************************************************************/

data _null_; 
	format infile $char256.; 
	input;
	infile = resolve(_infile_);
	file _webout;
	put infile;
	cards4;
		<html>
		<head>
		<body>
		<center>
		<br><br>
		<h1>SAS PROC PRINT OF SASHELP.CARS</h1>
		</center>
		<br>
		</body>
		</html>
;;;;
run;

ods html file=_webout; /* This line opens the Output Delivery System to allow SAS Proc output streaming and close HTML */

options nodate nonumber;

proc print data=sashelp.cars (obs=10);
run;


ods html close; /* This line closes the Output Delivery System to end SAS Proc output streaming and resume HTML */

data _null_; 
	format infile $char256.; 
	input;
	infile = resolve(_infile_);
	file _webout;
	put infile;
	cards4;
		<html>
		<head>
		<body>
		<center>
		<br><br>
		<button type="button" onclick="alert('Hello world!')">Update Table</button>
		</center>
		<br>
		</body>
		</html>
;;;;
run;






















