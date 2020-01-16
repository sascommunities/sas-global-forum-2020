/* CAS Enabled */
/* Leveraging the Output Delivery System to generate a CSV file from a CAS table */

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
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
   table.addCaslib /
   caslib="sas7bdat"
   dataSource={srctype="path"}
   path="&datapath";
run;

/* Load SAS7BDAT into CAS */
proc cas;
table.loadTable /
path='baseball.sas7bdat'
casout={caslib='casuser',
name='baseball', replace=true};
quit;

ods csvall file="&datapath./ODS_CSVALL.csv";
proc print data=caswork.baseball;
run;
ods csvall close;