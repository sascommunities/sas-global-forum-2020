/* CAS Enabled */
/* SAS Viya 3.4 or Lower */
/* DATA Step emulation of PROC SORT NODUPKEY is accomplished by using FIRST. (dot) processing */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

/* Establish CASLIB to SAS7BDAT data sets */
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
proc cas;
table.loadTable /
path='baseball.sas7bdat'
casout={caslib='casuser',
name='baseball', replace=true};
quit;

/* Two ways to set the active CASLIB to CASUSER */
options caslib='casuser';

proc fedsql sessref=casauto; 
   create table nodup {options replace=true} 
   as select distinct div, team 
   from casuser.baseball 
   group by div, team; 
quit;


data nodup;
   set baseball;
   by div team ;
   if first.team then output;
run;