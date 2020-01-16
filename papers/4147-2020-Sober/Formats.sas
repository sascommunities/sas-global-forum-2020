/* CAS Enabled */
/* Ensuring SAS FORMATS are knowing to CAS */

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
   path='cars.sas7bdat'
   casout={caslib='casuser',
   name='cars', replace=true};
quit;

/* create formats that are known in SPRE and CAS */
proc format library=work.formats casfmtlib="casformats";
   value enginesize
   low - <2.7 = "Very economical"
   2.7 - <4.1 = "Small"
   4.1 - <5.5 = "Medium"
   5.5 - <6.9 = "Large"
   6.9 - high = "Very large";
run;

/* Listing of CAS table using user defined formats */
proc print data=cars;
   format enginesize enginesize.;
   var enginesize;
run;
/* Save format so they can be used between CAS sessions */
cas casauto savefmtlib fmtlibname=casformats
   table=enginefmt replace;