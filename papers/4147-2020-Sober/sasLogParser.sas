/* Macro variable for the path to sas log parser directory */
/* Note: Ensure the path ends with the delimiter \ for Windows or / for Linux */
%let sasLogParser=C:\path\to\sasLogParser\;

/* Macro varialbe for the path containing the SAS Logs */
/* Note: Ensure the path ends with the delimiter \ for Windows or / for Linux */
%let path2files=C:\path\to\sasLogParser\logs\; 

%include "&sasLogParser.sasLogParserMacros.sas";

%check(&sasLogParser.logfiles.txt);
options LINESIZE=250; 
proc printto log="&sasLogParser.logfiles.txt";
run;
%list_files(&path2files.,log);
proc printto;
run;

%check(&sasLogParser.includeCode.sas);
 
%deleteFolder(folderToDelete=&sasLogParser.reports);

%mkdir;

data _null_;
   length line pdfLine statement1 statement2 sasLogStatement odsStatement name reportPath $500.;
   infile "&sasLogParser.logfiles.txt" truncover;
   file "&sasLogParser.includeCode.sas" ; 
   input line $500.;

   if line =: "&path2files.";
 
   findLog=length(trim(line));
   pathLength=length(line);
   do i = 1 to pathLength;
      if substr(line,i,1) = "&delm." then
	     lastDelm=i+1;
   end;
   name = substr(line,lastDelm,pathLength);
   nameLength=length(trim(name));
   n=nameLength-2;
   substr(name,n,5)='pdf";';

   odsStatement1="ods pdf file=";
   odsStatement2="&sasLogParser.reports&delm." || name;
   odsStatement=odsStatement1 || '"' || odsStatement2; 
   
   letStatement="%" || "let log1=";
   sasLogStatement="%" || "saslog(file=" || "&" || "log1,test=" || "&" || "test1);";
   statement1=odsStatement;
   statement2=letStatement || trim(line) || ';';
   pdsClose='ods pdf close;';

   put odsStatement;
   put statement2;
   put sasLogStatement;
   put pdsClose;
run;

proc delete data=work.logs;
run;

%let test1=SAS9Log;

ods noresults;
%include "&sasLogParser.includeCode.sas";

ods pdf file="&sasLogParser.reports&delm.1.descendingRealTime.pdf"; 

proc sort data=work.logs;
   by descending realtime;
run;

proc print data=work.logs label;
   title "Descending Clock Time";
   var step realtime cputime totaltime totalcpu fileName;
run;
ods pdf close;

ods excel file="&sasLogParser.reports&delm.1.descendingRealTime.xlsx" ;
proc print data=work.logs label;
   title "Descending Clock Time";
   var step realtime cputime totaltime totalcpu fileName;
run;
ods excel close;

data seconds;
   length proc $40.;
   set logs;
   realTimeSeconds = second(realtime);
   realTimeMinutes = minute(realtime);
   realTimeHours = hour(realtime);
   realTimeTotalSeconds = realTimeSeconds + (realTimeMinutes * 60) + (realTimeHours * 3600);
   cpuTimeSeconds = second(cputime);
   cpuTimeMinutes = minute(cputime);
   cpuTimeHours = hour(cputime);
   cpuTimeTotalSeconds = cpuTimeSeconds + (cpuTimeMinutes * 60) + (cpuTimeHours * 3600);
   totalTimeSeconds = second(totalTime);
   totalTimeMinutes = minute(totalTime);
   totalTimeHours = hour(totalTime);
   totalTimeTotalSeconds = totalTimeSeconds + (totalTimeMinutes * 60) + (totalTimeHours * 3600);
   totalCPUSeconds = second(totalcpu);
   totalCPUMinutes = minute(totalcpu);
   totalCPUHours = hour(totalcpu);
   totalCPUtotalSeconds = totalCPUseconds + (totalCPUminutes * 60) + (totalCPUhours * 3600);
   proc = scan(step,3);
   if proc = 'initialization' then proc = ' ';
      else if proc = 'statement' then proc = 'DATA statement';
	  else proc = 'PROC ' || proc;
run;

ods excel file="&sasLogParser.reports&delm.4.totalseconds.xlsx" ;
proc print data=seconds;
   var step realtime cputime  totaltime totalcpu fileName  
	   realTimeTotalSeconds realTimeHours realTimeMinutes realTimeSeconds
       cpuTimeTotalSeconds cpuTimeHours cpuTimeMinutes cpuTimeSeconds
       totalTimeTotalSeconds totalTimeHours totalTimeMinutes totalTimeSeconds
       totalCPUtotalSeconds totalCPUhours totalCPUminutes totalCPUseconds
	   proc
   ;
run;
ods excel close;

ods pdf file="&sasLogParser.reports&delm.2.descendingCPUTime.pdf"; 

proc sort data=work.logs;
   by descending cputime;
run;

proc print data=work.logs Label;
   title "Descending CPU Time";
   var step realtime cputime totaltime totalcpu fileName;
run;
ods pdf close;

ods excel file="&sasLogParser.reports&delm.2.descendingCPUTime.xlsx" ;
proc print data=work.logs Label;
   title "Descending CPU Time";
   var step realtime cputime totaltime totalcpu fileName;
run;
ods excel close;

ods pdf file="&sasLogParser.reports&delm.3.StepsFrequency.pdf"; 
proc freq data=work.logs;
   title "Steps";
   table step;
run;
ods pdf close;

ods excel file="&sasLogParser.reports&delm.3.StepsFrequency.xlsx"; 
proc freq data=work.logs;
   title "Steps";
   table step;
run;
ods excel close;
