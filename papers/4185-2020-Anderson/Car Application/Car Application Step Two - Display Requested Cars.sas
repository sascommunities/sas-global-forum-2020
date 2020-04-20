/********************************************************************************/
/* Car Application Step Two - Display Requested Cars				       		*/
/********************************************************************************/
/* This code accepts the parameters sent from the selection screen, resolves	*/
/* them as macro variables and uses data step code to subset the SASHELP.CARS	*/
/* table. It generates dynamic URLS for the next screen and displays the 		*/
/* cars with a PROC PRINT. Make _output_type = ODS_HTML5.						*/
/********************************************************************************/

%let font_value = Calibri; /* Set univeral font value */

/***********************************************************************************************************************/
/* This is the value for the next program (Step 3). Define that Job (we'll add the code later) and get it from the Job */
/* Submit property by cut and pasting from ?_program until the end and overwrite that value below up to &_action.      */
/***********************************************************************************************************************/
   
%let INFO_URL=?_program=%2FUsers%2Fsasdemo%2FSGF%20Examples%2FCustom%20App%20Step%203&_action%nrstr(&MakeAndModel=);

ods escapechar='^';

/* These are the variables sent from Step One. They'll be resolved and used below for Where clause construction */

%Global CarType MaxPrice MinMPG Cyl;

Data work.MyCars (keep = MakeModel MSRP MPG Engine Info rate ) ;
	set SASHELP.CARS (rename = (Cylinders = Cylinder Horsepower=Horses));
	length MakeModel MakeModel_URL Description $100;
	length Info varchar(1024);	
	where Type = "&CarType"; /* Subset by car type */
	MakeModel_URL = trim(left(Make)) || " " || trim(left(Model));
	MakeModel=tranwrd(MakeModel_URL, "auto", "Auto");
	MakeModel=tranwrd(MakeModel, "manual", "Manual");
	MakeModel=tranwrd(MakeModel, "convertible", "Convertible");
	MakeModel=tranwrd(MakeModel, "hatch", "Hatch");
	MakeModel=tranwrd(MakeModel, "coupe", "Coupe");
	MakeModel=tranwrd(MakeModel, "2dr", "2DR");
	MakeModel=tranwrd(MakeModel, "4dr", "4DR");
	MakeModel=tranwrd(MakeModel, "5dr", "5DR");
	MakeModel=tranwrd(MakeModel, "4dr", "4DR");
	MPGnum = (MPG_City+MPG_Highway)/2;
	MPG= put(MPGNum,$2.);
	MSRP = MSRP * 1.25; /* Adjust the price of the car for inflation */
	Cylinders = put(Cylinder,$1.);
	Horsepower = put(Horses,$3.);
	Description = trim(left(Horsepower)) || " Horsepower " || trim(left(EngineSize)) || " Liter " || Cylinders || " Cylinder";
	Engine = trim(left(Description)); /* Change the value of the server name below (http up /SASJobExecution) ONLY to match your environment */
	Info = "<a href='http://sasserver.demo.sas.com/SASJobExecution/"||"&INFO_URL"||urlencode(strip(MakeModel_URL))||"'>Find This Car</a>";
	rate = rand("Integer", 1, 5);  /* requires SAS 9.4M4 or later */
	label MakeModel = "Make & Model";
	label Info = "Local Dealerships";
output;
run;

proc sort data = work.MyCars;
	by  MSRP;
run;

/* Add a phony "Star Rating" by generating a random 5 digit number and a variable with a corresponding number of black star emoji (&#9733;) */

Data work.MyCars;
	set work.MyCars;
    where MSRP < &MaxPrice; /* Subset by MaxPrice */
	length Rating $100.;
			if rate = 1 then do;
	rating = "<font face=&font_name color=#5C5C5C>&#9733;</font>";
	end;
		if rate = 2 then do;
	rating = "<font face=&font_name color=#5C5C5C>&#9733;&#9733;</font>";
	end;
		if  rate = 3 then do;
	rating = "<font face=&font_name color=#5C5C5C>&#9733;&#9733;&#9733;</font>";

	end;
		if  rate = 4 then do;
	rating = "<font face=&font_name color=#5C5C5C>&#9733;&#9733;&#9733;&#9733;</font>";

	end;
		if rate = 5 then do;
	rating = "<font face=&font_name color=#5C5C5C>&#9733;&#9733;&#9733;&#9733;&#9733;</font>";

	end;
run;


%Global MakeModel MSRP EngineSize Cylinders Horsepower MPG;

/* This line opens the Output Delivery System to allow SAS Proc output streaming and close HTML */

ods html file=_webout;

options nodate nonumber;

title 'Cars That Meet Your Search Criteria';

proc print data=work.mycars noobs label;
	var MakeModel MSRP Engine MPG Rating Info; 
run;

/* This line closes the Output Delivery System to end SAS Proc output streaming and resume HTML */

ods html close;
