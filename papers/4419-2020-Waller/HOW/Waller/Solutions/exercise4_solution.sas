data cesd;
  set in.cesd;
  **************************************************************
  **  Exercise 3 Code                                         **
  **************************************************************;
  array acesda {20} cesd1_1-cesd1_20;
  array acesdb {20} cesd24_1-cesd24_20;
  array ancesda {20} ncesd1_1-ncesd1_20;
  array ancesdb {20} ncesd24_1-ncesd24_20;
  do i=1 to 20;
    ancesda[i]=acesda[i]-1;
    ancesdb[i]=acesdb[i]-1;
	if i in (4,8,12,16) then do;
      ancesda[i]=3-ancesda[i];
	  ancesdb[i]=3-ancesdb[i];
    end;
  end;
run;

data cesdlong;
  set cesd;
  **************************************************************
  **  Exercise 4:                                             **
  **  Create an indexed array for each questionnaire item that**
  **  contains two items, one for time point 1 and one for    **
  **  time point 24.                                          **
  **                                                          **
  **  You will do CESD items 1 through 3, I have provided     **
  **  the rest of the code for items 4-20.                    **
  **************************************************************;
  array aone {2} ncesd1_1 ncesd24_1;
  array atwo {2} ncesd1_2 ncesd24_2;
  array athree {2} ncesd1_3 ncesd24_3;
  array afour {2} ncesd1_4 ncesd24_4;
  array afive {2} ncesd1_5 ncesd24_5;
  array asix  {2} ncesd1_6 ncesd24_6;
  array aseven {2} ncesd1_7 ncesd24_7;
  array aeight {2} ncesd1_8 ncesd24_8;
  array anine {2} ncesd1_9 ncesd24_9;
  array aten  {2} ncesd1_10 ncesd24_10;
  array aeleven {2} ncesd1_11 ncesd24_11;
  array atwelve {2} ncesd1_12 ncesd24_12;
  array athirteen {2} ncesd1_13 ncesd24_13;
  array afourteen {2} ncesd1_14 ncesd24_14;
  array afifteen {2} ncesd1_15 ncesd24_15;
  array asixteen {2} ncesd1_16 ncesd24_16;
  array aseventeen {2} ncesd1_17 ncesd24_17;
  array aeighteen {2} ncesd1_18 ncesd24_18;
  array anineteen {2} ncesd1_19 ncesd24_19;
  array atwenty {2} ncesd1_20 ncesd24_20;
  **************************************************************
  **  Using the indexed arrays, create a new variable for     **
  **  each questionnaire item that will take on the value of  **
  **  the question item at each time point in the array       **
  **  and output that to this new data set cesdlong.          **
  **                                                          **
  **  You will do items 1-3.  I have provided code for items  **
  **  4-20.                                                   **
  **                                                          **
  **  Code is provided that creates the total CESD score.     **
  **  Total score is sum across rescaled items and is only    **
  **  calculated 5 or fewer items are missing.                **
  **  The total score is adjusted if there are 1-5 missing    **
  **  items by substituting the average of the non-missing    **
  **  items in for those items that are missing.              **
  **************************************************************;
  do i=1 to 2;
    if i=1 then timept=1;
	if i=2 then timept=24;
	cesd1=aone[i];
	cesd2=atwo[i];
	cesd3=athree[i];
	cesd4=afour[i];
	cesd5=afive[i];
	cesd6=asix[i];
	cesd7=aseven[i];
	cesd8=aeight[i];
	cesd9=anine[i];
	cesd10=aten[i];
	cesd11=aeleven[i];
	cesd12=atwelve[i];
	cesd13=athirteen[i];
	cesd14=afourteen[i];
	cesd15=afifteen[i];
	cesd16=asixteen[i];
	cesd17=aseventeen[i];
	cesd18=aeighteen[i];
	cesd19=anineteen[i];
	cesd20=atwenty[i];
	*************************************
	**  Creation of CESD Total Score   **
	*************************************;
    nmisscesd=nmiss(of cesd1-cesd20);
    if 0<=nmisscesd<=5 then do;
      cesdtotal=sum(of cesd1-cesd20);
	  if nmisscesd>0 then cesdtotal=round(((20*cesdtotal)/(20-nmisscesd)),.1);
    end;
    else if nmisscesd>5 then cesdtotal=.;
	************************************************
	** Output the observation for each time point **
	************************************************;
	output;
  **********************
  ** End the DO loop. **
  **********************;
  end;
  keep id timept cesd1-cesd20 cesdtotal;
run;
   
ods pdf body='c:\HOW\Waller\Results\exercise4_output.pdf';

proc print data=cesd (obs=2);
  var id ncesd1_1-ncesd1_20 ncesd24_1-ncesd24_20;
title 'Rescaled and Reversed Items from Exercises 1 and 3';
title2 'The Short-Wide Data Set';
run;

proc print data=cesdlong (obs=4);
  var id timept cesd1-cesd20 cesdtotal;
title 'The Long and Skinny Data Set with Two Observation for Individual';
title2 'One for Each Time Point';
title3 'Created Using Indexed Arrays and Iterative DO Loops';
run;

ods pdf close;

run;
quit;
run;
