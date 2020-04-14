%cassetup();

/* expand it using different options */
libname mylib 'data';
libname sys cas;
libname lib cas NCHARMULTIPLIER=1.5;

data sys.class_sys;
	set mylib.class;
run;

data lib.class_lib;
	set mylib.class;
run;

data lib.class_ds(NCHARMULTIPLIER=2);
	set mylib.class;
run;

proc contents data=lib.class_lib; run;
proc contents data=lib.class_ds; run;
