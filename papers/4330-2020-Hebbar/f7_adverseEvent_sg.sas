%let pid=xx-xxx-xxxx;
%let dpi=150;

/*------------------------------------------*/
/*--Use AE data previously subset for PID --*/
/*------------------------------------------*/
data ae_1217;
  input aestdtc $1-10 aeseq aedecod $18-51 aesev $53-60 aeout $62-73 aeendtc $75-84 aestdy aeendy;
  datalines;
2013-03-06    1  Dizziness                          Moderate RESOLVED     2013-03-06    3       4
2013-03-20    2  Cough                              Mild     NOT RESOLVED              17       .
2013-03-27    4  Dizziness                          Mild     RESOLVED     2013-03-27   24      26
2013-03-30    5  Electrocardiogram T Wave Inversion Mild     NOT RESOLVED              27       .
2013-04-01    6  Dizziness                          Mild     RESOLVED     2013-04-11   29      39
2013-03-26    7  Application Site Dermatitis        Moderate NOT RESOLVED 2013-06-18   23     107
2013-05-17    8  Headache                           Mild     RESOLVED     2013-05-18   75      76
2013-03-26    9  Application Site Dermatitis        Moderate RESOLVED     2013-06-18   23     107
2013-05-27   10  Pruritus                           Moderate RESOLVED     2013-06-18   85     107
;
run;
/*proc print noobs;run;*/

/*------------------------------------------*/
/*--Use CM data previously subset for PID --*/
/*------------------------------------------*/
data cm_1217;
  input cmtrt $1-18 cmstdtc $20-29 cmseq visitdy cmdose cmdosu $47-56 smdosfrq $58-70 cmstdy cmendy cmdtc $84-93 visitnum;;
  datalines;
Ginko Biloba       2013-01-15   4   -7  1.00  Tablet     ONCE A DAY     -48   -15  2013-02-16  1
Vicks Formula 44D  2013-03-20  18   28  1.00  Teaspoon   ONCE A DAY      17    25  2013-03-30  5
Hydrocortisone     2013-03-27  19   28  1.00  Unit       AS NEEDED       24   107  2013-03-30  5
Beconase           2013-03-30  20   28  1.00  Spray      2 TIMES A DAY   27     .  2013-03-30  5
Ibuprofen          2013-05-17  41   84  500.0 Milligram  ONCE A DAY      75    75  2013-05-25  9
;run;
/*proc print;run;*/

data ae1;
  set ae_1217 end=eof;
  keep  aeseq  aesev  aestdtc aeendtc aestdate aeendate aestdy aeendy aedecod;
  format aestdate aeendate mindate maxdate YYMMDD10.;
  retain minday maxday mindate maxdate;

  aestdate = input(substr(AESTDTC, 1, 10), YYMMDD10.);
  aeendate = input(substr(AEENDTC, 1, 10), YYMMDD10.);

  if ( _n_ = 1) then do;
     minday=aestdy;
     if aeendy = .  then maxday = aestdy;
     else maxday=aeendy;

     mindate=aestdate;
     if endate = . then maxdate = endate;
     else maxdate=endate;
  end;

  minday=min(minday, aestdy);
  maxday=max(maxday, aeendy);
  mindate=min(mindate, aestdate);
  maxdate=max(maxdate, aeendate);
  
  if ( eof = 1 ) then do;
    call symputx('minday', minday);
    call symputx('maxday', maxday);
    call symputx('mindate', mindate);
    call symputx('maxdate', maxdate);
  end;

run;

data ae2;
  set ae1 nobs=nobs;
  length graphht $6;
  format lastdate YYMMDD10. lastday BEST12.;

  if aeendy = . then
     lastday= symget('maxday');
  else
     lastday= aeendy;

  if aeendate = . then
     lastdate = symget('maxdate');
  else
     lastdate = aeenddate;

  if aesev = 'MILD' then sev=1;
  else if aesev = 'MODERATE' then sev=2;
  else if aesev = 'SEVERE' then sev=3;
  else sev=4;
  run;

