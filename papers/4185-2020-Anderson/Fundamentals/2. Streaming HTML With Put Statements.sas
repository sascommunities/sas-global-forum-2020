/********************************************************************************/
/* Example Two -  Streaming basic HTML with PUT Statments	       				*/
/********************************************************************************/
/* The following example creates a simple job that uses DATA step code to 		*/
/* return HTML to the client. If you’re familiar with this approach from 		*/
/* creating streaming Stored Processes, you’ll recall the need to wrap your 	*/
/* HTML in PUT statements and single quotation marks. This is easily 			*/
/* illustrated to display output for the classic Hello World message. Unlike 	*/
/* the SAS PROC example, our output requires the parameter _output_type = HTML 	*/
/* in order to properly stream the results										*/
/********************************************************************************/

data _null_;
file _webout;
	put '<head><title>Hello World!</title></head>'; 
	put '<body>'; 
	put '<h1>Hello World!</h1>'; 
	put '</body>'; 
	put '</html>';
	put '<html>'; 
run;
