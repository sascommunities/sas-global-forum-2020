/** First parameter is the data set that contains all of the variables.  **/
/** Second parameter is the number of loops.              **/
/** Third parameter is the new data set that contains the new variables. **/                  
                                                                                                                                        
libname mypaper '/folders/myfolders/Long to Wide Paper';

/* dataset mypaper.sampledata */

data ay1 ay2 ay3 ay4;
set mypaper.sampledata;
if semester = 'Fall 2014' then do;
	prefit = 1;
	output ay1;
end;
else if semester = 'Fall 2015' then do;
	prefit = 2;
	output ay2;
end;
else if semester = 'Fall 2016' then do;
	prefit = 3;
	output ay3;
end;
else do;
	prefit = 4;
	output ay4;
end;
run;

%macro vars(dsn,num,out);                                                                                                               
   %do j = 1 %to &num;
   %let dsid=%sysfunc(open(&dsn&j));                                                                                                        
   %let n=%sysfunc(attrn(&dsid,nvars)); 
   %let pref = semester&j._; 
	   data &out&j;
	      set &dsn&j(rename=(                                                                                                                    
	      %do i = 1 %to &n;                                                                                                                 
	         %let var=%sysfunc(varname(&dsid,&i));
			 &var=&pref&var   
	      %end;));  
 	      %let rc=%sysfunc(close(&dsid)); 
		where &pref.prefit = &j; 
		drop &pref.prefit &pref.semester ;
		rename &pref.college = college;	
	 run;

	 proc sort data = &out&j;
	 by college;
	 run;

	%end; 
%mend vars;                                                                                                                             
                                                                                                                                        
%vars(ay,4,aynew);

data newcolleges;
merge aynew: ;
by college;
run;

/* proc transpose comparison */
proc sort data=mypaper.sampledata out=ay_sort;
by college ;
run;

proc transpose data=ay_sort out=ay_transposed prefix = male_;
id semester;
by college;
var male ;*female Both_Parents_College First_Generation No_FAFSA One_Parent_College;
where semester = 'Fall 2014';
run;


/* second version if gender as a row split out into additional datasets */
/* sample data not configured for this macro */


%macro vars2(dsn,num,typ,out);                                                                                                               
   %do j = 1 %to &num;
   %let dsid=%sysfunc(open(&dsn&j));                                                                                                        
   %let n=%sysfunc(attrn(&dsid,nvars)); 
   %let pref = semester&j._&typ._; 
	   data &out&j;
	      set &dsn&j(rename=(                                                                                                                    
	      %do i = 1 %to &n;                                                                                                                 
	         %let var=%sysfunc(varname(&dsid,&i));
			 &var=&pref&var   
	      %end;));  
 	      %let rc=%sysfunc(close(&dsid)); 
		where &pref.prefit = &j; 
		drop &pref.prefit &pref.semester ;
		rename &pref.college = college;		
	 run;

	 proc sort data = &out&j;
	 by college;
	 run;

	%end; 
%mend vars2;                 
 

%vars2(ay_v2m,4,male,ay_v3m);

%vars2(ay_v2f,4,female,ay_v3f);
