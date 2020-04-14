/* Get the encoding of the data set */
libname mylib 'data';
%let dsid=%SYSFUNC(open(mylib.class));
%let dsenc=%KSCAN(%SYSFUNC(attrc(&dsid,ENCODING)), 1, " ");
%let rc=% SYSFUNC(close(&dsid));

/* Get the session encoding */
%let sessenc=%SYSFUNC(getOption(ENCODING));

/*Check the compatibbility */
%let isCompat=%SYSFUNC(encodCompat(&dsenc, &sessenc));
%put &isCompat; /* 1: compatible; 0: incompatible */
