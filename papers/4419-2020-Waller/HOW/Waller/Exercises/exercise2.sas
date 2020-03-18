data cesd;
  set in.cesd;
  **************************************************************
  **  Create an two non-indexed arrays for the original CESD  **
  **  questionnaire items and the rescaled questionnaire      **
  **  items.  Include both time points (1 and 24) in each     **
  **  array.                                                  **
  **  Make sure that the order of the questionnaire items is  **
  **  consistent from the original to the rescaled array.     **
  **************************************************************;
  array acesd ;
  array ancesd ;
  ***************************************************************
  **  Rescale the original questionniare items from 1-4 to 0-3 **
  **  using a DO OVER loop.                                    **
  ***************************************************************;
  do over ;
  *******************************
  ** Rescale using array names **
  *******************************;

  **********************
  ** End the DO loop. **
  **********************;

run;

ods pdf body='c:\HOW\Waller\Results\exercise2_output.pdf';

proc print data=cesd;
  var id cesd1_1 ncesd1_1 cesd1_20 ncesd1_20 cesd24_1 ncesd24_1 cesd24_20 ncesd24_20;
title 'Original and Rescaled CESD Items 1 and 20';
title2 'Using Non-Indexed ARRAYs and a DO OVER Loop';
run;

ods pdf close;

run;
quit;
run;
