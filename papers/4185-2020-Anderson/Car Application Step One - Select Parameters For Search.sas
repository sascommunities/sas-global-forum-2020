/********************************************************************************/
/* Car Application Step One - Select Parameters For Search			       		*/
/********************************************************************************/
/* We exclusively stream HTML via a Data _null_ step to render the page      	*/
/* from which users select their search options. 								*/
/********************************************************************************/


%let font_value = Calibri; /* Set univeral font value */


data _null_; 
	format infile $char256.; 
	input;
	infile = resolve(_infile_);
	file _webout;
	put infile;
	cards4;
		<HTML>
		<head>
		<title>What Type Of Car Do You Want?</title>
		</head>
		<BODY> 


		<font face=&font_value color="#5C5C5C" size=5>

		<b>What Type Of Car Do You Want?</b></center></font>
		<br><br>
		<font face=&font_value>
		<div class="center">
		<form action="/SASJobExecution/" target="_self">
		<input type="hidden" name="_program" value="/Users/sasdemo/SGF Examples/Custom App Step 2">
		<label for="MaxPrice">Maximum Price</label>

		<input type="number" id="MaxPrice" name="MaxPrice" required
		min="11000" max="200000" size="10" value=20000 step=500>

		<br><br>
		<label for="CarType">Car Type</label>

		<select id="CarType" name="CarType">
		<option value="Sedan">Sedan</option>
		<option value="SUV">SUV</option>
		<option value="Truck">Truck</option>
		<option value="Sports">Sports</option>
		<option value="Hybrid">Hybrid</option>
		<option value="Wagon">Wagon</option>

		</select>

		<br><br>

		<label for="Cyl">Engine Size </label>             
		<select id="Cly" name="Cyl">
		<option value="4">4 Cylinder</option>
		<option value="8">8 Cylinder</option>
		<option value="12">Show All Cars</option>
		</select>


		<br><br>

		<label for="MinMPG">Minimum Miles Per Gallon</label>

		<input type="number" id="MinMPG" name="MinMPG" required
		min="15" max="50" size="10" value=25 step=5>

		<br><br>

		</font>
		/*<INPUT TYPE="hidden" name="_debug" VALUE="131">*/
		<INPUT TYPE="SUBMIT" VALUE="Find My New Car"></center></FORM></div>
		</BODY>
		</HTML>
;;;;
run;