/*--Find corresponding min date for minday = -12 --*/
data _null_;
  min = -12;
  delta = min - &minday;

  mindate2 = &mindate + delta;
  call symputx('mindate2', mindate2);
  call symputx('minday2', min);
run;

/*--Create severity data to ensure all severity values are in the data set--*/
data severity;
  input aesev $ xs ys;
  datalines;
Mild     -100 -100
Moderate -100 -100
Severe   -100 -100
;
run;

/*--Merge Severity data into timeline data--*/
data ae;
  set severity ae2;
  run;

/*--Add End Caps to AE Timeline data--*/
data AE_Cap;
  set ae;
  keep aeseq aedecod aestdy aeendy aestdate aesev aehicap;
  label aesev='Severity';
  if aeendate = . then do;
    aeendate=&maxdate;
	aeendy=&maxday;
	aehicap='FilledArrow';
  end;
  if aeendy eq aestdy then aeendy=aestdy+0.5;

  /*--Clear values for dummy observations--*/
  if aestdy eq . then do;
    aeendy=.;
	aehicap='';
  end;
run;

/*--Define Attribute Maps--*/
data attrmap;
  retain id 'Severity';
  input value $ 1-10 fillcolor $ 12-20;
  datalines;
Mild       green
Moderate   gold
Severe     red
Medication lightblue
;
run;

/*--Create data set for Mild, Moderate and Severe events--*/
proc sort data=ae2 out=ae2s;
  by aestdy sev;
  run;
/*proc print data=ae2s ; run;*/

data aeshort(keep=eventdy MILD MODERATE SEVERE);
set ae2s(rename=(aestdy=eventdy));
by eventdy; 

 if AESEV= 'SEVERE' then severe=eventdy;
 else if AESEV = 'MODERATE' then moderate=eventdy;
 else if AESEV = 'MILD' then mild=eventdy;

 if last.eventdy then
    output; 
;run;


/*---------------------------------------------------------------------*/
/*--Extract MEDS data for one patient, assemble full meds description--*/
/*---------------------------------------------------------------------*/

data cm;
set cm_1217 end=eof;
length cmdosu2 $5;
retain lastendy 0;

/*--Shorten dosage unit names--*/
if cmdosu='Milligram' then cmdosu2='Mg';
else if cmdosu='Tablet' then cmdosu2='Tab';
else if cmdosu='Teaspoon' then cmdosu2='Tsp';
else cmdosu2=cmdosu;

/*--Find last day of study--*/
if (cmendy ne .) and (lastendy < cmendy) then lastendy=cmendy;

/*--Build full med description--*/
CMMED = strip(CMTRT) || " " || strip(CMDOSE) || " "  || strip(CMDOSU2);
label CMMED="Prescribed Drugs";

if eof = 1 then do;
  put lastendy;
  call symputx('lastday', lastendy);  /*--Last day of study--*/
end;

run;

proc sort data=cm;
by CMMED;run;
/*proc print data=cm; run;*/

/*---------------------------------------------*/
/*--Extract MEDS dates, compute graph height --*/
/*---------------------------------------------*/
data meds;
keep studyid usubjid cmseq cmtrt cmdose cmdosu cmstdtc cmendtc cmstdy cmendy startdate enddate 
     startday endday cmmed y;
format STARTDATE  YYMMDD10. ENDDATE YYMMDD10.;
label STARTDATE="Start Date" ENDDATE="End Date" STARTDAY="Start Day" ENDDAY="End Day";
set work.cm;
by CMMED;
retain STARTDATE ENDDATE STARTDAY ENDDAY;
retain y;
if _n_ = 1 then
  Y=0;

if first.CMMED then do;
  STARTDATE=input(CMDTC, yymmdd10.);
  ENDDATE=input(CMDTC, yymmdd10.);
  STARTDAY= CMSTDY;
  if STARTDAY = . then
     STARTDAY = VISITDY;
  ENDDAY  = CMENDY;
end;
CURRDATE = input(CMDTC, yymmdd10.);
CURRDAY  = VISITDY;
if STARTDATE > CURRDATE  then
   STARTDATE = CURRDATE;
