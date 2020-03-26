/*********************************************************************************************
Longitudinal_Data_Macro.sas -- macro to assemble individual dataset to
one longitudinal data structure

Instructions:
   The macro arguments are as follows, where "?" indicates a
   required argument:

	? inputdata = all input datasets extracted from database
	? dizname_all = names of all included medical conditions and procedures.
	? dizname_ICD10 = names of all included medical conditions, 
					  use XXX instead none. 
	? dizname_PRO10 = names of all included procedures if have ICD procedure code,
					  use XXX instead none. 
	? dizname_CPT = names of all included procedures if have CPT code,
					  use XXX instead none. 
	? dizname_STOP = names of all included procedures if have VA Stop code,
					  use XXX instead none. 
	? coding = original variable name in extracted datasets.
	? outvar = variable name is going to used in longitudinal dataset.

		Example:
			%Let inputdata=Outpatients Inpatients Procedures;
			%let dizname_all=DZNAME DZNAME1 DZNAME2 PROCNAME1 PROCNAME2 PROCNAME3;
			%let dizname_ICD10=DZNAME DZNAME1 DZNAME2;
			%let dizname_PRO10=PROCNAME1 PROCNAME2;
			%let dizname_CPT=PROCNAME1 PROCNAME2 PROCNAME3;
			%let dizname_STOP=XXX;
			%let coding=ICDCode;
			%let outvar=Comorbidities;
**********************************************************************************************/;
%macro getdataset;
	data _null_;
			array _ndata &inputdata;
			call symput('n_data', left(put(dim(_ndata), 2.0)));
	run;

	data indata;
		set 
		%do h=1 %to &n_data;
			%let orgdata= %scan(&inputdata, &h); 
			&orgdata
		%end;
		;
	run;
%mend getdataset;

