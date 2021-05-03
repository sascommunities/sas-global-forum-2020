%put sasLogParserMacros.sas version 3.14 03May2021:10:00;
/* Delete the report directory */
%macro deleteFolder(folderToDelete=&sasLogParser.reports);
%if %sysfunc(fileexist(&sasLogParser.reports)) %then %do;
data work.FilesToDelete;
   length Name $ 100;
   keep Name;
   call symput('reports',1);
   rc = filename("folder", "&folderToDelete.");
   
   dirId = dopen("folder");
   do i = 1 to dnum(dirID);
      Name = dread(dirId, i);
      output;
   end;

   rc = dclose(dirId);
run;
data _null_;
   set work.FilesToDelete end=lastDeleted;

/*   put "Deleting " Name;*/

   rc = filename("delfile", cats("&folderToDelete./", Name));
   rc = fdelete("delfile");
/*   put "del file " rc=;*/
   rc = filename("delfile");

   if lastDeleted then do;
/*      put "Deleting the folder '&folderToDelete.'";*/
      rc = filename("folder", "&folderToDelete.");
      rc = fdelete("folder");
/*      put "del folder " rc=;*/
      rc = filename("folder");
   end;
run;
%end;
%else %do;
  %put The directory &sasLogParser.reports does not exist.;   
%end;
%mend;

/* Create the report directory */
%macro mkdir;
  /* Create the reports directory */
  options DLCREATEDIR;
  libname reports "&sasLogParser.reports";
/*  libname reports clear;*/
%mend mkdir;

/* List all files with a given extention to the SAS Log */
%macro list_files(dir,ext);
  %local filrf rc did memcnt i;
  %global name delm;
  %let rc=%sysfunc(filename(filrf,&dir));
  %let did=%sysfunc(dopen(&filrf));      

/* Set the delimiter based on operating system */
  %if (%upcase(%substr(&SYSSCP, 1, 3)) = WIN) %then %do;
     %let delm = \;
  %end;
  %else %do;
     %let delm = /; 
  %end;

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
        %list_files(&dir.&name&delm.,&ext)
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
   length oldline line step $100. product $25. fileName $500.;
   informat realtime time11.2 fileName $500.;
   format realtime cputime totaltime totalcpu time11.2 step $35. fileName $500.;
   retain oldline realtime totaltime;
   infile saslog truncover;
   fileName="&file";
   product="&test"; 
   input line $100. ;
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

proc append base=work.logs data=&test;
run;
%mend saslog;
