data cesd;
  set in.cesd;
  **************************************************************
  ** Exercise 1 Code - Expanded to use with Exericise 3       **
  ** Referencing multiple arrays within a single DO loop to   **
  ** create new rescaled items.                               ** 
  **************************************************************
  **  Exercise 3: Referecing specific array items using the   **
  **  index and then reversing just those items using a       **
  **  nested DO loop.                                         **
  **                                                          **
  **  Using index values of 4, 8, 12, and 16 reverse the 4th, **
  **  8th, 12th, and 16th items in each array.                **
  **  Note: You do not need new variables or arrays unless you**
  **  want to keep the original rescaled items. Then you would**
  **  create two new arrays, one with the four rescaled items **
  **  you want to reverse and a new array with new variables  **
  **  for the reversed items.                                 **
  **************************************************************;
  array acesda {20} cesd1_1-cesd1_20;
  array acesdb {20} cesd24_1-cesd24_20;
  array ancesda {20} ncesd1_1-ncesd1_20;
  array ancesdb {20} ncesd24_1-ncesd24_20;
  do i=1 to 20;
    ancesda[i]=acesda[i]-1;
    ancesdb[i]=acesdb[i]-1;
	***********************************************
	** Reference specific variables in the array **
	** and create a nested DO loop.              **
	***********************************************;
	if i in (4,8,12,16) then do;
    *******************************************
	** Reverse the specific references items **
	*******************************************;
      ancesda[i]=3-ancesda[i];
	  ancesdb[i]=3-ancesdb[i];
	*****************************
    ** End the nested DO loop. **
    *****************************;
    end;
  **********************
  ** End the DO loop. **
  **********************;
  end;
run;

ods pdf body='c:\HOW\Waller\Results\exercise3_output.pdf';

proc print data=cesd;
  var id cesd1_4 ncesd1_4 cesd1_8 ncesd1_8 cesd1_12 ncesd1_12 cesd1_16 ncesd1_16
         cesd24_4 ncesd24_4 cesd24_8 ncesd24_8 cesd24_12 ncesd24_12 cesd24_16 ncesd24_16;
title 'Original and Rescaled Reversed Items 4, 8, 12, and 16';
title2 'Using Indexed ARRAYs and an Iterative DO Loop';
run;

ods pdf close;

run;
quit;
run;
