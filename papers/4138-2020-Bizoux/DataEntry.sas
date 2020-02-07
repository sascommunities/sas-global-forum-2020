/* Define macro variables for the parameters defined in the URL */
%global id maxid answer01 answer02 answer03 answer04 answer05;
/* Define CAS server connection, session and CAS libraries */
options cashost="intcas01.race.sas.com" casport=5570;
cas mySession sessopts=(caslib="casuser");
libname visual cas caslib="visual";
libname casuser cas caslib="casuser";

/* Macro invoked at the beginning of the Job execution */
%macro init;
	%if %symexist(id) and %eval(&id > 0) %then
		%do;

			/* Call record macro to register the answers */
		%record;

			/* Increment question id */
		%let id = %eval(&id + 1 );
		%end;
	%else
		%do;

			/* Code executed when loading the first time */
		%let id = 1;
			
			data casuser.questions; 
				set visual.quiz_programming; 
			run;
			proc cas; 
				table.promote /caslib="casuser" name="questions";
			quit;
		%end;

	/* Define the number of questions */
	proc sql noprint;
		create table maxid as select max(id) as maxid from casuser.questions;
		select maxid into :maxid from maxid;
	quit;

%mend;

/* Macro invoked when last question has been answered */
%macro finish;
	%if %eval(&id > &maxid) %then
		%do;
			/* Generate the data set to be loaded into the Global CASLib used for reporting */
			data casuser.toLoad;
				set casuser.questions (drop= questions choices hint justification);
				userid = "&sysuserid";
				datetime = datetime();
				format datetime datetime16.;
			run;
			/* Load data into the CASLib used for reporting and perform some cleanup activities */
			proc cas;
				table.tableExists result=res/caslib='visual' name='quiz_answers';
				
				if res.exists > 0 then
				do;
					datastep.runcode result=dsResult /code="data visual.quiz_answers (append=yes); set casuser.toLoad; run;";
				end;
				else
				do;
					table.promote / caslib='casuser' name='toLoad' target='quiz_answers' targetlib='visual';
					table.promote / caslib='visual' name='quiz_answers';
				end;
				table.save / caslib='visual' name='quiz_answers' table={caslib='visual' name='quiz_answers'} replace=true;
				table.dropTable / caslib='casuser' name='questions';
				table.deleteSource / caslib='casuser' source='questions';
				table.dropTable / caslib='casuser' name='toLoad';
				table.deleteSource / caslib='casuser' source='toLoad';
			quit;
			/* Terminate the CAS session */
			cas mySession terminate;
		%end;
%mend;

/* Macro invoked to record the answers */
%macro record;
	proc cas;
		questionsTbl.name="questions";

		do i=1 to 5 by 1;
			name_i=put(i, z2.);
			varName='Answer'||name_i;

			if symget(varName) > "" then
				do;
					questionsTbl.where="&id = id and name ='"|| varName ||"'";
					table.update / table=questionsTbl set={{var='selected', value="1"}};
				end;
		end;
	quit;

%mend;

/* Macro generating the json file send to client application */
%macro output; 
	%if %eval(&id > &maxid) %then
		%do;
			data questions; 
				set casuser.questions;			
			run;
			proc sort data=questions out=sortedQuestions;
				by id name;
			run;
			proc json out=_webout nosastags pretty;
				write open object;
					write values "state";
					write open object;
						write values "numberOfQuestions" &maxid;
						write values "summary" true;
					write close;
					write values "data";
					write open array;
	 					export sortedQuestions ;
					write close;
				write close;				
			run; 
			quit;
		%end;
	%else
		%do;
			proc json out=_webout nosastags pretty;
				write open object;
					write values "state";
					write open object;
						write values "numberOfQuestions" &maxid;
						write values "summary" false;
					write close;
					write values "data";
					write open array;
	 					export casuser.questions (where=(ID=&id)) ;
					write close;
				write close;				
			run; 
			quit;
		%end;
%mend;

%init; 
%output;
%finish;
