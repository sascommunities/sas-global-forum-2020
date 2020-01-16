/* Requires SAS Viya 3.5+ */
/* CAS Enabled */
/* PROC SORT NODUPKEY and NOUNIKEY on CAS Table Examples */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

data casuser.cars;
   set sashelp.cars;
run;

proc sort data=casuser.cars out=casuser.cars_nodupkey nodupkey;
   by origin;
quit;

proc sort data=casuser.cars out=casuser.cars_nounikey nounikey;
   by msrp;
quit;

proc sort data=casuser.cars out=casuser.cars_nodupkey nodupkey
          dupout=casuser.cars_nodupkey_dups;
   by origin;
quit;

proc sort data=casuser.cars out=casuser.cars_nounikey nounikey
          uniout=casuser.cars_nounikey_uniout;
   by msrp;
quit;