/* sasLogParser.sas version 3.14 03May2021:10:00 */
/* Macro variable for the path to sas log parser directory */
/* Note: Ensure the path ends with the delimiter \ for Windows or / for Linux */
%let sasLogParser=C:\path\to\utility\;

/* Macro varialbe for the path containing the SAS Logs */
/* Note: Ensure the path ends with the delimiter \ for Windows or / for Linux */
%let path2files=C:\path\to\logs\; 

/* options mprint source2; */

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

/*   odsStatement1="ods pdf file=";*/
/*   odsStatement2="&sasLogParser.reports&delm." || name;*/
/*   odsStatement=odsStatement1 || '"' || odsStatement2; */
   
   letStatement="%" || "let log1=";
   sasLogStatement="%" || "saslog(file=" || "&" || "log1,test=" || "&" || "test1);";
/*   statement1=odsStatement;*/
   statement2=letStatement || trim(line) || ';';
/*   pdsClose='ods pdf close;';*/

/*   put odsStatement;*/
   put statement2;
   put sasLogStatement;
/*   put pdsClose;*/
run;

proc delete data=work.logs;
run;

%let test1=SAS9Log;

ods noresults;
%include "&sasLogParser.includeCode.sas";

/* Start: create descendingRealTime.xlsx and stepFrequency.xlsx reports */ 
proc sort data=work.logs;
   by descending realtime;
run;

data reports.logs (compress=char);
   set work.logs;
run;

/*ods pdf file="&sasLogParser.reports&delm.descendingRealTime.pdf"; */
/*proc print data=work.logs label;*/
/*   title "Descending Clock Time";*/
/*   var step realtime cputime totaltime totalcpu fileName;*/
/*run;*/
/*ods pdf close;*/

ods excel file="&sasLogParser.reports&delm.descendingRealTime.xlsx" ;
proc print data=work.logs Label;
   title "Descending Real Time";
   var step realtime cputime totaltime totalcpu fileName;
run;
ods excel close;

ods excel file="&sasLogParser.reports&delm.stepsFrequency.xlsx"; 
proc freq data=work.logs;
   title "Steps";
   table step;
run;
ods excel close;
/* Stop: create descendingRealTime.xlsx and stepFrequency.xlsx reports */