%macro Longdata_cdw;
	data _null_;
			array _xvars &dizname_all;
			call symput('n_all', left(put(dim(_xvars), 2.0)));
			array _cvars &dizname_ICD10;
			call symput('n_icd10', left(put(dim(_cvars), 2.0)));
			array _dvars &dizname_ICD9;
			call symput('n_icd9', left(put(dim(_dvars), 2.0)));
			array _evars &dizname_PRO10;
			call symput('n_pro10', left(put(dim(_evars), 2.0)));
			array _fvars &dizname_PRO9;
			call symput('n_pro9', left(put(dim(_fvars), 2.0)));
			array _gvars &dizname_CPT;
			call symput('n_cpt', left(put(dim(_gvars), 2.0)));
			array _hvars &dizname_stop;
			call symput('n_stop', left(put(dim(_hvars), 2.0)));
	run;

	%put number &n_all &n_icd10 &n_icd9 &n_pro10 &n_pro9 &n_cpt &n_data;

	%do m=1 %to &n_all; 
		%let xi= %scan(&dizname_all, &m); 
		%let xi_text=%lowcase(&xi);
		%put name &xi;
		/*setup default setting*/
		%let icd10=no;
		%let icd9=no;
		%let procedure9=no;
		%let procedure10=no;
		%let cpt=no;
		%let stopcode=no;

		/*identify icd10 diagnosise code*/;
		%do c = 1 %to &n_icd10;
			%if %lowcase(&xi) = %lowcase(%scan(&dizname_ICD10, &c)) %then %do;
				%let icd10 = yes;
				%end;
		%end;
		%put ICD10=&icd10;

		/*identify icd9 diagnosise code*/;
		%do d = 1 %to &n_icd9;
			%if %lowcase(&xi) = %lowcase(%scan(&dizname_ICD9, &d)) %then %do;
				%let icd9 = yes;
				%end;
		%end;
		%put ICD9=&icd9;


		/*identify icd10 procedure code*/;
		%do e = 1 %to &n_pro10;
			%if %lowcase(&xi) = %lowcase(%scan(&dizname_pro10, &e)) %then %do;
				%let procedure10 = yes;
				%end;
		%end;
		%put ICD_Procedure10=&procedure10;

		/*identify icd9 procedure code*/;
		%do f = 1 %to &n_pro9;
			%if %lowcase(&xi) = %lowcase(%scan(&dizname_pro9, &f)) %then %do;
				%let procedure9 = yes;
				%end;
		%end;
		%put ICD_Procedure9=&procedure9;

		/*identify CPT/HCPCS code*/;
		%do g = 1 %to &n_cpt;
			%if %lowcase(&xi) = %lowcase(%scan(&dizname_cpt, &g)) %then %do;
				%let cpt = yes;
				%end;
		%end;
		%put CPT=&cpt;

		/*identify stop code*/;
		%do h = 1 %to &n_stop;
			%if %lowcase(&xi) = %lowcase(%scan(&dizname_stop, &h)) %then %do;
				%let stopcode = yes;
				%end;
		%end;
		%put STOPCODE=&stopcode;

	/*setup null dataset*/
		data &xi._temp; set _null_; run;

		%if &icd10=yes %then %do;
			data &xi._icd10;
				set indata;
				length &outvar $32 &outvar._label $50;
				%&xi._icd10(coding=&coding);
				keep subjectid dates &coding &outvar &outvar._label;
			run;

			data &xi._temp;
				set &xi._temp
					&xi._icd10 (where=(lowcase(&outvar)="&xi_text"))
					;
			run;		
		%end;

		%if &icd9=yes %then %do;
			data &xi._icd9;
				set indata;
				length &outvar $32 &outvar._label $50;
				%&xi._icd9(coding=&coding);
				keep subjectid dates &coding &outvar &outvar._label;
			run;

			data &xi._temp;
				set &xi._temp
					&xi._icd9 (where=(lowcase(&outvar)="&xi_text"))
					;
			run;
		%end;

		%if &procedure10=yes %then %do;
			data &xi._pro10;
				set indata;
				length &outvar $32 &outvar._label $50;
				%&xi._procedure10(coding=&coding);
				keep subjectid dates &coding &outvar &outvar._label;
			run;

			data &xi._temp;
				set &xi._temp
					&xi._pro10 (where=(lowcase(&outvar)="&xi_text"))
					;
			run;	
		%end;

		%if &procedure9=yes %then %do;
			data &xi._pro9;
				set indata;
				length &outvar $32 &outvar._label $50;
				%&xi._procedure9(coding=&coding);
				keep subjectid dates &coding &outvar &outvar._label;
			run;

			data &xi._temp;
				set &xi._temp
					&xi._pro9 (where=(lowcase(&outvar)="&xi_text"))
					;
			run;	
		%end;

		%if &cpt=yes %then %do;
			data &xi._cpt;
				set indata;
				length &outvar $32 &outvar._label $50;
				%&xi._cpt(coding=&coding);
				keep subjectid dates &coding &outvar &outvar._label;
			run;

			data &xi._temp;
				set &xi._temp
					&xi._cpt (where=(lowcase(&outvar)="&xi_text"))
					;
			run;	
		%end;

		%if &stopcode=yes %then %do;
			data &xi._stop;
				set indata;
				length &outvar $32 &outvar._label $50;
				%&xi._stop(coding=&coding);
				keep subjectid dates &coding &outvar &outvar._label;
			run;

			data &xi._temp;
				set &xi._temp
					&xi._stop (where=(lowcase(&outvar)="&xi_text"))
					;
			run;	
		%end;

		proc sort data=&xi._temp nodupkey; by subjectid dates &coding; run;

		data report;
			set report
				&xi._temp
				;
		run;

		proc datasets; delete &xi._icd10 &xi._icd9 &xi._pro10 &xi._pro9 &xi._cpt &xi._stop
								&xi._temp; quit;
	%end;
%mend Longdata_CDW;
