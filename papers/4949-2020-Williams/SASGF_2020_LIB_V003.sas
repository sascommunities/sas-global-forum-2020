



/*
SAS Global Forum
Library References performing data access as well as some helper functions. Used primarily to illustrate the need to use an %INCLUDES within each session
*/

%Macro IsNumeric(VarToCheck);
   %local Result;
   %let Result = %eval(not %sysfunc(verify(&VarToCheck.,-0123456789)));
&Result
%mend;

%Macro LibraryExist(lb);
   %local Result;
   %Let Result=-1;

   %IF %LENGTH(&lb)=0 %Then
      %Let Result=0;   
   %else
   %do;
      %let Result = %sysfunc(LibRef(&lb));
      %if &Result = 0 %then 
         %let Result = 1;
      %Else
         %let Result = 0;
   %end; 
&Result %mend;

%macro SafeSpace(ParentLib=, NewLib=);

   %local ParentPath;
   %Local CreatedPath;
   %local UniqueName;
   %local Leader;
   %let Leader=;
   %let UniqueName =;
   %let ParentPath=;
   %LET CreatedPath=;

   /*Default to work if no library was provided*/
   %IF %LENGTH(&ParentLib.)=0 %THEN
      %LET ParentLib = WORK;

   %if %SUBSTR(%IsNumeric(&NewLib.),1,1) = 1 %then
   %do;
      %PUT ERROR: NewLib cannot start with a numeric character *&LibName.*;
      %goto Finish;
   %end;

   %IF %length(&NewLib.)>8 %THEN 
   %do;
      %PUT ERROR: NewLib must be 8 characters or less *&NewLib.*=*%length(&NewLib.)* ;
      %goto Finish;
   %end;

   *Get the network path for the Existing Parent Library;
   proc sql noprint;
      SELECT DISTINCT path
      INTO :ParentPath
      FROM sashelp.vLibNam
      WHERE UPCASE(libname)=UPCASE("&ParentLib.")
      ;
   quit;

   %If %Length(&ParentPath.)=0 %THEN
   %do;
      %PUT ERROR: Cannot find path for *&ParentLib.* in sashelp.vLibNam;
      %Goto Finish;
   %end;

   *
      Create both a new file sub directory and a new library in SAS
      with a unique locations 
   ;

   /*
   Get a unique name based on the server and a timestamp
   Other strategies are possible, including added a random number,
   depending on the number of expected concurrent users and processes
   */
   %let UniqueName = %UPCASE(&SYSHOSTNAME.)_%SUBSTR(%Sysfunc(datetime()),1,10);
   /*Limit length to 32*/
   %let Result=%Right(&UniqueName.,32);

   /*If name starts with a number, replace with a letter*/
   %let Leader = %substr(&UniqueName.,1,1);
   %if %IsNumeric(&Leader.) = 1 %THEN
   %do;
      %let UniqueName = %SUBSTR(&UniqueName.,2);
      %LET UniqueName=A&UniqueName.;
   %end;

   /*Create the new network location and map it to a LibName*/
   %let CreatedPath = %SYSFUNC(TRIM(&ParentPath.))\&UniqueName.&NewLib.;
   options DLCREATEDIR;
   libname &NewLib. "&CreatedPath.";
   options NODLCREATEDIR;
      
   *
      Just in case this file system folder was used before,
      destroy anything in that folder. 
   ;
   PROC DATASETS LIB=&NewLib. NOLIST NOWARN KILL;
   RUN;
   
%Finish:
%mend;





%PUT Data Access Simulation Macros;
%MACRO DataSourceOne(Results=);
   *Some dummy data, replace with database queries;
   proc sql;
      Insert into &Results. VALUES("&SysMacroName.",'A');
      Insert into &Results. VALUES("&SysMacroName.",'B');
      Insert into &Results. VALUES("&SysMacroName.",'C');
      Insert into &Results. VALUES("&SysMacroName.",'D');
      Insert into &Results. VALUES("&SysMacroName.",'E');
   quit;

%MEND;
%MACRO DataSourceTwo(Results=);
   proc sql;
      Insert into &Results. VALUES("&SysMacroName.",'A');
      Insert into &Results. VALUES("&SysMacroName.",'B');
      Insert into &Results. VALUES("&SysMacroName.",'C');
      Insert into &Results. VALUES("&SysMacroName.",'D');
      Insert into &Results. VALUES("&SysMacroName.",'E');
   quit;   

%MEND;
%MACRO DataSourceThree(Results=);
   proc sql;
      Insert into &Results. VALUES("&SysMacroName.",'A');
      Insert into &Results. VALUES("&SysMacroName.",'B');
      Insert into &Results. VALUES("&SysMacroName.",'C');
      Insert into &Results. VALUES("&SysMacroName.",'D');
      Insert into &Results. VALUES("&SysMacroName.",'E');
   quit;

%MEND;
%put NOTE: Done loading macro library;

