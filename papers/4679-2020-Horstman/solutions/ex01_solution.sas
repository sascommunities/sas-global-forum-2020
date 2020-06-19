/******************************************************************************
* HANDS-ON WORKSHOP                                                           *
*                                                                             *
* Title       : Using SAS Macro Variable Lists to Create Dynamic Data-Driven  *
*               Programs                                                      *
*                                                                             *
* Instructor  : Josh Horstman                                                 *
*                                                                             *
* Exercise    : 01                                                            *
* Input Data  : SASHELP.CARS                                                  *
* Goal        : Create a simple macro variable at execution time using the    *
*               DATA step                                                     *
*                                                                             *
* Instructions: Using the CALL SYMPUTX routine, place the MSRP for an Acura   *
*               MDX into a macro variable called MDX_PRICE.                   *
*                                                                             *
******************************************************************************/

data _null_;
   set sashelp.cars;
   where strip(make)='Acura' and strip(model)='MDX';
   call symputx('MDX_PRICE',msrp);
run;

* Verify the contents of the new macro variable by printing to the SAS log.;
options nosource;
%put ===================================;
%put The MSRP for an Acura MDX is &MDX_PRICE..;
%put ===================================;
options source;
