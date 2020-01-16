/* SPRE Enabled */
/* High cardinality of a BY variable may run faster in SPRE. Best practice in how to leverage SPRE with a CAS table */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

libname data "&datapath";

data caswork.cars;
   set sashelp.cars;
run;

proc sort data=caswork.cars out=data.cars;
   by msrp;
run;

data data.cars2; 
   set data.cars;
   by msrp;
run;

/* Load SAS7BDAT into CAS */
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
/* SAS7BDAT datasets will be loaded in parallel when the shared file system has been mounted on all CAS workers */
/* and all CAS workers have direct access to the SAS7BDAT file at the physical path &datapath */
proc casutil;
   load casdata='cars2.sas7bdat' outcaslib='casuser' casout='cars' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');
run;