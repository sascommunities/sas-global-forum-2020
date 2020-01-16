/* CAS Enabled */
/* How to Emulate DATA Step DESCENDING BY Statements in SAS Cloud Analytic Services (CAS) */
/* SAS Viya 3.4 or lower */
/* SAS Viya 3.5 or higher supports DESCENDING on a DATA Step BY Statement */
/* SAS Viya 3.5 or higher supports DESCENDING on a DATA Step BY statement with the caveat that DESCENDING is not not supported on the first variable of the BY statement */
/* If there is a DESCENDING on the first variable of the BY statement it will run in SPRE */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

/* Load SAS7BDAT into CAS */
proc cas;
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
run;
   table.dropCaslib /
   caslib='sashdat' quiet = true;
run;
   table.addCaslib /
   caslib='sas7bdat' dataSource={srctype='path'}
   path="&datapath";
run;
proc casutil;
   load casdata='cars.sas7bdat'
   casout='cars' outcaslib='casuser' replace
   importoptions=(filetype='basesas' dtm= 'auto');
run;

/* Create a CAS view */
/* For each DESCENDING numeric create a new variable(s) */
/* The value of the new variable(s) is the negated value */
/* of the original DESCENDING BY numeric variable(s) */

proc cas;
   table.view / replace = true
   caslib='casuser'
   name='descending'
   tables={{
      name='cars'
      varlist={'msrp' 'make'},
      computedVars={{name='n_msrp'}},
      computedVarsProgram='n_msrp = -(msrp)'
   }};
run;
quit;

data descending2;
   set descending;
   by make n_msrp ;
   if first.make ;
run;