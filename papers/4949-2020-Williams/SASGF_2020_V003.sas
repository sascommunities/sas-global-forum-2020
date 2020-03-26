*A macro library;
%INCLUDE '\\MyNetwork\SASGF_2020_LIB.sas';
options mprint;

%MACRO GetSerialData(Results=);

   PROC SQL;
      create table &Results. (Source CHAR(100),Value CHAR(1))   ;
   QUIT;
   
   %DataSourceOne(Results=&Results.);
   %DataSourceTwo(Results=&Results.);
   %DataSourceThree(Results=&Results.);

%mend;

%MACRO GetParallelData(WorkingLib=,Results=);

   *CalledBy used to create a unique temporary WORK-ing library;
   %LOCAL CalledBy;
   %LET CalledBy=&SysMacroName.;

   *Make sure the WORK-ing directory provided;
   %IF %LibraryExist(&WorkingLib.)=0 %THEN
   %DO;
      %PUT ERROR: WorkingLib *&WorkingLib.* does not exist.;
      %GOTO Finish;
   %END;

   *Create the final Results dataset;
   PROC SQL;
      create table &Results. (Source CHAR(100),Value CHAR(1))   ;
   QUIT;

   *Check Grid Status (zero is operational );
   %IF %SYSFUNC(grdsvc_enable(_all_,Server=SASApp)) NE 0 %THEN
   %DO;
      %PUT WARNING: no grid, no worries, run macros in serial;
      %DataSourceOne(Results=&Results.);
      %DataSourceTwo(Results=&Results.);
      %DataSourceThree(Results=&Results.);
   %END;
   %ELSE
   %DO;
      %PUT WARNING: Grid Available, run macros in parallel;

      *Make sure the WORK-ing directory us usable by grid   ;
      %IF %UPCASE(&WorkingLib.) = WORK %THEN
      %DO;
         %PUT ERROR:  Grid servers cannot use WORK.;
         %goto Finish;
      %END;

      %SafeSpace(NewLib=Temp1,ParentLib=&WorkingLib.);
      %SafeSpace(NewLib=Temp2,ParentLib=&WorkingLib.);
      %SafeSpace(NewLib=Temp3,ParentLib=&WorkingLib.);

      *Make blank copies Results in each temp library;
      PROC SQL;
         CREATE TABLE Temp1.Results AS SELECT * FROM &Results. ;
         CREATE TABLE Temp2.Results AS SELECT * FROM &Results. ;
         CREATE TABLE Temp3.Results AS SELECT * FROM &Results. ;
      QUIT;

      *Use automatic sign on for simplicity;
      OPTIONS AUTOSIGNON;
      ************************
      Create First Grid Session: Ses1
      ***********************;

      *Use SYSLPUT Inherit variables into Ses1;
      %SYSLPUT _LOCAL_ / REMOTE = Ses1;

      RSUBMIT Ses1 
         WAIT=NO           /*enables parallel processing*/
         INHERITLIB=(Temp1)/*specifies SAS libraries to inherit*/ 
      ;
         *Between RSUBMIT and ENDSUBMIT do everything you
         would do for a new program.;
   
         *include reference to macro library;
         %INCLUDE '\\MyNetwork\SASGF_2020_LIB.sas';
         *Run the macro;
         %DataSourceOne(Results=Temp1.Results);
      ENDRSUBMIT;

      ************
      Repeat for session 2 
      *************;
      %SYSLPUT _LOCAL_ / REMOTE = Ses2;
      RSUBMIT Ses2 WAIT=NO INHERITLIB=(Temp2) ;         
         %INCLUDE '\\MyNetwork\SASGF_2020_LIB.sas';
         %DataSourceTwo(Results=Temp2.Results);
         %put NOTE: Server Host: &syshostname.;
      ENDRSUBMIT;

      ************
      Repeat for session 3
      *************;
      %SYSLPUT _LOCAL_ / REMOTE = Ses3;
      RSUBMIT Ses3 WAIT=NO INHERITLIB=(Temp3) ;         
         %INCLUDE '\\MyNetwork\SASGF_2020_LIB.sas';
         %DataSourceThree(Results=Temp3.Results);
         %put NOTE: Server Host: &syshostname.;
      ENDRSUBMIT;

      *Syncronize parallel processes;
      WaitFor _all_ ;
      *Sign off to free up grid resources; 
      Signoff _all_;

      *Now merge parallel results without fear of locking;
      DATA &Results.;
         SET Temp1.Results
             Temp2.Results
             Temp3.Results
         ;
      RUN;
         
      *A bit of clean up;
      PROC DATASETS LIB=Temp1 NOLIST NOWARN KILL; RUN;
      PROC DATASETS LIB=Temp2 NOLIST NOWARN KILL; RUN;
      PROC DATASETS LIB=Temp3 NOLIST NOWARN KILL; RUN;

   %END;

%Finish:
%MEND;


%PUT;
%GetSerialData(Results=WORK.Serial);

Title Serial Results;
PROC SQL OUTOBS = 100;
   SELECT * FROM Serial;
QUIT;

LIBNAME Sandbox '\\MyNetwork\';
*
Note that the only difference between the calls is the
definition of a local variable for a new WORK-ing library
;
%GetParallelData(Results=WORK.Parallel,WorkingLib=SANDBOX);

Title Parallel Results;
PROC SQL OUTOBS = 100;
   SELECT * FROM Parallel;
QUIT;
