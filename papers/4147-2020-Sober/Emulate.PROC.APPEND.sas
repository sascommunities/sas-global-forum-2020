/* CAS Enabled */
/* DATA Step emualtion of PROC APPEND */
/* Note PROC APPEND is not CAS enabled and will run in SPRE */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

/* CASLIB to SAS7BDATs */
proc cas;
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
run;
   table.dropCaslib /
   caslib='sashdat' quiet = true;
run;
   table.addCaslib /
   caslib='sas7bdat'
   dataSource={srctype='path'}
   path="&datapath" ;
quit;

/*Load SAS7BDAT into CAS */
proc cas;
   table.loadTable /
   path='baseball.sas7bdat'
   casout={caslib='casuser',
   name='baseball', replace=true};
quit;
proc cas;
   table.loadTable /
   path='baseball.sas7bdat'
   casout={caslib='casuser',
   name='baseball2', replace=true};
quit;
proc cas;
   table.loadTable /
   path='baseball.sas7bdat'
   casout={caslib='casuser',
   name='baseball3', replace=true};
quit;
proc contents data=baseball;
run;

/* Appending 2 CAS tables to an existing CAS table using a two level name */
data caswork.baseball (append=yes);
   set caswork.baseball2 caswork.baseball3;
run;

proc contents data=baseball;
run;