if (CURRDAY ne . ) and (STARTDAY > CURRDAY) then
   STARTDAY = CURRDAY;
if ENDDATE < CURRDATE then
   ENDDATE = CURRDATE;
if (CURRDAY ne . ) and (ENDDAY < CURRDAY) then
   ENDDAY = CURRDAY;

if last.CMMED then do;
  output;
  Y=Y+1;
end;

run;
/*proc print data=meds;run;*/

ods _all_ close;
ods listing gpath=&gpath image_dpi=&dpi;
footnote;

data ae_cap2;
  set ae_cap;
  keep aestdate aeseq aestdy aeendy aesev aedecod aehicap;
  if aestdy;
  run;

proc sort data=ae_cap out=ae_cap_sort;
  by aedecod aestdy;
run;

/*--AE by aedecod without multiple labels     --*/
/*--Create common variables to combine with CM--*/
data ae_by_name;
  format stdate date7.;

    length name $50 label $50 sev $12 locap $12;
    set ae_cap_sort;
	keep name label stdy endy stdate sev locap hicap;

	by aedecod;
	
	if first.aedecod then aename=aedecod;

	name=aedecod;
	label=aename;
    stdy=aestdy;
	endy=aeendy;
	stdate=aestdate;
	sev=aesev;
	locap='';
    hicap=aehicap;
run;
/*proc print;run;*/


/*--Add End Caps to AE Timeline data--*/
data Meds2_Cap;
  set Meds;
  label cmmed='Medication';
  stday2=startday;
  enday2=endday;
  if startday < &minday2 then do;
    stday2=&minday2;
	lowcap='FilledArrow';
	end;
  else if endday > &maxday then do;
    enday2=&maxday;
	highcap='FilledArrow';
  end;
  run;
ods listing;
/*proc print;run;*/

data Meds3;
  set Meds2_Cap;
  keep mild moderate severe y stday2 enday2 lowcap highcap cmmed startdate;
  run;
/*proc print;run;*/

/*--Create common variables to combine with AE--*/
data cmmeds;
  format stdate date7.;
  length name $50 label $50 sev $12;
  label sev='Severity';

  set Meds3(rename=(y=cmseq stday2=cmstdy enday2=cmendy 
                        lowcap=cmlocap highcap=cmhicap startdate=cmstdate));
  keep name label stdy endy stdate sev locap hicap;

  if cmstdate eq . then do;
    cmlocap='';
    cmstdy=.;
  end;

  name=cmmed;
  label=cmmed;
  stdy=cmstdy;
  endy=cmendy;
  stdate=cmstdate;
  sev='Medication';
  locap=cmlocap;
  hicap=cmhicap;

  run;
/*proc print;run;*/

/*--Combined AE and CM data--*/
/*--Add columns to draw all Meds on top of one AE--*/
data AE_CM;
  set ae_by_name cmmeds;
  run;

proc sort data=AE_CM out=AE_CM_Sort;
  by  stdy;
  run;

/*--Combined AE_CM graph showing AE only--*/
/*--Meds are drawn with transparency=1 to correctly align the axis with
 * meds graph--*/
ods graphics / reset  noScale width=6.5in height=3.5in ;
title "Combined AE and CM for Patient Id = &pid";
proc sgplot data=AE_CM_sort dattrmap=attrmap;
  refline 0 / axis=x lineattrs=(color=black);
  highlow y=name low=stdy high=endy / type=bar group=sev lineattrs=(color=gray pattern=solid) 
                  barwidth=0.8 lowlabel=label lowcap=locap highcap=hicap attrid=Severity  nomissinggroup
                  labelattrs=(size=9 weight=bold);
  scatter y=name x=stdate / x2axis markerattrs=(size=0);
  xaxis grid display=(nolabel)  offsetmax=0.02 values=(&minday2 to &maxday by 2) valueattrs=(size=8);  
  x2axis display=(nolabel)  offsetmax=0.02 values=(&mindate2 to &maxdate)  valueattrs=(size=7); 
  yaxis  reverse  display=(noticks novalues nolabel) colorbands=odd 
                  colorbandsattrs=(color=cxf5f5f5);
run;
