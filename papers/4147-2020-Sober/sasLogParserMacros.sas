/* List all files with a given extention to the SAS Log */
%macro list_files(dir,ext);
  %local filrf rc did memcnt name i;
  %let rc=%sysfunc(filename(filrf,&dir));
  %let did=%sysfunc(dopen(&filrf));      

   %if &did eq 0 %then %do; 
    %put Directory &dir cannot be open or does not exist;
    %return;
  %end;

   %do i = 1 %to %sysfunc(dnum(&did));   

   %let name=%qsysfunc(dread(&did,&i));

      %if %qupcase(%qscan(&name,-1,.)) = %upcase(&ext) %then %do;
        %put &dir.&name;
      %end;
      %else %if %qscan(&name,2,.) = %then %do;        
        %list_files(&dir.&name,&ext)
      %end;

   %end;
   %let rc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(filrf));     

%mend list_files;

/* Check the existance of a file and delete it if it exists */
%macro check(file);
%if %sysfunc(fileexist(&file)) ge 1 %then %do;
   %let rc=%sysfunc(filename(temp,&file));
   %let rc=%sysfunc(fdelete(&temp));
%end; 
   %else %put The file &file does not exist;
%mend check; 

/* ***************************************************** */
* MACRO SASLOG v8_________________________________________
* FILE
*       Type: String
*      Group: General
*      Label: path to sas log that is being parsed 
*       Attr:  Modifiable, Required
* _________________________________________________________
* 
* TEST
*       Type: String
*      Group: General
*      Label: Used in TITLE2 statement of PROC PRINT
*             Used as the name of the sas data set 
*             Used as the input to the sas variable PRODUCT
*       Attr:  Modifiable, Required
* _________________________________________________________;

%macro saslog(file=C:\temp\saslog1.log,test=test_sas);
filename saslog "&file";
data &test;
   length oldline line step $80. product $25. fileName $100.;
   informat realtime time11.2 fileName $100.;
   format realtime cputime totaltime totalcpu time11.2 step $35. fileName $100.;
   retain oldline realtime totaltime;
   infile saslog truncover;
   fileName="&file";
   product="&test"; 
   input line $80. ;
   arg1=scan(line,1);
   arg2=scan(line,2);
   If arg1 = 'real' then do;
      step = oldline;
      x=find(step,'(');
      if x gt 0 then
      step=substr(step,1,x-1);
	  time=scan(line,3,' ');
	  if length(time) =< 5 then
	     realtime=hms(0,0,time); 
	  else if length(time) > 5 and length(time) <=7 then do
	     time='00:0' || time;
	     realtime=input(time,time11.2);
	  end;
	  else if length(time) = 8 then do
	     time='00:' || time;
	     realtime=input(time,time11.2);
	  end;
	  else
	     realtime=input(time,time11.2);
	  if Step eq "NOTE: The SAS System used:" then do;
	     Totaltime=realtime;
		 realtime=.;
	  end;
	  else 
	     totaltime=.;
   end;
   If arg1 = 'cpu'  then do;
     * step = 'cpu time';
      step=oldline;
      x=find(step,'(');
      if x gt 0 then
      step=substr(step,1,x-1);
	  time=scan(line,3,' ');
	  if length(time) =< 5 then
	     cputime=hms(0,0,time); 
	  else if length(time) > 5 and length(time) <=7 then do
	     time='00:0' || time;
	     cputime=input(time,time11.2);
	  end;
	  else if length(time) = 8 then do
	     time='00:' || time;
	     cputime=input(time,time11.2);
	  end;
	  else
	     cputime=input(time,time11.2);
	  if Step eq "NOTE: The SAS System used:" then do;
	     Totalcpu=cputime;
		 cputime=.;
	  end;
	  else 
	     totalcpu=.;
	  output;
   end;
   else If arg1 = 'user' and arg2 = 'cpu'  then do;
     * step = 'cpu time';
      step=oldline;
      x=find(step,'(');
      if x gt 0 then
      step=substr(step,1,x-1);	  
	  time=scan(line,4,' ');
	  if length(time) =< 5 then
	     cputime=hms(0,0,time); 
	  else if length(time) > 5 and length(time) <=7 then do
	     time='00:0' || time;
	     cputime=input(time,time11.2);
	  end;
	  else if length(time) = 8 then do
	     time='00:' || time;
	     cputime=input(time,time11.2);
	  end;
	  else
	     cputime=input(time,time11.2);
	  if Step eq "NOTE: The SAS System used:" then do;
	     Totalcpu=cputime;
		 cputime=.;
	  end;
	  else 
	     totalcpu=.;
	  output;
   end;
   if substr(line,1,5) eq 'NOTE:' then oldline=line;
   keep product step realtime cputime totaltime totalcpu fileName;
   Label product=Product
         step=Step
		 realtime=Real Time
		 cputime=CPU Time
		 totaltime=Total Time
		 totalcpu= Total CPU Time
		 filename=File Name;

run;
title "&file";
title2 "&test";
proc print label; 
   var step realtime cputime totaltime totalcpu ;
   sum realtime cputime totaltime totalcpu;
run;
proc append base=work.logs data=&test;
run;
%mend saslog;
