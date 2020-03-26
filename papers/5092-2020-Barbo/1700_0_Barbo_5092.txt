/*
MACRO_check_var_exist.sas

Purpose:  To check for variables that exist in more than one dataset. 
          Ideal to use before merging 2 or more datasets as a check to 
          prevent incorrect variables from overwriting correct ones with
          the same name.

Written by:
  Andrea Barbo
  February 2020

Inputs:   dta       - string of datasets under consideration, separated by space and 
                      must be preceded by a libref if stored as a permanent dataset
          link_var  - string of variable names that should be excluded from the checking
                    - normally, these would be the variables needed to merge datasets and as such, must be present in all

Output:   List of variables that exist in more than one dataset in the Results Window

Usage:    %check_var_exist(dta=cars1 cars2 cars3,link_var=make model drivetrain)
*/

%macro check_var_exist(dta=,link_var=);
  data _null_;
    /*remove excess blank characters from list of datasets*/
    _var="&dta";
    dta_list=tranwrd(compbl(strip(_var)),". ",".");
    call symputx("dta_list",dta_list);

    /*count how many datasets to check for overlapping variables*/
    cnt_dta=count(strip(dta_list)," ")+1;
    call symputx("cnt_dta",cnt_dta);

    /*list of variables to exclude from checking*/
    list_var=lowcase("'"||tranwrd(compbl(strip("&link_var"))," ","','")||"'");
    call symputx("list_var",list_var);
  run;
  %put &dta_list &cnt_dta &list_var;

  /*output variables that exist in more than 1 dataset*/
  proc sql;
    select * 
    from (select distinct upcase(name) as name label="Column Name",type,length,libname,memname
          from sashelp.vcolumn
      %if %sysfunc(find(%scan(%sysfunc(lowcase(&dta_list)),1,' '),.))>0 %then %do;
          where ( (lowcase(libname)="%scan(%scan(%sysfunc(lowcase(&dta_list)),1,' '),1,'.')" and lowcase(memname)="%scan(%scan(%sysfunc(lowcase(&dta_list)),1,' '),2,'.')")
      %end;
      %else %do;
          where ( (lowcase(libname)="work" and lowcase(memname)="%scan(%sysfunc(lowcase(&dta_list)),1,' ')")
      %end;
          %do i=2 %to &cnt_dta;
           %if %sysfunc(find(%scan(%sysfunc(lowcase(&dta_list)),&i,' '),.))>0 %then %do;
            or (lowcase(libname)="%scan(%scan(%sysfunc(lowcase(&dta_list)),&i,' '),1,'.')" and lowcase(memname)="%scan(%scan(%sysfunc(lowcase(&dta_list)),&i,' '),2,'.')")
           %end;
           %else %do;
            or (lowcase(libname)="work" and lowcase(memname)="%scan(%sysfunc(lowcase(&dta_list)),&i,' ')")
           %end;
          %end;
          ) and lowcase(name) not in (&list_var)
    )
    group by name
    having count(*)>1
    order by name,libname,memname
    ;
  quit;
%mend check_var_exist;
