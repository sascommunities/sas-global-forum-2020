/*****************************************************************/
/* Prior to running this program, you need to have a CAS server. */
/*****************************************************************/

/* Use the following CAS statements to define your CAS session.
   SESS0 is a controller-only (SMP) session that has 0 workers
   SESS4 is an MPP session that has 4 workers
*/
%let SMPPort = 12345;     /* put your port here */
%let MPPPort = 12346;     /* put your port here */
cas sess0  host='your_host_name' casuser='your_username' port=&SMPPort;  /* SMP, 0 workers */
cas sess4  host='your_host_name' casuser='your_username' port=&MPPPort nworkers=4;


/************************************************************************/
/* Modify the CAS statements ABOVE this line. The statements after this */
/* line should not need modification.                                   */
/************************************************************************/

/* associate CASLIBs with the session */
libname myLib0  cas sessref=sess0;
libname myLib   cas sessref=sess4;

/* A classic PROC IML program */
PROC IML;
   c = {1, 2, 1, 3, 2, 0, 1};          /* weights                       */
   x = {0, 2, 3, 1, 0, 2, 2};          /* data                          */
   wtSum = c` * x;                     /* inner product (weighted sum)  */
   var1  = var(x);                     /* variance of original data     */
   stdX = (x-mean(x)) / std(x);        /* standardize data              */
   var2 = var(stdX);                   /* variance of standardized data */
   print wtSum var1 var2;
QUIT;

/* Example of using PROC CAS in SAS to call the iml action */
PROC CAS;
loadactionset 'iml';                   /* load the action set           */
source pgm;
   c = {1, 2, 1, 3, 2, 0, 1};          /* weights                       */
   x = {0, 2, 3, 1, 0, 2, 2};          /* data                          */
   wtSum = c` * x;                     /* inner product (weighted sum)  */
   var1  = var(x);                     /* variance of original data     */
   stdX = (x-mean(x)) / std(x);        /* standardize data              */
   var2 = var(stdX);                   /* variance of standardized data */
   print wtSum var1 var2;
endsource;
iml / code=pgm;                  /* run the 'pgm' program in the action */
RUN;
QUIT;

/***************************************/
/* Example 1: Simple MapReduce example */
/***************************************/

proc cas;
session sess0;                         /* SMP session: controller node only        */
loadactionset 'iml';                   /* load the action set                      */
source MapReduceAdd;
   start getThreadID(j);
      L = nodeInfo();                  /* get information about nodes and threads  */
      j = L$'threadId';                /* this function runs on the j_th thread    */
   finish;
   start AddRow(X);
      call getThreadId(j);             /* running in the j_th thread               */
      sum = sum(X[j, ]);               /* compute the partial sum for the j_th row */
      print sum;                       /* print partial sum for this thread        */
      return sum;                      /* return the partial sum                   */
   finish;

   /* ----- Main Program ----- */
   x = shape(1:1000, 4);               /* create a 4 x 250 matrix                  */
   Total = MapReduce(x, 'AddRow', '_SUM'); /* use built-in _SUM reducer            */
   print Total;
endsource;
iml / code=MapReduceAdd nthreads=4;
run;
QUIT;

/****************************************/
/* Example 2: Complex MapReduce example */
/****************************************/

/* Simulate B independent samples from a uniform(0,1) distribution.
   Mapper: Generate M samples, where M ~ B/numThreads. Return M statistics.
   Reducer: Concatenate the statistics.
   Main Program: Estimate standard error and CI for mean.
 */
proc cas;
session sess4;                         /* use session with four workers     */
loadactionset 'iml';                   /* load the action set               */
source SimMean;

start SimMeanUniform(L);               /* define the mapper                 */
   call randseed(L$'seed');            /* each thread uses different stream */
   M = nPerThread(L$'B');              /* number of samples for thread      */
   x = j(L$'N', M);                    /* allocate NxM matrix for samples   */
   call randgen(x, 'Uniform');         /* simulate from U(0,1)              */
   return mean(x);                     /* row vector = mean of each column  */
finish;

