/* CAS Enabled */
/* How to Load all datasets from a CASLIB */

/* cas casauto terminate; */
cas;
caslib _all_ assign;
%put  &_sessref_;

proc cas; 
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
run;
   table.dropCaslib /
   caslib='sashdat' quiet = true;
run;
  table.addcaslib /
  caslib="sas7bdat"
  datasource={srctype="path"}
  path="&datapath";
  
  table.fileinfo result=ds / caslib="sas7bdat" includedirectories=false;
  datasets=ds.fileinfo;
  do row over datasets;
    if row.name contains '.sas7bdat' then do;
      table.loadtable / path=row.name caslib="sas7bdat"
      casout={caslib="casuser" name=row.name};
    end;
  end;  
quit;
