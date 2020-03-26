/*In this example, we need to merge a finder file that lacks the linkable indentifer, bene_id, to an intermediate crosswalk of the bene_link_key to bene_id.
/*The finder file is for a single state with a year and month element that indicates for which years and months we want the eligibilty data for each bene*/
data finder_file;
   input bene_link_key $ state $ year month;
   datalines;
a12345 AL 2014 01
b78912 AL 2014 01
c98751 AL 2014 01
c98751 AL 2014 02
d23467 AL 2014 02
;
run;
proc print data=finder_file;run;
/*This is the table that crosswalks between the bene_link_key and the bene_id for all states*/
data bene_key;
   input bene_link_key $ state $ bene_id;
   datalines;
a12345 AL 456
b78912 AL 789
c98751 AL 254
d23467 AL 896
f67753 OH 345
g89754 OH 876
h78427 WY 543
;
run;
proc print data=bene_key;run;
/*this is the eligibility table for 01/2014, which includes data for all states*/
data elig_2014_01;
   input bene_id  state $ eligibility $;
   datalines;
456 AL .
789 AL MDCD
254 AL MDCD
896 AL MDCD
345 OH MDCD
876 OH .
543 WY MDCD
;
run;
proc print data=elig_2014_01;run;
data elig_2014_02;
   input bene_id  state $ eligibility $;
   datalines;
456 AL MDCD
789 AL MDCD
254 AL MDCD
896 AL MDCD
345 OH MDCD
876 OH MDCD
543 WY MDCD
;
run;
proc print data=elig_2014_02;run;
/*Since we will need to repeat these joins for multiple states and years, we can use a macro to reduce typographical errors and spending less time coding*/
%macro join_ff_to_elig(year, month, state);.
/*this macro function creates a table for the input state, year, and month that contains the eligibility data for that state's finder file beneficiaries 
for that year and month using the bene_link_key table to crosswalk between the finder file and the monthly eligibility table*/
	proc sql;
		create table elig_&state._&year._&month. as
		select ff.state, ff.year, ff.month,
			bk.bene_id,
			el.eligibility
		from finder_file ff left join bene_key bk
		on ff.bene_link_key = bk.bene_link_key and ff.state=bk.state
		left join elig_&year._&month. el
		on bk.bene_id=el.bene_id
		where ff.state="&state." and ff.year=&year. and ff.month=&month.;
	
		title "Eligibility data for &state., &month./&year.";
		select * from elig_&state._&year._&month.;
		title;
	quit;
%mend;

%join_ff_to_elig(year=2014,month=01,state=AL);	
%join_ff_to_elig(year=2014,month=02,state=AL);	

/*update this file path to your appropriate CCW directory*/
%let myfilepath = D:\Users\LDurbak\Box Sync\My Box Notes\My stuff\Blog;
data _null_;
	file "&myfilepath./auto_ff_to_elig_AL_2014_01.sas";
run;

%let state=AL;
%let year=2014;
%let month=01;
data _null_;
	file "&myfilepath./auto_ff_to_elig_AL_2014_01.sas";
	put 'proc sql; ';
	put @4 'create table '"elig_&state._&year._&month." 'as ';
	put @4 'select ff.state, ff.year, ff.month, ';
	put @8 'bk.bene_id,';
	put @8 'el.eligibility';
	put @4 'from finder_file ff left join bene_key bk ';
	put @4 'on ff.bene_link_key = bk.bene_link_key and ff.state=bk.state ';
	put @4 'left join elig_&year._&month. el ';
	put @4 'on bk.bene_id=el.bene_id ';
	put @4 'where ff.state= "'"&state."'" and  ';
	put @8 'ff.year='"&year."'and ';
	put @8 'ff.month='"&month."';';
	put @12 '';
	put @4 'title "Eligibility data for '"&state."', '"&month."'/'"&year."'"; ';
	put @4 'select * from '"elig_&state._&year._&month."'; ';
	put @4 'title; ';
	put 'quit; ';
run;

%let state=AL;
%macro loop_years_months;
%do loop_yr = 2014 %to 2018;
	%let year=&loop_yr.;
	%do loop_mnth=1 %to 12;
	%let month=%sysfunc(putn(&loop_mnth.,z2.)); /*code within %sysfunc() maintains leading zeros in single-digit months*/
	data _null_;
		file "&myfilepath./auto_ff_to_elig_&state._&year._&month..sas";
		put 'proc sql; ';
		put @4 'create table '"elig_&state._&year._&month." 'as ';
		put @4 'select ff.state, ff.year, ff.month, ';
		put @8 'bk.bene_id,';
		put @8 'el.eligibility';
		put @4 'from finder_file ff left join bene_key bk ';
		put @4 'on ff.bene_link_key = bk.bene_link_key and ff.state=bk.state ';
		put @4 'left join elig_&year._&month. el ';
		put @4 'on bk.bene_id=el.bene_id ';
		put @4 'where ff.state= "'"&state."'" and  ';
		put @8 'ff.year='"&year."'and ';
		put @8 'ff.month='"&month."';';
		put @12 '';
		put @4 'title "Eligibility data for '"&state."', '"&month."'/'"&year."'"; ';
		put @4 'select * from '"elig_&state._&year._&month."'; ';
		put @4 'title; ';
		put 'quit; ';
	run;
	%end;
%end;
%mend;

%loop_years_months;

