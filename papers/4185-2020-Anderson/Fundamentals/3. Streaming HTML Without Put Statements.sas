/********************************************************************************/
/* Example Three -  Streaming HTML Output without PUT Statements	       		*/
/********************************************************************************/
/* While the previous approach to streaming HTML worked just fine, wrapping your*/ 
/* HTML code in PUT statements and quotation marks could become tedious as your	*/ 
/* code grows. Luckily, by wrapping your code into an INFILE statement, the same*/ 
/* data _null_ technique above enables you to skip that step. The output still	*/ 
/* needs to be set to _output_type = HTML in order for this approach to work:	*/
/********************************************************************************/
/* NOTE: Please do NOT remove the 4 semicolons at the end of CARDS4.			*/
/********************************************************************************/


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
		<p>Hello World, Isn’t This Just Sooooo Much Easier?!?<p>
		</body>
		</html>
	;;;;
run;
