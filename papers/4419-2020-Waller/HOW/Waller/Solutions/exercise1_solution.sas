data cesd;
  set in.cesd;
  **************************************************************
  **  Create an two indexed arrays for the original CESD      **
  **  questionnaire items and the rescaled questionnaire      **
  **  items.  Include both time points (1 and 24) in each     **
  **  array.                                                  **
  **************************************************************;
  array acesd {40} cesd1_1-cesd1_20 cesd24_1-cesd24_20;
  array ancesd {40} ncesd1_1-ncesd1_20 ncesd24_1-ncesd24_20;
  ***************************************************************
  **  Rescale the original questionniare items from 1-4 to 0-3 **
  **  using an iterative DO loop with start value of 1.        **
  **  What will the end value be?                              **
  ***************************************************************;
  do i=1 to 40;
  *******************************
  ** Rescale using array names **
  *******************************;
    ancesd[i]=acesd[i]-1;
  **********************
  ** End the DO loop. **
  **********************;
  end;
run;

ods pdf body='c:\HOW\Waller\Results\exercise1_output.pdf';

proc print data=cesd;
  var id cesd1_1 ncesd1_1 cesd1_20 ncesd1_20 cesd24_1 ncesd24_1 cesd24_20 ncesd24_20;
title 'Original and Rescaled CESD Items 1 and 20';
title2 'Using Indexed ARRAYs and an Iterative DO Loop';
run;

ods pdf close;

run;
quit;
run;
