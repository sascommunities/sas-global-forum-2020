/******************************************************************************
* HANDS-ON WORKSHOP                                                           *
*                                                                             *
* Title       : Using SAS Macro Variable Lists to Create Dynamic Data-Driven  *
*               Programs                                                      *
*                                                                             *
* Instructor  : Josh Horstman                                                 *
*                                                                             *
* Exercise    : 06                                                            *
* Input Data  : SASHELP.CLASS                                                 *
* Goal        : Create a vertical macro variable list at execution time       *
*               using the DATA step                                           *
*                                                                             *
* Instructions: Using CALL SYMPUTX statements, create a vertical macro        *
*               variable list consisting of macro variables names STUDENT1    *
*               through STUDENT19, each containing one name.                  *
*                                                                             *
*               Also create a macro variable called NUM_STUDENTS containing   *
*               the number of students in the list.                           *
*                                                                             *
******************************************************************************/

data _null_;
   set sashelp.class end=eof;
   /* Add a CALL SYMPUTX statement to create one of the STUDENTn macro variables. */
   if eof then /* Add another CALL SYMPUTX statement to create NUM_STUDENTS. */ ;
run;

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
