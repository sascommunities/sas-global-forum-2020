/* 1. Check the information of the SAS data set */
libname euclib "/home/sasdemo/demoscript/data";
proc contents data=euclib.carsinfo;
run;
proc print data=euclib.carsinfo (obs=10);
run;

/* 2. Expand the space of character variables with CVP engine */
libname euclib2 CVP "/home/sasdemo/demoscript/data";
proc contents data=euclib2.carsinfo;
run;
proc print data=euclib2.carsinfo (obs=10);
run;

/* 3. Save the SAS data set to SAS Viya with UTF-8 encoding using CVP engine libname */
libname u8lib "/home/sasdemo/demoscript/u8_data";
data u8lib.carsinfo;
	set euclib2.carsinfo;
run;
proc contents data=u8lib.carsinfo;
run;
proc print data=u8lib.carsinfo (obs=10);
run;

/* 4. Migrate format catalogs to SAS Viya */
proc format cntlin=euclib2.cnformat lib=u8lib;
run;
option fmtsearch=(u8lib);
proc print data=u8lib.carsinfo (obs=10);
run;

/* 5. Migrate index to SAS Viya */
proc datasets lib=u8lib nolist;
	modify carsinfo;
	Index create Make / Updatecentiles=5;
quit;
proc contents data = u8lib.carsinfo;
run;

/* 6. Reset the environment */
option fmtsearch=(work library);
libname u8lib "/home/sasdemo/demoscript/u8_data";
proc datasets lib = u8lib nolist kill;
quit;
libname euclib clear;
libname euclib2 clear;
libname u8lib clear;