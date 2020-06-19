/******************************************************************************
* HANDS-ON WORKSHOP                                                           *
*                                                                             *
* Title       : Using SAS Macro Variable Lists to Create Dynamic Data-Driven  *
*               Programs                                                      *
*                                                                             *
* Instructor  : Josh Horstman                                                 *
*                                                                             *
* Exercise    : 02                                                            *
* Input Data  : SASHELP.CARS                                                  *
* Goal        : Create a simple macro variable at execution time using the    *
*               SQL procedure                                                 *
*                                                                             *
* Instructions: Using the INTO clause in PROC SQL, place the WEIGHT for an    *
*               Acura MDX into a macro variable called MDX_WEIGHT.            *
*                                                                             *
******************************************************************************/

proc sql noprint;
   select weight into :MDX_WEIGHT trimmed
   from sashelp.cars
   where strip(make)='Acura' and strip(model)='MDX';
quit;

* Verify the contents of the new macro variable by printing to the SAS log.;
options nosource;
%put ===================================;
%put The weight of an Acura MDX is &MDX_WEIGHT..;
%put ===================================;
options source;
