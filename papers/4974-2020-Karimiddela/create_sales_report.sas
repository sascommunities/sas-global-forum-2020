
/**********************************************************************************************************/
/**********************************************************************************************************/
/********** Author: Venkata Sivarami Reddy Karimiddela ****************************************************/
/********** purpose: Creating Monthly/Quarterly Sales report **********************************************/
/**********************************************************************************************************/
/**********************************************************************************************************/

/*****************************************************************************************/
/*************************** Initializing macro variables ********************************/
/*****************************************************************************************/
%LET REPORT_LOC= ; /*location of report where you want to save */

/*macro variables to assign required width for each variable printing on the report */
%LET WD1= %STR(WIDTH=2IN);
%LET WD2= %STR(WIDTH=1.5IN);
%LET WD3= %STR(WIDTH=.6IN);
%LET WD4= %STR(WIDTH=.5IN);
%LET WD5= %STR(WIDTH=.7IN);
%LET WD6= %STR(WIDTH=.8IN);

/*****************************************************************************************/
/*************************** Importing input data into SAS********************************/
/*****************************************************************************************/

proc import datafile=/*Location of input data */ out=SALES_DATA dbms=xlsx replace;
run;

/*****************************************************************************************/
/*************************** Creating macro to generate sales report *********************/
/*****************************************************************************************/

%MACRO SALES_REPORT(YEAR=2019,QM_FLAG=Q,QTR=QTR1,MONTH=JAN);
	DATA SALES;
		SET SALES_DATA;
			%IF %EVAL(&QM_FLAG. EQ Q) %THEN %DO;
				WHERE YEAR= &YEAR. AND QTR_SHRT_NM="&QTR"; /*Filtering data for the given year and quarter */
			%END;
			%ELSE %DO;
				WHERE YEAR= &YEAR. AND MTH_SHRT_NM="&MONTH"; /*Filtering data for the given year and month */
			%END;
	RUN;

	PROC SQL;
	SELECT COUNT(*) INTO: DATA_CHECK FROM SALES;
	QUIT;

	%IF %EVAL(&DATA_CHECK NE 0) %THEN %DO; /*Checking whether do we have any records for the selected period*/

		PROC SQL;
			/*creating macro variable to see number of countries are exists in data*/
			SELECT COUNT(DISTINCT COUNTRY) INTO: NO_OF_COUNTRIES FROM SALES; 
			/*creating macro variable for ech country in  the data*/
			SELECT DISTINCT COUNTRY INTO: COUNTRY1 - :COUNTRY%LEFT(&NO_OF_COUNTRIES) FROM SALES ORDER BY COUNTRY; 
			 /*creating macro variable to see number of regions are exists in data*/
			SELECT COUNT(DISTINCT REGION) INTO: NO_OF_REGIONS FROM SALES;
			/*creating macro variable for ech region in  the data*/
			SELECT DISTINCT REGION INTO: REGION1 - :REGION%LEFT(&NO_OF_REGIONS) FROM SALES ORDER BY REGION; 
			/*creating macro variable to see number of divisions are exists in data*/
			SELECT COUNT(DISTINCT DIVISION) INTO: NO_OF_DIVISIONS FROM SALES; 
			/*creating macro variable for ech division in  the data*/
			SELECT DISTINCT DIVISION INTO: DIVISION1 - :DIVISION%LEFT(&NO_OF_DIVISIONS) FROM SALES ORDER BY DIVISION; 
			/*creating macro variable to see number of products are exists in data*/
			SELECT COUNT(DISTINCT PRODUCT) INTO: NO_OF_PRODUCTS FROM SALES;
			/*creating macro variable for ech product in  the data*/
			SELECT DISTINCT PRODUCT INTO: PRODUCT1 - :PRODUCT%LEFT(&NO_OF_PRODUCTS) FROM SALES ORDER BY PRODUCT; 
			
		QUIT;

		PROC SORT DATA=SALES; BY PRODUCT SALE_DT SALE_TIME;RUN;

