/* CAS Enabled */
/* Provides information on your SAS Viya environment */

/* Establish a CAS session */
cas;
%put  &_sessref_;

/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;

%put &sysvlong4.;
cas casauto listabout;
proc cas;
about;
run;