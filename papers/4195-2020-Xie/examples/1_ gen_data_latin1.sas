/* original data */
libname mylib 'data';
data mylib.class;
	length Name $ 8 Sex $ 1;
	input  Name $ Sex $ Age;
	format Name $8. Age best2.;
	datalines;
André M 14
Valérie F 13
Béatrice F 13
;
run;

/* original data in SPDE */
libname mylib spde 'spde';
data mylib.class;
	length Name $ 8 Sex $ 1;
	input  Name $ Sex $ Age;
	format Name $8. Age best2.;
	datalines;
André M 14
Valérie F 13
Béatrice F 13
;
run;

/* transport file */
filename cportout 'class.xpt';
proc cport data=mylib.class file=cportout; run;

/* Curly qutes */
libname mylib 'data';
data mylib.notice;
	message="We will visit the “National Museum” next Friday"; 
run;
