/********************************************************************************/
/* Car Application Step Three - Display Local Dealerships			       		*/
/********************************************************************************/
/* This code accepts make and model from the dynamic URL in the prior 			*/
/* screen and makes up a fake list of dealerships that have the car in stock	*/
/* as well as a dynamic link to a loan calculator. Set _output_type = ODS_HTML5	*/	
/********************************************************************************/

%let font_name = Calibri; /* Set global Font */

/***********************************************************************************************************************/
/* This is the value for the next program (Step 4). Define that Job (we'll add the code later) and get it from the Job */
/* Submit property by cut and pasting from ?_program until the end and overwrite that value below up to &_action.      */
/***********************************************************************************************************************/ 

%let LOAN_URL=?_program=%2FUsers%2Fsasdemo%2FSGF%20Examples%2FCustom%20App%20Step%204%nrstr(&LoanAMT=);

ods escapechar='^';

/* Variable for car make and model sent from Step Two via name/value pairs in URL. */

%Global MakeAndModel;

Data work.MyCar ;
	set SASHELP.CARS (rename = (Cylinders = Cylinder Horsepower=Horses));
	length MakeModel Description CarURL $120;
	MakeModel = trim(left(Make)) || " " || trim(left(Model));
	MPGnum = (MPG_City+MPG_Highway)/2;
	MPG= put(MPGNum,$2.);
	Cylinders = put(Cylinder,$1.);
	Horsepower = put(Horses,$3.);
	Description = trim(left(Horsepower)) || " Horsepower " || trim(left(EngineSize)) || " Liter " || Cylinders || " Cylinder";
	Engine = trim(left(Description));
run;

/* To mimic a car search for more effectively, we'll create a list of 10 fake dealerships, each with slightly different prices for each car */

Data work.MyOffers (keep = Make CarURL Loan TotalCost MakeModel StickerPrice SalesTax TitleTax PlateTransferTax RegistrationTax Dealership Phone) ;
	set work.MyCar ;
	where MakeModel = "&MakeAndModel";
	length MakeModel Description CarURL Dealership $120;
	length Loan varchar(1024);
	MakeModel = trim(left(Make)) || " " || trim(left(Model));
	MSRP = MSRP * 1.25; /* Adjusting for inflation */

	do i = 1 to 10;
	   x = rand("uniform", 1,500);  /* Creating Random upcharge for dealerships so prices vary slightly */
	   StickerPrice = MSRP + (x*3); /* Applying Random upcharge for dealerships so prices vary slightly */
	   if i = 1 then do;
	   	Dealership = "Rosenthal " || Make; /* Add Dealership */
	   end;
	      if i = 2 then do;
	   	Dealership = "East Valley " || Make;
	   end;
	      if i = 3 then do;
	   	Dealership = "Turnage " || Make;
	   end;
	         if i = 4 then do;
	   	Dealership = "South Shore Autos";
	   end;
	         if i = 5 then do;
	   	Dealership = Trim(left(Make)) || " Of West Valley";
	   end;
	         if i = 6 then do;
	   	Dealership = "Triangle " || Make;
	   end;
	      if i = 7 then do;
	   	Dealership = "Brenneman " || Make;
	   end;
	         if i = 8 then do;
	   	Dealership = "Express Luxury Automobiles";
	   end;
	         if i = 9 then do;
	   	Dealership = "Four Corners " ||Trim(left(Make)) || "/Tesla/Ferrari";
	   end;
	            if i = 10 then do;
	   	Dealership = "County " ||Trim(left(Make)) || " & Motocycles";
	   end;
	    x=  (1111 + floor((1+9999-1111)*rand("uniform"))); /* Create random last 4 digits for phone number */
		   Phone="1-866-555-"||trim(left(x)); /* Create phone number */ 
		SalesTax = StickerPrice * 0.06;
		TitleTax = 50;
		PlateTransferTax = 10;
		RegistrationTax = (128+180)/2;
		TotalCost = SalesTax + TitleTax + PlateTransferTax + RegistrationTax + StickerPrice;
		format SalesTax TitleTax PlateTransferTax RegistrationTax StickerPrice TotalCost DOLLAR8.;
		label MakeModel = "Make & Model";
		label StickerPrice = "Sticker Price";
		label Phone = "Phone Number";
		label TotalCost = "Total Cost Of Ownership";
		/* Change the value of the server name below (http up /SASJobExecution) ONLY to match your environment */
		Loan = "<a href='http://sasserver.demo.sas.com/SASJobExecution/"||"&LOAN_URL"||urlencode(strip(TotalCost))||"'>Calculate</a>";
		label Loan = "Monthly Payment";
	output;

end;

run;

/* Sort output table */

proc sort data = work.MyOffers ;
	by  TotalCost;
run;

%global LoanAmt LoanYears InterestRate MonthlyPayment NumPayments DisplayImageURL Loan;

%Global MakeModel MSRP EngineSize Cylinders Horsepower MPG Loan;

/* This line opens the Output Delivery System to allow SAS Proc output streaming and close HTML */

ods html file=_webout;


options nodate nonumber;

title "Local Dealerships With The &MakeAndModel In Stock";

proc print data = work.myoffers noobs label;
	var Dealership Phone StickerPrice SalesTax TitleTax PlateTransferTax RegistrationTax TotalCost Loan;     
run;

/* This line closes the Output Delivery System to end SAS Proc output streaming and resume HTML */

ods html close;
