/* CAS Enabled */
/* How to convert character data type into varchar data type when lifting a table into CAS */ 
/* To reduce the size of CAS tables consider converting CHARACTER data into VARCHAR data using PROC CASUTIL IMPORTOPTIONS VARCHARCONVERSION= statement */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

proc cas;
  file log;
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
run;
   table.dropCaslib /
   caslib='sashdat' quiet = true;
run;
  addcaslib /
    datasource={srctype="path"}
    name="sas7bdat"
    path="&datapath" ; 
 run;
 
data sas7bdat.table_with_char;
               length a $ 300;
a="qazwsxedcrfvtgbyhnujmiklopqazwsxedcrfvtgbyhnujmikolp12345678901234567890123456789012345678901234567890123456789012345678901234567890";
run;


proc casutil;
               load casdata="table_with_char.sas7bdat" incaslib="sas7bdat" outcaslib="casuser"
               casout="table_with_varchar" importoptions=(filetype="basesas" varcharconversion=16) replace;
run;

proc cas;
   sessionProp.setSessOpt /
   caslib="casuser";
run;
   table.columninfo / table="table_with_varchar";
quit;
