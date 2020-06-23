/******************************************************************************
* HANDS-ON WORKSHOP                                                           *
*                                                                             *
* Title       : Using SAS Macro Variable Lists to Create Dynamic Data-Driven  *
*               Programs                                                      *
*                                                                             *
* Instructor  : Josh Horstman                                                 *
*                                                                             *
* Exercise    : 08                                                            *
* Input Data  : SASHELP.CARS                                                  *
* Goal        : Use a vertical macro variable list within a macro DO loop.    *
*                                                                             *
*                                                                             *
* Instructions: Split the CARS data set into a separate data set for each     *
*               unique value of ORIGIN.  Use a vertical macro variable list   *
*               to avoid hard-coding so the code is dynamic.                  *
*                                                                             *
*               The syntax to refer to element i from a vertical macro        *
*               variable list VAR1 - VARn is: &&var&i                         *
*                                                                             *
******************************************************************************/

%macro split_data;

   * Create the vertical macro variable list.;
   proc sql noprint;
      select distinct origin into :ORIGIN1-
         from sashelp.cars;
      %let NUM_ORIGINS = &sqlobs;
   quit;

   /* Replace both hard-coded values of ASIA below using the a reference
      to a vertical macro variable list. */

   %do i = 1 %to &NUM_ORIGINS;
      data cars_asia; * CHANGE THIS LINE ;
         set sashelp.cars;
         where origin = "Asia"; * CHANGE THIS LINE ;
      run;
   %end;

%mend split_data;

%split_data;

