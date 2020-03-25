libname mylib 'data';

/* Truncated if print the data set directly */
proc print data=mylib.class; run;

/* Expand it using CVP */
libname mylib cvp 'data';
proc print data=mylib.class; run;
proc contents data=mylib.class; run;

/* Specify a multiplier */
libname mylib cvp 'data' cvpmultiplier=1.5;
proc contents data=mylib.class; run;

/* Save it as a UTF-8 data set */
libname outlib "output";
proc datasets nolist;
copy in=mylib out=outlib override=(encoding=session outrep=session)
     memtype=data;
run; quit;
proc contents data=outlib.class; run;

/* Only expand 'Name' using cvpinclude */
libname mylib 'data' cvpbytes=1 cvpinclude="name";
proc contents data=mylib.class; run;
proc print data=mylib.class; run;

/* Using CVP with SPDE */
libname mylib cvp 'spde' cvpengine=spde;
proc contents data=mylib.class; run;

/* Convert variables to VARCHAR */
libname mylib cvp 'data' cvpvarchar=yes;
proc contents data=mylib.class; run;
