
/********************************************************************************/
/* Car Application Step Four - Select Loan Terms					       		*/
/********************************************************************************/
/* This code accepts the loan amount from the prior screen and displays a form  */
/* of loan term options rendered entirely in HTML. Set _OUTPUT_TYPE = HTML		*/	
/********************************************************************************/


%let font_value = Calibri; /* Set univeral font value */

/* This variable for loan amount was sent from Step Three via name/value pairs in URL from prior step and will be resolved in form below. */

%global LoanAMT ;

/********************************************************************************/
/* Create form for parameter selection. Make appropriate changes as noted.      */
/********************************************************************************/
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
  <input type="hidden" name="_program" value="/Users/sasdemo/SGF Examples/Custom App Step 5"> /* Change to metadata location of next Job */



Desired Loan Amount

<input type="number" id="LoanAMT" name="LoanAmt" value="&LoanAMT" readonly
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
/*<INPUT TYPE="hidden" name="_debug" VALUE="131">*/  /* Uncomment if you'd like to see log displayed in output. Helpful for debugging! */
<INPUT TYPE="SUBMIT" VALUE="Calculate Payment">

</center>
</FORM>
</div>
</BODY>
</HTML>
;;;;
run;


















