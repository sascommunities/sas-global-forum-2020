/********************************************************************************/
/* Car Application Step Five - Display Monthly Payment Info			       		*/
/********************************************************************************/
/* This code accepts the loan term parameters from the prior screen, resolves	*/
/* them as macro variables and runs some code to determine terms of the loan	*/
/* then displays this information with PROC PRINTS and a GPLOT.					*/	
/********************************************************************************/

%let font_value = Calibri;

options nodate nonumber;

*  Define the escape character for ODS inline formatting;

ods escapechar='^';

%global LoanAmt LoanYears EndValue InterestRate;
%let loan = &LoanAmt;
%let years = &LoanYears;
%let interest = &InterestRate;

data work.emi_form;
P=&loan;
R=&interest/100;
N=12;
Years=&years;
date1=today();

Balance=P;
ERate=R/N;
NPER=N*YEARS;
I_Rate=&interest;
DO i=1 to NPER;
    PMT= (ERATE + ERATE/(((1+ERATE)**NPER) -1))*P;
    Balance= BALANCe*(1+ERATE) - PMT;
    Interest=BALANCE*ERATE;
    Principal=PMT-INTEREST;
   	 LoanRequested = PUT(p, DOllAR21.2);
     Payment = PUT(PMT, DOllAR21.2);
     	 InterestRate = PUT(r,percent6.2);
NextMonth = intnx('month',date1,i);
format NextMonth monyy7.;
    OUTPUT;
label i = "Payment Number";
label Balance = "Outstanding Balance";
label NextMonth = "Date of Payment";

END;


Format PMT BALANCE INTEREST PRINCIPAL DOllAR21.2;
RUN;


proc summary data=emi_form;
var interest PMT;
output out=totals sum=;
run;

data totals;
	set totals;
	
	     interest2 = PUT(interest, DOllAR21.2);
	          PMT2 = PUT(PMT, DOllAR21.2);

label PMT = "Monthly Payment";
label _FREQ_ = "Months";
run; 
 

/* Open work table created from subset and import variable values as macro variables */

%global LoanAmt LoanYears InterestRate MonthlyPayment NumPayments ;
%macro GetMacros;
%let dsid=%sysfunc(open(work.emi_form,i)); /* first, open the table */
%if (&dsid = 0) %then /* If it doesn't open, abort */
  %put %sysfunc(sysmsg());
%else %do; /* Pull Date */
   %let num_obs=%sysfunc(attrn(&dsid,nlobs)); /* Get number of obs */
   %put work.nuisance_complaints Table Has &num_obs Obervations;
   %do i=1 %to &num_obs; /* Loop One By One Thru Code to Pull Each Obs */ 
      %let rc=%sysfunc(fetchobs(&dsid,&i)); /* Open the Obs requested at this time */
     
%let LoanAmt=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,LoanRequested)))); /* Read each var into memory as macros */
%let LoanYears=%sysfunc(getvarn(&dsid,%sysfunc(varnum(&dsid,Years)))); /* Read each var into memory as macros */
%let InterestRate=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,InterestRate)))); /* Read each var into memory as macros */
%let MonthlyPayment=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,Payment)))); /* Read each var into memory as macros */ 
%let NumPayments=%sysfunc(getvarn(&dsid,%sysfunc(varnum(&dsid,NPER)))); /* Read each var into memory as macros */ 


%end;
%put Data for &CASENUM;
%end; /* Pull Date */
%let rc=%sysfunc(close(&dsid));
%mend GetMacros; /* close macro */
%GetMacros; /* execute macro */

%global InterestPaid TotalAmountPaid ;
%macro GetMacros2;
%let dsid=%sysfunc(open(work.totals,i)); /* first, open the table */
%if (&dsid = 0) %then /* If it doesn't open, abort */
  %put %sysfunc(sysmsg());
%else %do; /* Pull Date */
   %let num_obs=%sysfunc(attrn(&dsid,nlobs)); /* Get number of obs */
   %put work.nuisance_complaints Table Has &num_obs Obervations;
   %do i=1 %to &num_obs; /* Loop One By One Thru Code to Pull Each Obs */ 
      %let rc=%sysfunc(fetchobs(&dsid,&i)); /* Open the Obs requested at this time */
     
%let InterestPaid=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,INTEREST2)))); /* Read each var into memory as macros */
%let TotalAmountPaid=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,PMT2)))); /* Read each var into memory as macros */



%end;
%put Data for &CASENUM;
%end; /* Pull Date */
%let rc=%sysfunc(close(&dsid));
%mend GetMacros2; /* close macro */
%GetMacros2; /* execute macro */

options nodate nonumber;

title "Your Loan Terms";

data loanterms;
LoanAmt = "&LoanAmt";
InterestRate = "&InterestRate";
NumPayments = "&NumPayments";
InterestPaid = "&InterestPaid";
TotalAmountPaid= "&TotalAmountPaid";
MonthlyPayment = "&MonthlyPayment";
label LoanAmt = "Sticker Price";
label InterestRate = "Interest Rate"; 
label NumPayments = "Number Of Payments";
label InterestPaid = "Interest On Loan";
label TotalAmountPaid = "Total Amount Owed";
label MonthlyPayment = "Monthly Payment";
run;

proc print data=work.loanterms label noobs;
var MonthlyPayment NumPayments InterestRate LoanAmt InterestPaid TotalAmountPaid;
run;

title "Monthly Breakdown";


ods graphics / reset width=800px height=450px imagemap NOBORDER ;

proc sgplot data=WORK.EMI_FORM;
	vline NextMonth / response=Balance lineattrs=(thickness=2 color=CX434FAC);
	xaxis discreteorder=data display=(nolabel) valuesrotate=vertical;
	yaxis grid;
run;

ods graphics / reset;


proc  print data =work.emi_form label noobs;
var i NextMonth Balance Principal Interest  ;
run;
