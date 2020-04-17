/* 1. Check the contents of the SAS data set in SAS EUC-CN session */
libname euclib "C:\SGF2020\use_cvp_to_migrate_to_viya";
options fmtsearch = (euclib);

proc contents data=euclib.carsinfo;
run;

proc print data=euclib.carsinfo (obs=10);
run;

/* 2. Generate the format data set in SAS EUC-CN session */
proc format cntlout=euclib.cnformat lib=euclib;
run;

data euclib.cnformat;
  set euclib.cnformat;
  keep FMTNAME START LABEL TYPE;
run;

proc print data=euclib.cnformat;
run;


/* 3. Review the index in SAS EUC-CN session */
proc datasets lib=euclib nolist;
   contents data=carsinfo out2=euclib.index;
quit;
proc print data = euclib.index;
run;
