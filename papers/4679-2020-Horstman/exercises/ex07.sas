/******************************************************************************
* HANDS-ON WORKSHOP                                                           *
*                                                                             *
* Title       : Using SAS Macro Variable Lists to Create Dynamic Data-Driven  *
*               Programs                                                      *
*                                                                             *
* Instructor  : Josh Horstman                                                 *
*                                                                             *
* Exercise    : 07                                                            *
* Input Data  : SASHELP.STOCKS                                                *
* Goal        : Use a horizontal macro variable list within a macro DO loop.  *
*                                                                             *
*                                                                             *
* Instructions: Create a separate plot in a separate file for each value of   *
*               STOCK in the STOCKS data set. Use a horizontal macro variable *
*               list with the %SCAN function to replace hard-coding values so *
*               the code is dynamic.                                          *
*                                                                             *
*               %SCAN accepts three argument:                                 *
*                  1) A string to be parsed into words                        *
*                  2) A number indicating which word should be returned       *
*                  3) A delimiter character that identifies word boundaries   *
*                                                                             *
******************************************************************************/

%macro graph_stocks;

   * Create the horizontal macro variable list.;
   proc sql noprint;
      select distinct stock into :STOCK_LIST separated by '~'
         from sashelp.stocks;
      %let NUM_STOCKS = &sqlobs;
   quit;

	/* Replace both hard-coded values of IBM below using the %SCAN function
	   to parse the current stock from the STOCK_LIST macro variable. */

   %do I = 1 %to &NUM_STOCKS;
      ods pdf file= "IBM.pdf"; * CHANGE THIS LINE ;
         proc sgplot data=sashelp.stocks;
            where stock = "IBM";  * CHANGE THIS LINE ;
            highlow x=date high=high low=low;
         run;
      ods pdf close;
   %end;

%mend graph_stocks;

%graph_stocks;

