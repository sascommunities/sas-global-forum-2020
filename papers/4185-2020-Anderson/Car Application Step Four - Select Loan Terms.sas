
/********************************************************************************/
/* Car Application Step Four - Select Loan Terms					       		*/
/********************************************************************************/
/* This code accepts the loan amount from the prior screen and displays a form  */
/* of loan term options rendered entirely in HTML.								*/	
/********************************************************************************/

%JESBEGIN;
*  Close all open destinations;

%let font_value = Calibri; /* Set univeral font value */

*ods html file=_webout;

*%let _output_type = ods_html5; /* Need to specify in order to stream SAS proc code output in web */




*ODS PATH work.templat(update)sasuser.templat(read)fo
               sashelp.tmplmst(read);

options nodate nonumber;


*  Declare input parameter;

%global _ODSSTYLE;

*  Define the escape character for ODS inline formatting;

ods escapechar='^';


*ods  html close;

*%let _output_type = html; /* Need to specify in order to have SAS HTML code output to _webout */

%global LoanAMT;

data totals;
	
	     LoanAMT = PUT(&LoanAMT, 8.2);
	         
run; 
 

/* Open work table created from subset and import variable values as macro variables */

%global LoanAmt LoanYears InterestRate MonthlyPayment NumPayments LoanAmount;
%macro GetMacros;
%let dsid=%sysfunc(open(work.totals,i)); /* first, open the table */
%if (&dsid = 0) %then /* If it doesn't open, abort */
  %put %sysfunc(sysmsg());
%else %do; /* Pull Date */
   %let num_obs=%sysfunc(attrn(&dsid,nlobs)); /* Get number of obs */
   %put work.nuisance_complaints Table Has &num_obs Obervations;
   %do i=1 %to &num_obs; /* Loop One By One Thru Code to Pull Each Obs */ 
      %let rc=%sysfunc(fetchobs(&dsid,&i)); /* Open the Obs requested at this time */
     
%let LoanAmount=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,LoanAMT)))); /* Read each var into memory as macros */


%end;
%put Total Loan Amount Is &LoanAmount;
%end; /* Pull Date */
%let rc=%sysfunc(close(&dsid));
%mend GetMacros; /* close macro */
%GetMacros; /* execute macro */


data _null_; 
  format infile $char256.; 
  input;
  infile = resolve(_infile_);
  file _webout;
  put infile;
cards4;
<HTML>
<head>
<title>Enter Your Desired Loan Terms</title>
</head>
<BODY> 

<font face=&font_value color="#5C5C5C" size=5>

<b>Enter Your Desired Loan Terms</b></center></font>
<br><br><font face=&font_value>
<form action="/SASJobExecution/" target="_self">
  <input type="hidden" name="_program" value="/Users/sasdemo/SGF Examples/Custom App Step 5">



Desired Loan Amount

<input type="number" id="LoanAMT" name="LoanAmt" value="&LoanAmount" readonly
       size="10" >
       
              <br><br>
              
<label for="status">Years</label>

<input type="number" id="LoanYears" name="LoanYears" required
       min="1" max="8" size="10" value=5 >
       
              <br><br>
              
 <label for="status">Interest Rate</label>

<input type="number" id="InterestRate" name="InterestRate" required
       value="3.5" step="0.1" min="0" max="10"
       
              <br><br>
      
              </font>
<br>
/*<INPUT TYPE="hidden" name="_debug" VALUE="131">*/
/*<button TYPE="SUBMIT" onclick="window.location.href='http://sasserver.demo.sas.com/SASJobExecution/?_program=%2FMy%20Folder%2FLoanCalculator%2FLoanCalc'">Cancel</button>*/
<INPUT TYPE="SUBMIT" VALUE="Calculate Payment">

</center>
</FORM>
</div>
</BODY>
</HTML>
;;;;
run;


















