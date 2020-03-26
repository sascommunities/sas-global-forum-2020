/* Determine if iris sepal width is a predictor of iris sepal length */
/* Do this for species Setosa */
data iris;
    set sashelp.iris;
    if species = 'Setosa';
run;

/* Frequency histogram for sepal width */
/* See if assumptions for linear regression are met.  These include */
/*   Normal distribution */
proc sgplot data=iris;
  title "Sepal Width Frequency Distribution";
  histogram sepalwidth / scale=count;
  density sepalwidth / scale=count;
run;
title;
 
/* Using macro variable to filter for species */
%let species=Setosa;
proc sgplot data=sashelp.iris(where=(species="&species."));
  title "Sepal Width Frequency Distribution for &species.";
  histogram sepalwidth / scale=count;
  density sepalwidth / scale=count;
run;
title;

/* Use proc sgpanel to display scatter plots by species */
/* Same code as for sgplot but with panelby statement added */
proc sgpanel data=sashelp.iris;
  title "Sepal Width Frequency Distribution";
  panelby species;   /* Create a separate plot for each species */
  histogram sepalwidth / scale=count;
  density sepalwidth / scale=count;
run;
title;

/* Scatter plot for sepal width against Sepal Length with regression line */
/* See if assumptions for linear regression are met.  These include */
/*   Predictor variable (x) has a linear relationship with the response (y) */
/*   Homoskedasticity i.e. equal variance throughout sample */
proc sgscatter data=iris;
    plot sepallength*sepalwidth / reg;
    title "Sgscatter scatter plot of Sepal Width (x) against Sepal Length (y)";
run;
 
proc sgscatter data=sashelp.iris(where=(species="&species."));
    plot sepallength*sepalwidth / reg;
    title "Sgscatter scatter plot of Sepal Width (x) against Sepal Length (y) for &species.";
run;

/* Create scatter plot with regression line using sgplot.  */
/* Add confidence limits for the mean CLM and individual   */
/* predicted values CLI          */
proc sgplot data=sashelp.iris(where=(species="&species."));
 scatter x=sepalwidth y=sepallength;
 title "Sgplot scatter plot of Sepal Width (x) against Sepal Length (y)";
 reg x=sepalwidth y=sepallength /clm cli;
run;

/* Create scatter plots by species using sgpanel */
proc sgpanel data=sashelp.iris;
 panelby species;
 scatter x=sepalwidth y=sepallength;
 title "Scatter plot of Sepal Width (x) against Sepal Length (y)";
 reg x=sepalwidth y=sepallength /clm cli;
run;

/* If assumptions are met, we can perform linear regression */
/* Simple linear regression predicting sepal length from sepal width */
proc reg data=iris outest=est1;
   eq1: model  sepallength=sepalwidth;
run;
 
proc reg data=sashelp.iris(where=(species="&species.")) outest=est1;
   eq1: model  sepallength=sepalwidth;
run;
/* Display Orion Sales for quantity and profit by quarter and compare each quarter */
/* to the same quarter for 1999 - 2002 on a line chart */
proc sql;
 drop table orsales_qtr;
quit;

/* Prepare data for display on line chart with 2 y axes */
proc sql;
 create table orsales_qtr as
 select year
        ,substr(quarter,5,2) as qtr format $2.     /* Quarter */
	    ,sum(profit) as profit format dollar13.    /* Format profit */
	    ,sum(quantity) as quantity format comma15. /* Format quantity */
 from sashelp.orsales
 group by year
          ,calculated qtr
 order by year
          ,calculated qtr;
quit;

/* Create line chart with two y axes          */
/* Use one color for each of four quarters, datacontrastcolors    */
/* Use solid line for quantity, lineattrs=(pattern=solid)          */
/* Use dashed line for profit, lineattrs=(pattern=longdash)        */
/* Group lines by year, group=year                                 */
/* Use yaxis and y2axis to reference left and right hand vertical axes  */
/* Inset description at bottom of plot, inset 'text' / position=bottom  */
proc sgplot data=orsales_qtr;
 title;
 title1 color=black "Orion Sales 1999 - 2002";
    styleattrs datacontrastcolors=(purple green orange blue);
    xaxis type=discrete label='Quarter';
    yaxis label='Units Sold - Solid Line' grid minor;
    y2axis label='Profit $ - Dashed Line' minor;
    series x=qtr y=quantity / group=year lineattrs=(pattern=solid);
    series x=qtr y=profit / group=year lineattrs=(pattern=longdash) y2axis;
    INSET 'Units Sold and Profit by Quarter'/ POSITION = BOTTOM BORDER TEXTATTRS=(Size=11 Weight=Bold);
run;
title;
title1;

/* PROC SGRENDER */
/* Create stat graph template */
proc template;
  define statgraph surface;
  begingraph;
     layout overlay3d;
      surfaceplotparm x=height y=weight z=density;
     endlayout;
   endgraph;
  end;
run;
/* Generate graphics output from the template */
/* Input dataset contains information on height, weight and density */
title;
title1 'Height, weight and density plot based on a custom statgraph template';
proc sgrender data=sashelp.gridded template=surface;
run;
title;
title1;
