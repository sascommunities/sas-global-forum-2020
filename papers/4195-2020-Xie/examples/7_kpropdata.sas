libname mylib 'data';

/* Truncated */
proc print data=mylib.notice; run;

/* Covert to stright qutes */
libname mylib 'data' inencoding=asciiany;

data converted;
	set mylib.notice;
	message = kpropdata(message, 'PUNC', 'wlatin1');
run;

proc print data=converted; run;

/* Unprintable characters */
data corrupted;
	length text $ 30;
	text = 'The SAS® System in UTF-8';
	output;
	text = 'The SAS' || 'ae'x || ' System in Latin1';
	output;
run;
proc print data=corrupted; run;

data removed;
	set corrupted;
	text = kpropdata(text, 'TRIM');
run;
proc print data=removed; run;

data fixed;
	set corrupted;
	keep new;
	new = kpropdata(text, 'REMOVE'); /* Remove the data string if any    */
                                 /* unprintable characters are found */
	if new = ' ' then
	   new = kpropdata(text, 'REMOVE', 'latin1'); /* Transcode as Latin1 */
run;
proc print data=fixed; run;
