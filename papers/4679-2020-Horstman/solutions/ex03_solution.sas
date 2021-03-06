/******************************************************************************
* HANDS-ON WORKSHOP                                                           *
*                                                                             *
* Title       : Using SAS Macro Variable Lists to Create Dynamic Data-Driven  *
*               Programs                                                      *
*                                                                             *
* Instructor  : Josh Horstman                                                 *
*                                                                             *
* Exercise    : 03                                                            *
* Input Data  : SASHELP.CLASS                                                 *
* Goal        : Create a horizontal macro variable list at execution time     *
*               using the SQL procedure                                       *
*                                                                             *
* Instructions: Using the INTO and SEPARATED BY syntax in PROC SQL, create a  *
*               horizontal macro variable list called STUDENT_LIST containing *
*               the names of all the students separated by spaces.            *
*                                                                             *
*               Add a %LET statement to copy the value of the automatic macro *
*               variable SQLOBS into a macro variable called NUM_STUDENTS.    *
*                                                                             *
******************************************************************************/

proc sql noprint;
   select distinct name into :STUDENT_LIST separated by ' '
   from sashelp.class;
   %let NUM_STUDENTS = &sqlobs;
quit;

* Verify the contents of the new macro variables by printing to the SAS log.;
options nosource;
%put ======================;
%put Number of Students: &NUM_STUDENTS;
%put Student List: &STUDENT_LIST;
%put ======================;
options source;

