/* CAS Enabled */
/* How to delete a CAS table */
/* A good programming habit */ 

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
/* SAS7BDAT datasets will be loaded in parallel when the shared file system has been mounted on all CAS workers */
/* and all CAS workers have direct access to the SAS7BDAT file at the physical path *datapath */

proc casutil;
   load casdata='baseball.sas7bdat' outcaslib='casuser' casout='baseball' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');
   load casdata='cars.sas7bdat' outcaslib='casuser' casout='cars' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');
run;

PROC DELETE data=CASWORK._all_; 
run;

proc casutil;
    load casdata='baseball.sas7bdat' outcaslib='casuser' casout='baseball' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');
   load casdata='cars.sas7bdat' outcaslib='casuser' casout='cars' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');

proc casutil
   incaslib="casuser";
   droptable casdata="baseball";
   droptable casdata="cars";
run;

proc casutil;
    load casdata='baseball.sas7bdat' outcaslib='casuser' casout='baseball' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');
   load casdata='cars.sas7bdat' outcaslib='casuser' casout='cars' replace
   importoptions=(filetype='basesas' dtm='auto' debug='dmsglvli');
run;

proc cas;
   table.droptable / caslib="casuser" name="baseball";
   table.droptable / caslib="casuser" name="cars";
run;