/* CAS Enabled */
/* FedSQL is CAS enabled, convert PROC SQL code into FedSQL to leverage CAS */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

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
   path="&datapath";
run;
/* Load SAS7BDAT into CAS */
table.loadTable /
path='baseball.sas7bdat'
casout={caslib='casuser',
name='baseball', replace=true};
quit;

/* Set the active CASLIB to CASUSER */
options caslib='casuser';

/* Original PROC SQL that runs in SPRE */
proc sql; create table BenchMark as
     select count(*) as ItemCount
     , sum( abs( nhits - nruns ) < 0.1*natbat )   as DIFF_10
     from sashelp.baseball;
run;

/* PROC FedSQL code runs in CAS */
proc fedsql sessref=casauto; 
   create table BenchMark {options replace=true} as
     select count(*) as ItemCount
     , sum(case 
           when (abs (nhits - nruns ) < (0.1*natbat)
                ) is true then 1 end 
          ) as DIFF_10
     from baseball;
quit;
