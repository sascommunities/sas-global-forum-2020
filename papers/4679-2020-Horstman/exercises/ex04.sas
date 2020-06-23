/******************************************************************************
* HANDS-ON WORKSHOP                                                           *
*                                                                             *
* Title       : Using SAS Macro Variable Lists to Create Dynamic Data-Driven  *
*               Programs                                                      *
*                                                                             *
* Instructor  : Josh Horstman                                                 *
*                                                                             *
* Exercise    : 04                                                            *
* Input Data  : SASHELP.CLASS                                                 *
* Goal        : Create a vertical macro variable list at execution time       *
*               using the SQL procedure                                       *
*                                                                             *
* Instructions: Using the INTO and SEPARATED BY syntax in PROC SQL, create a  *
*               vertical macro variable list consisting of macro variables    *
*               named STUDENT1 through STUDENT19, each containing one name.   *
*                                                                             *
*               Add a %LET statement to copy the value of the automatic macro *
*               variable SQLOBS into a macro variable called NUM_STUDENTS.    *
*                                                                             *
******************************************************************************/

proc sql noprint;
   select /* Add required SQL syntax here */
   from sashelp.class;
   /* Add %LET statement here */
quit;

* Verify the contents of the new macro variables by printing to the SAS log.;
options nosource;
%put ======================;
%put Number of Students: &NUM_STUDENTS;
%put;
%put Student 1: &STUDENT1;
%put Student 2: &STUDENT2;
%put Student 3: &STUDENT3;
%put ...;
%put Student 17: &STUDENT17;
%put Student 18: &STUDENT18;
%put Student 19: &STUDENT19;
%put ======================;
options source;

