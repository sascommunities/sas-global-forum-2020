/* Paper 4839-2020
Read Before You Read: Reading, Rewriting & Re-Reading
                      Difficult Delimited Data in a Data Step
Appendix A - Complete Code for Unquoted Delimiters           */

FILENAME BADFILE 'C:\TEMP\mp_movie_data.txt';

/****************************************************************************
Creating the sample text file with an unquoted delimiter in the first field
****************************************************************************/
data _NULL_;
  file BADFILE;
  put "Name|Year|Rating on Rotten Tomatoes|Rank on IMDb";
  put "And Now for Something Completely Different|1971|90%|4";
  put "Monty Python and the Holy Grail|1975|97%|1";
  put "Monty Python's|Life of Brian|1979|95%|2";
  *                  ^-- injected delimiter;
  put "Monty Python Live at the Hollywood Bowl|1982|N/A|6";
  put "Monty Python's The Meaning of Life|1983|85%|3";
run;

/****************************************************************************
A DATA step that will fail to read record #3 correctly
****************************************************************************/
data iamerror;
  infile BADFILE dlm='|' firstobs=2;
  format Name $50. Year 4. Rating $3. Rank 1. ;
  input  Name      Year    Rating     Rank;
run;

/****************************************************************************
Apply our trick of using "INPUT @" & "_INFILE_" automatic variable
****************************************************************************/
data r4d4 (drop=DLM1at field2);
  infile BADFILE dlm='|' firstobs=2;
  format Name $50. Year 4. Rating $3. Rank 1. ;
  input @;
  DLM1at = find(_INFILE_, '|');
  length field2 $4;
  field2 = substr(_INFILE_, DLM1at + 1, 4);
  if lengthn(compress(field2, '1234567890')) ne 0 then do;
    _INFILE_ = substr(_INFILE_, 1, dlm1at - 1) || ' ' ||
               substr(_INFILE_, dlm1at + 1);
  end;
  input  Name      Year    Rating     Rank;
run;
