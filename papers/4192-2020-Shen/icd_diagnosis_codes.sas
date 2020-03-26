/*********************************************************************
XXXX.SAS -- ICD-10 diagnosis codes for medical condition XXXX

This program are including 
1) dataset to input ICD-10 diagnosis codes for medical condition XXXX. 
2) macro variables used in different SAS statements
3) macros to match varied databases and coding methods 

Instructions:
   XXXX is the given name of a medical condition. It also matches the
   title of this program
		Example:
			DZNAME replaces XXXX in this paper 
**********************************************************************/;

/*Input ICD-10 Diagnosis Code*/
Data ICD10;
	length ICDCode $ 6;
	input ICDCode $  lag;
	datalines;

	;
run;

/*Get Macro Variables*/
data ICD10_all; 
	set ICD10;
	retain order;
	order+1;
	length newicd $32;
	if order=1 then do;
		if lag in (1 2) then newicd='&coding'||" =: '"||cats(icdcode)||"'";
		else if lag=0 then newicd='&coding'||" = '"||cats(icdcode)||"'";
	end;
	else do;
		if lag in (1 2) then newicd='or &coding'||" =: '"||cats(icdcode)||"'";
		else if lag=0 then newicd='or &coding'||" = '"||cats(icdcode)||"'";		
	end;
run;

/*Macro variable used for none pass-thru coding in CDW*/
proc sql noprint;
	select newicd
	into :XXXX10 separated by ' ' 
	from work.ICD10_All;
quit;

data ICD10_SQL; 
	set ICD10;
	retain order;
	order+1;
	length newicd $32;
	if order=1 then do;
		if lag in (1 2) then newicd='&coding'||" like '"||cats(icdcode)||"%'";
		else if lag=0 then newicd='&coding'||" = '"||cats(icdcode)||"'";
	end;
	else do;
		if lag in (1 2) then newicd='or &coding'||" like '"||cats(icdcode)||"%'";
		else if lag=0 then newicd='or &coding'||" = '"||cats(icdcode)||"'";		
	end;
run;

/*Macro variable used for explicity pass-thru coding method in CDW*/
proc sql noprint;
	select newicd 
	into :XXXX10_SQL separated by ' ' 
	from work.ICD10_SQL;
quit;

data ICD10_OMOP; 
	set ICD10;
	retain order;
	order+1;
	length newicd $32;
	if order=1 then do;
		if lag in (1 2) then newicd='&coding'||" like 'ICD10|"||cats(icdcode)||"%'";
		else if lag=0 then newicd='&coding'||" = 'ICD10|"||cats(icdcode)||"'";
	end;
	else do;
		if lag in (1 2) then newicd='or &coding'||" like 'ICD10|"||cats(icdcode)||"%'";
		else if lag=0 then newicd='or &coding'||" = 'ICD10|"||cats(icdcode)||"'";		
	end;
run;

/*Macro variable used for OMOP data with explicity pass-thru coding*/ 
proc sql noprint;
	select newicd
	into :XXXX10_OMOP separated by ' '
	from work.ICD10_OMOP;
quit;

data ICD10_CMS; 
	set ICD10;
	retain order;
	order+1;
	length newicd $32;
	if order=1 then do;
		if Lag=1 then newicd='&coding'||"=substr("||cats(compress(icdcode, '.'))||", 1, 3)";
		else if lag=2 then newicd='&coding'||"=substr("||cats(compress(icdcode, '.'))||", 1, 4)";
		else if lag=0 then newicd='&coding'||"= '"||cats(compress(icdcode, '.'))||"'";
	end;
	else do;
		if Lag=1 then newicd='or &coding'||"=substr("||cats(compress(icdcode, '.'))||", 1, 3)";
		else if lag=2 then newicd='&coding'||"=substr("||cats(compress(icdcode, '.'))||", 1, 4)";
		else if lag=0 then newicd='or &coding'||"= '"||cats(compress(icdcode, '.'))||"'";		
	end;
run;

/*Macro variable used for CMS files*/
proc sql noprint;
	select newicd
	into :XXXX10_CMS separated by ' '
	from work.ICD10_CMS;
quit;

proc datasets; 
	delete ICD10 ICD10_All ICD10_SQL ICD10_OMOP ICD10_CMS;
quit;

/*Macro used in SAS statement during data step*/
%macro XXXX_ICD10 (coding=); 
	if &XXXX10 then do;
		&outvar='XXXX'; 
		&outvar._label='Label_Text'; 
	end; 
%mend XXXX_ICD10;

/*Macro used in SAS statement for explicity pass-thru coidng*/
%macro XXXX_ICD10_SQL (coding=); 
	(&XXXX10_SQL)
%mend XXXX_ICD10_SQL;

/*Macro used in SAS statement for OMOP by explicity pass-thru coidng*/
%macro XXXX_ICD10_OMOP (coding=);
	(&XXXX10_OMOP)
%mend XXXX_ICD10_OMOP;

/*Macro used in SAS statement for CMS files*/
%macro XXXX_ICD10_CMS (coding=); 
	if i=1 then do;	
		if &XXXX10_CMS 
			then do;	
				&outvar.='XXXX'; 
				&outvar._label='Label_Text'; 
				&outvar._primary=1; 
				&outvar._code=&coding;
				stop=1; 
			end;
		else stop=0;
	end;

	else do;
		if &XXXX10_CMS 
			then do;	
				&outvar.='XXXX'; 
				&outvar._label='Label_Text'; 
				&outvar._primary=2; 
				&outvar._code=&coding;
				stop=1; 
			end;
		else stop=0;				
	end;
%mend XXXX_ICD10_CMS;
