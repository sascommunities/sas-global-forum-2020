/* CAS Enabled */
/* Best practice to parallel load a SAS7BDAT data set into a CAS table */

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
/* SAS7BDAT datasets will be loaded in parallel when the shared file system has been mounted on all CAS workers and
all CAS workers have direct access to the SAS7BDAT file at the physical path /viyafiles/sasss1/data */
proc casutil;
   load casdata='dummy.sas7bdat' outcaslib='casuser' casout='dummy' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');
run;
/* Set active CASLIB to CASUSER */
options caslib='casuser';
