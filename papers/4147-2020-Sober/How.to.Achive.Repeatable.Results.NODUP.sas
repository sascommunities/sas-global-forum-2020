/* CAS Enabled */
/* How to achieve repeatable results with distributed DATA Step BY Groups */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

/* Create a new variable i.e. ROW_ID */
data caswork.baseball;
   set sashelp.baseball;
   row_id=_n_;
run;
/* BY statement must contain the new variable i.e. ROW_ID, as the last variable on the BY statement */
data caswork.nodup;
   set caswork.baseball;
   by  div team row_id  ;
   if first.team  then output;
run;
