*SAS code;
PROC REG DATA= REG_SERIES; MODEL y = x;
OUTPUT OUT = RESIDS
R = y_residuals;
RUN; QUIT;
*SAS LAG and DIF functions to create the set of the lagged and differenced values of y_residuals;
DATA TimeSeries;
SET RESIDS;
y_residuals_1st_LAG = LAG1 (y_residuals); y_residuals_1st_DIFF = DIF1 (y_residuals); y_residuals_1st_DIFF_1st_LAG = DIF1 (LAG1(y_residuals)); y_residuals_1st_DIFF_2nd_LAG = DIF1 (LAG2(y_residuals)); y_residuals_1st_DIFF_3rd_LAG = DIF1 (LAG3(y_residuals)); y_residuals_1st_DIFF_4th_LAG = DIF1 (LAG4(y_residuals)); y_residuals_1st_DIFF_5th_LAG = DIF1 (LAG5(y_residuals));
RUN;
*SAS PROC REG for residuals ADF (stationarity) test at level, with fixed 5 Lag Length and a constant;
PROC REG DATA = TimeSeries;
MODEL y_residuals_1st_DIFF = y_residuals_1st_LAG
y_residuals_1st_DIFF_1st_LAG y_residuals_1st_DIFF_2nd_LAG y_residuals_1st_DIFF_3rd_LAG y_residuals_1st_DIFF_4th_LAG y_residuals_1st_DIFF_5th_LAG;
RUN; QUIT;