/* ----- Main Program ----- */
/* Put the arguments for the mapper into a list */
L = [#'N'    = 36,                     /* sample size                       */
     #'seed' = 123,                    /* random number seed                */
     #'B'    = 1E6 ];                  /* total number of samples           */
/* Simulate on all threads; return Monte Carlo distribution */
stat = MapReduce(L, 'SimMeanUniform', '_HCONCAT');

/* Form Monte Carlo estimates */
alpha = 0.05;
stat = stat`;
numSamples = nrow(stat);
MCEst = mean(stat);                    /* estimate of mean,                 */
SE = std(stat);                        /* standard deviation,               */
call qntl(CI, stat, alpha/2 || 1-alpha/2);     /* and 95% CI                */
R = numSamples || MCEst || SE || CI`;          /* combine for printing      */
print R[format=8.4 L='95% Monte Carlo CI'
        c={'NumSamples' 'MCEst' 'StdErr' 'LowerCL' 'UpperCL'}];

endsource;
iml / code=SimMean nthreads=8;
run;

/***************************************/
/* Example 3: Simple ParTasks example  */
/***************************************/

proc cas;
session sess0;                         /* SMP session: controller node only    */
loadactionset 'iml';
source partasks;
   start detTask(A);
      return det(A);
   finish;
   start invTask(A);
      return inv(A);
   finish;
   start eigvalTask(A);
      return eigval(A);
   finish;

   /* ----- Main Program ----- */
   A = toeplitz(1000:1);               /* 1000 x 1000 symmetric matrix         */
   Tasks = {'detTask' 'invTask' 'eigvalTask'};
   Args = [A, A, A];                   /* each task gets same arg in this case */
   opt = {1,                           /* distribute to threads on controller  */
          1};                          /* display information about the tasks  */
   Results = ParTasks(Tasks, Args, opt); /* results are returned in a list     */

   /* the i_th list item is the result of the i_th task */
   det    = Results$1;                 /* get det(A)                           */
   inv    = Results$2;                 /* get inv(A)                           */
   eigval = Results$3;                 /* get eigval(A)                        */
endsource;
iml / code=partasks nthreads=4;
run;
quit;


/***************************************/
/* Example 4: Complex ParTasks example */
/***************************************/

/* Power curve computation: delta = 0 to 2 by 0.025 */
proc cas;
session sess4;                         /* use session with four workers     */
source TTestPower;

/* Helper function: Compute t test for each column of X and Y.
   X is (n1 x m) matrix and Y is (n2 x m) matrix.
   Return the number of columns for which t test rejects H0 */


start TTestH0(x, y);
   n1 = nrow(X);     n2 = nrow(Y);     /* sample sizes                      */
   meanX = mean(x);  varX = var(x);    /* mean & var of each sample         */
   meanY = mean(y);  varY = var(y);
   poolStd = sqrt( ((n1-1)*varX + (n2-1)*varY) / (n1+n2-2) );

   /* Compute t statistic and indicator var for tests that reject H0 */
   t = (meanX - meanY) / (poolStd*sqrt(1/n1 + 1/n2));
   t_crit =  quantile('t', 1-0.05/2, n1+n2-2);       /* alpha = 0.05        */
   RejectH0 = (abs(t) > t_crit);                     /* 0 or 1              */
   return  sum(RejectH0);              /* count how many reject H0          */
finish;

/* Simulate two groups; Count how many reject H0: delta=0 */
start SimTTest(L);                     /* define the mapper                 */
   call randseed(L$'seed');            /* each thread uses different stream */
   x = j(L$'n1', L$'B');               /* allocate space for Group 1        */
   y = j(L$'n2', L$'B');               /* allocate space for Group 2        */
   call randgen(x, 'Normal', 0,         1);   /* X ~ N(0,1)                 */
   call randgen(y, 'Normal', L$'delta', 1);   /* Y ~ N(delta,1)             */
   return TTestH0(x, y);
finish;

/* ----- Main Program ----- */
numSamples = 1e5;
L = [#'delta' = .,   #'n1' = 10,  #'n2' = 10,
     #'seed'  = 321, #'B'  = numSamples];

/* Create list of arguments. Each arg gets different value of delta */
delta = T( do(0, 2, 0.025) );
ArgList = ListCreate(nrow(delta));
do i = 1 to nrow(delta);
   L$'delta' = delta[i];
   call ListSetItem(ArgList, i, L);
end;

RL = ParTasks('SimTTest', ArgList, {2, 0});  /* assign nodes before threads */

/* Summarize results and write to CAS table for graphing */
varNames = {'Delta' 'ProbEst' 'LCL' 'UCL'};  /* names of result vars        */
Result = j(nrow(delta), 4, .);
zCrit = quantile('Normal', 1-0.05/2);  /* zCrit = 1.96                      */
do i = 1 to nrow(delta);               /* for each task                     */
   p = RL$i / numSamples;              /* get proportion that reject H0     */
   SE = sqrt(p*(1-p) / L$'B');         /* std err for binomial proportion   */
   LCL = p - zCrit*SE;                 /* 95% CI                            */
   UCL = p + zCrit*SE;
   Result[i,] = delta[i] || p || LCL || UCL;
end;

call MatrixWriteToCas(Result, '', 'PowerCurve', varNames);
endsource;
iml / code=TTestPower nthreads=8;
quit;


/***************************************/
/* for comparison, compute exact power */
/***************************************/

ods select none;
proc power;
  twosamplemeans  power = .            /* missing ==> "compute this" */
    meandiff= 0 to 2 by 0.025          /* delta = 0, 0.1, ..., 2     */
    stddev=1                           /* N(delta, 1)                */
    ntotal=20;                         /* 20 obs in the two samples  */
  ods output Output=Power;             /* output results to data set */
run;
ods select all;

libname myLib  cas sessref=sess4;
proc sort data=myLib.PowerCurve out=PowerCurve;
by Delta;
run;

data Combine;
   merge Power PowerCurve;
run;

/* overlay the simulated results with the curve of exact power */
title 'Power of the t Test';
title2 'Samples are N(0,1) and N(delta,1), n1=n2=10';
proc sgplot data=Combine noautolegend;
   series x=MeanDiff y=Power;
   scatter x=Delta y=ProbEst / yerrorlower=LCL yerrorupper=UCL;
   inset ('Number of Samples'='100,000') / border;
   yaxis min=0 max=1 label='Power (1 - P[Type II Error])' grid;
   xaxis label='Difference Between Population Means' grid;
run;



/***********************************************/
/* Example 5: Write a function that scores     */
/* a regression model. Run on large CAS table. */
/***********************************************/

/* 5a. Simulate in parallel. 
       nObsPerThread is the number of obs for each thread */
title;
libname myLib  cas sessref=sess4;
%let nObs  = 1e6;
%let nVars = 500;
data myLib.ScoreData(drop=i j nExtras nObsPerThread) / single=no;
   array x[&nVars];
   call streamInit(73);
   nObsPerThread  = int(&nObs/_nthreads_);
   nExtras        = mod(&nObs,_nthreads_);
   if _threadid_ <= nExtras  then nObsPerThread = nObsPerThread + 1;

   do i = 1 to nObsPerThread;
      do j= 1 to &nVars;   x{j} = rand('Uniform');   end;
      ID = i + (_threadid_-1) * nObsPerThread;
      output;
   end;
run;

/* 5b: Write IML function to score observations */
proc cas;
session sess4;                         /* use session with four workers  */
loadactionset 'iml';
source ScorePgm;

/* Score regression model. b[1] is intercept. X contains rows of data. */
start RegScore(b, X);
   return ( b[1] + X*b[2:nrow(b)] );
finish;

b = T( 2 || (1:100)/100 );             /* column of parameters for model */
inVars   = 'X1':'X100';                /* name of input variables        */
outVars  = 'Pred';                     /* name of output variable        */
copyVars = 'ID';                       /* names of variables to copy     */

rc = Score('RegScore', b,              /* scoring function and arg       */
           inVars, outVars,            /* input & output variables       */
           'ScoreData', 'PredVals',    /* input & output CAS table names */
           1000, copyVars);            /* block size, variables to copy  */

/* OPTIONAL: Save the function in an astore for scoring later */
rc = astore('MyStore',                 /* name of astore                 */
            'RegScore', b,             /* scoring function and arg       */
            inVars, outVars);          /* input & output variables       */

endsource;
iml / code = ScorePgm nthreads=4;
run;

/* 5c. Show information about the output table */
columnInfo / table='PredVals';         /* table of predicted values */
run;
quit;

/***********************************************/
/* Example 6: Use PROC ASTORE to score         */
/* the same regression model.                  */
/***********************************************/

/* PROC ASTORE can load iml action and evaluate model on new data */
proc astore;
score rstore = myLib.MyStore           /* astore written by iml action */
      data = myLib.ScoreData           /* new data table to score      */
      out  = myLib.PredVals2  copyvars=(ID);
run;

proc print data=myLib.PredVals2(where=(ID<=5)) noobs;
   var ID Pred;
run;
