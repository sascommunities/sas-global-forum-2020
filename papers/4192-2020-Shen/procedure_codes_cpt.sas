/*********************************************************************
XXXX.SAS -- CPT codes for surgical procedure XXXX

This program are including 
1) dataset to input CPT codes for surgical procedure XXXX. 
2) macro variables used in different SAS statements
3) macros to match varied databases and coding methods 

Instructions:
   XXXX is the given name of a medical condition. It also matches the
   title of this program
		Example:
			PROCNAME1 replaces XXXX in this paper 
**********************************************************************/;

/*Input CPT Code*/
Data CPT;
	length CPT_Code $ 6;
	input CPT_Code $  lag;
	datalines;

	;
run;

/*Get Macro Variables*/
data CPT_all;
	set CPT;
	retain order;
	order+1;
	length NewCPT $32;
	if order=1 then do;
		if Lag in (1 2) then NewCPT='&coding'||"=substr("||cats(CPT_Code)||", 1, 3)";
		else if lag=0 then NewCPT='&coding'||" = '"||cats(CPT_Code)||"'";
	end;
	else do;
		if Lag in (1 2) then NewCPT='&coding'||"=substr("||cats(CPT_Code)||", 1, 3)";
		else if lag=0 then NewCPT='or &coding'||" = '"||cats(CPT_Code)||"'";		
	end;
run;

/*Macro variable used for none pass-thru coding in CDW*/
proc sql noprint;
	select NewCPT
	into :XXXX_CPT separated by ' '
	from work.CPT_All;
quit;

data CPT_SQL;
	set CPT;
	retain order;
	order+1;
	length NewCPT $32;
	if order=1 then do;
		if Lag in (1 2) then NewCPT='&coding'||" like '"||cats(CPT_Code)||"%'";
		else if lag=0 then NewCPT='&coding'||" = '"||cats(CPT_Code)||"'";
	end;
	else do;
		if Lag in (1 2) then NewCPT='or &coding'||" like '"||cats(CPT_Code)||"%'";
		else if lag=0 then NewCPT='or &coding'||" = '"||cats(CPT_Code)||"'";		
	end;
run;

/*Macro variable used for explicity pass-thru coding method in CDW*/
proc sql noprint;
	select NewCPT
	into :XXXX_CPT_SQL separated by ' '
	from work.CPT_SQL;
quit;

data CPT_OMOP;
	set CPT;
	retain order;
	order+1;
	length NewCPT $32;
	if order=1 then do;
		if Lag in (1 2) then NewCPT='&coding'||" like 'CPT|"||cats(CPT_Code)||"%'";
		else if lag=0 then NewCPT='&coding'||" = 'CPT|"||cats(CPT_Code)||"'";
	end;
	else do;
		if Lag in (1 2) then NewCPT='or &coding'||" like 'CPT|"||cats(CPT_Code)||"%'";
		else if lag=0 then NewCPT='or &coding'||" = 'CPT|"||cats(CPT_Code)||"'";		
	end;
run;

/*Macro variable used for OMOP data with explicity pass-thru coding*/ 
proc sql noprint;
	select NewCPT
	into :XXXX_CPT_OMOP separated by ' '
	from work.CPT_OMOP;
quit;

data CPT_CMS;
	set CPT;
	retain order;
	order+1;
	length NewCPT $32;
	if order=1 then do;
		if Lag=1 then NewCPT='&coding'||"=substr("||cats(CPT_Code)||", 1, 3)";
		else if Lag=2 then NewCPT='&coding'||"=substr("||cats(CPT_Code)||", 1, 4)";
		else if lag=0 then NewCPT='&coding'||" = '"||cats(CPT_Code)||"'";
	end;
	else do;
		if Lag=1 then NewCPT='&coding'||"=substr("||cats(CPT_Code)||", 1, 3)";
		else if Lag=2 then NewCPT='&coding'||"=substr("||cats(CPT_Code)||", 1, 4)";
		else if lag=0 then NewCPT='or &coding'||" = '"||cats(CPT_Code)||"'";		
	end;
run;

/*Macro variable used for CMS files*/
proc sql noprint;
	select NewCPT
	into :XXXX_CPT_CMS separated by ' '
	from work.CPT_CMS;
quit;

proc datasets; 
	delete CPT CPT_All CPT_SQL CPT_OMOP CPT_CMS;
quit;

/*Macro used in SAS statement during data step*/
%macro XXXX_CPT (coding=);
	if &XXXX_CPT then do;
		&outvar='XXXX'; 
		&outvar._label='Text_XXX'; 
	end;
%mend XXXX_CPT;

/*Macro used in SAS statement for explicity pass-thru coidng*/
%macro XXXX_CPT_SQL (coding=);
	(&XXXX_CPT_SQL) 
%mend XXXX_CPT_SQL;

/*Macro used in SAS statement for OMOP by explicity pass-thru coidng*/
%macro XXXX_CPT_OMOP (coding=);
	(&XXXX_CPT_OMOP) 
%mend XXXX_CPT_OMOP;

/*Macro used in SAS statement for CMS files*/
%macro XXXX_CPT_CMS (coding=); 
	if i=1 then do;	
		if &XXXX_CPT_CMS 
			then do;	
				&outvar.='XXXX'; 
				&outvar._label='Text_XXX'; 
				&outvar._primary=1; 
				&outvar._code=&coding;
				stop=1; 
			end;
		else stop=0;
	end;

	else do;
		if &XXXX_CPT_CMS 
			then do;	
				&outvar.='XXXX'; 
				&outvar._label='Text_XXX'; 
				&outvar._primary=2; 
				&outvar._code=&coding;
				stop=1; 
			end;
		else stop=0;				
	end;
%mend XXXX_CPT_CMS;