/*****************************************************************************************/
/*************************** Preparing columns to use in reporting  *********************/
/*****************************************************************************************/
		DATA SALES;
			SET SALES;
				RPTQTR="&YEAR"||" "||"&QTR"||" REPORTING";
				 /*concatening columns to display in hierarchical order */
				COL1=CAT(STRIP(RPTQTR), "~n", " ", STRIP(COUNTRY), "~n", "  ", STRIP(REGION),"~n", "   ", STRIP(DIVISION));
				COL2=PRODUCT|| " "||UPCASE(PUT(SALE_DT, MMDDYYS8.)||" "||SALE_TIME||" ");
				ONLINE_OFFER1=PUT(ONLINE_OFFER,BEST.); /*converting numeric column to character column */
				ON_OFFER_ON_STORE1=PUT(ON_OFFER_ON_STORE,BEST.); /*converting numeric column to character column */
		RUN;

/*****************************************************************************************/
/*************************** Macro to create sales summary at different levels ***********/
/*****************************************************************************************/

		%MACRO SALES_SUMMARY(SUMMARY_LEVEL=PRODUCT,COL1=PRODUCT);
			PROC SQL;
				CREATE TABLE SALES_SUMMARY AS
					SELECT DISTINCT &SUMMARY_LEVEL. AS COL1, 
									SUM(QUANTITY_SOLD) AS  QUANTITY_SOLD,
									SUM(PRODUCT_UNIT_PRICE) AS PRODUCT_UNIT_PRICE,
									SUM(SALE_REVENUE) AS SALE_REVENUE,
									SUM(DISCOUNT) AS DISCOUNT,
									SUM(NET_REVENUE) AS NET_REVENUE
					FROM SALES
					GROUP BY &SUMMARY_LEVEL.;
			QUIT;

/*****************************************************************************************/
/*************************** Printing summary data in ODS destination with PROC REPORT****/
/*****************************************************************************************/

			PROC REPORT DATA=SALES_SUMMARY SPLIT='*' SPANROWS 
				STYLE(COLUMN)=[COLOR=BLACK FONTSIZE=6PT BORDERSPACING=0 BORDERWIDTH=0 FONTFAMILY=COURIER TEXTALIGN=LEFT] 
				STYLE(HEADER)=[COLOR=BLACK FONTSIZE=6PT BACKGROUND=WHITE FONTFAMILY=COURIER TEXTALIGN=LEFT BORDERBOTTOMWIDTH=0.1PX 
					BORDERBOTTOMSTYLE=DOTTED BORDERBOTTOMCOLOR=BLACK BORDERLEFTWIDTH=0 BORDERRIGHTWIDTH=0 CELLSPACING=2 CELLPADDING=2] 
				STYLE(REPORT)=[BORDERCOLOR=WHITE BORDERWIDTH=0 FONTFAMILY=COURIER TEXTALIGN=LEFT FONTSIZE=6PT RULES=NONE FRAME=VOID CELLSPACING=1 
					CELLPADDING=1];
				COLUMNS COL1 QUANTITY_SOLD PRODUCT_UNIT_PRICE SALE_REVENUE DISCOUNT NET_REVENUE ;
				DEFINE COL1/DISPLAY  "&COL1." STYLE(COLUMN)={&WD6 ASIS=ON} RIGHT;
				DEFINE QUANTITY_SOLD/ DISPLAY  FORMAT=COMMA12.1 '# OF UNITS' STYLE(COLUMN)={&WD6  VJUST=B} RIGHT;
				DEFINE PRODUCT_UNIT_PRICE/ DISPLAY  'UNIT PRICE'  FORMAT=DOLLAR12.2 STYLE(COLUMN)={&WD6  VJUST=B} RIGHT;
				DEFINE SALE_REVENUE/ DISPLAY   FORMAT=DOLLAR12.2 'SALE REVENUE' STYLE(COLUMN)={&WD6  VJUST=B} RIGHT;
				DEFINE DISCOUNT/ DISPLAY  'DISCOUNT' FORMAT=DOLLAR12.2 STYLE(COLUMN)={&WD6  VJUST=B} RIGHT;
				DEFINE NET_REVENUE/ DISPLAY  'NET REVENUE' FORMAT=DOLLAR12.2 STYLE(COLUMN)={&WD6  VJUST=B} RIGHT;
				
			RUN;
		%MEND SALES_SUMMARY;

/*****************************************************************************************/
/*************************** Macro to create footnotes across PDF report *****************/
/*****************************************************************************************/

		%MACRO FOOTNOTES();
			%IF "&QM_FLAG." = "Q" %THEN %DO;
				FOOTNOTE1 FONT=COURIER JUSTIFY=LEFT HEIGHT=5PT "Sales Report for the period &QTR &YEAR";
				FOOTNOTE2 " ";
				
			%END;
			%ELSE %DO;
				FOOTNOTE1 FONT=COURIER JUSTIFY=LEFT HEIGHT=5PT "Sales Report for the period &MONTH &YEAR";
				FOOTNOTE2 " ";
				
			%END;
		%MEND FOOTNOTES;

