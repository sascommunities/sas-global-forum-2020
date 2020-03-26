/********************************************************************
Creating a Dataset for Sparse Data (SPARSE)
This is the dataset being used for Example #1 and Example #2
********************************************************************/
DATA SPARSE;
	SEED = 13531;
	CALL STREAMINIT(SEED);

	DO _N_ = 1 TO 230;

		IF (_N_ LE 30) THEN PROCEDURE = "New";
		IF (_N_ GT 30) THEN PROCEDURE = "Old";

		IF (_N_ LT 222) THEN COMPLICATION = 0;
		IF (_N_ GE 222) THEN COMPLICATION = 1;

		AGE_OLD = RAND("NORMAL", 45, 5);
		AGE_NEW = RAND("NORMAL", 52, 8);

		IF (_N_ GT 30) THEN AGE = AGE_OLD;
		IF (_N_ LE 30) THEN AGE = AGE_NEW;

		AGE = FLOOR(AGE);

		OUTPUT;
	END;
	
	DROP SEED;
RUN;

/********************************************************************
Creating the Dataset SPREAD
This is the dataset being used for Example #3
********************************************************************/
DATA SPREAD;
	INPUT GROUP EVENT WEIGHT;
	CARDS;
1 4 15
2 15 210
;
RUN;

/********************************************************************
Illustrative Example #1
Complete Separation Example
********************************************************************/
/* 2 x 2 Contingency Table */
PROC FREQ DATA = SPARSE;
	TABLES COMPLICATION*PROCEDURE / NOPERCENT NOROW CHISQ FISHER RELRISK;
RUN;
/* Here we get a Fisher's Exact Test P-Value and see Chi-Square cannot
   be computed. Note that we cannot get a Relative Risk or an Odds Ratio
   because of the 0 cell. */

/* Maximum Likelihood Logistic Regression */
PROC LOGISTIC DATA = SPARSE;
	CLASS COMPLICATION(REF = "0") PROCEDURE(REF = "Old") / PARAM = GLM;
	MODEL COMPLICATION = PROCEDURE;
RUN;
/* Note the warnings printed in both the Log as well as the Output */

/* Exact Logistic Regression */
PROC LOGISTIC DATA = SPARSE;
	CLASS COMPLICATION(REF = "0") PROCEDURE(REF = "Old") / PARAM = GLM;
	MODEL COMPLICATION = PROCEDURE;
	EXACT PROCEDURE / ESTIMATE = ODDS;
RUN;

/* Firth Regression */
PROC LOGISTIC DATA = SPARSE;
	CLASS COMPLICATION(REF = "0") PROCEDURE(REF = "Old") / PARAM = GLM;
	MODEL COMPLICATION = PROCEDURE / FIRTH;
RUN;

/********************************************************************
Illustrative Example #2
Rare Event with a Continuous Covariate/Explanatory Variable Example
********************************************************************/
/* Means and Standard Deviation of AGE for Those with a Complication
   and those without a Complication */
PROC MEANS DATA = SPARSE MAXDEC = 2;
	CLASS COMPLICATION;
	VAR AGE;
RUN;

/* Maximum Likelihood Logistic Regression */
PROC LOGISTIC DATA = SPARSE;
	CLASS COMPLICATION(REF = "0") / PARAM = GLM;
	MODEL COMPLICATION = AGE;
RUN;

/* Firth Regression */
PROC LOGISTIC DATA = SPARSE;
	CLASS COMPLICATION(REF = "0") / PARAM = GLM;
	MODEL COMPLICATION = AGE / FIRTH;
RUN;

/********************************************************************
Illustrative Example #3
Rare Event Example
********************************************************************/
/* 2 x 2 Contingency Table */
PROC FREQ DATA = SPREAD;
	WEIGHT WEIGHT;
	TABLES GROUP*EVENT / NOPERCENT NOROW;
RUN;

/* Maximum Likelihood Logistic Regression */
PROC LOGISTIC DATA = SPREAD;
	CLASS GROUP(REF = "2") / PARAM = GLM;
	MODEL EVENT / WEIGHT = GROUP;
RUN;

/* Exact Logistic Regression */
PROC LOGISTIC DATA = SPREAD;
	CLASS GROUP(REF = "2") / PARAM = GLM;
	MODEL EVENT / WEIGHT = GROUP;
	EXACT GROUP / ESTIMATE = ODDS;
RUN;

/* Firth Regression */
PROC LOGISTIC DATA = SPREAD;
	CLASS GROUP(REF = "2") / PARAM = GLM;
	MODEL EVENT / WEIGHT = GROUP / FIRTH;
RUN;
