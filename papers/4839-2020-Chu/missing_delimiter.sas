/* Paper 4839-2020
Read Before You Read: Reading, Rewriting & Re-Reading
                      Difficult Delimited Data in a Data Step
Appendix B - Complete Code for Missing Delimiters            */

FILENAME MISSING 'C:\TEMP\osbbb.txt';

/****************************************************************************
Creating the sample text file with a missing delimiter in a few records
****************************************************************************/
data _NULL_;
  file MISSING;
  put 'Animal~Mode~Date~Bird';
  put 'Beaver~~09OCT2019~N';
  put 'Gannet~22JUL2018~Y';
  *          ^-- missing delimiter;
  put 'Peacock~~17DEC2017~Y';
  put 'Robin~23FEB2019~Y';
  *         ^-- missing delimiter;
  put 'Nuthatch~19APR2019~Y';
  *            ^-- missing delimiter;
run;

/****************************************************************************
A DATA step that will fail to read records #2, 4 and 5 correctly
****************************************************************************/
data missing;
  infile MISSING dlm='~' DSD firstobs=2 truncover;
  format Animal $8.  Mode $5.  Date DATE9.  Bird $1.;
  input  Animal      Mode      Date:DATE9.  Bird;
run;

/****************************************************************************
Apply our trick of using "INPUT @" & "_INFILE_" automatic variable
First using normal string functions, then using regular expressions
****************************************************************************/
data fixed (drop=DLM1AT field4);
  infile MISSING dlm='~' DSD firstobs=2;
  format Animal $8.  Mode $5.  Date DATE9.  Bird $1.;
  input @;
  length field4 $1;
  field4 = scan(_INFILE_, 4, '~', 'M');
  if field4 not in ('Y', 'N') then do;
    DLM1AT = FIND(_INFILE_, '~');
     _INFILE_ = SUBSTR(_INFILE_, 1, DLM1AT) ||
                '~' || SUBSTR(_INFILE_, DLM1AT + 1);
   end;
  input  Animal      Mode      Date:DATE9.  Bird;
run;

data everythings_better_with_regex;
  infile MISSING dlm='~' DSD firstobs=2;
  format Animal $8.  Mode $5.  Date DATE9.  Bird $1.;
  input @;
  _INFILE_ = PRXCHANGE('s/^([^~]{1,8}~)([^~])/\1~\2/', 1, _INFILE_);
  input  Animal      Mode      Date:DATE9.  Bird;
run;