/*****************************************************************************************/
/*************************** Data preparation to ptint dynamic text in second page********/
/*****************************************************************************************/

		PROC SQL;
			SELECT DISTINCT ONLINE_OFFER INTO: ONLINE_OFFER FROM SALES ORDER BY ONLINE_OFFER DESC;
			SELECT DISTINCT ON_OFFER_ON_STORE INTO: STORE_OFFER FROM SALES ORDER BY ON_OFFER_ON_STORE DESC;
		QUIT;
		%IF &ONLINE_OFFER. EQ 1 %THEN %DO;
			PROC SQL;
				SELECT DISTINCT SALE_DT INTO: ONLINE SEPARATED BY ", " FROM SALES 
				WHERE ONLINE_OFFER=1 ORDER BY SALE_DT;
			QUIT;
		
			DATA ONLINE; /*Creating dataset for online offer */
				LENGTH R1 $200;
				R1="Online Offer"; OUTPUT;
				R1="Offer is available on below dates."; OUTPUT;
				R1="&ONLINE";OUTPUT;
				R1="All Online offer sales are highlighted in BLUE"; OUTPUT;
			RUN;
		%END;
		%ELSE %IF &STORE_OFFER. EQ 1 %THEN %DO;
			PROC SQL;
				SELECT DISTINCT SALE_DT INTO: OFFLINE SEPARATED BY ", " FROM SALES 
				WHERE ON_OFFER_ON_STORE=1 ORDER BY SALE_DT;
			QUIT;

			DATA OFFLINE; /*Creating dataset for store offer */
				LENGTH R1 $200;
				R1="Store Offer"; OUTPUT;
				R1="Offer is available on below dates."; OUTPUT;
				R1="&OFFLINE";OUTPUT;
				R1="All Store offer sales are highlighted in GREEN"; OUTPUT;
			RUN;
		%END;

/*****************************************************************************************/
/*************************** Printing Dynamic text on the second page of the report ******/
/*****************************************************************************************/

		%MACRO ONLINE_STORE_DATA(INPUT=ONLINE,ROW=Online Offer);

			PROC REPORT DATA=&INPUT. SPLIT='*' SPANROWS NOHEADER
					STYLE(COLUMN)=[COLOR=BLACK FONTSIZE=6PT BORDERSPACING=0 BORDERWIDTH=0 FONTFAMILY=COURIER TEXTALIGN=LEFT] 
					STYLE(HEADER)=[COLOR=BLACK FONTSIZE=6PT BACKGROUND=WHITE FONTFAMILY=COURIER TEXTALIGN=LEFT BORDERBOTTOMWIDTH=0.1PX 
						BORDERBOTTOMSTYLE=DOTTED BORDERBOTTOMCOLOR=BLACK BORDERLEFTWIDTH=0 BORDERRIGHTWIDTH=0 CELLSPACING=2 CELLPADDING=2] 
					STYLE(REPORT)=[BORDERCOLOR=WHITE BORDERWIDTH=0 FONTFAMILY=COURIER TEXTALIGN=LEFT FONTSIZE=6PT RULES=NONE FRAME=VOID CELLSPACING=1 
						CELLPADDING=1];
					COLUMNS  R1;
					DEFINE R1/DISPLAY  " " ;
					COMPUTE R1;
						IF STRIP(R1) eq "&ROW." then do;
							call define (_col_, "style", "style=[fontweight=bold]");
						END;
					ENDCOMP;					
				
			RUN;
		%MEND ONLINE_STORE_DATA;
		
/*****************************************************************************************/
/***************************Creating macro variable holds file name of pdf output file****/
/*****************************************************************************************/
			

		DATA _NULL_;
			%IF %EVAL(&QM_FLAG. EQ Q) %THEN %DO;
				FNAME="&QTR."||"_SALES_REPORT";
			%END;
			%ELSE %DO;
				FNAME="&MONTH."||"_SALES_REPORT";
			%END;
			CALL SYMPUT("FNAME", FNAME);
		RUN;
		
