/********************************************************************************/
/* Example One -  A Simple Proc Print with results streamed to browser	       	*/
/********************************************************************************/
/* Among the most basic uses of a SAS job is the ability to run code in         */
/* a non-interactive manner to return SAS procedure output to the browser. 		*/
/* The following example creates a simple job that uses a PROC PRINT on the 	*/
/* SASHELP.CARS table and streams output to the client. There’s little more 	*/
/* to this approach than creating a SAS job with your code and specifying  		*/
/* the parameter _Output_Type = ods_html5: 										*/
/********************************************************************************/

proc print data=SASHELP.CARS (obs=10);
run;
