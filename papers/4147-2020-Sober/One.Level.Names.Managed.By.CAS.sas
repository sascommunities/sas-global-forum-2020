/* CAS Enabled */
/* How to reference CAS tables using a one-level name */

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
   caslib="sas7bdat" dataSource={srctype="path"}
   path="&datapath";
run;
proc casutil;
   load casdata="baseball.sas7bdat"
   casout='baseball' outcaslib='casuser' replace
   importoptions=(filetype='basesas' dtm='auto');
run;
/* Set active CASLIB to CASUSER */
options caslib='casuser';

/*Runs in CAS*/
/*Target table is a CAS Table*/
/*Source table is a CAS Table*/
data baseball2;
set baseball;
ratio = nruns / nhits;
run;
/*Runs in CAS*/
/*Source table is a CAS Table*/
/*PROC MEANS is CAS enabled*/
proc means data=baseball2;
run;