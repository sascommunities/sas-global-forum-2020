/***************************************************************************************
Observation_Data_Macro.sas -- macro to convert longitudinal data structure to 
analytical dataset (one observation one subject)

Instructions:
   The macro arguments are as follows, where "?" indicates a
   required argument:

	? outvar = variable name used in longitudinal dataset.
	? in_out = output dataset.
	? casenum = number of enconter.
	? varname = names of all included medical conditions and procedures. 
		Example:
			%let outvar=Comorbidities;
			%let in_out=Obs_data;
			%let casenum=1;
			%let varname=DZNAME DZNAME1 DZNAME2 PROCNAME1 PROCNAME2 PROCNAME3;
******************************************************************************************/;
%macro Obs_CDW (Indata=);
	data _null_;
		array _xvars &varname;
		call symput('n_names', left(put(dim(_xvars), 2.0)));
	run;
	%put &n_names;

	%do m = 1 %to &n_names;
		%let xi = %scan(&varname, &m);
		%let xi_text=%lowcase(&xi);
		%put working on predictor variable &m &xi &xi_text;

		data &xi._temp;
			set &indata
				  ;
			by subjectid;
			where lowcase(&outvar)="&xi_text";
			&xi.=1;
			call symput("labelname", &outvar._label);
			proc sort nodupkey; by subjectid dates; 
		run;

		data &xi._nodup;
			set &xi._temp
				  ;
			by subjectid;
			if first.subjectid;
			keep subjectid &xi;
		run;

		data &xi._first;
			set &xi._temp;
			by subjectid dates; 
			if first.subjectid=1;
			rename dates=fstdates_&xi;
			keep subjectid dates;
		run; 

		data &xi._last;
			set &xi._temp ;
			by subjectid; 
			keep subjectid dates count;
			rename dates=lastdates_&xi;
			if first.subjectid then count=0;
				count+1;
			if last.subjectid then output;
		run; 

		data &xi._&in_out;
			merge &xi._nodup &xi._first &xi._last(in=inlast where=(count>=&casenum));
			by subjectid;
			if inlast;
			drop count;
			label &xi="&labelname";
		run;
			
		proc datasets; delete &xi._temp &xi._nodup &xi._first &xi._last; quit;

	%end; 
%mend Obs_CDW;

%macro obs_data;
	data _null_;
		array _xvars &varname;
		call symput('n_names', left(put(dim(_xvars), 2.0)));
		array _svars &datasets;
		call symput('n_sets', left(put(dim(_svars), 2.0)));
	run;
	%put &n_names;

	%do m = 1 %to &n_names;
		%let xi = %scan(&varname, &m);
		%put working on predictor variable &m &xi;

			data &xi._all;
				set 
				%do h=1 %to &n_sets;
					%let inputset= %scan(&datasets, &h); 
					&xi._&inputset
				%end;
				;
				where &xi=1;
				proc sort nodupkey; by subjectid fstdates_&xi;
				proc sort nodupkey; by subjectid;
			run;

			data report;
				merge report 
					  &xi._all
					  ;
				by subjectid;
			run;


		proc datasets; delete &xi._all; quit;
	%end; 
%mend obs_data;
