/* CAS Enabled */
/* Best practice to save a CAS table as a SAS7BDAT table */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

/* CASLIB for SAS7BDAT data sets */
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
   load casdata='baseball.sas7bdat' outcaslib='casuser' casout='baseball' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');
run;

/* Two ways to save a CAS table as a SAS7BDAT */
proc cas;
   table.save / caslib='sas7bdat'
   table={name='baseball', caslib='casuser'},
   name='baseball.sas7bdat'
   replace=True;
quit;

proc casutil;
   save casdata='baseball' incaslib='casuser'
   casout='baseball.sas7bdat' outcaslib='sas7bdat'
   replace;
quit;


/* Set active CASLIB to CASUSER */
options caslib='casuser';
