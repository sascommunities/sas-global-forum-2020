/* CAS Enabled */
/* How to Parallel Load and Compress a CAS Table */

/* cas casauto terminate; */
cas;
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

  index /
    table={caslib="sas7bdat" name="cars.sas7bdat" singlepass=true}
    casout={caslib="sas7bdat" name="cars" compress=true replication=1} ; 
  run;
  print _status ; 
  run;

  tabledetails /
    caslib="sas7bdat"
    name="cars" ; 
  run;
quit;
