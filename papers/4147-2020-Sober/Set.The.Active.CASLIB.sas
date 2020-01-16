/* CAS Enabled */
/* When loading data into CAS you need to change to the active CASLIB prior to accessing that CAS table */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

/* Two ways to set the active CASLIB to CASUSER */
options caslib="casuser";

proc cas;
sessionProp.setSessOpt /
caslib="casuser";
run;
quit;