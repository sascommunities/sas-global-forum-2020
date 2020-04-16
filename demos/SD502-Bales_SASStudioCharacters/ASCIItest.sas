%macro asciitest(lref, 
                 dsname, 
                 htmlfref=,
                 printrep=print
                 );

%*********************************************************************;
%*
%*  MACRO: ASCIITEST
%*
%*  USAGE: %asciitest(libref, SAS_data_set_name <...>);
%*
%*  REQUIRED ARGUMENTS: (positional parameters)
%*    LREF       SAS libref. See the note below about use of INENCODING.
%*    DSNAME     SAS data set name.
%*    
%*  OPTIONAL ARGUMENTS: (keyword parameters)
%*    HTMLFREF=  Fileref for HTML output. If HTMLFREF is not set, the 
%*               default output destination will be used.
%*    PRINTREP=  By default, if non-ASCII characters are found in the data
%*               a simple report is printed. To suppress output, set PRINTREP=no.
%*
%*  DESCRIPTION:
%*    This macro inspects the characters in each character column of a
%*    SAS data set. If any non-ASCII characters are found in the data, 
%*    a simple report is created that includes the observation number, 
%*    variable name and the text that contains the characters.
%*
%*  NOTES:
%*    If all characters in the data are ASCII, a NOTE will be displayed 
%*    in the SAS log and no output will be generated. To 
%*
%*    If the data set encoding is different than the SAS session encoding,
%*    you may see transcoding or truncation errors. To remedy the problem,
%*    set the input encoding for your library to ASCIIANY. For example,
%*
%*    LIBNAME yourlib "path_to_directory" INENCODING=ASCIIANY;
%*
%*    You could also see odd results in the characters included in the report.
%*
%*  VERSION: 1.0 SASGF2020_SD502
%*
%*********************************************************************;

   %local dsencoding;
   %let numissues=0;
   
   proc sql noprint;
      select scan(encoding, 1, ' ') into :dsencoding
         from dictionary.tables
         where upcase(libname) = upcase("&lref") and upcase(memname) = upcase("&dsname") and memtype = "DATA";
   quit;
      
   /* If the data set encoding could not be retrieved, assume the data set does not exist. */
   /* Terminate the macro normally.                                                        */
   %if %length(&dsencoding) = 0 %then %do;
       %put WARNING: The data set &lref..&dsname was not found. Terminating macro execution.;
       %return;
   %end;
      
   %let dsencoding=%sysfunc(trim(&dsencoding));
   
   data asciitest;
      retain issues 0;
      set &lref..&dsname end=eof;
      array cvars[*] $ _character_;
      do i=1 to dim(cvars);
         xid=kpropdata(cvars[i],'UESC',"&dsencoding",'asciiany');
         if index(xid,'\u') then do;
            cvname = vname(cvars(i));
            obsnum = _n_;
            nastring = cvars[i];
            issues+1;
            output;
         end;
      end;
      if eof and issues > 0 then do;
         call symput('numissues', trim(left(issues)));
      end;
   run;

   %if &numissues ne 0 %then %do; /* Non-ASCII data found */
      %if &printrep ne print %then %do;
          %put NOTE: &numissues strings in the &lref..&dsname data set contain non-ASCII characters;
      %end;
      %else %do; /* Print the results */
          %if &htmlfref ne %then %do;
              ods html file=&htmlfref;
          %end;
      
          title "Non-ASCII characters found in data set &lref..&dsname";
          title2 "The data set encoding is &dsencoding";
          proc print data=asciitest noobs label;
             label obsnum='Observation number'
                   cvname='Variable containing non-ASCII'
                   nastring='String with non-ASCII';
             var obsnum cvname nastring;
          run;
      
          %if &htmlfref ne %then %do;
              ods html close;
          %end;
      %end; /* Print the results */
   %end; /* Non-ASCII data found */
   %else %do;
      %put NOTE: All characters in the &lref..&dsname data set are ASCII.;
   %end;

%mend;