/*****************************************************************************************/
/*********************** Start printing data into PDF file (ODS destination) *************/
/*****************************************************************************************/

		TITLE;
		FOOTNOTE;
		ODS LISTING CLOSE;
		ODS ESCAPECHAR="^";
		OPTIONS ORIENTATION=PORTRAIT TOPMARGIN=.05IN BOTTOMMARGIN=.05IN LEFTMARGIN=.4IN RIGHTMARGIN=.01IN NODATE;
		ODS PDF FILE="&REPORT_LOC/%STR(%QCMPRES(&FNAME)).pdf";
	
/*****************************************************************************************/
/*********************** Printing title of the report on firat page of the report*********/
/*****************************************************************************************/

		ODS LAYOUT START;
		DATA _NULL_;
			%DO I=1 %TO 20;
				ODS TEXT=" ";
			%END;
			ODS TEXT="^{style[font_weight=bold font_size=20pt just=c color=purple ]SALES REPORT}";
			ODS TEXT="^{style[font_weight=bold font_size=20pt just=c color=purple ]%TRIM(&QTR.) %TRIM(&YEAR.)}";
		RUN;
		%FOOTNOTES(); /* printing footnotes */

		ODS LAYOUT END;

		TITLE1 FONT=COURIER BOLD JUSTIFY=CENTER "Sales Report" BOLD JUSTIFY=RIGHT HEIGHT=7PT 
				"REPORT DATE: %SYSFUNC(TODAY(), MMDDYY10.)"; 
		%FOOTNOTES();

/*****************************************************************************************/
/*********************** Printing dynamic text on the second page of the report **********/
/*****************************************************************************************/

		ODS PDF STARTPAGE=NOW ;
		ODS LAYOUT START;
			DATA _NULL_;
				ODS TEXT=" ";
				ODS TEXT="^{style[font_weight=bold font_size=10pt just=l color=purple ]NOTES:}";
				ODS TEXT=" ";
			RUN;
			%ONLINE_STORE_DATA(INPUT=ONLINE,ROW=Online Offer);
			ODS PDF STARTPAGE=NO;
			%ONLINE_STORE_DATA(INPUT=OFFLINE,ROW=Store Offer);

		
		ODS LAYOUT END;
/*****************************************************************************************/
/***********************start printing detail data from third page of the report onwaards*/
/*****************************************************************************************/				

			%DO P=1 %TO &NO_OF_COUNTRIES;
				%DO Q=1 %TO &NO_OF_REGIONS;
					%DO R=1 %TO &NO_OF_DIVISIONS;
						ODS PDF STARTPAGE=NOW;
							ODS ESCAPECHAR="~";

