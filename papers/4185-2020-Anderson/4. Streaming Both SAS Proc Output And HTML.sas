/********************************************************************************/
/* Example Four	- Streaming Both SAS Proc Output And HTML 	       				*/
/********************************************************************************/
/* While the previous approach to streaming HTML worked just fine, wrapping your*/ 
/* HTML code in PUT statements and quotation marks could become tedious as your	*/ 
/* code grows. Luckily, by wrapping your code into an INFILE statement, the same*/ 
/* data _null_ technique above enables you to skip that step. The output still	*/ 
/* needs to be set to _output_type = html in order for this approach to work:	*/
/********************************************************************************/
