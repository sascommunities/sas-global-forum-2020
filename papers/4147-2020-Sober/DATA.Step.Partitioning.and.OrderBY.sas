/* CAS Enabled*/
/* Example of using DATA Step to partition and order a CAS table */
/* Benfit, when a BY statement mactes the partition and ordering, */
/* the data is immediately ready for processing by each thread */
/* If the BY statment does not math the partition and ordering then their is a */
/* cost i.e. the BY is done on the fly to group the data correctly on each thread */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

data caswork.baseball(partition=(div row_order) orderby=(div row_order));
   set sashelp.baseball;
   row_order = _n_;
run;
data caswork.baseball2;
   set caswork.baseball;
   BY DIV ROW_ORDER; /* The data is already in the correct order */
   x=row_order *10;
run;