/*****************************************************************************************/
/***********************Start printing product level detail data *************************/
/*****************************************************************************************/	

							PROC REPORT DATA=SALES SPLIT='*' SPANROWS 
								STYLE(COLUMN)=[COLOR=BLACK FONTSIZE=6PT BORDERSPACING=0 BORDERWIDTH=0 FONTFAMILY=COURIER TEXTALIGN=LEFT] 
								STYLE(HEADER)=[COLOR=BLACK FONTSIZE=6PT BACKGROUND=WHITE FONTFAMILY=COURIER TEXTALIGN=LEFT BORDERBOTTOMWIDTH=0.1PX 
									BORDERBOTTOMSTYLE=DOTTED BORDERBOTTOMCOLOR=BLACK BORDERLEFTWIDTH=0 BORDERRIGHTWIDTH=0 CELLSPACING=2 CELLPADDING=2] 
								STYLE(REPORT)=[BORDERCOLOR=WHITE BORDERWIDTH=0 FONTFAMILY=COURIER TEXTALIGN=LEFT FONTSIZE=6PT RULES=NONE FRAME=VOID CELLSPACING=1 
									CELLPADDING=1];
								COLUMNS COL1 COL2 QUANTITY_SOLD PRODUCT_UNIT_PRICE SALE_REVENUE DISCOUNT NET_REVENUE ONLINE_OFFER1 ON_OFFER_ON_STORE1;
								DEFINE COL1/GROUP  'RPT QTR/COUNTRY/REGION/DIVISION' STYLE(COLUMN)={&WD1 ASIS=ON} LEFT;
								DEFINE COL2/GROUP   'PRODUCT/SALE DATE/SALE TIME' STYLE(COLUMN)={&WD2 VJUST=B} LEFT ORDER=INTERNAL;
								DEFINE QUANTITY_SOLD/ ANALYSIS SUM FORMAT=COMMA12.1 '# OF UNITS' STYLE(COLUMN)={&WD3  TEXTALIGN=RIGHT VJUST=B} RIGHT;
								DEFINE PRODUCT_UNIT_PRICE/ ANALYSIS SUM 'UNIT PRICE'  FORMAT=DOLLAR12.2 STYLE(COLUMN)={&WD3 TEXTALIGN=RIGHT VJUST=B} RIGHT;
								DEFINE SALE_REVENUE/ ANALYSIS SUM  FORMAT=DOLLAR12.2 'SALE REVENUE' STYLE(COLUMN)={&WD5 TEXTALIGN=RIGHT VJUST=B} RIGHT;
								DEFINE DISCOUNT/ ANALYSIS SUM 'DISCOUNT' FORMAT=DOLLAR12.2 STYLE(COLUMN)={&WD4 TEXTALIGN=RIGHT VJUST=B} RIGHT;
								DEFINE NET_REVENUE/ ANALYSIS SUM 'NET REVENUE' FORMAT=DOLLAR12.2 STYLE(COLUMN)={&WD3 TEXTALIGN=RIGHT VJUST=B} RIGHT;
								DEFINE ONLINE_OFFER1/STYLE(COLUMN)={WIDTH=.1in FOREGROUND=white}left " ";
								DEFINE ON_OFFER_ON_STORE1/STYLE(COLUMN)={WIDTH=.1in FOREGROUND=white}left " ";
								BREAK AFTER  COL1/ UL OL SUMMARIZE SKIP /* Printing summary of the detail data at division level */
										STYLE=[FONT_WEIGHT=BOLD FONT_SIZE=6PT BORDERTOPWIDTH=0.01PX 
										BORDERTOPSTYLE=DOTTED BORDERTOPCOLOR=BLACK BORDERLEFTWIDTH=0 BORDERRIGHTWIDTH=0];
								WHERE COUNTRY="&&COUNTRY&P" AND REGION="&&REGION&Q" AND DIVISION="&&DIVISION&R" ;
								COMPUTE AFTER COL1;
									COL1="TOTAL SLAE FOR THE DIVISION: &&DIVISION&R";
								ENDCOMP;
								COMPUTE ONLINE_OFFER1; /* highlighting online offers sales data */
									IF STRIP(ONLINE_OFFER1)="1" THEN DO; 
										CALL DEFINE(_ROW_, "style", "style=[foreground=blue]"); 
									END;
									IF STRIP(ONLINE_OFFER1) in ("1","0") THEN DO; 
										ONLINE_OFFER1=" "; 
									END;
								ENDCOMP;
								COMPUTE ON_OFFER_ON_STORE1; /* highlighting offline/store offers sales data */
									IF STRIP(ON_OFFER_ON_STORE1)="1" THEN DO; 
										CALL DEFINE(_ROW_, "style", "style=[foreground=green]"); 
									END;
									IF STRIP(ON_OFFER_ON_STORE1) in ("1","0") THEN DO; 
										ON_OFFER_ON_STORE1=" "; 
									END;
								ENDCOMP;
									
							RUN;
													
					%END;
				%END;
			%END;
			
/*****************************************************************************************/
/*********************** printing product level summary data *****************************/
/*****************************************************************************************/	

			ODS PDF STARTPAGE=NOW;
			%SALES_SUMMARY(SUMMARY_LEVEL=PRODUCT,COL1=PRODUCT);
			
/*****************************************************************************************/
/*********************** printing division level summary data ****************************/
/*****************************************************************************************/

			ODS PDF STARTPAGE=NOW;
			%SALES_SUMMARY(SUMMARY_LEVEL=DIVISION,COL1=DIVISION);

/*****************************************************************************************/
/*********************** printing region level summary data ******************************/
/*****************************************************************************************/
			
			ODS PDF STARTPAGE=NOW;
			%SALES_SUMMARY(SUMMARY_LEVEL=REGION,COL1=REGION);

/*****************************************************************************************/
/*********************** printing country level summary data *****************************/
/*****************************************************************************************/
			
			ODS PDF STARTPAGE=NOW;
			%SALES_SUMMARY(SUMMARY_LEVEL=COUNTRY,COL1=COUNTRY);

		ODS PDF CLOSE;
		ODS LISTING;
		
	%END;
	%ELSE %DO;
		%PUT "NO DATA AVAILABLE FOR THE GIVEN SELECTION";
	%END;
%MEND SALES_REPORT;
%SALES_REPORT();






