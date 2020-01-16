/* CAS Enabled */
/* Best practice to save a CAS table as a SASHDAT table */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

/* CASLIB for SASHDAT */
proc cas;
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
run;
   table.dropCaslib /
   caslib='sashdat' quiet = true;
run;
   table.addCaslib /
   caslib='sashdat'
   dataSource={srctype='DNFS'}
   path="&datapath" ;
quit;

/* Load CAS table */
proc casutil;
   load casdata='baseball.sashdat' outcaslib='casuser' casout='baseball' replace;
quit;

/* Two ways to save a CAS table to SASHDAT */
proc cas;
   table.save / caslib='sashdat'
   table={name='baseball', caslib='casuser'},
   name='baseball.sashdat'
   replace=True;
quit;

proc casutil;
   save casdata='baseball' incaslib='casuser'
   casout='baseball.sashdat' outcaslib='sashdat'
   replace;
quit;
