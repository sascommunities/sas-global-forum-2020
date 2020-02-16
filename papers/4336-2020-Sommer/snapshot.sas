%macro SNAPSHOT(snaplib  = %str(SNAPLIB),
                maxsnaps = %str(100),
                action   = %str(LIST),
                name     = %str(),  
                base     = %str(),        
                comp     = %str(),         
                libs     = %str(_NONE_));
 %*+----------------------------------------------------------------+
   | Copyright (c) 2020 by SAS Institute Inc., Cary, NC 27513-8000
   | Name:     SNAPSHOT.sas   
   | Purpose:  Snapshot SAS environment and allow for comparision
   | Author:   Carl Sommer - Carl.Sommer@sas.com
   |
   | SAS Global Forum Session: 4336 - 
   |       Minimizing Environmental Disturbances: 
   |  	   Applying Leave No Trace Principles to SAS® Programming 
   |
   |
   | Parameters:
   |  SNAPLIB  library where snapshots are recorded (Default is SNAPLIB)
   |
   |  MAXSNAPS maximum number of snapshots to allow to be recorded (Default is 100)
   |           Only used on initial capture to the snaplib.
   |
   |  ACTION   What type of action to perform.  One of the following:
   |               CAPTURE - Take a snapshot
   |               COMPARE - Compare two snapshots
   |               LIST    - List the snapshots taken  (Default)
   |               CLEAR   - Erase all snapshots
   |
   |  NAME     Name to assign to the snapshot.  Only used (and required)
   |           when specifying ACTION=CAPTURE.   This parameter value is
   |           case-insensitive.
   |
   |  BASE     Base snapshot to use when comparing two snapshots.  Must
   |           be a valid name specified for an earlier ACTION=CAPTURE.
   |           This parameter value is case-insensitive.
   |
   |  COMP     Second snapshot to use when comparing two snapshots.  Must
   |           be a valid name specified for an earlier ACTION=CAPTURE.
   |           This parameter value is case-insensitive.
   |
   |  LIBS    list of SAS librefs to monitor for changes.  Default is _NONE_
   |          Blank means _NONE_.   Can also specify _ALL_, or a space-delimited list
   |          Note that SASHELP is included in _ALL_
   |
   |  Output: For ACTION=CAPTURE, confirmation of the snapshot being taken
   |          For ACTION=LIST, a list of the snapshots that have been taken
   |          For ACTION=COMPARE, text in the log indicating if any
   |          differences have been noted, and PROC COMPARE output of such
   |
   | Usage:   %SNAPSHOT(snaplib=SNAPSHOT,
   |                    action=CAPTURE,
   |                    name=INIT,
   |                    libs=STAGE ENHANCE REPORT)
   |
   |            < some processing >
   |
   |           %SNAPSHOT(action=CAPTURE,
   |                   name=ETL,
   |                   libs=STAGE ENHANCE REPORT)
   |
   |            %SNAPSHOT(ACTION=COMPARE,base=INIT,comp=ETL)   |
   |
   | Notes:
   |   This macro requires that the user already allocate the libref for the
   |   SNAPLIB= parameter
   |
   |   The following tables within snapshot library are used to manage and store information:
   |		CKPTLIST	List of snapshots recorded by ACTION=CAPTURE
   |        MACROVARS   The values of macro variables at the time of the snapshot
   |        OPTIONS     The values of all options at the time of the snapshot
   |        DATASETS    The structure of the tables and views in the LIBS at the time of the snapshot
   |
   | FUTURE: This relies on specific PROC SQL dictionary tables.   This macro could be enhanced
   |         to support more of the information available from the dictionary tables, such as GOPTIONS.
   |         Additionally, this macro could be extended to capture information about CAS sessions, but 
   |         this is currently not available in dictionary tables, but would instead require additional
   |         code to capture and parse information available from the CAS statement.   
   |         
   +----------------------------------------------------------------+;

    %************************** ;
    %* Preserve user settings * ;
    %************************** ;
    %let _notes   = %SYSFUNC(getoption(notes));
    %let _source  = %SYSFUNC(getoption(source));
    %let _source2 = %SYSFUNC(getoption(source2));
    %let _mprint  = %SYSFUNC(getoption(mprint));
    %let _mlogic  = %SYSFUNC(getoption(mlogic));

    options nonotes nosource nosource2 nomprint nomlogic;

    %let _ckptlist  = %str(&snaplib..CKPTLIST);
    %let _genmax    = &maxsnaps; 
	%let _action    = %upcase(&action);
    %let _name      = %upcase(&name);
    %let _base      = %upcase(&base);
    %let _comp      = %upcase(&comp);
    %let _libs      = %upcase(&libs);

    %***************************** ;
    %* Make sure we have SNAPLIB * ;
    %***************************** ;
    %if %sysfunc(libref(&snaplib)) ne 0 %then %do;
        %put ERROR: (&sysmacroname) Libref &SNAPLIB not assigned.;
        %goto exit;
    %end;

    %****************************** ;
    %* Validate ACTION= parameter * ;
    %****************************** ;
    %if &_action ne %str(CAPTURE) and
        &_action ne %str(COMPARE) and
        &_action ne %str(LIST)    and
        &_action ne %str(CLEAR)   %then %do;
        %put ERROR: (&sysmacroname) Invalid ACTION= parameter value &action specified.;
        %goto exit;
    %end;

    %************************* ;
    %* handle ACTION = CLEAR * ;
    %************************* ;
    %if &_action eq %str(CLEAR) %then %do;
		proc datasets lib=&snaplib nodetails nolist kill;	    
		quit;
		%put **** Snapshots cleared from &SNAPLIB ****;
		%goto exit;        
    %end;
	
    %************************ ;
    %* handle ACTION = LIST * ;
    %************************ ;
    %if &_action eq %str(LIST) %then %do;
		%let _empty = 0;
		%if %sysfunc(exist(&_ckptlist,DATA)) ne 1 %then %let _empty = 1;
		%else %do;
			%let _dsid=%sysfunc(open(&_ckptlist));
			%if (&_dsid gt 0) %then %do;
				%if %sysfunc(attrn(&_dsid,NOBS)) eq 0 %then %let _empty = 1;
				%let _dsid=%sysfunc(close(&_dsid));
			%end;
		%end;

		%if &_empty eq 1 %then %do;
			data _null_;
				length a $21;
				a = (put(datetime(),datetime21.2)) ;
				put '********* SNAPSHOT REPORT - ' a ' *********';
				put '    ----  No snapshots have been taken ----';
				put 60*'*';
			run;
		%end;
		%else %do;
			data _null_;
				length a $21;
				a = (put(datetime(),datetime21.2)) ;
				set &_ckptlist end=_last ;
				if _n_ = 1 then do;
					put '********* SNAPSHOT REPORT - ' a ' *********';
					put @1 'Name' @20 'When Taken' @50 'Generation';
				end;
				put @1 Snapshot @20 When @50 Generation;
				if _last then put 60*'*';
			run;
		%end;
		%goto exit;
    %end;


    %*************************************************************** ;
    %* CAPTURE needs this macro to build SQL IN-clause with commma * ;
	%* I am sure there are better ways to do this, but this works  * ;
    %*************************************************************** ;
    %macro _buildInClauseList(string=%str());
        %let _count = 0;
        %let _word=%qscan(&string,1);
        %do %while(%str(X&_word)X ne XX );
            %let _count=%eval(&_count+1);
            %let _word=%qscan(&string,&_count);
        %end;

        %if &_count gt 0 %then %do _loop = 1 %to &_count;
			%let _word = %qscan(&string,&_loop);
            "&_word"
            %if %eval(&_loop+1) lt &_count %then %do;
                %str(,)
            %end;
        %end;
    %mend _buildInClauseList;


    %*************************** ;
    %* handle ACTION = CAPTURE * ;
    %*************************** ;
    %if &_action eq %str(CAPTURE) %then %do;
		%if &_name eq %str() %then %do;
			%put ERROR: (&sysmacroname) name= must be specified for ACTION=CAPTURE;
			%goto exit;
		%end;

		%******************************************* ;
		%* Map the name (if valid) to a generation * ;
		%******************************************* ;
		%let _lastGen = %str();

		%if %sysfunc(exist(&_ckptlist,DATA)) eq 1 %then %do;
			%let   _nameValid = %str();
			proc sql noprint;
				select distinct snapshot into :_nameValid
				from &_ckptlist
				where snapshot = "&_name";
			quit;

			%if &_nameValid ne %str() %then %do;
				%put ERROR:(&sysmacroname) Cannot reuse a snapshot name.;
				%goto exit;
			%end;

			proc sql noprint;
				select MAX(Generation) into :_lastGen
				from &_ckptlist ;
			quit;

			%if &_lastGen eq %str() %then %do;
				%put ERROR:(&sysmacroname) Cannot retrieve last generation.;
				%goto exit;
			%end;

			%let _nextGen = %eval(&_lastGen + 1);
			data &_ckptlist(label='Snapshot History');         
				set &_ckptlist end=_last; 
				output;
				if _last then do;
					Snapshot   = "&_name";
					When       = datetime();
					Generation = &_nextGen;
					output;
				end;
			run;
			%let _genClause = %str();
		%end;
		%else %do;  %* Prime the snapshot list ;
			data &_ckptlist(label='Snapshot History');
				attrib Snapshot   length=$200 label='Snapshot name';
				attrib When       length=8    label='When snapshot was taken'           format=datetime21.2 ;
				attrib Generation length=8    label='Generation number for status data' format=best5.;
				Snapshot   = "&_name";
				When       = datetime();
				Generation = 1;
			run;

			%************************************************** ;
			%* Assume we can start all of our snapshots fresh * ;
			%************************************************** ;
			%let _genClause = %str(genmax=&_genmax);
		%end;

		proc sql noprint;  
			%******************************* ;
			%* Capture the Macro variables * ;
			%******************************* ;
			create table &snaplib..MACROVARS(&_genClause label='Macro Snapshots') as
				select name, scope, value
				from dictionary.macros
				where scope ne "&sysmacroname" 
				  and name  ne 'SYSINDEX' 
				  and scope ne 'AUTOMATIC'
				order by scope, name ;

			%*************************************************************************** ;
			%* Capture the OPTIONS - handle special case of options set by this macro. * ;
			%* Also include OFFSET, as option values are chunked by 1024-characters    * ;
			%*************************************************************************** ;
			create table &snaplib..OPTIONS(&_genClause label='Option Snapshots') as
				select optname, 
					case optname  
						when 'NOTES'   then "&_notes"
						when 'SOURCE'  then "&_source"
						when 'SOURCE2' then "&_source2"
						when 'MPRINT'  then "&_mprint"
						when 'MLOGIC'  then "&_mlogic"
						else setting
					end as setting, level, offset				
				from dictionary.options
				order by level, optname, offset ;

			%***************************** ;
			%* Capture the Data Set info * ;
			%***************************** ;
			create table &snaplib..DATASETS(&_genClause label='Dataset Snapshots') as
				select libname, memname, crdate,modate,nobs,obslen,nvar
				from dictionary.tables			
				where memtype eq 'DATA' 
				%if &_libs eq %str(_NONE_) or &_libs eq %str() %then %do;
				    %* cheezy way to emulate obs=0 ;
					and memtype ne 'DATA'
				%end;					
				%else %if &_libs ne %str(_ALL_) %then %do;
					and libname in
					( %_buildInClauseList(string=&_libs) )
				%end;
				order by libname, memname ;
		quit;
		%put **** Snapshot &_name Capture Completed ****;
		%goto exit;
    %end;


    %*************************** ;
    %* handle ACTION = COMPARE * ;
    %*************************** ;
    %if &_action eq %str(COMPARE) %then %do;
		%if &_base eq %str() %then %do;
			%put ERROR: (&sysmacroname) base= must be specified for ACTION=COMPARE;
			%goto exit;
		%end;

		%if &_comp eq %str() %then %do;
			%put ERROR: (&sysmacroname) comp= must be specified for ACTION=COMPARE;
			%goto exit;
		%end;

		%if %sysfunc(exist(&_ckptlist,DATA)) ne 1 %then %do;
			%put ERROR: (&sysmacroname) No snapshots have been taken.;
			%goto exit;
		%end;

		%****************************** ;
		%* Validate the snapshot name * ;
		%****************************** ;
		%let _baseData = %str();
		proc sql noprint;
			select distinct Snapshot into :_baseData
			from &_ckptlist
			where Snapshot = "&_base";
		quit;

		%if &_baseData eq %str() %then %do;
			%put ERROR:(&sysmacroname) Invalid snapshot specified for base=.;
			%goto exit;
		%end;

		%let _compData = %str();
		proc sql noprint;
			select distinct Snapshot into :_compData
			from &_ckptlist
			where Snapshot = "&_comp";
		quit;

		%if &_compData eq %str() %then %do;
			%put ERROR:(&sysmacroname) Invalid snapshot specified for comp=.;
			%goto exit;
		%end;

		%**************************************** ;
		%* base= and comp= must not be the same * ;
		%**************************************** ;
		%if &_baseData eq &_compData %then %do;
			%put ERROR:(&sysmacroname) base= and comp= must be different snapshots;
			%goto exit;
		%end;

		%*********************************************** ;
		%* base= must be earlier than comp= for sanity * ;
		%*********************************************** ;
		%let _baseData = %str();
		%let _compData = %str();
		proc sql noprint;
			select When into :_baseData
			from &_ckptlist
			where Snapshot = "&_base";

			select When into :_compData
			from &_ckptlist
			where Snapshot = "&_comp";
		quit;

		%if %eval(&_baseData ge &_compData) %then %do;
			%put ERROR:(&sysmacroname) base snapshot was taken later than comp snapshot.;
			%goto exit;
		%end;

		%*********************************************** ;
		%* Get the generation number for base and comp * ;  %* TODO make this case-insenstive?;
		%*********************************************** ;
		%let _baseData = %str();
		%let _compData = %str();
		proc sql noprint;
			select Generation into :_baseData
			from &_ckptlist
			where Snapshot = "&_base";

			select Generation into :_compData
			from &_ckptlist
			where Snapshot = "&_comp";
		quit;

		%******************************************************* ;
		%* Very rudimentary reporting but it gets the job done * ;
		%******************************************************* ;
		%put ********* Snapshot Comparison Started  *********;
		%put ********* Base Snapshot: &base ;
		%put ********* Comp Snapshot: &comp ;
		%put ;

		%******************* ;
		%* Macro Variables * ;
		%******************* ;
		title "MACRO VARIABLE comparison for snapshots &_base and &_comp";
		proc compare base=&snaplib..macrovars(gennum=&_baseData)
				  compare=&snaplib..macrovars(gennum=&_compData);
			id scope name;
		run;
		%if &sysinfo eq 0 %then %put --  No MACRO Variable differences found. ;
		%else %put --  MACRO Variable differences found.  See PROC COMPARE output;

		%*********** ;
		%* Options * ;
		%*********** ;
		title "OPTION comparison for snapshots &_base and &_comp";

		proc compare base=&snaplib..options(gennum=&_baseData)
			 compare=&snaplib..options(gennum=&_compData) ;
			id level optname offset;
		run;
		%if &sysinfo eq 0 %then %put --  No OPTION differences found. ;
		%else %put --  OPTION differences found.  See PROC COMPARE output;
		
		%************ ;
		%* Datasets * ;
		%************ ;

		%************************************************************************************* ;
        %* handle special case if base or comp are empty as we will get a warning in the log * ;
		%* this could happen if libs=_NONE_ was specified for the base= or comp= snapshot    * ;
		%************************************************************************************* ;
		data _null_;
			if 0 then set SNAPLIB.options(gennum= 1) nobs=nobsb;
			if 0 then set snaplib.options(gennum=2)  nobs=nobsc;
			call symputx('_baseobs',nobsb);
			call symputx('_compobs',nobsc);
        run;

        %if &_baseobs eq 0 %then %put **** BASE dataset snapshot is empty;
		%if &_compobs eq 0 %then %put **** COMPARE dataset snapshot is empty;
		%if &_baseobs gt 0 and &_compobs gt 0 %then %do;
			title "DATASET comparison for snapshots &_base and &_comp";
			proc compare base=&snaplib..datasets(gennum=&_baseData)
				compare=&snaplib..datasets(gennum=&_compData) ;
				id libname memname;
			run;
			%if &sysinfo eq 0 %then %put --  No DATASET differences found. ;
			%else %put --  DATASET differences found.  See PROC COMPARE output;
		%end;
		
		%put ******** Snapshot Comparison Completed ********;
		%goto exit;
	%end;
	
%exit:
    %sysmacdelete _buildInClauseList / nowarn;
    options &_notes &_source &_source2 &_mprint &_mlogic;
%mend SNAPSHOT;
