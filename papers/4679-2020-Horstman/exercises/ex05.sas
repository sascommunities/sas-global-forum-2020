/******************************************************************************
* HANDS-ON WORKSHOP                                                           *
*                                                                             *
* Title       : Using SAS Macro Variable Lists to Create Dynamic Data-Driven  *
*               Programs                                                      *
*                                                                             *
* Instructor  : Josh Horstman                                                 *
*                                                                             *
* Exercise    : 05                                                            *
* Input Data  : SASHELP.CLASS                                                 *
* Goal        : Create a horizontal macro variable list at execution time     *
*               using the DATA step                                           *
*                                                                             *
* Instructions: Using CALL SYMPUTX statements, create a horizontal macro      *
*               variable list called STUDENT_LIST containing the names of all *
*               the students separated by the tilde character (~).            *
*                                                                             *
*               Also create a macro variable called NUM_STUDENTS containing   *
*               the number of students in the list.                           *
*                                                                             *
******************************************************************************/

data _null_;
   set sashelp.class end=eof;
   length student_list $200;
   retain student_list;
   student_list = ; /* Concatenate the current value of NAME to STUDENT_LIST. */ 
   if eof then do;
      /* Add a CALL SYMPUTX statement to create the STUDENT_LIST macro variable. */
      /* Add another CALL SYMPUTX statement to create NUM_STUDENTS. */
   end;
run;

* Verify the contents of the new macro variables by printing to the SAS log.;
options nosource;
%put ======================;
%put Number of Students: &NUM_STUDENTS;
%put Student List: &STUDENT_LIST;
%put ======================;
options source;
